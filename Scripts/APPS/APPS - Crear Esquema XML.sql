--
-- Crear un ESQUEMA en ORACLE
--
-- 1. Crear el directorio xml_outnom en el incoming del FTP de Prod r12 de Oracle
--
           mkdir /interface/GRPEBSP/incoming/xml_outnom
--           
-- 2. Crear directorio lógico en Base Datos (if exists, please drop it and create again with apps):
--
           CREATE DIRECTORY XML_OUTNOM AS '/interface/GRPEBSP/incoming/xml_outnom';
--           
-- 3. Otorgar permisos de Lectura (ó escritura) a BOLINF
--
           GRANT READ ON DIRECTORY XML_OUTNOM TO BOLINF;
--           
-- 4. Create the next schema:
--
    BEGIN          
        DBMS_XMLSCHEMA.REGISTERSCHEMA (
                        schemaurl => 'http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd',                        
                        schemadoc => BFILENAME ('XML_OUTNOM', 'cfdv32.xsd'));          
    END;
    