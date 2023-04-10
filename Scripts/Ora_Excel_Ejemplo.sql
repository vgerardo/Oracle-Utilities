

declare

v_file_blob			blob; 
doc_id PLS_INTEGER;
sheet_id PLS_INTEGER;
row_id PLS_INTEGER;
v_col_str  varchar2(3);

type t_header is varray(12) of bolinf.GRP_INV_MAC_TYPE_CLMNA;-- index by BINARY_INTEGER;
v_header    t_header  := t_header(
                              bolinf.GRP_INV_MAC_TYPE_CLMNA('Articulo', 25, 'N', '')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Descripcion ( Inidcar si es artículos Corporativo o CAPEX, hasta 150 carácteres)', 60, 'N','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Presentación del producto', 20, 'S', '')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Precio por',12,'S','') 
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Moneda',12,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Precio Actual',12,'S','')              
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Nuevo Precio',12,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Tiempo de entrega (Máximo número de días )',12,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Razon social',60,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Pedido minimo',12,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Especificaciones ( precio por, flete, etc.)',100,'S','')
                             ,bolinf.GRP_INV_MAC_TYPE_CLMNA('Hotel(es)',20,'S','') 
                        );


begin
	
    /*
	SELECT file_data
    into v_file_blob
	FROM fnd_lobs
	WHERE file_id = 2985204    
    ;*/

    ORA_EXCEL.new_document;
    ORA_EXCEL.add_sheet('Modificaciones');

    -- Header columns style
    ORA_EXCEL.add_style(style_name  => 'Header',
                        border      => TRUE,
                        border_style => 'thin',
                        border_color => '000000',
                        vertical_align  => 'middle',
                        horizontal_align => 'left',
                        color       => 'FFFFFF',
                        bg_color    => '178ED2' --Azul turquesa
                        );


    -- Header columns style
    ORA_EXCEL.add_style(style_name  => 'ReadOnly',
                        border      => TRUE,                        
                        border_style => 'thin',
                        border_color => 'B5B5B5',                        
                        --vertical_align  => 'middle',
                        --horizontal_align => 'center',
                        --color       => 'FFFFFF',
                        bg_color    => 'F8F8F8' -- gris clara 
                        ); 

    ORA_EXCEL.add_row;                                              --linea 1
    ORA_EXCEL.add_row;                                              --linea 2
    ORA_EXCEL.set_row_height(30);
    ORA_EXCEL.set_cell_value('A', 'DIRECCION DE COMPRAS');          
    ORA_EXCEL.set_cell_font('A', 'Calibri', 22);
    ORA_EXCEL.set_cell_bold('A');    
    ORA_EXCEL.merge_cells('A', 'M');
    ORA_EXCEL.set_cell_align_center('A');
    ORA_EXCEL.set_cell_vert_align_middle('A');
        
    ORA_EXCEL.add_row;                                              --linea 3
    ORA_EXCEL.add_row;                                              --linea 4
    ORA_EXCEL.set_row_height(20);    
    ORA_EXCEL.set_cell_value('A', 'Cambio de Información');
    ORA_EXCEL.set_cell_font('A', 'Calibri', 18);
    ORA_EXCEL.set_cell_bold('A');
    ORA_EXCEL.merge_cells('A', 'M');
    ORA_EXCEL.set_cell_align_center('A');
    
    ORA_EXCEL.add_row;                                              --linea 5
    
    ORA_EXCEL.add_row;                                              --linea 6        
    FOR c IN 1..v_header.count LOOP
        v_col_str := ORA_EXCEL.column_number_to_column_name(c);
        ORA_EXCEL.set_cell_value(v_col_str, v_header(c).nombre);        
        ORA_EXCEL.set_column_width(v_col_str, v_header(c).ancho);
        ORA_EXCEL.set_cell_style(v_col_str, 'Header');        
    END LOOP;

    -- aqui irian los Datos
    FOR r in 1..1000 LOOP
        ORA_EXCEL.add_row;                                              --linea 7..1007      
        FOR c IN 1..v_header.count LOOP
            v_col_str := ORA_EXCEL.column_number_to_column_name(c);
            ORA_EXCEL.set_column_width(v_col_str, v_header(c).ancho);
            
            if v_header(c).editable = 'S' then
                ORA_EXCEL.set_cell_unlocked(v_col_str); -- Set cell protection flag as unlocked
            else
                ORA_EXCEL.set_cell_style(v_col_str, 'ReadOnly');
            end if;        
        END LOOP;
    END LOOP;

    ORA_EXCEL.protect_sheet(protect_password => 'posadas',-- Unlock password, 10 chars max, a-z A-Z 0-9
                            protect_format_cells => TRUE, -- Disable cells formatting
                            protect_format_columns => TRUE, -- Disable columns formatting
                            protect_format_rows => TRUE, -- Disable rows formatting
                            protect_insert_columns => TRUE, -- Disalbe columns insert
                            protect_insert_rows => TRUE, -- Disable rows insert
                            protect_insert_hyperlinks => TRUE, -- Disable hyperlinks insert
                            protect_delete_columns => TRUE, -- Disable delete comments
                            protect_delete_rows => TRUE, -- Disable delete rows
                            protect_auto_filter => TRUE, -- Disable auto filter
                            protect_pivot_tables => TRUE, -- Disable pivot tables
                            protect_sort => TRUE, -- Disable sort
                            protect_objects => TRUE, -- Disable objects editing
                            protect_scenarios => TRUE, -- Disable scenarios editing
                            protect_select_locked_cells => FALSE, -- Allow locked cells selection
                            protect_select_unlock_cells => FALSE -- Allod unlocked cells selection
                    );
    
    ORA_EXCEL.save_to_file('GRP_OUTGOING', 'My_First_Excel.xlsx');
    --ORA_EXCEL.save_to_blob(my_blob);
  
end;
