<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="no"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- dieses XSLT wird auf statistik_toc_XXXX.xml angewandt und 
        schreibt ein CSV für die Kreisgrafik der verwendeten Textsorten
   -->
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <xsl:for-each
            select="distinct-values(uri-collection('../inputs/?select=statistik_toc_*.xml'))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:result-document indent="no"
                href="../statistik4/statistik_{$korrespondenz-nummer}-a.csv">
                <xsl:apply-templates select="$current-doc" mode="list-a"/>
            </xsl:result-document>
            <xsl:result-document indent="no"
                href="../statistik4/statistik_{$korrespondenz-nummer}-b.csv">
                <xsl:apply-templates select="$current-doc" mode="list-b"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list" mode="list-a">
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:text>"Textsorte","Anzahl"&#10;</xsl:text>
        <xsl:variable name="textsorten">
            <list>
                <item ref="anderes">Anderes</item>
                <item ref="bild">Bild</item>
                <item ref="brief">Brief</item>
                <item ref="karte">Karte</item>
                <item ref="kartenbrief">Kartenbrief</item>
                <item ref="telegramm">Telegramm</item>
                <item ref="umschlag">Umschlag</item>
                <item ref="widmung">Widmung</item>
            </list>
        </xsl:variable>
        <xsl:for-each select="$textsorten/list/item">
            <xsl:variable name="corresp" select="@ref" as="xs:string"/>
            <xsl:value-of select="."/>
            <xsl:text>,</xsl:text>
            <xsl:value-of
                select="count($correspAction-gesamt/descendant::*:objectType[@corresp = $corresp])"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list" mode="list-b">
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:text>"Textsorte","Anzahl"&#10;</xsl:text>
        <xsl:variable name="textsorten">
            <list>
                <item ref="anderes">Anderes</item>
                <item ref="bild">Bild</item>
                <item ref="bild-fotografie">Fotografie</item>
                <item ref="brief">Brief</item>
                <item ref="brief-entwurf">Briefentwurf</item>
                <item ref="karte">Karte</item>
                <item ref="karte-postkarte">Postkarte</item>
                <item ref="karte-bildpostkarte">Bildpostkarte</item>
                <item ref="karte-briefkarte">Briefkarte</item>
                <item ref="karte-visitenkarte">Visitenkarte</item>
                <item ref="kartenbrief">Kartenbrief</item>
                <item ref="telegramm">Telegramm</item>
                <item ref="telegramm-entwurf">Telegrammentwurf</item>
                <item ref="umschlag">Umschlag</item>
                <item ref="widmung">Widmung</item>
                <item ref="widmung-widmung_umschlag">Widmung Umschlag</item>
                <item ref="widmung-widmung_vorsatzblatt">Widmung Vorsatzblatt</item>
                <item ref="widmung-widmung_schmutztitel">Widmung Schmutztitel</item>
                <item ref="widmung-widmung_vortitel">Widmung Vortitel</item>
                <item ref="widmung-widmung_titelblatt">Widmung Titelblatt</item>
            </list>
        </xsl:variable>
        <xsl:for-each select="$textsorten/list/item">
            <xsl:variable name="corresp" select="tokenize(@ref, '-')[1]" as="xs:string"/>
            <xsl:variable name="ana" select="tokenize(@ref, '-')[2]" as="xs:string?"/>
            <xsl:message select="$ana"></xsl:message>
            <xsl:value-of select="."/>
            <xsl:text>,</xsl:text>
            <xsl:choose>
                <xsl:when test="fn:normalize-space($ana) =''">
                    <xsl:value-of
                        select="count($correspAction-gesamt/descendant::*:objectType[@corresp = $corresp and not(@ana)])"/>
                </xsl:when>
                <xsl:when
                    test="$correspAction-gesamt/descendant::tei:objectType[@corresp = $corresp and @ana = $ana][1]">
                    <xsl:value-of
                        select="count($correspAction-gesamt/descendant::*:objectType[@corresp = $corresp and @ana = $ana])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
