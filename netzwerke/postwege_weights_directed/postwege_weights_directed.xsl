<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="local-functions" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>

    <xsl:mode on-no-match="shallow-skip"/>

    <!-- this template creates a csv file for network analysis
         containing all mailing routes with weights, directions and coordinates.
         Ein Brief kann heute in mehreren Etappen dokumentiert sein
         (sent -> transmitted -> arrived -> redirected -> delivered -> received);
         jede aufeinanderfolgende Etappe wird als eigene Kante gezählt, nicht nur
         die Strecke vom ersten zum letzten correspAction. -->

    <xsl:variable name="quote" select="'&quot;'"/>
    <xsl:variable name="separator" select="','"/>
    <xsl:variable name="newline" select="'&#xA;'"/>

    <!-- path to edition files -->
    <xsl:variable name="editions"
        select="collection('../../data/editions/?select=L*.xml')"/>

    <!-- path to listplace.xml -->
    <xsl:variable name="listplace"
        select="document('../../data/indices/listplace.xml')"/>

    <!-- Liefert für einen Brief die Kanten (als "vonRef|nachRef") zwischen allen
         aufeinanderfolgenden Stationen seines Postwegs, in Dokumentreihenfolge. -->
    <xsl:function name="local:route-edges" as="xs:string*">
        <xsl:param name="correspDesc" as="element(tei:correspDesc)"/>
        <xsl:variable name="stations"
            select="$correspDesc/tei:correspAction[tei:placeName[1]/@ref]"/>
        <xsl:sequence
            select="
                for $i in 1 to (count($stations) - 1)
                return
                    concat($stations[$i]/tei:placeName[1]/@ref, '|', $stations[$i + 1]/tei:placeName[1]/@ref)"
        />
    </xsl:function>

    <xsl:template match="/">

        <xsl:result-document indent="false"
            href="../../netzwerke/postwege_weights_directed/postwege_weights_directed.csv">

        <xsl:text>Source</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>SourceID</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Lat-Long-Sender</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Target</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>TargetID</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Lat-Long-Receiver</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Type</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Label</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Weight</xsl:text>
        <xsl:value-of select="$newline"/>

        <!-- alle Kanten aller Briefe, jede Etappe einzeln -->
        <xsl:variable name="all-edges" as="xs:string*"
            select="$editions//tei:correspDesc ! local:route-edges(.)"/>

        <xsl:for-each select="distinct-values($all-edges)">

            <xsl:variable name="sendeort-pmb" select="substring-before(., '|')"/>

            <xsl:variable name="sendeort-name"
                select="$listplace//tei:listPlace/tei:place[concat('#', @xml:id) = $sendeort-pmb]/tei:placeName[1]"/>

            <xsl:variable name="empfangsort-pmb" select="substring-after(., '|')"/>

            <xsl:variable name="empfangsort-name"
                select="$listplace//tei:listPlace/tei:place[concat('#', @xml:id) = $empfangsort-pmb]/tei:placeName[1]"/>

            <xsl:variable name="lat-long-sender"
                select="$listplace//tei:listPlace/tei:place[concat('#', @xml:id) = $sendeort-pmb]/tei:location[@type = 'coords']/tei:geo"/>

            <xsl:variable name="lat-long-receiver"
                select="$listplace//tei:listPlace/tei:place[concat('#', @xml:id) = $empfangsort-pmb]/tei:location[@type = 'coords']/tei:geo"/>

            <xsl:variable name="label">
                <xsl:choose>
                    <xsl:when test="$sendeort-name and $empfangsort-name">
                        <xsl:value-of select="concat($sendeort-name, '–', $empfangsort-name)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$sendeort-name and not($empfangsort-name)">
                                <xsl:value-of select="concat($sendeort-name, '–', 'Unbekannt')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$empfangsort-name and not($sendeort-name)">
                                        <xsl:value-of
                                            select="concat('Unbekannt', '–', $empfangsort-name)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when
                                                test="not($sendeort-name) and not($empfangsort-name)">
                                                <xsl:text>Unbekannt–Unbekannt</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- Gewicht: wie oft kommt genau diese Kante (Von-Ort -> Nach-Ort) über alle
                 Briefe und alle Etappen hinweg vor -->
            <xsl:variable name="weight" select="count($all-edges[. = current()])"/>

            <!-- source -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$sendeort-name">
                    <xsl:value-of select="$sendeort-name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unbekannt</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- source id -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$sendeort-pmb">
                    <xsl:value-of select="substring-after($sendeort-pmb, '#pmb')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>nicht vorhanden</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- lat-long-sender -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$lat-long-sender">
                    <xsl:value-of select="$lat-long-sender"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>nicht vorhanden</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- target -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$empfangsort-name">
                    <xsl:value-of select="$empfangsort-name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unbekannt</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- target id -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$empfangsort-pmb">
                    <xsl:value-of select="substring-after($empfangsort-pmb, '#pmb')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>nicht vorhanden</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- lat-long-receiver -->
            <xsl:value-of select="$quote"/>
            <xsl:choose>
                <xsl:when test="$lat-long-receiver">
                    <xsl:value-of select="$lat-long-receiver"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>nicht vorhanden</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- type -->
            <xsl:value-of select="$quote"/>
            <xsl:text>Directed</xsl:text>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- label -->
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$label"/>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$separator"/>

            <!-- weight -->
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$weight"/>
            <xsl:value-of select="$quote"/>
            <xsl:value-of select="$newline"/>

        </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
