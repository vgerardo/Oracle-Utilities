SET SERVEROUTPUT ON
declare

v_xml   xmltype := xmltype ('
                            <SOBRE>
                                <PARAMETRO/>
                            </SOBRE>
                        ');

v_datos     xmltype := xmltype ('<EMPLEADOS>
                                 <NOMBRE>gerardo vargas</NOMBRE>
                                 <DIRECCION>golfo de panama 29 lomas lindas</DIRECCION>
                              </EMPLEADOS>');


doc       xmldom.DOMDocument; 
v_parent  xmldom.DOMNode;
v_nodo    xmldom.DOMNode;
v_list    xmldom.DOMNodeList;
v_element xmldom.DOMElement;
v_cdata   xmldom.DOMCDataSection;
v_clob    clob;

begin

    doc     := xmldom.newDomDocument (v_xml);
    --xmldom.setVersion (doc, '1.0');
    --v_parent    := xmldom.makeNode (doc);
    v_element   := xmldom.getDocumentElement (doc);                         --Elemento Raiz
    
    v_list      := xmldom.getElementsByTagName (v_element, 'PARAMETRO');
    v_nodo      := xmldom.item (v_list, 0);                                 --La lista empieza desde el indice CERO.
    
    --v_element   := xmldom.createElement (doc, 'PARAMETRO');
    --v_nodo      := xmldom.appendChild (v_parent, xmldom.makeNode (v_element));

    v_cdata   := xmldom.createCDataSection (doc, v_datos.getClobVal());
    v_nodo := xmldom.appendChild (v_nodo, xmldom.makenode( v_cdata ) );

    --Solo para visualizar el XML en el OUTPUT
    Dbms_Lob.createtemporary (v_clob, false);
    xmldom.writeToClob (doc,v_clob);
    DBMS_OUTPUT.put_line ( v_clob );

    xmldom.freeDocument (doc);

end;
/