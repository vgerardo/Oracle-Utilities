SET SERVEROUTPUT ON
declare

    v_xml     xmltype := xmltype ('<EMPLEADOS>
                                     <NOMBRE>gerardo vargas</NOMBRE>
                                     <PARAMETRO/>
                                     <DIRECCION>golfo de panama 29 lomas lindas</DIRECCION>
                                  </EMPLEADOS>');

    doc       xmldom.DOMDocument;
    v_parent  xmldom.DOMNode;
    v_nodo    xmldom.DOMNode;
    v_list    xmldom.DOMNodeList;
    v_element xmldom.DOMElement;
    cdata     xmldom.DOMCDataSection;
    v_clob    clob;

begin

    doc     := xmldom.newDomDocument (v_xml);
   
    xmldom.setVersion (doc, '1.0');
    
    --v_parent    := xmldom.makeNode (doc);
   
    v_element   := xmldom.getDocumentElement (doc);                         --Elemento Raiz
    v_list      := xmldom.getElementsByTagName (v_element, 'PARAMETRO');
    v_nodo      := xmldom.item (v_list, 0);
    
    --v_element   := xmldom.createElement (doc, 'PARAMETRO');
    --v_nodo      := xmldom.appendChild (v_parent, xmldom.makeNode (v_element));

    cdata   := xmldom.createCDataSection (doc, 'contents of cdatasection');

    v_nodo := xmldom.appendChild (v_nodo, xmldom.makenode( cdata ) );

    dbms_lob.createtemporary (v_clob, false);
    xmldom.writeToClob (doc,v_clob);
    dbms_output.put_line( v_clob );


    xmldom.freeDocument(doc);

end;
/