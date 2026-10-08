<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title>ISO Schematron rules</title>
   <!-- This file generated 2026-10-01T09:28:55Z by 'extract-isosch.xsl'. -->
   <!-- ********************* -->
   <!-- namespaces, declared: -->
   <!-- ********************* -->
   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
   <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
   <ns prefix="rna" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
   <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
   <ns prefix="sch1x" uri="http://www.ascc.net/xml/schematron"/>
   <!-- ******************************************************* -->
   <!-- constraints in en, und, mul, zxx, of which there are 34 -->
   <!-- ******************************************************* -->
   <pattern id="schematron-constraint-CMC_generatedBy_within_post-1">
      <rule context="tei:*[@generatedBy]">
         <assert test="ancestor-or-self::tei:post">The @generatedBy attribute is for use within a &lt;post&gt; element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-when-2">
      <rule context="tei:*[@when]">
         <report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-from-3">
      <rule context="tei:*[@from]">
         <report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-to-4">
      <rule context="tei:*[@to]">
         <report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-only_1_ODD_source-5">
      <rule context="tei:*[@source]">
         <let name="srcs" value="tokenize( normalize-space(@source),' ')"/>
         <report test="(   self::tei:classRef                                 | self::tei:dataRef                                 | self::tei:elementRef                                 | self::tei:macroRef                                 | self::tei:moduleRef                                 | self::tei:schemaSpec )                                   and                                   $srcs[2]"> When used on a schema description element (like &lt;<value-of select="name(.)"/>&gt;), the @source attribute should have only 1 value. (This one has <value-of select="count($srcs)"/>.)</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-targetLang-6">
      <rule context="tei:*[not(self::tei:schemaSpec)][@targetLang]">
         <assert test="@target">@targetLang should only be used on &lt;<name/>&gt; if @target is specified.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-spanTo-points-to-following-7">
      <rule context="tei:*[ starts-with( @spanTo, '#') ]">
         <assert test="id( substring( @spanTo, 2 ) ) &gt;&gt; ."> The element indicated by @spanTo (<value-of select="@spanTo"/>) must follow the current &lt;<name/>&gt; element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-subtypeTyped-8">
      <rule context="tei:*[@subtype]">
         <assert test="@type"> The &lt;<name/>&gt; element should not be categorized in detail with @subtype unless also categorized in general with @type.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-calendar_attr_on_empty_element-9">
      <rule context="tei:*[@calendar]">
         <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more systems or calendars to which the date represented by the content of this element belongs, but this &lt;<name/>&gt; element has no textual content.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-p-in-ab-or-p-10">
      <rule context="tei:p">
         <report test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )"> Abstract model violation: Paragraphs may not occur inside other paragraphs or &lt;ab&gt; elements.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-p-in-l-11">
      <rule context="tei:l//tei:p">
         <assert test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note"> Abstract model violation: Metrical lines (&lt;l&gt; elements) may not contain higher-level structural elements such as &lt;div&gt;, &lt;p&gt;, or &lt;ab&gt;, unless &lt;p&gt; is a child of &lt;figure&gt; or &lt;note&gt;, or is a descendant of &lt;floatingText&gt;.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-ptrAtts-12">
      <rule context="tei:ptr">
         <report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on &lt;<name/>&gt;.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-gloss-list-must-have-labels-13">
      <rule context="tei:list[@type='gloss']">
         <assert test="tei:label"> The content of a "gloss" list should include a sequence of one or more pairs of a &lt;label&gt; element followed by an &lt;item&gt; element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-l-in-l-14">
      <rule context="tei:l">
         <report test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">Abstract model violation: Metrical lines (&lt;l&gt; elements) may not contain &lt;l&gt; or &lt;lg&gt; elements.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-atleast1oflggapl-15">
      <rule context="tei:lg">
         <assert test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An &lt;lg&gt; element must contain at least one child &lt;l&gt;, &lt;lg&gt;, or &lt;gap&gt; element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-lg-in-l-16">
      <rule context="tei:lg">
         <report test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">Abstract model violation: Lines may not contain line groups.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-div-in-l-17">
      <rule context="tei:l//tei:div">
         <assert test="ancestor::tei:floatingText"> Abstract model violation: Metrical lines (&lt;l&gt; elements) may not contain higher-level structural elements such as &lt;div&gt;, unless &lt;div&gt; is a descendant of &lt;floatingText&gt;.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-div-in-ab-or-p-18">
      <rule context="tei:div">
         <report test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)"> Abstract model violation: &lt;p&gt; and &lt;ab&gt; may not contain higher-level structural elements such as &lt;div&gt;, unless &lt;div&gt; is a descendant of &lt;floatingText&gt;.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-substContents1-19">
      <rule context="tei:subst">
         <assert test="child::tei:add and (child::tei:del or child::tei:surplus)"> &lt;<name/>&gt; must have at least one child &lt;add&gt; and at least one child &lt;del&gt; or &lt;surplus&gt;.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-one_ms_singleton_max-20">
      <rule context="tei:msContents|tei:physDesc|tei:history|tei:additional">
         <let name="gi" value="name(.)"/>
         <report test="preceding-sibling::*[ name(.) eq $gi ]                           and                           not( following-sibling::*[ name(.) eq $gi ] )"> Only one &lt;<name/>&gt; is allowed as a child of &lt;<value-of select="name(..)"/>&gt;.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-msId_minimal-21">
      <rule context="tei:msIdentifier">
         <report test="not( parent::tei:msPart )                           and                           ( child::*[1]/self::idno  or  child::*[1]/self::altIdentifier  or  normalize-space(.) eq '')">An &lt;msIdentifier&gt; must contain either a &lt;repository&gt; or &lt;location&gt;.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-check_note_seg-22">
      <rule context="tei:rs[@type='letter|postcard']">
         <assert test="starts-with(@ref, 'L')"> The @ref attribute must start with 'L'</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-check_note_seg-23">
      <rule context="tei:rs[@type='bible']">
         <assert test="matches(@ref, '^[A-Z]|\d')"> The @ref attribute for rs type @bible must start with a captial letter or with a number</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-check_note_seg-24">
      <rule context="tei:rs[@type='person|place|org|bibl']">
         <assert test="starts-with(@ref, '#tillich_')"> The @ref attribute must start with '#tillich_'</assert>
         <assert test="matches(@ref, '\d$')"> The @ref attribute must end with a number</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-teiHeader-profileDesc-25">
      <rule context="tei:teiHeader">
         <assert test="tei:profileDesc"> A teiHeader must contain a profileDesc.</assert>
      </rule>
   </pattern>
</schema>
