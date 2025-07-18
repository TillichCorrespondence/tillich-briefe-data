<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:s="http://purl.oclc.org/dsdl/schematron"
    exclude-result-prefixes="tei">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!-- Root template -->
    <xsl:template match="/">
        <s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron"
                  xmlns:tei="http://www.tei-c.org/ns/1.0"
                  queryBinding="xslt2">
            
            <!-- Add title and description -->
            <s:title>Schematron rules extracted from Tillich-Briefe ODD</s:title>
            <s:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
            
            <!-- Extract all constraintSpec elements with schematron scheme -->
            <xsl:apply-templates select="//tei:constraintSpec[@scheme='schematron']"/>
            
        </s:schema>
    </xsl:template>
    
    <!-- Template for constraintSpec elements -->
    <xsl:template match="tei:constraintSpec[@scheme='schematron']">
        <!-- Create a pattern for each constraintSpec -->
        <s:pattern id="{@ident}">
            <xsl:if test="tei:desc">
                <s:title><xsl:value-of select="tei:desc"/></s:title>
            </xsl:if>
            
            <!-- Process the constraint content -->
            <xsl:apply-templates select="tei:constraint/s:rule"/>
        </s:pattern>
    </xsl:template>
    
    <!-- Template for Schematron rules -->
    <xsl:template match="s:rule">
        <s:rule context="{@context}">
            <xsl:apply-templates select="s:assert | s:report"/>
        </s:rule>
    </xsl:template>
    
    <!-- Template for Schematron assertions -->
    <xsl:template match="s:assert">
        <s:assert test="{@test}">
            <xsl:value-of select="normalize-space(.)"/>
        </s:assert>
    </xsl:template>
    
    <!-- Template for Schematron reports -->
    <xsl:template match="s:report">
        <s:report test="{@test}">
            <xsl:value-of select="normalize-space(.)"/>
        </s:report>
    </xsl:template>
    
</xsl:stylesheet>
