<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>

    <!-- CSV variables -->
    <xsl:variable name="quote" select="'&quot;'"/>
    <xsl:variable name="separator" select="','"/>
    <xsl:variable name="newline" select="'&#xA;'"/>

    <xsl:template match="/">
        <!-- Group by correspondence -->
        <xsl:for-each-group select="//tei:correspDesc[tei:correspContext/tei:ref[@type='belongsToCorrespondence']]"
            group-by="tei:correspContext/tei:ref[@type='belongsToCorrespondence']/@target">

            <xsl:variable name="korr-id" select="current-grouping-key()"/>
            <xsl:variable name="korr-name" select="tei:correspContext/tei:ref[@type='belongsToCorrespondence'][1]"/>

            <!-- Skip correspondence_null and planned -->
            <xsl:if test="$korr-id != 'correspondence_null'">

                <!-- Collect all mentioned persons in this correspondence -->
                <xsl:variable name="mentioned-persons">
                    <xsl:for-each-group select="current-group()//tei:note/tei:ref[@type='https://lod.academy/cmif/vocab/terms#mentionsPerson']"
                        group-by="@target">
                        <xsl:variable name="pers-id" select="current-grouping-key()"/>
                        <xsl:variable name="exclude-ref" select="concat('pmb', substring-after($korr-id, '_'))"/>

                        <!-- Exclude correspondence partner -->
                        <xsl:if test="$pers-id != $exclude-ref">
                            <xsl:variable name="count" select="count(current-group())"/>
                            <xsl:variable name="pers-name" select="normalize-space(current-group()[1])"/>
                            <person id="{$pers-id}" count="{$count}">
                                <xsl:value-of select="$pers-name"/>
                            </person>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:variable>

                <!-- Only create CSV if there are persons -->
                <xsl:if test="$mentioned-persons/person">
                    <xsl:variable name="total-persons" select="count($mentioned-persons/person)"/>

                    <!-- Determine file suffix based on count -->
                    <xsl:variable name="suffix">
                        <xsl:choose>
                            <xsl:when test="$total-persons &gt; 100">_top100</xsl:when>
                            <xsl:when test="$total-persons &gt; 30">_top30</xsl:when>
                            <xsl:otherwise>_alle</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- Create CSV file -->
                    <xsl:result-document href="../../netzwerke/person_freq_corr_weights_directed/person_freq_corr_weights_directed_{$korr-id}{$suffix}.csv">
                        <xsl:text>Source,Target,Weight,Type&#10;</xsl:text>

                        <!-- Sort by count descending and take top N -->
                        <xsl:variable name="limit">
                            <xsl:choose>
                                <xsl:when test="$total-persons &gt; 100">100</xsl:when>
                                <xsl:when test="$total-persons &gt; 30">30</xsl:when>
                                <xsl:otherwise><xsl:value-of select="$total-persons"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:for-each select="$mentioned-persons/person">
                            <xsl:sort select="@count" data-type="number" order="descending"/>
                            <xsl:if test="position() &lt;= $limit">
                                <xsl:value-of select="concat($quote, $korr-name, $quote, $separator)"/>
                                <xsl:value-of select="concat($quote, normalize-space(.), $quote, $separator)"/>
                                <xsl:value-of select="concat(@count, $separator)"/>
                                <xsl:text>Directed</xsl:text>
                                <xsl:value-of select="$newline"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:result-document>
                </xsl:if>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
