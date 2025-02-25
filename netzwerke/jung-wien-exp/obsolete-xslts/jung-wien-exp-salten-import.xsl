<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Startpunkt: Das root-Element -->
    <xsl:template match="/root">
        <!-- Beispielhafter Container im TEI-Format -->
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="row"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Transformation jedes row-Elements -->
    <xsl:template match="row[not(descendant::*[contains(., 'Gertrude')])]">
        <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>sent</xsl:text>
                </xsl:attribute>
                <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="pmb-ref">
                        <xsl:choose>
                            <xsl:when test="contains(Absender, 'Bahr')">
                                <xsl:text>10815</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Absender, 'Beer')">
                                <xsl:text>10863</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Absender, 'Hofmannsthal')">
                                <xsl:text>11740</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Absender, 'Goldmann')">
                                <xsl:text>11485</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Absender, 'Salten')">
                                <xsl:text>2167</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Absender, 'Schnitzler')">
                                <xsl:text>2121</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="Absender"/>
                </xsl:element>
                <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="date">
                    <xsl:attribute name="when">
                        <xsl:value-of select="replace(date-iso, 'T00:00:00', '')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>received</xsl:text>
                </xsl:attribute>
                <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="pmb-ref">
                        <xsl:choose>
                            <xsl:when test="contains(Empfänger, 'Bahr')">
                                <xsl:text>10815</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Empfänger, 'Beer')">
                                <xsl:text>10863</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Empfänger, 'Hofmannsthal')">
                                <xsl:text>11740</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Empfänger, 'Goldmann')">
                                <xsl:text>11485</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Empfänger, 'Salten')">
                                <xsl:text>2167</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(Empfänger, 'Schnitzler')">
                                <xsl:text>2121</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="Empfänger"/>
                </xsl:element>
                
            </xsl:element>
        </xsl:element>
    </xsl:template>




</xsl:stylesheet>
