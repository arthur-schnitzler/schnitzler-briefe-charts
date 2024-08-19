# schnitzler-briefe-statistik
This repository gathers various CSV files containing analyses of the professional correspondence of Arthur Schnitzler (1862–1931). The analyses can be found at https://schnitzler-briefe.acdh.oeaw.ac.at/tocs.html, and the processed data is available here: https://github.com/arthur-schnitzler/schnitzler-briefe-data/.

# tagebuch-vorkommen-jahr
the folder /tagebuch-vorkommen-jahr contains csv files with occurences of persons in the diary between 1879–1931

# tagebuch-vorkommen-korrespondenzpartner
is similar to the one above but exists of xml-files (not csv) and is limited to the correspondences edited in schnitzler-briefe

# statistik1
contains csvs for a graph that shows number of surviving correspondence pieces per sender and receiver. schnitzler’s letters (usually fewer survive than the one he received) are shown as negative numbers

# statistik2
csvs comparing the amount of letters/year with the amount of mentions/year (using the data in tagebuch-vorkommen-korrespondenzpartner)

# statistik3
this sums the element `<measure unit='zeichenanzahl' quantity='XXX'>` for each correspondence
partner individually

# statistik4
this differentiates types of text (»brief«, »postkarte« etc.)

# karte1
json-files containing the relevant data for the highchart flow-maps for all the surviving correspondence pieces

# karte2
similar to the one above with the difference that the map shows schnitzler’s correspondence pieces

# karte3
… and this one shows the pieces directed to Schnitzler