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

            <!-- Skip correspondence_null -->
            <xsl:if test="$korr-id != 'correspondence_null'">

                <!-- Collect all mentioned places in this correspondence -->
                <xsl:variable name="mentioned-places">
                    <xsl:for-each-group select="current-group()//tei:note/tei:ref[@type='https://lod.academy/cmif/vocab/terms#mentionsPlace']"
                        group-by="@target">
                        <xsl:variable name="count" select="count(current-group())"/>
                        <xsl:variable name="place-name" select="normalize-space(current-group()[1])"/>
                        <place id="{current-grouping-key()}" count="{$count}">
                            <xsl:value-of select="$place-name"/>
                        </place>
                    </xsl:for-each-group>
                </xsl:variable>

                <!-- Only create CSV if there are places -->
                <xsl:if test="$mentioned-places/place">
                    <xsl:variable name="total-places" select="count($mentioned-places/place)"/>

                    <!-- Determine file suffix based on count -->
                    <xsl:variable name="suffix">
                        <xsl:choose>
                            <xsl:when test="$total-places &gt; 100">_top100</xsl:when>
                            <xsl:when test="$total-places &gt; 30">_top30</xsl:when>
                            <xsl:otherwise>_alle</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- Create CSV file -->
                    <xsl:result-document href="../../netzwerke/place_freq_corr_weights_directed/place_freq_corr_weights_directed_{$korr-id}{$suffix}.csv">
                        <xsl:text>Source,Target,Weight,Type&#10;</xsl:text>

                        <!-- Sort by count descending and take top N -->
                        <xsl:variable name="limit">
                            <xsl:choose>
                                <xsl:when test="$total-places &gt; 100">100</xsl:when>
                                <xsl:when test="$total-places &gt; 30">30</xsl:when>
                                <xsl:otherwise><xsl:value-of select="$total-places"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:for-each select="$mentioned-places/place">
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
