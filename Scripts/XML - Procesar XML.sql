SET SERVEROUTPUT ON 

DECLARE
v_dummy     varchar2(1000);
v_clob      CLOB := EMPTY_CLOB();
v_blob      BLOB;

v_entity        xmlDom.DOMEntity;
v_size          integer := dbms_lob.lobmaxsize;
v_dest_offset   integer := 1;
v_src_offset    integer := 1;
v_blob_csid     number := dbms_lob.default_csid;
v_lang_context  number := dbms_lob.default_lang_ctx;
v_warning       integer;

v_parser        xmlParser.Parser;
v_docto         xmlDom.DOMDocument;
v_nodos_parent  xmlDom.DOMNodeList;
v_nodos_child   xmlDom.DOMNodeList;
v_nodo          xmlDom.DOMNode;
v_nodo_attrs    xmlDom.DOMNamedNodeMap;
v_nodo_attr     xmlDom.DOMNode;

BEGIN
    SELECT file_data
    into v_blob
    FROM FND_LOBS
    WHERE FILE_ID = 3298007
    ;
    
    DBMS_LOB.CreateTemporary(v_clob,true);

    DBMS_LOB.ConvertToClob(
                        v_clob,
                        v_blob,
                        v_size,
                        v_dest_offset,
                        v_src_offset,
                        v_blob_csid,
                        v_lang_context,
                        v_warning
                    );


    BEGIN
    v_parser := DBMS_xmlParser.newparser;
    DBMS_xmlParser.SetValidationMode (v_parser, FALSE);
    DBMS_xmlParser.ParseClob (v_parser, v_clob);
    v_docto := DBMS_xmlParser.getDocument (v_parser);
    -- Se libera el parser que ya no se utiliza    
    exception
        when OTHERS then
        dbms_output.put_line('Erro while parsing!!!!');        
    END;
    
    DBMS_LOB.FreeTemporary (v_clob);
    DBMS_xmlParser.FreeParser (v_parser);
    
    v_nodos_parent := xmlDom.getElementsByTagName(v_docto,'*');
    --v_nodos_parent := xmlDom.getChildrenByTagName ( xmlDom.GetDocumentElement(v_docto), '*');
    v_size := xmlDom.getLength (v_nodos_parent);
    
    dbms_output.put_line (v_size);
    /*
    for i in 0 ..v_size-1 loop
        
        v_nodo := xmlDom.item(v_nodos_parent, i);
        dbms_output.put_line (xmlDom.getNodeName(v_nodo)||' ');

        IF DBMS_XMLDOM.GetNodeType(v_nodo) IN (DBMS_XMLDOM.TEXT_NODE, DBMS_XMLDOM.CDATA_SECTION_NODE) THEN
          v_dummy := v_dummy || DBMS_XMLDOM.GetNodeValue(v_nodo);
          dbms_output.put_line (lpad(' ',5)||v_dummy);
        END IF;
    
        v_nodo_attrs    := xmlDom.getAttributes (v_nodo);        
        for a in 0..xmlDom.getLength(v_nodo_attrs)-1 loop
            v_nodo_attr := xmlDom.item (v_nodo_attrs, a);
            dbms_output.put_line (lpad(' ',5)||xmlDom.getNodeName(v_nodo_attr)||' = '||xmlDom.getNodeValue (v_nodo_attr));
        end loop;

        v_nodos_child   := xmlDom.getChildNodes (v_nodo);
        for c in 0..xmlDom.getLength(v_nodos_child)-1 loop
            v_nodo := xmlDom.item(v_nodos_child, c);            
            v_nodo_attrs    := xmlDom.getAttributes (v_nodo);        
            for a in 0..xmlDom.getLength(v_nodo_attrs)-1 loop
                v_nodo_attr := xmlDom.item (v_nodo_attrs, a);
                dbms_output.put_line (lpad(' ',8)||xmlDom.getNodeName(v_nodo_attr)||' = '||xmlDom.getNodeValue (v_nodo_attr));
            end loop;
        end loop;
        
    end loop;
    */

    --
    -- Lista todos los Nodos Hijos
    --
    v_nodos_child   := DBMS_XSLPROCESSOR.selectNodes (DBMS_xmlDom.MakeNode(v_docto), 
                                                     '//*/cfdi:Conceptos/cfdi:Concepto'
                                                   , 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3"'
                                                    );
    dbms_output.put_line ('Nodos :' || xmlDom.getLength(v_nodos_child));
    for a in 0..xmlDom.getLength(v_nodos_child)-1 loop
        v_nodo_attr := DBMS_XMLDOM.item (v_nodos_child, a);
        dbms_output.put_line (lpad(' ',3)||xmlDom.getNodeName(v_nodo_attr));
        DBMS_XSLPROCESSOR.valueOf (v_nodo_attr,'@Descripcion',v_dummy);
        dbms_output.put_line (lpad(' ',3)||'Nodo Específico: ' || v_dummy);
    end loop;
    
    --
    -- Selecciona solo UN nodo
    --
    v_nodo := DBMS_XSLPROCESSOR.selectSingleNode (DBMS_xmlDom.MakeNode(v_docto), 
                                                  '//*/cfdi:Emisor'                                                  
                                                , 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3"'
                                          );
    v_nodo_attrs    := xmlDom.getAttributes (v_nodo);    
    dbms_output.put_line ('Atributos del Nodo: '||xmlDom.getLength(v_nodo_attrs));            
    for a in 0..xmlDom.getLength(v_nodo_attrs)-1 loop
        v_nodo_attr := xmlDom.item (v_nodo_attrs, a);
        dbms_output.put_line (lpad(' ',8)||xmlDom.getNodeName(v_nodo_attr)||' = '||xmlDom.getNodeValue (v_nodo_attr));
    end loop;
    DBMS_XSLPROCESSOR.valueOf (v_nodo,'@Rfc',v_dummy);
    dbms_output.put_line ('RFC Emisor: '||v_dummy);

    v_nodo := DBMS_XSLPROCESSOR.selectSingleNode (DBMS_xmlDom.MakeNode(v_docto), 
                                                  '//*/cfdi:Complemento/tfd:TimbreFiscalDigital'                                                  
                                                , 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3" 
                                                   xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"'
                                          );
    DBMS_XSLPROCESSOR.valueOf (v_nodo,'@FechaTimbrado',v_dummy);
    dbms_output.put_line ('FechaTimbrado: '||v_dummy);

    DBMS_XSLPROCESSOR.valueOf (v_nodo,'@UUID',v_dummy);
    dbms_output.put_line ('UUID: '||v_dummy);

    v_nodo := DBMS_XSLPROCESSOR.selectSingleNode (DBMS_xmlDom.MakeNode(v_docto), 
                                                  '*'                                                  
                                                , 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3"'
                                          );
    DBMS_XSLPROCESSOR.valueOf (v_nodo,'@Moneda',v_dummy);
    dbms_output.put_line ('Moneda: '||v_dummy);


    xmlDom.FreeDocument(doc => v_docto);
    
end;
/


