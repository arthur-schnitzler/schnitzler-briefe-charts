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
      "type": "von partner",
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
  - `type`: Brieftyp (siehe unten)
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
    - `lat`: Breitengrad (kann null sein)
    - `lon`: Längengrad (kann null sein)

## Brieftypen

Das `type`-Feld unterscheidet zwischen:

- **`von schnitzler`**: Briefe von Schnitzler an den Korrespondenzpartner
- **`von partner`**: Briefe vom Korrespondenzpartner an Schnitzler
- **`umfeld schnitzler`**: Briefe von Schnitzler an Dritte (nicht an den Korrespondenzpartner)
- **`umfeld partner`**: Briefe vom Korrespondenzpartner an Dritte (nicht an Schnitzler)
- **`umfeld`**: Briefe zwischen Dritten (weder Schnitzler noch Korrespondenzpartner als Absender)

## Filteroptionen für die Kartenansicht

Diese Datenstruktur ermöglicht folgende Filter:

1. **Brieftyp-Filter**:
   - Nur Hauptkorrespondenz (`type === "von schnitzler" || type === "von partner"`)
   - Nur von Schnitzler (`type === "von schnitzler"`)
   - Nur vom Partner (`type === "von partner"`)
   - Mit Umfeldbriefen von Schnitzler (`type !== "von partner" && type !== "umfeld partner" && type !== "umfeld"`)
   - Mit Umfeldbriefen des Partners (`type !== "von schnitzler" && type !== "umfeld schnitzler" && type !== "umfeld"`)
   - Alle Briefe

3. **Zeitfilter**:
   - Nach `date` filtern
   - Zeitspanne mit Slider auswählen

4. **Ortsfilter**:
   - Nach `from` oder `to` filtern
   - Nur Briefe mit gültigen Koordinaten anzeigen

## Beispiel-Verwendung

```javascript
// Alle Briefe laden
fetch('karte_pmb10863.json')
  .then(res => res.json())
  .then(data => {
    // Nur Briefe von Schnitzler (Hauptkorrespondenz + Umfeld)
    const filtered = data.letters.filter(
      letter => letter.type === 'von schnitzler' ||
                letter.type === 'umfeld schnitzler'
    );

    // Zeitspanne filtern (1896-1900)
    const timeFiltered = filtered.filter(
      letter => letter.date >= '1896-01-01' && letter.date <= '1900-12-31'
    );

    // Auf Karte darstellen
    timeFiltered.forEach(letter => {
      if (letter.from && letter.to) {
        drawLine(letter.from, letter.to, {
          color: letter.type === 'von schnitzler' ? 'blue' : 'lightblue'
        });
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
