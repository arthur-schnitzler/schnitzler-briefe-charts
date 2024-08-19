<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT wird auf schnitzler-tagebuch-data/indices/listperson.xml angewandt und 
        schreibt ein CSV für die Balkendiagramme in schnitzler-tagebuch
        mit der Anzahl der Objekte pro Jahr
   -->
    <xsl:param name="index-person-day"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-tagebuch-data/master/indices/index_person_day.xml')"
        as="node()"/>
    <xsl:key name="tagebuch-treffer" match="*:list/*:item" use="*:ref/text()"/>
    <xsl:param name="listperson"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-tagebuch-data/master/indices/listperson.xml')/tei:TEI/tei:text[1]/tei:body[1]/tei:div[1]/tei:listPerson[1]"
        as="node()"/>
    <xsl:template match="/">
        <xsl:variable name="startYear" select="1879"/>
        <xsl:variable name="endYear" select="1931"/>
        <xsl:for-each select="$listperson/tei:person/@xml:id">
            <xsl:variable name="personennummer" select="."/>
            <xsl:result-document indent="no"
                href="../tagebuch-vorkommen-jahr/tagebuch-vorkommen-jahr_{$personennummer}.csv">
                <xsl:text>year,"Erwähnungen"&#10;</xsl:text>
                <xsl:for-each select="($startYear to $endYear)">
                    <xsl:variable name="currentYear" select="."/>
                    <xsl:value-of select="$currentYear"/>
                    <!-- Zählen der tei:date[@when] für das aktuelle Jahr -->
                    <xsl:text>,</xsl:text>
                    <xsl:value-of
                        select="count(key('tagebuch-treffer', $personennummer, $index-person-day)[fn:year-from-date(@target) = $currentYear])"/>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
