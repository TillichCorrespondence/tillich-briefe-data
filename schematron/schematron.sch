<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns="http://purl.oclc.org/dsdl/schematron">
    <ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    <pattern id="check-tei-rs-ref">
        <title>Check if @ref starts with "#tillich_" and ends with a number</title>
        
        <!-- Rule to match <tei:rs> element -->
        <rule context="tei:rs">
            
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