<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="true"/>
    <xsl:template name="main">
        <xsl:for-each
            select="distinct-values(collection('../inputs/?select=statistik_toc_*.xml')/document-uri(.))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:variable name="korrespondenzpartner-name"
                select="$current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/text()"/>
            <xsl:result-document href="../karte/karte_{$korrespondenz-nummer}.json">
                <xsl:text>{&#10;</xsl:text>
                <xsl:text>  "correspondent": {&#10;</xsl:text>
                <xsl:text>    "id": "</xsl:text>
                <xsl:value-of select="$korrespondenz-nummer"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>    "name": "</xsl:text>
                <xsl:value-of select="$korrespondenzpartner-name"/>
                <xsl:text>"&#10;</xsl:text>
                <xsl:text>  },&#10;</xsl:text>
                <xsl:text>  "letters": [</xsl:text>
                <xsl:apply-templates select="$current-doc/tei:list/tei:item">
                    <xsl:with-param name="korrespondenz-id" select="$korrespondenz-nummer"/>
                </xsl:apply-templates>
                <xsl:text>&#10;  ]&#10;</xsl:text>
                <xsl:text>}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:param name="korrespondenz-id"/>
        <xsl:if test="position() > 1">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>&#10;    {&#10;</xsl:text>
        <!-- ID des Briefes -->
        <xsl:text>      "id": "</xsl:text>
        <xsl:value-of select="@corresp"/>
        <xsl:text>",&#10;</xsl:text>
        <!-- Titel -->
        <xsl:text>      "title": "</xsl:text>
        <xsl:value-of
            select="normalize-space(replace(replace(tei:title[@level = 'a'], '&quot;', '\\&quot;'), '&#xA;', ' '))"/>
        <xsl:text>",&#10;</xsl:text>
        <!-- Typ: von wem der Brief ist -->
        <xsl:variable name="type" as="xs:string">
            <xsl:choose>
                <!-- 1 Der Brief ist von Schnitzler an den Partner -->
                <xsl:when
                    test="tei:correspDesc[1]/tei:correspAction[@type = 'sent'][1]/tei:persName[@ref = '#pmb2121'][1] and tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id][1]">
                    <xsl:text>von schnitzler</xsl:text>
                </xsl:when>
                <!-- 2 Der Brief ist vom Partner an Schnitzler -->
                <xsl:when
                    test="tei:correspDesc[1]/tei:correspAction[@type = 'sent'][1]/tei:persName[replace(@ref, '#', '') = $korrespondenz-id][1] and tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[@ref = '#pmb2121'][1]">
                    <xsl:text>von partner</xsl:text>
                </xsl:when>
                <!-- 3 Der Brief ist an den Partner gerichtet, kann nicht von Schnitzler sein, also kommt er aus Schnitzlers Umfeld -->
                <xsl:when
                    test="tei:correspDesc[1]/tei:correspAction[@type = 'received'][1]/tei:persName[replace(@ref, '#', '') = $korrespondenz-id][1]">
                    <xsl:text>umfeld schnitzler</xsl:text>
                </xsl:when>
                <!-- 4 Der Brief ist an Schnitzler gerichtet, aber nicht vom Partner, also kommt er aus dem Umfeld des Partners -->
                <xsl:when
                    test="tei:correspDesc[1]/tei:correspAction[@type = 'received'][1]/tei:persName[@ref = '#pmb2121'][1]">
                    <xsl:text>umfeld partner</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>umfeld</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>      "type": "</xsl:text>
        <xsl:value-of select="$type"/>
        <xsl:text>",&#10;</xsl:text>
        <!-- Datum -->
        <xsl:variable name="date"
            select="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when"/>
        <xsl:text>      "date": </xsl:text>
        <xsl:choose>
            <xsl:when test="$date">
                <xsl:text>"</xsl:text>
                <xsl:value-of select="$date"/>
                <xsl:text>"</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>null</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>,&#10;</xsl:text>
        <!-- Absender -->
        <xsl:text>      "sender": {&#10;</xsl:text>
        <xsl:text>        "name": "</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[@ref='#pmb2121']">
                <xsl:text>Schnitzler, Arthur</xsl:text>
            </xsl:when>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]">
                <xsl:value-of select="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>",&#10;</xsl:text>
        <xsl:text>        "ref": "</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[@ref='#pmb2121']">
                <xsl:text>pmb2121</xsl:text>
            </xsl:when>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]">
                <xsl:value-of select="$korrespondenz-id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="replace(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:persName[1]/@ref, '#', '')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"&#10;</xsl:text>
        <xsl:text>      },&#10;</xsl:text>
        <!-- Empfänger -->
        <xsl:text>      "receiver": {&#10;</xsl:text>
        <xsl:text>        "name": "</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'reveived']/tei:persName[@ref='#pmb2121']">
                <xsl:text>Schnitzler, Arthur</xsl:text>
            </xsl:when>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]">
                <xsl:value-of select="tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tei:correspDesc/tei:correspAction[@type = 'received']/tei:persName[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>",&#10;</xsl:text>
        <xsl:text>        "ref": "</xsl:text>
        <xsl:choose>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'reveived']/tei:persName[@ref='#pmb2121']">
                <xsl:text>pmb2121</xsl:text>
            </xsl:when>
            <xsl:when test="tei:correspDesc/tei:correspAction[@type = 'reveived']/tei:persName[replace(@ref, '#', '') = $korrespondenz-id]">
                <xsl:value-of select="$korrespondenz-id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="replace(tei:correspDesc/tei:correspAction[@type = 'reveived']/tei:persName[1]/@ref, '#', '')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"&#10;</xsl:text>
        <xsl:text>      },&#10;</xsl:text>
        <!-- Absenderort -->
        <xsl:variable name="sent-place-ref"
            select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
        <xsl:text>      "from": </xsl:text>
        <xsl:choose>
            <xsl:when
                test="$sent-place-ref != '' and starts-with(tei:correspDesc/tei:correspAction[@type = 'sent']/tei:placeName[1]/@ref, '#pmb')">
                <xsl:variable name="absender-nachgeschlagen"
                    select="document(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $sent-place-ref))"/>
                <xsl:variable name="absender-geo"
                    select="$absender-nachgeschlagen/descendant::*:location[@type = 'coords'][1]/*:geo[1]"/>
                <xsl:text>{&#10;</xsl:text>
                <xsl:text>        "name": "</xsl:text>
                <xsl:value-of select="$absender-nachgeschlagen/descendant::*:placeName[1]/text()"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>        "ref": "pmb</xsl:text>
                <xsl:value-of select="$sent-place-ref"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>        "lat": </xsl:text>
                <xsl:choose>
                    <xsl:when test="tokenize($absender-geo, ' ')[1] != ''">
                        <xsl:value-of select="replace(tokenize($absender-geo, ' ')[1], ',', '.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>null</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,&#10;</xsl:text>
                <xsl:text>        "lon": </xsl:text>
                <xsl:choose>
                    <xsl:when test="tokenize($absender-geo, ' ')[2] != ''">
                        <xsl:value-of select="replace(tokenize($absender-geo, ' ')[2], ',', '.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>null</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>      }</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>null</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>,&#10;</xsl:text>
        <!-- Empfangsort -->
        <xsl:variable name="received-place-ref"
            select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type = 'received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
        <xsl:text>      "to": </xsl:text>
        <xsl:choose>
            <xsl:when
                test="$received-place-ref != '' and starts-with(tei:correspDesc/tei:correspAction[@type = 'received']/tei:placeName[1]/@ref, '#pmb')">
                <xsl:variable name="empfaenger-nachgeschlagen"
                    select="document(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $received-place-ref))"/>
                <xsl:variable name="empfaenger-geo"
                    select="$empfaenger-nachgeschlagen/descendant::*:location[@type = 'coords'][1]/*:geo[1]"/>
                <xsl:text>{&#10;</xsl:text>
                <xsl:text>        "name": "</xsl:text>
                <xsl:value-of select="$empfaenger-nachgeschlagen/descendant::*:placeName[1]/text()"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>        "ref": "pmb</xsl:text>
                <xsl:value-of select="$received-place-ref"/>
                <xsl:text>",&#10;</xsl:text>
                <xsl:text>        "lat": </xsl:text>
                <xsl:choose>
                    <xsl:when test="tokenize($empfaenger-geo, ' ')[1] != ''">
                        <xsl:value-of select="replace(tokenize($empfaenger-geo, ' ')[1], ',', '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>null</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>,&#10;</xsl:text>
                <xsl:text>        "lon": </xsl:text>
                <xsl:choose>
                    <xsl:when test="tokenize($empfaenger-geo, ' ')[2] != ''">
                        <xsl:value-of select="replace(tokenize($empfaenger-geo, ' ')[2], ',', '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>null</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>      }</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>null</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>    }</xsl:text>
    </xsl:template>
</xsl:stylesheet>
