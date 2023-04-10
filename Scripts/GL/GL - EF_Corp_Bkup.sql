

INSERT INTO bolinf.csa_ef_corp_reps_bkup
    SELECT SYSDATE,
           grupo,
           id_rep,
           orden,
           nombre,
           visible,
           tipo,
           miles,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
    FROM   csa_ef_corp_reps;
commit;


INSERT INTO bolinf.csa_ef_corp_cncpt_bkup
    SELECT SYSDATE,
           id_rep,
           id_cnc,
           orden,
           nombre,
           tipo,
           visible,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
    FROM   bolinf.csa_ef_corp_cncpt;
commit;

INSERT INTO bolinf.csa_ef_corp_cntas_bkup
    SELECT SYSDATE,
           id_rep,
           id_cnc,
           oprdor,
           cia,
           cc,
           cuenta,
           subcta,
           intrco,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
    FROM   bolinf.csa_ef_corp_cntas;
commit;

INSERT INTO bolinf.csa_ef_corp_rfrnc_bkup
    SELECT SYSDATE,
           id_rep,
           id_cnc,
           oprdor,
           ref_rep,
           ref_cnc,
           ref_cia,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
    FROM   bolinf.csa_ef_corp_rfrnc ;    
commit;    
    

INSERT INTO bolinf.CSA_EF_CORP_EXCPC_bkup
    SELECT SYSDATE,
            ID_REP,
            CNCPTO,
            SI_VAR,
            OPRDOR,
            CIA,
            CC,
            CUENTA,
            SUBCTA,
            INTRCO,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
     FROM bolinf.csa_ef_corp_excpc;

commit;
    

select * from bolinf.csa_ef_corp_reps_bkup
where TO_CHAR(fecha_bkup,'DDMMYY') ='050210'
AND ID_REP = 101

select * 
from bolinf.csa_ef_corp_cncpt_bkup
where TO_CHAR(fecha_bkup,'DDMMYY') ='050210'
AND ID_REP = 101

select count(*) from bolinf.csa_ef_corp_cntas_bkup
where fecha_bkup > sysdate-.3 ;

select count(*) from bolinf.csa_ef_corp_rfrnc_bkup
where fecha_bkup > sysdate-.3 ;

