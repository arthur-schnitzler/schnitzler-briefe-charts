#!/usr/bin/env python3
"""
Generiert JSON-Daten für die 6 Statistik-Visualisierungen auf statistiken.html
Output: 6 JSON-Dateien für die verschiedenen Charts
"""

import glob
import json
import os
import urllib.request
from collections import defaultdict
from acdh_tei_pyutils.tei import TeiReader


# PMB-IDs der "großen 5" Korrespondenzen
BIG_FIVE = {
    'pmb10815': 'Bahr',
    'pmb10863': 'Beer-Hofmann',
    'pmb11485': 'Goldmann',
    'pmb11740': 'Hofmannsthal',
    'pmb2167': 'Salten'
}


def get_data_path():
    """Bestimmt den korrekten Pfad zu den Daten"""
    # Im GitHub Workflow: ../../data
    workflow_path = "../../data"
    # Lokal mit separatem Repository: ../../../schnitzler-briefe-data/data
    local_path = "../../../schnitzler-briefe-data/data"

    # Prüfe auf editions Verzeichnis, da das Hauptverzeichnis existieren könnte aber leer sein
    if os.path.exists(f"{workflow_path}/editions") and os.path.exists(f"{workflow_path}/indices"):
        return workflow_path
    elif os.path.exists(f"{local_path}/editions") and os.path.exists(f"{local_path}/indices"):
        return local_path
    else:
        raise FileNotFoundError(f"Datenverzeichnis nicht gefunden. Geprüft: {workflow_path}/editions und {local_path}/editions")


def count_text_length(doc):
    """Zählt die Textlänge eines Dokuments (Anzahl Zeichen im body)"""
    body_text = doc.any_xpath('//tei:body//text()')
    if body_text:
        return sum(len(str(text).strip()) for text in body_text)
    return 0


def get_sender_pmb_id(doc):
    """Extrahiert die PMB-ID des Senders"""
    sender = doc.any_xpath('//tei:correspAction[@type="sent"]//tei:persName/@ref')
    if sender:
        ref = sender[0].strip()
        if ref.startswith('#'):
            ref = ref[1:]
        return ref
    return None


def get_receiver_pmb_id(doc):
    """Extrahiert die PMB-ID des Empfängers"""
    receiver = doc.any_xpath('//tei:correspAction[@type="received"]//tei:persName/@ref')
    if receiver:
        ref = receiver[0].strip()
        if ref.startswith('#'):
            ref = ref[1:]
        return ref
    return None


def load_person_names():
    """Lädt Personennamen aus listperson.xml"""
    person_names = {}
    data_path = get_data_path()
    listperson_file = f"{data_path}/indices/listperson.xml"

    try:
        doc = TeiReader(listperson_file)
        persons = doc.any_xpath('//tei:person[@xml:id]')

        for person in persons:
            person_id = person.get('{http://www.w3.org/XML/1998/namespace}id')
            if person_id:
                # Versuche Nachname und Vorname zu finden
                surname = person.xpath('.//tei:surname/text()', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})
                forename = person.xpath('.//tei:forename/text()', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})

                if surname:
                    name = surname[0]
                    if forename:
                        name = f"{forename[0]} {surname[0]}"
                    person_names[person_id] = name

        print(f"✓ {len(person_names)} Personennamen aus listperson.xml geladen")
    except Exception as e:
        print(f"Warning: Could not load person names from listperson.xml: {e}")

    return person_names


def load_diary_mentions(pmb_id):
    """
    Lädt Tagebucherwähnungen für eine Person aus dem schnitzler-tagebuch-charts Repository
    Returns: Dictionary {year: count}
    """
    url = f"https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-tagebuch-charts/main/tagebuch-vorkommen-korrespondenzpartner/tagebuch-vorkommen_{pmb_id}.xml"

    mentions = {}
    try:
        print(f"  Lade Tagebucherwähnungen für {pmb_id}...")
        with urllib.request.urlopen(url, timeout=10) as response:
            xml_content = response.read()

        # Parse XML mit TeiReader
        import tempfile
        with tempfile.NamedTemporaryFile(mode='wb', suffix='.xml', delete=False) as tmp:
            tmp.write(xml_content)
            tmp_path = tmp.name

        try:
            doc = TeiReader(tmp_path)
            events = doc.any_xpath('//tei:event[@when]')

            for event in events:
                year = event.get('when')
                desc = event.xpath('.//tei:desc/text()', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})
                if year and desc:
                    count = int(desc[0])
                    mentions[year] = count

            print(f"  ✓ {len(mentions)} Jahre mit Tagebucherwähnungen geladen")
        finally:
            import os
            os.unlink(tmp_path)

    except Exception as e:
        print(f"  Warning: Could not load diary mentions for {pmb_id}: {e}")

    return mentions


