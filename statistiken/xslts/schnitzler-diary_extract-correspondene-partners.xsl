<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT holt die Anzahl der Erwähnungen von korrespondenz-partnern
        aus der datei index_person_day.xml (schnitzler-tagebuch-data)
        und schreibt eine liste
   -->
    <xsl:param name="index-person-day"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-tagebuch-data/master/indices/index_person_day.xml')"
        as="node()"/>
    <xsl:key name="tagebuch-treffer" match="*:list/*:item" use="*:ref/@corresp"/>
    <xsl:param name="korrespondenzen"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/main/data/indices/listcorrespondence.xml')"
        as="node()"/>
    <xsl:template match="/">
        <xsl:variable name="startYear" select="1888"/>
        <xsl:variable name="endYear" select="1931"/>
        <xsl:for-each select="$korrespondenzen/descendant::tei:persName[@role = 'main']/@ref">
            <xsl:variable name="korrespondenz" select="replace(., '#', '')" as="xs:string"/>
            <xsl:result-document indent="yes"
                href="../tagebuch/tagebuch-vorkommen_{$korrespondenz}.xml">
                <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    >
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title level="s">Arthur Schnitzler: Briefwechsel mit Autorinnen und
                                    Autoren</title>
                                <xsl:element name="title">
                                    <xsl:attribute name="level">
                                        <xsl:text>a</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>Erwähnungen in Schniztlers Tagebuch von </xsl:text>
                                    <xsl:value-of select="$korrespondenz"/>
                                </xsl:element>
                                <respStmt>
                                    <resp>providing the content</resp>
                                    <name>Martin Anton Müller</name>
                                    <name>Gerd-Hermann Susen</name>
                                    <name>Laura Untner</name>
                                </respStmt>
                                <respStmt>
                                    <resp>converted to XML encoding</resp>
                                    <name>Martin Anton Müller</name>
                                </respStmt>
                            </titleStmt>
                            <publicationStmt>
                                <publisher>Austrian Centre for Digital Humanities and Cultural
                                    Heritage (ACDH-CH)</publisher>
                                <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:value-of select="current-date()"/>
                                </xsl:element>
                                <!--<idno type="URI">
                                <xsl:text>https://id.acdh.oeaw.ac.at/schnitzler-briefe/tocs/</xsl:text>
                                <xsl:value-of select="$dateiname"/>
                            </idno>-->
                            </publicationStmt>
                            <sourceDesc>
                                <p>Erwähnungen im Tagebuch nach Jahren einzelner
                                    Korrespondenzpartner</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:for-each select="($startYear to $endYear)">
                                    <xsl:variable name="currentYear" select="."/>
                                    <xsl:element name="event">
                                        <xsl:attribute name="when">
                                            <xsl:value-of select="$currentYear"/>
                                        </xsl:attribute>
                                        <xsl:element name="desc">
                                        <xsl:value-of
                                            select="count(key('tagebuch-treffer', $korrespondenz, $index-person-day)[fn:year-from-date(@target) = $currentYear])"
                                        />
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
