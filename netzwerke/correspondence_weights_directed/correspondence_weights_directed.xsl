<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- this template creates a csv file for network analysis 
         containing all correspondences with weights and directions -->
    <xsl:variable name="quote" select="'&quot;'"/>
    <xsl:variable name="separator" select="','"/>
    <xsl:variable name="newline" select="'&#xA;'"/>
    <!-- path to edition files -->
    <xsl:variable name="editions" select="collection('../../data/editions/?select=L*.xml')"/>
    <!-- keys -->
    <xsl:key name="sender" match="tei:correspAction[@type = 'sent']/tei:persName[1]" use="@ref"/>
    <xsl:key name="receiver" match="tei:correspAction[@type = 'received']/tei:persName[1]"
        use="@ref"/>
    <xsl:template match="//tei:listPerson">
        <xsl:result-document indent="false"
            href="../../netzwerke/correspondence_weights_directed/correspondence_weights_directed.csv">
            <xsl:text>Source</xsl:text>
            <xsl:value-of select="$separator"/>
            <xsl:text>Target</xsl:text>
            <xsl:value-of select="$separator"/>
            <xsl:text>ID</xsl:text>
            <xsl:value-of select="$separator"/>
            <xsl:text>Type</xsl:text>
            <xsl:value-of select="$separator"/>
            <xsl:text>Label</xsl:text>
            <xsl:value-of select="$separator"/>
            <xsl:text>Weight</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:for-each select="tei:personGrp[@xml:id != 'correspondence_null' and not(@ana = 'planned')]">
                <xsl:variable name="schnitzler-pmb" select="'#pmb2121'"/>
                <xsl:variable name="schnitzler-name" select="'Arthur Schnitzler'"/>
                <xsl:variable name="other-pmb" select="tei:persName[1]/@ref"/>
                <xsl:variable name="other-name"
                    select="tei:persName[1]/concat(substring-after(., ', '), ' ', substring-before(., ','))"/>
                <xsl:variable name="label-1" select="concat($schnitzler-name, ' an ', $other-name)"/>
                <xsl:variable name="label-2" select="concat($other-name, ' an ', $schnitzler-name)"/>
                <xsl:variable name="weight-1"
                    select="count($editions//tei:TEI[key('receiver', $other-pmb)])"/>
                <xsl:variable name="weight-2"
                    select="count($editions//tei:TEI[key('sender', $other-pmb)])"/>
                <xsl:variable name="correspondence-id" select="substring-after(@xml:id, '_')"/>
                <!-- Schnitzler an Target -->
                <xsl:if test="$weight-1 != 0">
                    <!-- source -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$schnitzler-name"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- target -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$other-name"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- correspondence-id -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$correspondence-id"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- type -->
                    <xsl:value-of select="$quote"/>
                    <xsl:text>Directed</xsl:text>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- label -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$label-1"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- weight -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$weight-1"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$newline"/>
                </xsl:if>
                <!-- Source an Schnitzler -->
                <xsl:if test="$weight-2 != 0">
                    <!-- source -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$other-name"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- target -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$schnitzler-name"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- correspondence-id -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$correspondence-id"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- type -->
                    <xsl:value-of select="$quote"/>
                    <xsl:text>Directed</xsl:text>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- label -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$label-2"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$separator"/>
                    <!-- weight -->
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$weight-2"/>
                    <xsl:value-of select="$quote"/>
                    <xsl:value-of select="$newline"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
