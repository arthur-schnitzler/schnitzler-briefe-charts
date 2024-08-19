<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="true"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:template match="/">
        <xsl:for-each
            select="distinct-values(uri-collection('../inputs/?select=statistik_toc_*.xml'))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:if test="position() > 1">,</xsl:if>
            <xsl:result-document href="../karte2/karte_{$korrespondenz-nummer}.json">
                <xsl:text>{&#10;</xsl:text>
                <xsl:text>"title": {&#10;"text": "Korrespondenzstücke von Schnitzler"&#10;},&#10;</xsl:text>
                <xsl:text>"subtitle": {&#10; "text": ""&#10;},&#10;"series": [{&#10;</xsl:text>
                <xsl:text>"type": "map",&#10;</xsl:text>
                <xsl:text>"name": "Flow",&#10;</xsl:text>
                <xsl:text>"data": [</xsl:text>
                <xsl:apply-templates select="$current-doc" mode="ids"/>
                <xsl:text>]&#10;},&#10;</xsl:text>
                <xsl:text>{&#10;"type": "mapline",&#10;"name": "Flow Lines",&#10;</xsl:text>
                <xsl:text>"data": [</xsl:text>
                <xsl:apply-templates select="$current-doc"/>
                <xsl:text>]}&#10;]}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list" mode="ids">
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:for-each
            select="distinct-values(descendant::tei:correspDesc[tei:correspAction[@type='sent'][1]/tei:persName/@ref='#pmb2121']/tei:correspAction[@type='sent' or @type='received']/tei:placeName[1]/tokenize(normalize-space(@ref), ' ')[1])">
            <xsl:variable name="absenderort-ref" select="normalize-space(replace(., '#pmb', ''))"
                as="xs:string"/>
            <xsl:variable name="absender-nachgeschlagen"
                select="document(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $absenderort-ref))"
                as="node()"/>
            <xsl:variable name="absender-geo"
                select="$absender-nachgeschlagen/descendant::*:location[@type = 'coords'][1]/*:geo[1]"/>
            <xsl:text>{&#10;</xsl:text>
            <xsl:text>"id": "</xsl:text>
            <xsl:value-of select="$absender-nachgeschlagen/descendant::*:placeName[1]/text()"/>
            <xsl:text>",&#10;</xsl:text>
            <xsl:text>"lat": </xsl:text>
            <xsl:value-of select="replace(tokenize($absender-geo, ' ')[1], ',', '.')"/>
            <xsl:text>,&#10;</xsl:text>
            <xsl:text>"lon": </xsl:text>
            <xsl:value-of select="replace(tokenize($absender-geo, ' ')[2], ',', '.')"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>}</xsl:text>
            <xsl:if test="not(fn:position() = last())">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:list">
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:for-each
            select="distinct-values(child::tei:item/descendant::tei:correspDesc[tei:correspAction[@type='sent'][1]/tei:persName/@ref='#pmb2121' and tei:correspAction[@type = 'received'][1]/tei:placeName[1][@ref[starts-with(., '#pmb')]]][1]/tei:correspAction[@type = 'sent'][1]/tei:placeName[1][@ref[starts-with(., '#pmb')]])">
            <xsl:variable name="from" select="." as="xs:string"/>
            <xsl:for-each
                select="distinct-values($correspAction-gesamt/descendant::tei:item/tei:correspDesc[tei:correspAction[@type='sent'][1]/tei:placeName[1]=$from]/tei:correspAction[@type = 'received']/tei:placeName[1])">
                <xsl:variable name="to" select="." as="xs:string"/>
                <xsl:text>{&#10;"from": "</xsl:text>
                <xsl:value-of select="$from"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>"to": "</xsl:text>
                <xsl:value-of select="$to"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>"weight": </xsl:text>
                <xsl:value-of
                    select="count($correspAction-gesamt/descendant::tei:correspDesc[tei:correspAction[@type='sent'][1]/tei:persName/@ref='#pmb2121'][tei:correspAction[@type = 'sent']/tei:placeName[1] = $from and tei:correspAction[@type = 'received']/tei:placeName[1] = $to])"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="not(position() = last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <xsl:if test="not(position() = last())">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
