#!/usr/bin/env python3
"""
Generiert JSON-Daten für die 6 Statistik-Visualisierungen auf statistiken.html
Output: 6 JSON-Dateien für die verschiedenen Charts
"""

import glob
import json
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


def main():
    files = sorted(glob.glob("../../../schnitzler-briefe-data/data/editions/*.xml"))

    # Datenstrukturen für die 6 Visualisierungen
    viz1_all_pieces_by_year = defaultdict(int)  # Abb. 1
    viz2_received_by_year_and_person = defaultdict(lambda: defaultdict(int))  # Abb. 2
    viz4_all_text_length_by_year = defaultdict(int)  # Abb. 4
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

        # Abb. 2: An Schnitzler empfangene Stücke nach Jahr und Person
        if receiver_pmb == 'pmb2121' and sender_pmb:
            viz2_received_by_year_and_person[year][sender_pmb] += 1

        # Abb. 4: Textlänge aller Korrespondenzstücke nach Jahr
        viz4_all_text_length_by_year[year] += text_length

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

    # Finde die wichtigsten Korrespondenzpartner (Top 20 nach Gesamtzahl)
    person_totals = defaultdict(int)
    for year_dict in viz2_received_by_year_and_person.values():
        for person, count in year_dict.items():
            person_totals[person] += count

    top_persons = sorted(person_totals.items(), key=lambda x: x[1], reverse=True)[:20]

    output_viz2 = {
        'title': 'Edierte Korrespondenzstücke an Schnitzler im Laufe der Jahre',
        'years': years_sorted,
        'correspondents': []
    }

    for person_id, total in top_persons:
        person_data = {
            'id': person_id,
            'name': BIG_FIVE.get(person_id, person_id),
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

    # Abb. 4: Alle edierten Korrespondenzstücke nach Textlänge
    output_viz4 = {
        'title': 'Alle edierten Korrespondenzstücke nach Textlänge',
        'years': sorted(viz4_all_text_length_by_year.keys()),
        'text_lengths': [viz4_all_text_length_by_year[year] for year in sorted(viz4_all_text_length_by_year.keys())]
    }

    # Abb. 5: Goldmann und Hofmannsthal an Schnitzler (Textlänge)
    years_sorted_viz5 = sorted(viz5_goldmann_hofmannsthal_length.keys())
    output_viz5 = {
        'title': 'Paul Goldmann und Hugo von Hofmannsthal an Schnitzler nach Textlänge',
        'years': years_sorted_viz5,
        'goldmann': [viz5_goldmann_hofmannsthal_length[year]['goldmann'] for year in years_sorted_viz5],
        'hofmannsthal': [viz5_goldmann_hofmannsthal_length[year]['hofmannsthal'] for year in years_sorted_viz5]
    }

    # Abb. 6: Erwähnungen im Tagebuch - wird aus schnitzler-tagebuch-data geladen
    # Diese Visualisierung benötigt Daten aus dem Tagebuch-Repository
    output_viz6 = {
        'title': 'Erwähnungen im Tagebuch und Anzahl der Korrespondenzstücke',
        'note': 'Diese Daten müssen aus schnitzler-tagebuch-data bezogen werden',
        'years': years_sorted_viz5,
        'goldmann': {
            'letters': [viz2_received_by_year_and_person[year].get('pmb11485', 0) for year in years_sorted_viz5],
            'diary_mentions': []  # TODO: Aus Tagebuch-Daten laden
        },
        'hofmannsthal': {
            'letters': [viz2_received_by_year_and_person[year].get('pmb11740', 0) for year in years_sorted_viz5],
            'diary_mentions': []  # TODO: Aus Tagebuch-Daten laden
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
