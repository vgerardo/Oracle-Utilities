    --
    --El archivo se debe subir a directorio del FTP:
    -- /u01/oracle/DEV/inbound/xxcmxcarga/
    -- /u01/oracle/LANDOEA/inbound/xxcmxcarga/


drop table GVP_XML;

creAte table GVP_XML (ID NUMBER(15), MY_XML XMLTYPE);

SELECT * FROM GVP_XML;
DELETE GVP_XML;

-- Cargar un XML 
BEGIN
  --  FOR x in 1 .. 5000 LOOP
        INSERT INTO GVP_XML VALUES ( to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss'), 
                                     XMLType (
                                            BFILENAME ('XXCMX_IN_FILES', 'Shipping Consolidated.xml')
                                                        ,nls_charset_ID ('AL32UTF8')
                                            ) 
                                    );
   -- END LOOP;
   COMMIT;
END;
/

update XXCMX_WMS_UP_INTERFACE_ALL set
payload = (
SELECT 
XMLTransform (
        XMLQuery ('declare default element namespace "http://www.manh.com/ILSNET/Interface"; 
           //Shipment'
           PASSING payload
           RETURNING CONTENT
          ), 
'
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
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>
    
</xsl:stylesheet>
') SIN_NAMESPACE  
FROM GVP_XML
)
where id=518;


SELECT X.id, y.*
FROM GVP_XML X
   , XMLTable (
                XMLNameSpaces ('http://xmlns.oracle.com/apps/otm' AS "otm")
                , '/otm:Transmission/otm:TransmissionHeader'
                Passing x.my_xml
                Columns
                     GLogDate  varchar2(100) path '//otm:TransmissionCreateDt/otm:GLogDate'
                    ,TZId       varchar2(100) path '//otm:TransmissionCreateDt/otm:TZId'
                    ,TZOffset       varchar2(100) path '//otm:TransmissionCreateDt/otm:TZOffset'
        ) as Y
;

