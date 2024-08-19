<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT wird auf create-statistics.xml angewandt und 
        schreibt ein CSV für die Statistik 2 – Balkendiagramme
        mit der Anzahl der Objekte pro Jahr und Tagebuch
   -->
    <xsl:template match="/">
        <xsl:for-each select="distinct-values(uri-collection('../inputs/?select=statistik_toc_*.xml'))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc" select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:result-document indent="no"
                href="../statistik2/statistik_{$korrespondenz-nummer}.csv">
                <xsl:apply-templates select="$current-doc"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:variable name="korrespondenz-nummer"
            select="replace(tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')" as="xs:string"/>
        <xsl:variable name="startYear" select="1888"/>
        <xsl:variable name="endYear" select="1931"/>
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:text>year,"erhaltene Korrespondenzstücke","Erwähnungen im Tagebuch"&#10;</xsl:text>
        <xsl:for-each select="($startYear to $endYear)">
            <xsl:variable name="currentYear" select="."/>
            <xsl:variable name="correspAction-gesamt-zahl" as="xs:integer"
                select="count($correspAction-gesamt/tei:item/tei:correspDesc[1]/tei:correspAction[1]/tei:date[1][fn:year-from-date(@*[starts-with(., '1')][1]) = $currentYear])"/>
            <xsl:value-of select="$currentYear"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$correspAction-gesamt-zahl"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of
                select="document(concat('../tagebuch-vorkommen-korrespondenzpartner/tagebuch-vorkommen_', $korrespondenz-nummer, '.xml'))/descendant::tei:event[@when = $currentYear]/tei:desc"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
