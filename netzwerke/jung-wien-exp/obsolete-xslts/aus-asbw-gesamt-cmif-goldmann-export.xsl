<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl">
    
    
    
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:param name="placeName" select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-briefe-data/refs/heads/main/data/indices/listplace.xml')"/>
    <xsl:key name="placeMatch" match="tei:place" use="@xml:id"/>
    
    <!-- Startpunkt: Das root-Element -->
    <xsl:template match="/tei:TEI">
        <!-- Beispielhafter Container im TEI-Format -->
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="descendant::tei:profileDesc/tei:correspDesc[tei:correspContext/tei:ref[@type='belongsToCorrespondence' and @target='correspondence_2167']]"/>
        </xsl:element>
    </xsl:template>
    
    
        <xsl:template match="tei:persName">
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="pmb-ref">
                    <xsl:value-of select="replace(@ref, '#pmb', '')"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
            
        </xsl:template>
        
        <xsl:template match="tei:correspAction">
            <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="@type"/>
                <xsl:apply-templates select="tei:persName"/>
                <xsl:copy-of select="tei:date" copy-namespaces="false"/>
                <xsl:apply-templates select="tei:placeName"/>
            </xsl:element>
        </xsl:template>
    
    <xsl:template match="tei:placeName">
        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="geonames-ref">
                <xsl:value-of select="key('placeMatch', replace(@ref, '#', ''), $placeName)/tei:idno[@subtype='geonames'][1]/replace(substring-after(., 'geonames.org/'), '/', '')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
            
        </xsl:element>
    </xsl:template>
    
    <!-- Transformation jedes row-Elements -->
    <xsl:template match="tei:correspDesc">
        <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="tei:correspAction[@type='sent']"/>
            <xsl:apply-templates select="tei:correspAction[@type='received']"/>
            
        </xsl:element>
    </xsl:template>




</xsl:stylesheet>