def load_correspondence_pmb_ids():
    """Lädt die PMB-IDs der vollständigen Korrespondenzen aus listcorrespondence.xml"""
    correspondence_pmb_ids = set()
    data_path = get_data_path()
    listcorrespondence_file = f"{data_path}/indices/listcorrespondence.xml"

    try:
        doc = TeiReader(listcorrespondence_file)
        # Nur Korrespondenzen ohne ana="planned" und nicht correspondence_null
        person_groups = doc.any_xpath(
            '//tei:personGrp[not(@ana="planned") and not(@xml:id="correspondence_null")]'
        )

        for group in person_groups:
            # Extrahiere die PMB-ID aus der correspondence-ID (z.B. correspondence_11485 -> pmb11485)
            correspondence_id = group.get('{http://www.w3.org/XML/1998/namespace}id')
            if correspondence_id and correspondence_id.startswith('correspondence_'):
                pmb_id = 'pmb' + correspondence_id.replace('correspondence_', '')
                correspondence_pmb_ids.add(pmb_id)

        print(f"✓ {len(correspondence_pmb_ids)} vollständige Korrespondenzen aus listcorrespondence.xml geladen")
    except Exception as e:
        print(f"Warning: Could not load correspondence IDs from listcorrespondence.xml: {e}")

    return correspondence_pmb_ids


