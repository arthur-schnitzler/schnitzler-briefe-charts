# netzwerke

## correspondence_weights_undirected
counts the number of correspondence pieces of all correspondences in undirected graphs (visualization not published)

## correspondence_weights_directed
counts the number of correspondence pieces of all correspondences in directed graphs, [see visualization](https://schnitzler-briefe.acdh.oeaw.ac.at/tocs.html)

## postwege_weights_directed
evaluates the mail routes in directed graphs (sending and receiving locations, without intermediate stops), [see visualization](https://schnitzler-briefe.acdh.oeaw.ac.at/correspaction.html)

## person_freq_corp_weights_directed
counts the frequencies of the most frequently mentioned persons** in all correspondences in directed graphs (direction: from main correspondent to mentioned person), [see visualization](https://schnitzler-briefe.acdh.oeaw.ac.at/listperson.html)

## person_freq_corr_weights_directed
counts the frequencies of the most frequently mentioned persons** per correspondence in directed graphs, visualizations at correspondence sites, e. g. [Richard Beer-Hofmann](https://schnitzler-briefe.acdh.oeaw.ac.at/netzwerke_pmb10863.html)

## work_freq_corp_weights_directed
counts the frequencies of the most frequently mentioned works** in all correspondences in directed graphs (direction: from main correspondent to mentioned work), [see visualization](https://schnitzler-briefe.acdh.oeaw.ac.at/listwork.html)

## work_freq_corr_weights_directed
counts the frequencies of the most frequently mentioned works** per correspondence in directed graphs, visualizations at correspondence sites, e. g. [Richard Beer-Hofmann](https://schnitzler-briefe.acdh.oeaw.ac.at/netzwerke_pmb10863.html)

## place_freq_corr_weights_directed
counts the frequencies of the most frequently mentioned places** per correspondence in directed graphs, visualizations at correspondence sites, e. g. [Richard Beer-Hofmann](https://schnitzler-briefe.acdh.oeaw.ac.at/netzwerke_pmb10863.html)

## institution_freq_corp_weights_directed
counts the frequencies of the most frequently mentioned institutions** in all correspondences in directed graphs (direction: from main correspondent to mentioned institution), [see visualization](https://schnitzler-briefe.acdh.oeaw.ac.at/listplace.html)

## institution_freq_corr_weights_directed
counts the frequencies of the most frequently mentioned institutions** per correspondence in directed graphs, visualizations at correspondence sites, e. g. [Richard Beer-Hofmann](https://schnitzler-briefe.acdh.oeaw.ac.at/netzwerke_pmb10863.html)

** mentions are counted per document body

## jung-wien
this directory contains data concerning the correspondences between arthur schnitzler, richard beer-hofmann, hugo von hofmannsthal and hermann bahr:
- jung-wien-ist-alle.xml contains all relevant data in xml format
- jung-wien-ist-alle-to-csv.xsl transforms jung-wien-ist-alle.xml to jung-wien-ist-alle.csv
- jung-wien-ist-alle.csv contains the data as it is represented in jung-wien-ist-alle.xml, but in csv format (jung-wien-ist-alle.xlsx is the same, but for excel)
- jung-wien-ist-alle-to-jung-wien-alle-without-gaps.py transforms jung-wien-ist-alle.csv to jung-wien-alle-without-gaps.csv
- jung-wien-alle-without-gaps.csv fills the gaps in jung-wien-ist-alle.csv and pretends like there was always a reply (jung-wien-alle-without-gaps.xlsx is the same, but for excel)
- jung-wien-ist-und-without-gaps-to-per-year.py transforms both jung-wien-ist-alle.csv and jung-wien-alle-without-gaps.csv to jung-wien-ist-alle-per-year.csv and jung-wien-alle-without-gaps-per-year.csv
- jung-wien-ist-alle-per-year.csv and jung-wien-alle-without-gaps-per-year.csv summarizes the data from jung-wien-ist-alle.csv and jung-wien-alle-without-gaps.csv and outputs only one line per year for each correspondence (jung-wien-ist-alle-per-year.xlsx and jung-wien-alle-without-gaps-per-year.xlsx are the same, but for excel)
- get-pivot-tables.py transforms jung-wien-ist-alle.csv and jung-wien-alle-without-gaps.csv into pivot tables (for excel, see the subdirectory pivot-tables; the pivot tables for single correspondences are created manually by deleting columns)
