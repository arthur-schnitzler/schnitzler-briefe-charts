<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="true"/>

    <xsl:key name="place-lookup" match="tei:item" use="concat(
        normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', '')),
        '|',
        normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))
    )"/>

    <xsl:template name="main">
        <xsl:variable name="files" select="collection('../inputs/?select=statistik_toc_*.xml')"/>
        <xsl:message>Found <xsl:value-of select="count($files)"/> statistik_toc files</xsl:message>
        <xsl:for-each select="distinct-values($files/document-uri(.))">
            <xsl:variable name="current-uri" select="."/>
            <xsl:variable name="current-doc"
                select="document($current-uri)/tei:TEI/tei:text[1]/tei:body[1]"/>
            <xsl:variable name="korrespondenz-nummer"
                select="replace($current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/@target, 'correspondence_', 'pmb')"/>
            <xsl:variable name="korrespondenzpartner-name"
                select="$current-doc/tei:list[1]/tei:item[not(descendant::tei:ref[@type = 'belongsToCorrespondence'][2])][1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref[@type = 'belongsToCorrespondence'][1]/text()"/>
            <xsl:variable name="output-path" select="resolve-uri(concat('../arcs/arc_', $korrespondenz-nummer, '.json'), static-base-uri())"/>
            <xsl:message>Creating <xsl:value-of select="$output-path"/> for <xsl:value-of select="$korrespondenzpartner-name"/></xsl:message>

            <!-- Sammle alle Briefe -->
            <xsl:variable name="all-items" select="$current-doc/tei:list/tei:item"/>

            <!-- Sammle alle einzigartigen Orte -->
            <xsl:variable name="all-place-refs" as="xs:string*">
                <xsl:for-each select="$all-items">
                    <xsl:variable name="sent" select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
                    <xsl:variable name="received" select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
                    <xsl:if test="$sent != '' and starts-with(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref, '#pmb')">
                        <xsl:sequence select="$sent"/>
                    </xsl:if>
                    <xsl:if test="$received != '' and starts-with(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref, '#pmb')">
                        <xsl:sequence select="$received"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="unique-places" select="distinct-values($all-place-refs)"/>

            <xsl:result-document href="{$output-path}">
                <xsl:text>{&#10;</xsl:text>
                <xsl:text>  "correspondent": "</xsl:text>
                <xsl:value-of select="$korrespondenzpartner-name"/>
                <xsl:text>",&#10;</xsl:text>

                <!-- Nodes -->
                <xsl:text>  "nodes": [</xsl:text>
                <xsl:for-each select="$unique-places">
                    <xsl:sort select="."/>
                    <xsl:variable name="place-id" select="."/>
                    <xsl:variable name="count" select="count($all-items[
                        normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', '')) = $place-id or
                        normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', '')) = $place-id
                    ])"/>

                    <!-- Lookup place name from PMB -->
                    <xsl:variable name="place-doc" select="document(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $place-id))"/>
                    <xsl:variable name="place-name" select="$place-doc/descendant::*:placeName[1]/text()"/>

                    <xsl:if test="position() > 1">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:text>&#10;    {&#10;</xsl:text>
                    <xsl:text>      "id": "pmb</xsl:text>
                    <xsl:value-of select="$place-id"/>
                    <xsl:text>",&#10;</xsl:text>
                    <xsl:text>      "name": "</xsl:text>
                    <xsl:value-of select="$place-name"/>
                    <xsl:text>",&#10;</xsl:text>
                    <xsl:text>      "count": </xsl:text>
                    <xsl:value-of select="$count"/>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:text>    }</xsl:text>
                </xsl:for-each>
                <xsl:text>&#10;  ],&#10;</xsl:text>

                <!-- Links from Schnitzler -->
                <xsl:text>  "links_from_schnitzler": [</xsl:text>
                <xsl:call-template name="generate-links">
                    <xsl:with-param name="items" select="$all-items"/>
                    <xsl:with-param name="korrespondenz-nummer" select="$korrespondenz-nummer"/>
                    <xsl:with-param name="direction" select="'from_schnitzler'"/>
                </xsl:call-template>
                <xsl:text>&#10;  ],&#10;</xsl:text>

                <!-- Links to Schnitzler -->
                <xsl:text>  "links_to_schnitzler": [</xsl:text>
                <xsl:call-template name="generate-links">
                    <xsl:with-param name="items" select="$all-items"/>
                    <xsl:with-param name="korrespondenz-nummer" select="$korrespondenz-nummer"/>
                    <xsl:with-param name="direction" select="'to_schnitzler'"/>
                </xsl:call-template>
                <xsl:text>&#10;  ]&#10;</xsl:text>
                <xsl:text>}</xsl:text>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="generate-links">
        <xsl:param name="items"/>
        <xsl:param name="korrespondenz-nummer"/>
        <xsl:param name="direction"/>

        <!-- Filter items based on direction -->
        <xsl:variable name="filtered-items">
            <xsl:choose>
                <xsl:when test="$direction = 'from_schnitzler'">
                    <xsl:sequence select="$items[tei:correspDesc/tei:correspAction[@type='sent']/tei:persName[@ref='#pmb2121']]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$items[tei:correspDesc/tei:correspAction[@type='received']/tei:persName[@ref='#pmb2121']]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Group by from-to combination -->
        <xsl:variable name="routes" as="xs:string*">
            <xsl:for-each select="$filtered-items">
                <xsl:variable name="from-ref" select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
                <xsl:variable name="to-ref" select="normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', ''))"/>
                <xsl:if test="$from-ref != '' and $to-ref != '' and
                              starts-with(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref, '#pmb') and
                              starts-with(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref, '#pmb')">
                    <xsl:sequence select="concat($from-ref, '|', $to-ref)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="unique-routes" select="distinct-values($routes)"/>

        <xsl:for-each select="$unique-routes">
            <xsl:sort select="."/>
            <xsl:variable name="route" select="."/>
            <xsl:variable name="from-id" select="tokenize($route, '\|')[1]"/>
            <xsl:variable name="to-id" select="tokenize($route, '\|')[2]"/>

            <!-- Collect all titles for this route -->
            <xsl:variable name="route-items" select="$filtered-items[
                normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName[1]/@ref), ' ')[1], '#pmb', '')) = $from-id and
                normalize-space(replace(tokenize(normalize-space(tei:correspDesc/tei:correspAction[@type='received']/tei:placeName[1]/@ref), ' ')[1], '#pmb', '')) = $to-id
            ]"/>

            <xsl:if test="position() > 1">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#10;    {&#10;</xsl:text>
            <xsl:text>      "from": "pmb</xsl:text>
            <xsl:value-of select="$from-id"/>
            <xsl:text>",&#10;</xsl:text>
            <xsl:text>      "to": "pmb</xsl:text>
            <xsl:value-of select="$to-id"/>
            <xsl:text>",&#10;</xsl:text>
            <xsl:text>      "weight": </xsl:text>
            <xsl:value-of select="count($route-items)"/>
            <xsl:text>,&#10;</xsl:text>
            <xsl:text>      "titles": [</xsl:text>
            <xsl:for-each select="$route-items">
                <xsl:if test="position() > 1">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#10;        "</xsl:text>
                <xsl:value-of select="normalize-space(replace(replace(tei:title[@level='a'], '&quot;', '\\&quot;'), '&#xA;', ' '))"/>
                <xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:text>&#10;      ]&#10;</xsl:text>
            <xsl:text>    }</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
