<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>
    <xsl:mode on-no-match="shallow-skip"/>

    <!-- this template creates a csv file for network analysis 
         containing all correspondences with the mentioned people in each correspondence with weights and directions -->

    <!-- keys -->
    <xsl:key name="edition-by-person" match="tei:body"
        use="//tei:rs[@type = 'person' and not(ancestor::tei:note[@type = 'textConst']) and not(ancestor::tei:note[@type = 'commentary'])]/@ref"/>
    <xsl:key name="corresp-by-id"
        match="tei:correspContext/tei:ref[@type = 'belongsToCorrespondence']" use="@target"/>

    <!-- path to edition files -->
    <xsl:variable name="editions"
        select="collection('../../../schnitzler/arthur-schnitzler-arbeit/editions/?select=*.xml')"/>

    <!-- path to listperson.xml -->
    <xsl:variable name="listperson"
        select="document('../../../schnitzler/arthur-schnitzler-arbeit/indices/listperson.xml')"/>

    <!-- csv variables -->
    <xsl:variable name="quote" select="'&quot;'"/>
    <xsl:variable name="separator" select="','"/>
    <xsl:variable name="newline" select="'&#xA;'"/>

    <xsl:template match="/">

        <xsl:for-each select="//tei:personGrp[@xml:id != 'correspondence_null']">

            <!-- name of correspondence partner -->
            <xsl:variable name="korr-name"
                select="concat(substring-after(child::tei:persName[@role = 'main'], ', '), ' ', substring-before(child::tei:persName[@role = 'main'], ','))"/>

            <!-- correspondence id -->
            <xsl:variable name="korr-id" select="@xml:id"/>

            <xsl:variable name="persons">
                <xsl:for-each select="$listperson//tei:person">
                    <!-- normalized names and ids -->
                    <xsl:variable name="pers-id" select="concat('#', @xml:id)"/>
                    <xsl:variable name="pers-name" select="normalize-space(child::tei:persName[1])"/>
                    <!-- exclude mentions of correspondence partners -->
                    <xsl:variable name="exclude-ref"
                        select="concat('#pmb', substring-after($korr-id, '_'))"/>
                    <xsl:if test="$pers-id != $exclude-ref">
                        <!-- count person mentions in bodies -->
                        <xsl:variable name="overallcount"
                            select="count($editions//tei:TEI[key('edition-by-person', $pers-id)])"/>
                        <xsl:variable name="corrcount"
                            select="count($editions//tei:TEI[key('corresp-by-id', $korr-id)][key('edition-by-person', $pers-id)])"/>
                        <xsl:if test="$corrcount &gt; 0">
                            <person id="{$pers-id}" overallcount="{$overallcount}"
                                corrcount="{$corrcount}">
                                <xsl:value-of select="$pers-name"/>
                            </person>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- csv for each correspondence that mentions persons -->
            <xsl:if test="$persons/*:person">

                <xsl:result-document href="person_freq_corr_weights_directed_{$korr-id}.csv"
                    method="text">

                    <xsl:text>Source</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>CorrID</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>Target</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>PersID</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>Overallcount</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>Type</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>Label</xsl:text>
                    <xsl:value-of select="$separator"/>
                    <xsl:text>Weight</xsl:text>
                    <xsl:value-of select="$newline"/>

                    <xsl:for-each select="$persons/*:person">
                        <xsl:sort select="@corrcount" order="descending" data-type="number"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$korr-name"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="substring-after($korr-id, '_')"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="."/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="substring-after(@id, '#pmb')"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="@overallcount"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:text>Directed</xsl:text>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="concat($korr-name, '–', .)"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$separator"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="@corrcount"/>
                        <xsl:value-of select="$quote"/>
                        <xsl:value-of select="$newline"/>
                    </xsl:for-each>

                </xsl:result-document>

            </xsl:if>

        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
