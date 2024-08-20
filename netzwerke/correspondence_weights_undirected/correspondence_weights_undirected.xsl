<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:csv="csv:csv"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text" encoding="utf-8"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- this template creates a csv file for network analysis 
         containing all correspondences with weights -->
    <xsl:variable name="quote" select="'&quot;'"/>
    <xsl:variable name="separator" select="','"/>
    <xsl:variable name="newline" select="'&#xA;'"/>
    <xsl:variable name="source">
        <xsl:text>Arthur Schnitzler</xsl:text>
    </xsl:variable>
    <!-- path to edition files -->
    <xsl:variable name="editions" select="collection('../../data/editions/?select=L*.xml')"/>
    <!-- key -->
    <xsl:key name="correspKey" match="tei:correspContext/tei:ref[@type = 'belongsToCorrespondence']"
        use="@target"/>
    <xsl:template match="//tei:listPerson">
        <xsl:result-document indent="false"
            href="../../netzwerke/correspondence_weights_undirected/correspondence_weights_undirected.csv">
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
            <xsl:for-each select="child::tei:personGrp[@xml:id != 'correspondence_null']">
                <xsl:variable name="target"
                    select="concat(substring-after(child::tei:persName[@role = 'main'], ', '), ' ', substring-before(child::tei:persName[@role = 'main'], ','))"/>
                <xsl:variable name="label" select="$target"/>
                <xsl:variable name="corresp-id" select="@xml:id"/>
                <xsl:variable name="target-id" select="substring-after(@xml:id, '_')"/>
                <xsl:variable name="weight"
                    select="count($editions//tei:TEI[key('correspKey', $corresp-id)])"/>
                <!-- source -->
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$source"/>
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$separator"/>
                <!-- target -->
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$target"/>
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$separator"/>
                <!-- target-id -->
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$target-id"/>
                <xsl:value-of select="$quote"/>
                <xsl:value-of select="$separator"/>
                <!-- type -->
                <xsl:value-of select="$quote"/>
                <xsl:text>Undirected</xsl:text>
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
