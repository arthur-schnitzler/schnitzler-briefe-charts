<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>
    <xsl:mode on-no-match="shallow-skip"/>

    <!-- this template creates a csv file for network analysis 
         containing all correspondences with the 30 most frequently mentioned institutions in each correspondence with weights and directions -->

    <!-- keys -->
    <xsl:key name="edition-by-org" match="tei:body"
        use="//tei:rs[@type = 'org' and not(ancestor::tei:note[@type = 'textConst']) and not(ancestor::tei:note[@type = 'commentary'])]/@ref"/>
    <xsl:key name="corresp-by-id"
        match="tei:correspContext/tei:ref[@type = 'belongsToCorrespondence']" use="@target"/>

    <!-- path to edition files -->
    <xsl:variable name="editions"
        select="collection('../../../schnitzler/arthur-schnitzler-arbeit/editions/?select=*.xml')"/>

    <!-- path to listorg.xml -->
    <xsl:variable name="listorg"
        select="document('../../../schnitzler/arthur-schnitzler-arbeit/indices/listorg.xml')"/>

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

            <xsl:variable name="orgs">
                <xsl:for-each select="$listorg//tei:org">
                    <!-- normalized names and ids -->
                    <xsl:variable name="org-id" select="concat('#', @xml:id)"/>
                    <xsl:variable name="org-name" select="normalize-space(child::tei:orgName[1])"/>
                    <!-- count institution mentions in bodies -->
                    <xsl:variable name="overallcount"
                        select="count($editions//tei:TEI[key('edition-by-org', $org-id)])"/>
                    <xsl:variable name="corrcount"
                        select="count($editions//tei:TEI[key('corresp-by-id', $korr-id)][key('edition-by-org', $org-id)])"/>
                    <xsl:if test="$corrcount &gt; 0">
                        <org id="{$org-id}" overallcount="{$overallcount}" corrcount="{$corrcount}">
                            <xsl:value-of select="$org-name"/>
                        </org>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- csv for each correspondence that mentions institutions -->

            <xsl:if test="$orgs/*:org">

                <!-- unter/gleich 30 entitäten vorhanden -->
                <xsl:if test="count($orgs/*:org) &lt;= 30">
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_alle.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
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

                <!-- unter 100 entitäten vorhanden -->
                <xsl:if test="count($orgs/*:org) &gt; 30 and count($orgs/*:org) &lt; 100">

                    <!-- alle -->
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_alle.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
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

                    <!-- top 30 -->
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_top30.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
                            <xsl:sort select="@corrcount" order="descending" data-type="number"/>
                            <xsl:if test="position() &lt;= 30">
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
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:result-document>

                </xsl:if>

                <!-- über/gleich 100 entitäten vorhanden -->
                <xsl:if test="count($orgs/*:org) &gt;= 100">

                    <!-- alle -->
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_alle.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
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

                    <!-- top 30 -->
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_top30.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
                            <xsl:sort select="@corrcount" order="descending" data-type="number"/>
                            <xsl:if test="position() &lt;= 30">
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
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:result-document>

                    <!-- top 100 -->
                    <xsl:result-document
                        href="institution_freq_corr_weights_directed_{$korr-id}_top100.csv"
                        method="text">

                        <xsl:text>Source</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>CorrID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Target</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>OrgID</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Overallcount</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Type</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Label</xsl:text>
                        <xsl:value-of select="$separator"/>
                        <xsl:text>Weight</xsl:text>
                        <xsl:value-of select="$newline"/>

                        <xsl:for-each select="$orgs/*:org">
                            <xsl:sort select="@corrcount" order="descending" data-type="number"/>
                            <xsl:if test="position() &lt;= 100">
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
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:result-document>

                </xsl:if>

            </xsl:if>

        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
