<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns="http://purl.oclc.org/dsdl/schematron">
    <ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    <pattern id="check-tei-rs-ref">
        <title>Check if @ref starts with "#tillich_" and ends with a number</title>
        
        <!-- Rule to match <tei:rs> element -->
        <rule context="tei:rs[@type='letter']">
            <assert test="starts-with(@ref, '#L')">
                The @ref attribute must start with '#L'
            </assert>
        </rule>
        
        <rule context="tei:rs[@type='bible']">
            <assert test="matches(@ref, '^[A-Z]|\d')">
                The @ref attribute for rs type @bible must start with a captial letter or with a number
            </assert>
        </rule>
        <rule context="tei:rs[@type='person|place|org|bibl']">
            <!-- Assert that the @ref starts with "#tillich_" and ends with a number -->
            <assert test="starts-with(@ref, '#tillich_')">
                The @ref attribute must start with '#tillich_'
            </assert>
            <assert test="matches(@ref, '\d$')">
                The @ref attribute must end with a number
            </assert>
            
        </rule>
    </pattern>
    
</schema>