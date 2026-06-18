"""
Berechnet Venn-Daten (PMB-ID-Überschneidungen) für alle Projekte.
Aufruf: python make_venn_data.py

Datenquellen:
  - PMB-Gesamtlisten: data/indices-pmb/  (wird bei Bedarf heruntergeladen)
  - Projektliste: list-of-relevant-uris.xml (lokal oder via GitHub)

Projekte werden automatisch aus der Projektliste geladen.
Nur Projekte mit mindestens einem PMB-Eintrag erscheinen in der Ausgabe.
Schnittmengen werden für bis zu MAX_COMBO_SIZE Projekte berechnet.
"""

import json
import re
import sys
import urllib.request
from itertools import combinations
from pathlib import Path
from lxml import etree

from download_pmb_lists import ensure_pmb_lists

TEI = "http://www.tei-c.org/ns/1.0"
NS = {"t": TEI}

SCRIPT_DIR = Path(__file__).parent

# Lokales PMB-Verzeichnis; wird bei Bedarf von pmb.acdh.oeaw.ac.at befüllt
PMB_DIR = SCRIPT_DIR / "data/indices-pmb"

# Projektliste – lokal oder per Download
RELEVANT_URIS = SCRIPT_DIR / "../schnitzler-chronik-static/xslt/export/list-of-relevant-uris.xml"
RELEVANT_URIS_URL = (
    "https://raw.githubusercontent.com/arthur-schnitzler/"
    "schnitzler-chronik-static/main/xslt/export/list-of-relevant-uris.xml"
)

# Einträge aus list-of-relevant-uris.xml, die nicht als Projektkollektionen
# in den Venn-Diagrammen erscheinen sollen. Nur „pmb" selbst wird übersprungen,
# da es die Gesamtdatenbank repräsentiert und keine sinnvolle Vergleichsgröße ist.
# Neue Projekte müssen hier NICHT eingetragen werden – sie werden automatisch
# aus list-of-relevant-uris.xml geladen, sofern sie PMB-Daten besitzen.
SKIP_SUBTYPES = {"pmb"}

# Maximale Anzahl von Projekten pro Schnittmenge.
# Auf 3 begrenzt, um die Ausgabegröße handhabbar zu halten.
MAX_COMBO_SIZE = 3

# PMB-Dateien und zugehörige Entitäts-Tags
ENTITY_TYPES = {
    "person": ("listperson.xml", "person"),
    "work":   ("listbibl.xml",   "bibl"),
    "place":  ("listplace.xml",  "place"),
    "org":    ("listorg.xml",    "org"),
    "event":  ("listevent.xml",  "event"),
}


def load_projects(xml_path: Path) -> dict:
    """Liest Projekt-IDs, Labels und Farben aus list-of-relevant-uris.xml.
    Ignoriert Einträge mit type='print' oder 'print-online'."""
    tree = etree.parse(str(xml_path))
    projects = {}
    for item in tree.xpath("//item"):
        if item.get("type") in ("print", "print-online"):
            continue
        abbr_el = item.find("abbr")
        caption_el = item.find("caption")
        color_el = item.find("color")
        if abbr_el is None or color_el is None:
            continue
        pid = abbr_el.text.strip()
        if pid in SKIP_SUBTYPES:
            continue
        projects[pid] = {
            "label": (caption_el.text or pid).strip() if caption_el is not None else pid,
            "color": color_el.text.strip(),
        }
    return projects


def load_projects_from_bytes(xml_bytes: bytes) -> dict:
    """Wie load_projects, aber aus einem Byte-String statt einer Datei."""
    tree = etree.fromstring(xml_bytes)
    projects = {}
    for item in tree.xpath("//item"):
        if item.get("type") in ("print", "print-online"):
            continue
        abbr_el = item.find("abbr")
        caption_el = item.find("caption")
        color_el = item.find("color")
        if abbr_el is None or color_el is None:
            continue
        pid = abbr_el.text.strip()
        if pid in SKIP_SUBTYPES:
            continue
        projects[pid] = {
            "label": (caption_el.text or pid).strip() if caption_el is not None else pid,
            "color": color_el.text.strip(),
        }
    return projects


def extract_pmb_id(entity_el) -> str | None:
    """Extrahiert die kanonische PMB-ID aus idno[@subtype='pmb'] oder @xml:id."""
    for idno in entity_el.findall(f"{{{TEI}}}idno"):
        if idno.get("subtype") == "pmb" and idno.text:
            m = re.search(r"/entity/(\d+)/", idno.text)
            if m:
                return "pmb" + m.group(1)
    xml_id = entity_el.get("{http://www.w3.org/XML/1998/namespace}id", "")
    return xml_id if xml_id.startswith("pmb") else None


# Geschlechtskategorien für den Gender-Filter (nur Personen).
# PMB kodiert das Geschlecht als <sex value="male|female|not-set|…"/>.
# Alles außer male/female wird zu "unknown" zusammengefasst (= unbekannt).
SEXES = ["male", "female", "unknown"]


