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
        <xsl:for-each select="distinct-values(uri-collection('../inputs/?select=statistik_toc_*.xml'))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc" select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:result-document indent="no"
                href="../statistik3/statistik_{$korrespondenz-nummer}.csv">
                <xsl:apply-templates select="$current-doc"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <xsl:variable name="startYear" select="1888"/>
        <xsl:variable name="endYear" select="1931"/>
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:variable name="correspAction-schnitzler" as="node()">
            <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:item[tei:correspDesc[tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121']]">
                    <xsl:element name="item" namespace="http://www.tei-c.org/ns/1.0"
                        >
                    <xsl:copy>
                        <!-- Copy attributes of tei:item -->
                        <xsl:copy-of select="@*"/>
                        
                        <!-- Copy only the descendants tei:date and tei:measure -->
                        <xsl:copy-of select="descendant::tei:date[1] | descendant::tei:measure[1]"/>
                    </xsl:copy>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="correspAction-notschnitzler" as="node()">
            <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="descendant::tei:item[tei:correspDesc[tei:correspAction[last()]/tei:persName/@ref = '#pmb2121']]">
                    <xsl:element name="item" namespace="http://www.tei-c.org/ns/1.0"
                        >
                        <xsl:copy>
                            <!-- Copy attributes of tei:item -->
                            <xsl:copy-of select="@*"/>
                            
                            <!-- Copy only the descendants tei:date and tei:measure -->
                            <xsl:copy-of select="descendant::tei:date[1] | descendant::tei:measure[1]"/>
                        </xsl:copy>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <xsl:text>year,"von Schnitzler","an Schnitzler"&#10;</xsl:text>
        <xsl:for-each select="($startYear to $endYear)">
            <xsl:variable name="currentYear" select="."/>
            <xsl:variable name="summeSchnitzler"  select="sum($correspAction-schnitzler/descendant::tei:item[descendant::tei:date[1]/@*[starts-with(., '1')][1]/fn:year-from-date(.) = $currentYear]/tei:measure/@quantity)"/>
            <xsl:variable name="nichtSummeSchnitzler" select="sum($correspAction-notschnitzler/descendant::tei:item[descendant::tei:date[1]/@*[starts-with(., '1')][1]/fn:year-from-date(.) = $currentYear]/tei:measure/@quantity)"/>
            <xsl:value-of
                select="concat($currentYear, ',-', $summeSchnitzler, ',', $nichtSummeSchnitzler)"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
       
    </xsl:template>
</xsl:stylesheet>
