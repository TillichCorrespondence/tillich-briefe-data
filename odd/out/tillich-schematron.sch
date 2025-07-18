<?xml version="1.0" encoding="UTF-8"?>
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <s:title>Schematron rules extracted from Tillich-Briefe ODD</s:title>
   <s:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <s:pattern id="check_note_seg">
      <s:rule context="tei:rs[@type='letter']">
         <s:assert test="starts-with(@ref, 'L')">The @ref attribute must start with 'L'</s:assert>
      </s:rule>
      <s:rule context="tei:rs[@type='bible']">
         <s:assert test="matches(@ref, '^[A-Z]|\d')">The @ref attribute for rs type @bible must start with a captial letter or with a number</s:assert>
      </s:rule>
      <s:rule context="tei:rs[@type='person|place|org|bibl']">
         <s:assert test="starts-with(@ref, '#tillich_')">The @ref attribute must start with '#tillich_'</s:assert>
         <s:assert test="matches(@ref, '\d$')">The @ref attribute must end with a number</s:assert>
      </s:rule>
   </s:pattern>
</s:schema>