def main():
    data_path = get_data_path()
    files = sorted(glob.glob(f"{data_path}/editions/*.xml"))

    # Lade Personennamen und Korrespondenz-IDs
    person_names = load_person_names()
    correspondence_pmb_ids = load_correspondence_pmb_ids()

    # Datenstrukturen für die 6 Visualisierungen
    viz1_all_pieces_by_year = defaultdict(int)  # Abb. 1
    viz2_received_by_year_and_person = defaultdict(lambda: defaultdict(int))  # Abb. 2
    viz4_text_length_by_year_and_person = defaultdict(lambda: defaultdict(int))  # Abb. 4
    viz5_goldmann_hofmannsthal_length = defaultdict(lambda: {'goldmann': 0, 'hofmannsthal': 0})  # Abb. 5

    for xml_file in files:
        doc = TeiReader(xml_file)

        # ISO-Datum extrahieren
        iso_date = doc.any_xpath('//tei:title[@type="iso-date"]/text()')
        if not iso_date:
            continue
        iso_date = iso_date[0]
        year = iso_date.split('-')[0]

        # Sender und Empfänger
        sender_pmb = get_sender_pmb_id(doc)
        receiver_pmb = get_receiver_pmb_id(doc)

        # Textlänge
        text_length = count_text_length(doc)

        # Abb. 1: Alle Korrespondenzstücke nach Jahr
        viz1_all_pieces_by_year[year] += 1

        # Abb. 2: An Schnitzler empfangene Stücke nach Jahr und Person (Anzahl)
        if receiver_pmb == 'pmb2121' and sender_pmb:
            viz2_received_by_year_and_person[year][sender_pmb] += 1

        # Abb. 4: An Schnitzler empfangene Stücke nach Jahr und Person (Textlänge)
        if receiver_pmb == 'pmb2121' and sender_pmb:
            viz4_text_length_by_year_and_person[year][sender_pmb] += text_length

        # Abb. 5: Goldmann und Hofmannsthal an Schnitzler (Textlänge)
        if receiver_pmb == 'pmb2121':
            if sender_pmb == 'pmb11485':  # Goldmann
                viz5_goldmann_hofmannsthal_length[year]['goldmann'] += text_length
            elif sender_pmb == 'pmb11740':  # Hofmannsthal
                viz5_goldmann_hofmannsthal_length[year]['hofmannsthal'] += text_length

    # Abb. 1: Alle edierten Korrespondenzstücke im Verlauf der Jahre
    output_viz1 = {
        'title': 'Alle edierten Korrespondenzstücke im Verlauf der Jahre',
        'years': sorted(viz1_all_pieces_by_year.keys()),
        'counts': [viz1_all_pieces_by_year[year] for year in sorted(viz1_all_pieces_by_year.keys())]
    }

    # Abb. 2: Edierte Korrespondenzstücke an Schnitzler im Laufe der Jahre
    # Aggregiere alle Personen
    all_years_set = set()
    for year_dict in viz2_received_by_year_and_person.values():
        all_years_set.update(year_dict.keys())

    years_sorted = sorted(viz2_received_by_year_and_person.keys())

    # Nur Korrespondenzpartner aus listcorrespondence.xml verwenden
    person_totals = defaultdict(int)
    for year_dict in viz2_received_by_year_and_person.values():
        for person, count in year_dict.items():
            # Nur Personen mit vollständigen Korrespondenzen
            if person in correspondence_pmb_ids:
                person_totals[person] += count

    all_persons = sorted(person_totals.items(), key=lambda x: x[1], reverse=True)

    output_viz2 = {
        'title': 'Edierte Korrespondenzstücke an Schnitzler im Laufe der Jahre',
        'years': years_sorted,
        'correspondents': []
    }

    for person_id, total in all_persons:
        person_data = {
            'id': person_id,
            'name': person_names.get(person_id, person_id),
            'total': total,
            'counts': [viz2_received_by_year_and_person[year].get(person_id, 0) for year in years_sorted]
        }
        output_viz2['correspondents'].append(person_data)

    # Abb. 3: Vergleich der "großen 5" an Schnitzler
    output_viz3 = {
        'title': 'Vergleich der an Schnitzler gerichteten Briefe in den fünf umfangreichsten beruflichen Korrespondenzen',
        'years': years_sorted,
        'correspondents': []
    }

    for person_id, name in BIG_FIVE.items():
        person_data = {
            'id': person_id,
            'name': name,
            'counts': [viz2_received_by_year_and_person[year].get(person_id, 0) for year in years_sorted]
        }
        output_viz3['correspondents'].append(person_data)

    # Abb. 4: Alle edierten Korrespondenzstücke nach Textlänge (aufgeschlüsselt nach Person)
    # Nur Korrespondenzpartner aus listcorrespondence.xml verwenden
    person_text_totals = defaultdict(int)
    for year_dict in viz4_text_length_by_year_and_person.values():
        for person, text_length in year_dict.items():
            # Nur Personen mit vollständigen Korrespondenzen
            if person in correspondence_pmb_ids:
                person_text_totals[person] += text_length

    all_persons_by_text = sorted(person_text_totals.items(), key=lambda x: x[1], reverse=True)

    output_viz4 = {
        'title': 'Alle edierten Korrespondenzstücke nach Textlänge',
        'years': years_sorted,
        'correspondents': []
    }

    for person_id, total in all_persons_by_text:
        person_data = {
            'id': person_id,
            'name': person_names.get(person_id, person_id),
            'total': total,
            'text_lengths': [viz4_text_length_by_year_and_person[year].get(person_id, 0) for year in years_sorted]
        }
        output_viz4['correspondents'].append(person_data)

    # Abb. 5: Goldmann und Hofmannsthal an Schnitzler (Textlänge)
    years_sorted_viz5 = sorted(viz5_goldmann_hofmannsthal_length.keys())
    output_viz5 = {
        'title': 'Paul Goldmann und Hugo von Hofmannsthal an Schnitzler nach Textlänge',
        'years': years_sorted_viz5,
        'goldmann': [viz5_goldmann_hofmannsthal_length[year]['goldmann'] for year in years_sorted_viz5],
        'hofmannsthal': [viz5_goldmann_hofmannsthal_length[year]['hofmannsthal'] for year in years_sorted_viz5]
    }

    # Abb. 6: Erwähnungen im Tagebuch - wird aus schnitzler-tagebuch-charts geladen
    print("\nLade Tagebucherwähnungen...")
    goldmann_diary = load_diary_mentions('pmb11485')
    hofmannsthal_diary = load_diary_mentions('pmb11740')

    output_viz6 = {
        'title': 'Erwähnungen im Tagebuch und Anzahl der Korrespondenzstücke',
        'years': years_sorted_viz5,
        'goldmann': {
            'letters': [viz2_received_by_year_and_person[year].get('pmb11485', 0) for year in years_sorted_viz5],
            'diary_mentions': [goldmann_diary.get(year, 0) for year in years_sorted_viz5]
        },
        'hofmannsthal': {
            'letters': [viz2_received_by_year_and_person[year].get('pmb11740', 0) for year in years_sorted_viz5],
            'diary_mentions': [hofmannsthal_diary.get(year, 0) for year in years_sorted_viz5]
        }
    }

    # JSON-Dateien schreiben
    outputs = [
        ('viz1_all_pieces_by_year.json', output_viz1),
        ('viz2_received_by_schnitzler.json', output_viz2),
        ('viz3_big_five_comparison.json', output_viz3),
        ('viz4_all_text_length.json', output_viz4),
        ('viz5_goldmann_hofmannsthal_length.json', output_viz5),
        ('viz6_diary_mentions.json', output_viz6)
    ]

    for filename, data in outputs:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"✓ {filename} erstellt")

    print(f"\n✓ Alle Statistik-Visualisierungen erstellt")
    print(f"  - {len(files)} Briefe verarbeitet")
    print(f"  - Jahre: {min(viz1_all_pieces_by_year.keys())} - {max(viz1_all_pieces_by_year.keys())}")


if __name__ == "__main__":
    main()
