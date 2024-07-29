<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" indent="yes" encoding="utf-8"/>

    <xsl:mode on-no-match="shallow-skip"/>

    <!-- this template creates a xml file
         containing info about how often the top 30 people mentioned in ALL correspondences 
         are mentioned in each correspondence (just bodies without comments) -->

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

        <xsl:text>Source</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Target</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Type</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Label</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Weight</xsl:text>
        <xsl:value-of select="$newline"/>

        <!-- overall counts -->
        <xsl:variable name="overall-count">
            <xsl:for-each select="$listperson//tei:person">
                <!-- normalized names and ids -->
                <xsl:variable name="pers-id" select="concat('#', @xml:id)"/>
                <xsl:variable name="pers-name" select="normalize-space(child::tei:persName[1])"/>
                <!-- count person mentions in bodies -->
                <xsl:variable name="count"
                    select="count($editions//tei:TEI[key('edition-by-person', $pers-id)])"/>
                <xsl:if test="$count &gt; 0">
                    <person id="{$pers-id}" count="{$count}">
                        <xsl:value-of select="$pers-name"/>
                    </person>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="//tei:personGrp[@xml:id != 'correspondence_null']">

            <!-- name of correspondence partner -->
            <xsl:variable name="korr-name"
                select="concat(substring-after(child::tei:persName[@role = 'main'], ', '), ' ', substring-before(child::tei:persName[@role = 'main'], ','))"/>

            <!-- correspondence id -->
            <xsl:variable name="korr-id" select="@xml:id"/>

            <!-- counts in correspondences -->
            <xsl:variable name="top-30-persons">
                <xsl:for-each select="$overall-count/*:person">
                    <xsl:sort select="@count" order="descending" data-type="number"/>
                    <xsl:if test="position() &lt;= 30">
                        <!-- names and ids -->
                        <xsl:variable name="pers-id" select="@id"/>
                        <xsl:variable name="pers-name" select="text()"/>
                        <!-- exclude mentions of correspondence partners -->
                        <xsl:variable name="exclude-ref"
                            select="concat('#pmb', substring-after($korr-id, '_'))"/>
                        <xsl:if test="$pers-id != $exclude-ref">
                            <!-- count person mentions in bodies -->
                            <xsl:variable name="count"
                                select="count($editions//tei:TEI[key('corresp-by-id', $korr-id)][key('edition-by-person', $pers-id)])"/>
                            <xsl:if test="$count &gt; 0">
                                <person id="{$pers-id}" count="{$count}">
                                    <xsl:value-of select="$pers-name"/>
                                </person>
                            </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- csv -->
            <xsl:if test="$top-30-persons/*:person">

                <xsl:for-each select="$top-30-persons/*:person">
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$korr-name"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="."/>
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
                    <xsl:value-of select="@count"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$newline"/>
                </xsl:for-each>

            </xsl:if>

        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>