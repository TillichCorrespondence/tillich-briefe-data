<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Match outermost rs[@type="person"] with nested rs -->
    <xsl:template match="tei:rs[@type='person'][.//tei:rs[@type='person']][not(parent::tei:rs[@type='person'])]">
        <rs type="person" xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="ref">
                <xsl:value-of select="string-join(descendant-or-self::tei:rs[@type='person']/@ref, ' ')"/>
            </xsl:attribute>
            <xsl:value-of select=".//tei:rs[@type='person'][not(.//tei:rs[@type='person'])]"/>
        </rs>
    </xsl:template>
    
    <!-- Suppress nested rs elements -->
    <xsl:template match="tei:rs[@type='person'][ancestor::tei:rs[@type='person']]"/>
    
</xsl:stylesheet>