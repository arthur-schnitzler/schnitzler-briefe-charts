<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT wird auf statistik_toc_XXXX.xml angewandt und 
        schreibt ein CSV für die Statistik 3 – Balkendiagramme
        mit der Zeichenanzahl
   -->
    <xsl:template match="/">
        <xsl:for-each
            select="distinct-values(uri-collection('../inputs/?select=statistik_toc_*.xml'))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:result-document indent="no"
                href="../statistik3/statistik_{$korrespondenz-nummer}.csv">
                <xsl:apply-templates select="$current-doc">
                    <xsl:with-param select="$korrespondenz-nummer" name="korrespondenz-nummer"/>
                </xsl:apply-templates>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:param name="korrespondenz-nummer" as="xs:string"/>
        <xsl:variable name="startYear" select="1885"/>
        <xsl:variable name="endYear" select="1931"/>
        <xsl:variable name="listNode" select="."/>
        <xsl:text>year,"von Schnitzler","Umfeld von Schnitzler", "an Schnitzler", "Umfeld an Schnitzler"&#10;</xsl:text>
        <xsl:for-each select="($startYear to $endYear)">
            <xsl:variable name="currentYear" select="."/>
            <!-- von Schnitzler: sent by pmb2121 to korrespondenz-nummer -->
            <xsl:variable name="summeVonSchnitzler"
                select="sum($listNode/tei:item[tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121' and tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName/@ref = concat('#', $korrespondenz-nummer) and year-from-date(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when) = $currentYear]/tei:measure/@quantity)"/>
            
            <!-- Umfeld von Schnitzler: sent not by pmb2121 to korrespondenz-nummer -->
            <xsl:variable name="summeVonSchnitzlerUmfeld"
                select="sum($listNode/tei:item[not(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121') and (tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName/@ref = concat('#', $korrespondenz-nummer)) and year-from-date(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when) = $currentYear]/tei:measure/@quantity)"/>
            
            <!-- an Schnitzler: sent by korrespondenz-nummer to pmb2121 -->
            <xsl:variable name="summeVonPartner"
                select="sum($listNode/tei:item[tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName/@ref = concat('#', $korrespondenz-nummer) and tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName/@ref = '#pmb2121' and year-from-date(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when) = $currentYear]/tei:measure/@quantity)"/>
            
            <!--  sent by korrespondenz-nummer to Umfeld von Schnitzler -->
            <xsl:variable name="summeVonPartnerUmfeld"
                select="sum($listNode/tei:item[(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName/@ref = concat('#', $korrespondenz-nummer) and not(tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName/@ref = '#pmb2121')) and year-from-date(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when) = $currentYear]/tei:measure/@quantity)"/>
            <xsl:value-of
                select="concat($currentYear, ',', $summeVonSchnitzler, ',', $summeVonSchnitzlerUmfeld,',', $summeVonPartner, ',', $summeVonPartnerUmfeld)"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
