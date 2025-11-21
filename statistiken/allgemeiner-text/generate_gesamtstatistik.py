#!/usr/bin/env python3
"""
Generiert Gesamtstatistiken für die Schnitzler-Briefe Startseite
Output: gesamtstatistik.json für die Index-Seite
"""

import glob
import json
import os
from collections import defaultdict
from acdh_tei_pyutils.tei import TeiReader


def get_data_path():
    """Bestimmt den korrekten Pfad zu den Daten"""
    # Im GitHub Workflow: ../../data
    workflow_path = "../../data"
    # Lokal mit separatem Repository: ../../../schnitzler-briefe-data/data
    local_path = "../../../schnitzler-briefe-data/data"

    if os.path.exists(workflow_path):
        return workflow_path
    elif os.path.exists(local_path):
        return local_path
    else:
        raise FileNotFoundError("Datenverzeichnis nicht gefunden")


def count_complete_correspondences():
    """Zählt vollständige Korrespondenzen aus listcorrespondence.xml"""
    data_path = get_data_path()
    correspondence_file = f"{data_path}/indices/listcorrespondence.xml"
    doc = TeiReader(correspondence_file)
    person_groups = doc.any_xpath(
        "//tei:listPerson/tei:personGrp[not(@ana='planned') and not(@xml:id='correspondence_null')]"
    )
    return len(person_groups) if person_groups else 0


def main():
    data_path = get_data_path()
    files = sorted(glob.glob(f"{data_path}/editions/*.xml"))

    stats = {
        'total_letters': 0,
        'complete_correspondences': count_complete_correspondences(),
        'schnitzler_sent': 0,
        'schnitzler_received': 0,
        'third_party': 0,
        'by_object_type': defaultdict(int),
        'letters_by_year_and_type': defaultdict(lambda: {
            'schnitzler_sent': 0,
            'schnitzler_received': 0,
            'third_party': 0
        }),
        'letters_by_year_and_object_type': defaultdict(lambda: defaultdict(int)),
        'date_range': {'earliest': None, 'latest': None}
    }

    for xml_file in files:
        doc = TeiReader(xml_file)

        # ISO-Datum extrahieren
        iso_date = doc.any_xpath('//tei:title[@type="iso-date"]/text()')
        if not iso_date:
            continue
        iso_date = iso_date[0]
        year = iso_date.split('-')[0]

        stats['total_letters'] += 1

        # Datumsbereich
        if not stats['date_range']['earliest'] or iso_date < stats['date_range']['earliest']:
            stats['date_range']['earliest'] = iso_date
        if not stats['date_range']['latest'] or iso_date > stats['date_range']['latest']:
            stats['date_range']['latest'] = iso_date

        # Schnitzler als Sender/Empfänger
        is_schnitzler_sender = doc.any_xpath(
            '//tei:correspAction[@type="sent"]//tei:persName[@ref="#pmb2121"]'
        )
        is_schnitzler_receiver = doc.any_xpath(
            '//tei:correspAction[@type="received"]//tei:persName[@ref="#pmb2121"]'
        )

        if is_schnitzler_sender:
            stats['schnitzler_sent'] += 1
            stats['letters_by_year_and_type'][year]['schnitzler_sent'] += 1
        elif is_schnitzler_receiver:
            stats['schnitzler_received'] += 1
            stats['letters_by_year_and_type'][year]['schnitzler_received'] += 1
        else:
            stats['third_party'] += 1
            stats['letters_by_year_and_type'][year]['third_party'] += 1

        # Objekttyp
        object_type = doc.any_xpath(
            '//tei:sourceDesc/tei:listWit/tei:witness/tei:objectType/@corresp'
        )
        if object_type:
            type_value = object_type[0].strip()
            # Ignoriere xbrief
            if type_value and type_value != 'xbrief':
                stats['by_object_type'][type_value] += 1
                stats['letters_by_year_and_object_type'][year][type_value] += 1

    # Konvertiere zu regulären dicts
    output = {
        'total_letters': stats['total_letters'],
        'complete_correspondences': stats['complete_correspondences'],
        'schnitzler_sent': stats['schnitzler_sent'],
        'schnitzler_received': stats['schnitzler_received'],
        'third_party': stats['third_party'],
        'date_range': stats['date_range'],
        'by_object_type': dict(sorted(
            stats['by_object_type'].items(),
            key=lambda x: x[1],
            reverse=True
        )),
        'letters_by_year_and_type': {
            year: dict(data)
            for year, data in sorted(stats['letters_by_year_and_type'].items())
        },
        'letters_by_year_and_object_type': {
            year: dict(data)
            for year, data in sorted(stats['letters_by_year_and_object_type'].items())
        }
    }

    # JSON schreiben
    with open('gesamtstatistik.json', 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"✓ Gesamtstatistik erstellt: {stats['total_letters']} Briefe")


if __name__ == "__main__":
    main()
