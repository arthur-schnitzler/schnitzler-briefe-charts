"""
Berechnet Venn-Daten (PMB-ID-Überschneidungen) für alle Projekte.
Aufruf: python make_venn_data.py

Datenquellen:
  - PMB-Gesamtlisten: ../schnitzler-fischer-data/data/indices-pmb/
    (aktualisierbar via: python ../schnitzler-fischer-data/pyscripts/download_pmb_lists.py)
  - Projektliste: ../schnitzler-chronik-static/xslt/export/list-of-relevant-uris.xml

Jede Entität wird anhand ihrer idno[@subtype='<projektname>'] den Projekten zugeordnet.
Entitäten ohne idno[@subtype='pmb'] werden übersprungen.
"""

import json
import re
import sys
import urllib.request
from itertools import combinations
from pathlib import Path
from lxml import etree

TEI = "http://www.tei-c.org/ns/1.0"
NS = {"t": TEI}

SCRIPT_DIR = Path(__file__).parent

# Pfad zu den lokalen PMB-Gesamtlisten
PMB_DIR = SCRIPT_DIR / "../schnitzler-fischer-data/data/indices-pmb"

# Projektliste – lokal oder per Download
RELEVANT_URIS = SCRIPT_DIR / "../schnitzler-chronik-static/xslt/export/list-of-relevant-uris.xml"
RELEVANT_URIS_URL = (
    "https://raw.githubusercontent.com/arthur-schnitzler/"
    "schnitzler-chronik-static/main/xslt/export/list-of-relevant-uris.xml"
)

# Externe Normdaten-Quellen, die nicht als Projektkollektionen zählen
SKIP_SUBTYPES = {"pmb", "wikidata", "gnd", "wikipedia", "geonames", "oebl",
                 "wiengeschichtewiki", "fackel", "legalkraus", "semantickraus",
                 "kalliope-verbund", "dla-marbach"}

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


def build_project_sets(pmb_file: Path, entity_tag: str, projects: dict) -> dict:
    """
    Liest eine PMB-Liste und gibt {projekt_id: set[pmb_id]} zurück.
    Jede Entität wird genau einmal pro Projekt gezählt.
    """
    if not pmb_file.exists():
        print(f"  ⚠ Datei nicht gefunden: {pmb_file}", file=sys.stderr)
        return {}

    tree = etree.parse(str(pmb_file))
    project_sets = {pid: set() for pid in projects}

    for entity in tree.xpath(f".//t:{entity_tag}", namespaces=NS):
        pmb_id = extract_pmb_id(entity)
        if not pmb_id:
            continue

        for idno in entity.findall(f"{{{TEI}}}idno"):
            subtype = idno.get("subtype", "")
            if subtype in project_sets:
                project_sets[subtype].add(pmb_id)

    return project_sets


def intersection_key(proj_ids):
    return "|".join(sorted(proj_ids))


def main():
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
        for size in range(2, len(available) + 1):
            for combo in combinations(available, size):
                key = intersection_key(combo)
                shared = project_sets[combo[0]].copy()
                for pid in combo[1:]:
                    shared &= project_sets[pid]
                intersections_out[key] = len(shared)

        intersections_out = dict(sorted(intersections_out.items()))

        out = {"projects": projects_out, "intersections": intersections_out}
        out_path = OUTPUT_DIR / f"{entity_type}.json"
        out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"  → {out_path} ({len(available)} Projekte, {len(intersections_out)} Schnittmengen)")

    print("Fertig.")


if __name__ == "__main__":
    main()
