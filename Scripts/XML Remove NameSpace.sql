SET SERVEROUTPUT ON
DECLARE

v_xml xmltype := XMLType ('
<ns:WMWROOT xmlns:ns="http://www.manh.com/ILSNET/Interface" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
             xsi:schemaLocation="http://www.manh.com/ILSNET/Interface">
    <ns:EMPLEADO ns:id="1234" ns:email="gvargas@x.com">GERARDO VARGAS</ns:EMPLEADO>
    <ns:TELEFONO>443-22222</ns:TELEFONO>
</ns:WMWROOT>
');

--
-- XSL Style Sheet
--
v_xslt XMLType := XMLType ('
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="yes" omit-xml-declaration="yes" encoding="utf-8" />
    
    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="">
            
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}" namespace="">
                    <xsl:value-of select="." />
                </xsl:attribute>
            </xsl:for-each>
            
            <xsl:apply-templates select="node()" />
            
        </xsl:element>
    </xsl:template>
    
    <!--xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template-->
    
</xsl:stylesheet>
');
v_new  XMLType;
BEGIN

v_new := v_xml.Transform (v_xslt);

--DBMS_XMLPROCESSOR 

DBMS_OUTPUT.Put_LIne (v_new.getStringVal());

END;
/