def extract_sex(entity_el) -> str:
    """Liefert 'male', 'female' oder 'unknown' für eine Person."""
    sex_el = entity_el.find(f"{{{TEI}}}sex")
    if sex_el is not None:
        value = sex_el.get("value", "")
        if value in ("male", "female"):
            return value
    return "unknown"


def build_project_sets(pmb_file: Path, entity_tag: str, projects: dict,
                       with_sex: bool = False):
    """
    Liest eine PMB-Liste und gibt {projekt_id: set[pmb_id]} zurück.
    Jede Entität wird genau einmal pro Projekt gezählt.

    Mit with_sex=True wird zusätzlich {pmb_id: 'male'|'female'|'unknown'}
    zurückgegeben (Tupel). Nur für Personen sinnvoll.
    """
    if not pmb_file.exists():
        print(f"  ⚠ Datei nicht gefunden: {pmb_file}", file=sys.stderr)
        return ({}, {}) if with_sex else {}

    tree = etree.parse(str(pmb_file))
    project_sets = {pid: set() for pid in projects}
    sex_of = {}

    for entity in tree.xpath(f".//t:{entity_tag}", namespaces=NS):
        pmb_id = extract_pmb_id(entity)
        if not pmb_id:
            continue

        if with_sex:
            sex_of[pmb_id] = extract_sex(entity)

        for idno in entity.findall(f"{{{TEI}}}idno"):
            subtype = idno.get("subtype", "")
            if subtype in project_sets:
                project_sets[subtype].add(pmb_id)

    return (project_sets, sex_of) if with_sex else project_sets


def intersection_key(proj_ids):
    return "|".join(sorted(proj_ids))


def main():
    print("Stelle PMB-Gesamtlisten sicher …")
    ensure_pmb_lists(PMB_DIR)

    print("Lade Projektliste …")
    if RELEVANT_URIS.exists():
        projects = load_projects(RELEVANT_URIS)
    else:
        print(f"  Lokale Datei nicht gefunden, lade von {RELEVANT_URIS_URL}")
        with urllib.request.urlopen(RELEVANT_URIS_URL) as resp:
            xml_bytes = resp.read()
        projects = load_projects_from_bytes(xml_bytes)
    print(f"  {len(projects)} relevante Sammlungen gefunden")

    OUTPUT_DIR = SCRIPT_DIR / "venn"
    OUTPUT_DIR.mkdir(exist_ok=True)

    for entity_type, (filename, entity_tag) in ENTITY_TYPES.items():
        print(f"Processing {entity_type}…")

        pmb_file = PMB_DIR / filename
        with_sex = entity_type == "person"
        if with_sex:
            project_sets, sex_of = build_project_sets(
                pmb_file, entity_tag, projects, with_sex=True)
        else:
            project_sets = build_project_sets(pmb_file, entity_tag, projects)

        available = sorted(pid for pid in projects if project_sets.get(pid))

        projects_out = {}
        for proj_id in available:
            projects_out[proj_id] = {
                "label": projects[proj_id]["label"],
                "color": projects[proj_id]["color"],
                "count": len(project_sets[proj_id]),
            }

        intersections_out = {}
        for size in range(2, min(MAX_COMBO_SIZE, len(available)) + 1):
            for combo in combinations(available, size):
                key = intersection_key(combo)
                shared = project_sets[combo[0]].copy()
                for pid in combo[1:]:
                    shared &= project_sets[pid]
                intersections_out[key] = len(shared)

        intersections_out = dict(sorted(intersections_out.items()))

        out = {"projects": projects_out, "intersections": intersections_out}

        # Gender-Filter (nur Personen): pro Geschlecht die Projektzahlen und
        # Schnittmengen, jeweils auf Personen dieses Geschlechts beschränkt.
        # Die obersten Felder (count/intersections) bleiben die Gesamtwerte
        # (= „alle"), sodass bestehende Auswertungen unverändert funktionieren.
        if with_sex:
            by_sex = {}
            for sex in SEXES:
                sex_sets = {
                    pid: {x for x in project_sets[pid] if sex_of.get(x) == sex}
                    for pid in available
                }
                counts_sex = {pid: len(sex_sets[pid]) for pid in available}
                inter_sex = {}
                for size in range(2, min(MAX_COMBO_SIZE, len(available)) + 1):
                    for combo in combinations(available, size):
                        shared = sex_sets[combo[0]].copy()
                        for pid in combo[1:]:
                            shared &= sex_sets[pid]
                        inter_sex[intersection_key(combo)] = len(shared)
                by_sex[sex] = {
                    "counts": counts_sex,
                    "intersections": dict(sorted(inter_sex.items())),
                }
            out["by_sex"] = by_sex

        out_path = OUTPUT_DIR / f"{entity_type}.json"
        out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"  → {out_path} ({len(available)} Projekte, {len(intersections_out)} Schnittmengen)")

    print("Fertig.")


if __name__ == "__main__":
    main()
