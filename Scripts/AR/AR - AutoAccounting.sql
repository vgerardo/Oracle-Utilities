--
-- Crea la Combinación contable, en base a la configuración de AutoAccounting en AR
-- Los parametros de entrada son: ORGANIZACIÓN, TIPO DE TRANSACCION, CLIENTE, MEMOLINE
--
SET SERVEROUTPUT ON

DECLARE

p_org_name  varchar2(50) := 'POS_OU_GPO';
p_trx_type  varchar2(50) := 'GPO_FAC';
p_customer  varchar2(50) := 'FFIMOC';
p_memoline  varchar2(50) := 'HONORARIOS_ADMINISTRACION';

--
-- AutoAccounting
--
CURSOR C_AutoAccounting (p_org_name varchar2, p_type varchar2)
IS
    SELECT
        org_id,
        gl_default_id,
        type
    FROM ra_account_defaults_ALL
    WHERE 1=1
      and type = p_type -- REC, REV, TAX, etc
      and org_id  IN (
                SELECT organization_id
                FROM hr_operating_units
                WHERE   name LIKE p_org_name --'POS_OU_GPO'                
            )    
    ;

CURSOR C_Segments (p_default_id number)
IS
    SELECT
        gl_default_id,
        segment_num,
        segment,
        table_name,
        constant
    FROM ra_account_default_segments
    WHERE   gl_default_id = p_default_id --1002    
    ORDER BY segment_num
    ;

FUNCTION Obtiene_Segmento (p_org_id number, p_type varchar2, p_tabla varchar2, p_segment_num number) RETURN varchar2
IS
v_cta_id    number(15);
v_valor     VARCHAR2(10);
BEGIN

    IF p_tabla = 'RA_CUST_TRX_TYPES' THEN

            SELECT DECODE (p_type, 'REV', typ.gl_id_rev,
                                   'REC', typ.gl_id_rec)                                
            INTO v_cta_id
            FROM RA_CUST_TRX_TYPES_ALL typ
            WHERE 1=1
              and name = p_trx_type; -- 'GPO_FAC'
              
    ELSIF p_tabla = 'RA_SITE_USES' THEN

        SELECT DECODE (p_type, 'REV', uses.gl_id_rev,
                               'REC', uses.gl_id_rec) 
        into v_cta_id
        from hz_cust_accounts       cust,
             hz_cust_acct_sites_all site,
             hz_cust_site_uses_all  uses            
        where 1=1  
          and cust.cust_account_id = site.cust_account_id
          and site.cust_acct_site_id = uses.cust_acct_site_id
          and site.org_id = uses.org_id          
          and site.org_id = p_org_id
          and cust.account_number = p_customer --'FFIMTV'
          ;
        
    ELSIF p_tabla = 'RA_STD_TRX_LINES' THEN
        
        SELECT DECODE (p_type, 'REV', b.gl_id_rev,
                               'REC', 0) -- no existe REC no no lo jalle :)                                
        INTO v_cta_id
        FROM AR_MEMO_LINES_ALL_TL   tl,
             AR_MEMO_LINES_ALL_B    b
        WHERE 1=1
         and tl.memo_line_id = b.memo_line_id
         and tl.language = 'ESA'
         and tl.NAME = p_memoline --'HONORARIOS_ADMINISTRACION'
         ;     
        
    END IF;              


    SELECT decode (p_segment_num, 1, gcc.segment1,
                                  2, gcc.segment2,
                                  3, gcc.segment3,
                                  4, gcc.segment4,
                                  5, gcc.segment5,
                                  6, gcc.segment6,
                                  7, gcc.segment7,
                                  8, gcc.segment8
                                  )
    INTO v_valor
    FROM GL_CODE_COMBINATIONS   gcc
    WHERE gcc.code_combination_id = v_cta_id; 

    return v_valor;

END;

    
BEGIN

    DBMS_OUTPUT.PUT_LINE ('INICIO');

    -- obtiene cuenta de REVenue
    FOR c1 IN C_AutoAccounting (p_org_name, 'REV' )LOOP        
        DBMS_OUTPUT.PUT_LINE ('Combinación REVenue: ');
        FOR c2 IN C_Segments (c1.gl_default_id) LOOP
            -- Obtiene Segmento
            DBMS_OUTPUT.PUT ( Obtiene_Segmento (c1.org_id, c1.type, c2.table_name, c2.segment_num) ||'.' );
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE ('');

end;
/
