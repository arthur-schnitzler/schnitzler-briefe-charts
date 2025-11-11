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

                <!-- Collect all mentioned works in this correspondence -->
                <xsl:variable name="mentioned-works">
                    <xsl:for-each-group select="current-group()//tei:note/tei:ref[@type='https://lod.academy/cmif/vocab/terms#mentionsBibl']"
                        group-by="@target">
                        <xsl:variable name="count" select="count(current-group())"/>
                        <xsl:variable name="work-name" select="normalize-space(current-group()[1])"/>
                        <work id="{current-grouping-key()}" count="{$count}">
                            <xsl:value-of select="$work-name"/>
                        </work>
                    </xsl:for-each-group>
                </xsl:variable>

                <!-- Only create CSV if there are works -->
                <xsl:if test="$mentioned-works/work">
                    <xsl:variable name="total-works" select="count($mentioned-works/work)"/>

                    <!-- Always create _alle.csv with all entities -->
                    <xsl:result-document href="../../netzwerke/work_freq_corr_weights_directed/work_freq_corr_weights_directed_{$korr-id}_alle.csv">
                        <xsl:text>Source,Target,Weight,Type&#10;</xsl:text>
                        <xsl:for-each select="$mentioned-works/work">
                            <xsl:sort select="@count" data-type="number" order="descending"/>
                            <xsl:value-of select="concat($quote, $korr-name, $quote, $separator)"/>
                            <xsl:value-of select="concat($quote, normalize-space(.), $quote, $separator)"/>
                            <xsl:value-of select="concat(@count, $separator)"/>
                            <xsl:text>Directed</xsl:text>
                            <xsl:value-of select="$newline"/>
                        </xsl:for-each>
                    </xsl:result-document>

                    <!-- Create _top30.csv if more than 30 works -->
                    <xsl:if test="$total-works &gt; 30">
                        <xsl:result-document href="../../netzwerke/work_freq_corr_weights_directed/work_freq_corr_weights_directed_{$korr-id}_top30.csv">
                            <xsl:text>Source,Target,Weight,Type&#10;</xsl:text>
                            <xsl:for-each select="$mentioned-works/work">
                                <xsl:sort select="@count" data-type="number" order="descending"/>
                                <xsl:if test="position() &lt;= 30">
                                    <xsl:value-of select="concat($quote, $korr-name, $quote, $separator)"/>
                                    <xsl:value-of select="concat($quote, normalize-space(.), $quote, $separator)"/>
                                    <xsl:value-of select="concat(@count, $separator)"/>
                                    <xsl:text>Directed</xsl:text>
                                    <xsl:value-of select="$newline"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:result-document>
                    </xsl:if>

                    <!-- Create _top100.csv if more than 100 works -->
                    <xsl:if test="$total-works &gt; 100">
                        <xsl:result-document href="../../netzwerke/work_freq_corr_weights_directed/work_freq_corr_weights_directed_{$korr-id}_top100.csv">
                            <xsl:text>Source,Target,Weight,Type&#10;</xsl:text>
                            <xsl:for-each select="$mentioned-works/work">
                                <xsl:sort select="@count" data-type="number" order="descending"/>
                                <xsl:if test="position() &lt;= 100">
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
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
