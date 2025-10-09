<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT wird auf statistik_toc_XXXX.xml angewandt und 
        schreibt ein CSV für die Statistik 1 – Balkendiagramme
        mit der Anzahl der Objekte pro Jahr
   -->
    <xsl:template match="/">
        <xsl:variable name="baseDir" select="resolve-uri('.', base-uri())"/>
        <xsl:for-each
            select="distinct-values(uri-collection(resolve-uri('?select=statistik_toc_*.xml', $baseDir)))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:result-document indent="no"
                href="{resolve-uri(concat('../statistik1/statistik_', $korrespondenz-nummer, '.csv'), static-base-uri())}">
                <xsl:apply-templates select="$current-doc">
                    <xsl:with-param select="$korrespondenz-nummer" name="korrespondenz-nummer"></xsl:with-param>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:param name="korrespondenz-nummer" as="xs:string"/>
        <!-- Von Schnitzler an Partner -->
        <xsl:variable name="correspAction-von-schnitzler-an-partner"
            select="descendant::tei:correspDesc[tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121' and tei:correspAction[@type = 'received']/tei:persName/@ref = concat('#', $korrespondenz-nummer)]"/>
        <!-- Aus Schnitzlers Umfeld an den Korrespondenzpartner -->
        <xsl:variable name="correspAction-von-schnitzler-an-umfeld"
            select="descendant::tei:correspDesc[not(tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121') and (tei:correspAction[@type = 'received']/tei:persName/@ref = concat('#', $korrespondenz-nummer))]"/>
        <!-- Von Partner an Schnitzler -->
        <xsl:variable name="correspAction-von-partner"
            select="descendant::tei:correspDesc[tei:correspAction[@type = 'sent']/tei:persName/@ref = concat('#', $korrespondenz-nummer) and tei:correspAction[@type = 'received']/tei:persName/@ref = '#pmb2121']"/>
        <!-- Aus dem Umfeld des Korrespondenzpartners an Schnitzler -->
        <xsl:variable name="correspAction-von-partner-an-umfeld"
            select="descendant::tei:correspDesc[tei:correspAction[@type = 'received']/tei:persName/@ref = '#pmb2121' and not(tei:correspAction[@type = 'sent']/tei:persName/@ref = concat('#', $korrespondenz-nummer)) and not(tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121')]"/>

        <xsl:text>year,"von Schnitzler","Umfeld von Schnitzler", "an Schnitzler", "Umfeld an Schnitzler"&#10;</xsl:text>
        <xsl:for-each select="1885 to 1931">
            <xsl:variable name="currentYear" select="."/>
            <xsl:variable name="countSchnitzlerDates"
                select="count($correspAction-von-schnitzler-an-partner/tei:correspAction[1]/tei:date[number(tokenize(@*[contains(., '-')][1], '-')[1]) = $currentYear])"
                as="xs:integer"/>
            <xsl:variable name="countSchnitzlerUmfeldDates"
                select="count($correspAction-von-schnitzler-an-umfeld/tei:correspAction[1]/tei:date[number(tokenize(@*[contains(., '-')][1], '-')[1]) = $currentYear])"
                as="xs:integer"/>
            <xsl:variable name="countNotSchnitzlerDates"
                select="count($correspAction-von-partner/tei:correspAction[1]/tei:date[number(tokenize(@*[contains(., '-')][1], '-')[1]) = $currentYear])"
                as="xs:integer"/>
            <xsl:variable name="countNotSchnitzlerUmfeldDates"
                select="count($correspAction-von-partner-an-umfeld/tei:correspAction[1]/tei:date[number(tokenize(@*[contains(., '-')][1], '-')[1]) = $currentYear])"
                as="xs:integer"/>
            <xsl:value-of
                select="concat($currentYear, ',', $countSchnitzlerDates, ',', $countSchnitzlerUmfeldDates, ',', $countNotSchnitzlerDates, ',', $countNotSchnitzlerUmfeldDates)"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
