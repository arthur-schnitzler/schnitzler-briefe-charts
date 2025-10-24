# Kartendaten für interaktive Briefwechsel-Visualisierung

Dieser Ordner enthält JSON-Dateien für jede Korrespondenz mit Arthur Schnitzler. Die Dateien sind optimiert für eine interaktive Kartenansicht mit Filtern für Richtung und Zeitspanne.

## Dateistruktur

Jede Datei folgt dem Muster `karte_pmb{ID}.json`, wobei `{ID}` die PMB-ID des Korrespondenzpartners ist.

## JSON-Format

```json
{
  "correspondent": {
    "id": "pmb2128",
    "name": "Plessner, Else"
  },
  "letters": [
    {
      "id": "L03698",
      "title": "Elsa Plessner an Arthur Schnitzler, 14. 3. 1896",
      "date": "1896-03-14",
      "sender": {
        "name": "Plessner, Elsa",
        "ref": "pmb2128"
      },
      "receiver": {
        "name": "Schnitzler, Arthur",
        "ref": "pmb2121"
      },
      "from": {
        "name": "Wien",
        "ref": "pmb50",
        "lat": 48.208333,
        "lon": 16.373056
      },
      "to": {
        "name": "Wien",
        "ref": "pmb50",
        "lat": 48.208333,
        "lon": 16.373056
      }
    }
  ]
}
```

## Felder

- **correspondent**: Information über den Korrespondenzpartner
  - `id`: PMB-ID des Korrespondenzpartners
  - `name`: Name des Korrespondenzpartners

- **letters**: Array aller Briefe in der Korrespondenz
  - `id`: Eindeutige Brief-ID
  - `title`: Vollständiger Titel des Briefs
  - `date`: Sendedatum im Format YYYY-MM-DD (kann null sein)
  - `sender`: Absender des Briefs
    - `name`: Name des Absenders
    - `ref`: PMB-ID des Absenders
  - `receiver`: Empfänger des Briefs
    - `name`: Name des Empfängers
    - `ref`: PMB-ID des Empfängers
  - `from`: Absenderort (kann null sein)
    - `name`: Name des Orts
    - `ref`: PMB-ID des Orts
    - `lat`: Breitengrad
    - `lon`: Längengrad
  - `to`: Empfangsort (kann null sein)
    - `name`: Name des Orts
    - `ref`: PMB-ID des Orts
    - `lat`: Breitengrad
    - `lon`: Längengrad

## Filteroptionen für die Kartenansicht

Diese Datenstruktur ermöglicht folgende Filter:

1. **Richtungsfilter**:
   - Briefe von Schnitzler (sender.ref === "pmb2121")
   - Briefe an Schnitzler (receiver.ref === "pmb2121")
   - Beide Richtungen

2. **Zeitfilter**:
   - Nach `date` filtern
   - Zeitspanne mit Slider auswählen

3. **Ortsfilter**:
   - Nach `from` oder `to` filtern
   - Nur Briefe mit gültigen Koordinaten anzeigen

## Beispiel-Verwendung

```javascript
// Alle Briefe laden
fetch('karte_pmb2128.json')
  .then(res => res.json())
  .then(data => {
    // Nur Briefe von Schnitzler filtern
    const fromSchnitzler = data.letters.filter(
      letter => letter.sender.ref === 'pmb2121'
    );

    // Zeitspanne filtern (1896-1900)
    const filtered = fromSchnitzler.filter(
      letter => letter.date >= '1896-01-01' && letter.date <= '1900-12-31'
    );

    // Auf Karte darstellen
    filtered.forEach(letter => {
      if (letter.from && letter.to) {
        drawLine(letter.from, letter.to);
      }
    });
  });
```

## Generierung

Die JSON-Dateien werden mit dem XSLT-Skript `xslts/karte-json.xsl` aus den TEI-XML-Dateien generiert:

```bash
cd statistiken/xslts
java -jar ../../saxon/saxon9he.jar -xsl:karte-json.xsl -it:main
```
