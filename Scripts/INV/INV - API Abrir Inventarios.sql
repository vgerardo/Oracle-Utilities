
DECLARE

V_ABRIR_CERRAR              VARCHAR2(10) := 'C';    -- A=ABRIR  C=CERRAR
V_ABRIR_PERIODO             DATE    := TO_DATE ('01-11-2010', 'DD-MM-YYYY');
V_ORG_INV                   NUMBER  := 396;

V_last_scheduled_close_date DATE    := v_abrir_periodo-1;
V_prior_period_open         BOOLEAN;
V_new_acct_period_id        NUMBER    := 0;
V_duplicate_open_period     BOOLEAN;
V_commit_complete           BOOLEAN;
V_return_status             VARCHAR2(200);
v_wip_failed                BOOLEAN;          
v_close_failed              BOOLEAN;
v_download_failed           BOOLEAN;
v_req_id                    number;
v_closing_rowid             rowid;
v_closing_acct_period_id    number;
v_mes_str                   varchar2(10);


BEGIN

v_mes_str := to_char(V_ABRIR_PERIODO, 'MM');

IF  v_mes_str = '01' then
    v_mes_str := 'ENE-';
ELSIF v_mes_str = '02' then
    v_mes_str := 'FEB-';    
ELSIF v_mes_str = '03' then
    v_mes_str := 'MAR-';
ELSIF v_mes_str = '04' then
    v_mes_str := 'ABR-';
ELSIF v_mes_str = '05' then
    v_mes_str := 'MAY-';
ELSIF v_mes_str = '06' then
    v_mes_str := 'JUN-';
ELSIF v_mes_str = '07' then
    v_mes_str := 'JUL-';
ELSIF v_mes_str = '08' then
    v_mes_str := 'AGO-';
ELSIF v_mes_str = '09' then
    v_mes_str := 'SEP-';
ELSIF v_mes_str = '10' then
    v_mes_str := 'OCT-';
ELSIF v_mes_str = '11' then
    v_mes_str := 'NOV-';
ELSIF v_mes_str = '12' then
    v_mes_str := 'DIC-' ;       
END IF;                                

IF V_ABRIR_CERRAR = 'A' THEN

        CST_AccountingPeriod_PUB.Open_Period(   
                  p_api_version               => 1.0,
                  p_org_id                    => V_ORG_INV,
                  p_user_id                   => to_number(1082),
                  p_login_id                  => to_number(1082),
                  p_acct_period_type          => 21,
                  p_org_period_set_name       => 'CMXRI_CAL',
                  p_open_period_name          => v_mes_str || to_char(v_abrir_periodo, 'YY'),
                  p_open_period_year          => TO_CHAR(V_ABRIR_PERIODO, 'YYYY'),
                  p_open_period_num           => TO_CHAR(V_ABRIR_PERIODO,'MM'),
                  x_last_scheduled_close_date => V_last_scheduled_close_date,
                  p_period_end_date           => LAST_DAY (V_ABRIR_PERIODO),
                  x_prior_period_open         => V_prior_period_open,
                  x_new_acct_period_id        => V_new_acct_period_id,
                  x_duplicate_open_period     => V_duplicate_open_period,
                  x_commit_complete           => V_commit_complete,
                  x_return_status             => V_return_status );
                  
ELSIF V_ABRIR_CERRAR = 'C' THEN

    BEGIN
        SELECT rowid, acct_period_id
        INTO v_closing_rowid, v_closing_acct_period_id
        FROM ORG_ACCT_PERIODS
        WHERE period_name like v_mes_str || to_char(v_abrir_periodo, 'YY')
         and organization_id = V_ORG_INV
         ;
        

        IF SQL%FOUND THEN
        
                        
                CST_AccountingPeriod_PUB.Revert_PeriodStatus(
                    p_api_version     => 1.0,
                    p_org_id          => V_ORG_INV,
                    x_acct_period_id  => v_closing_acct_period_id,
                    x_revert_complete => V_commit_complete,
                    x_return_status   => V_return_status );
                          
        
        
            /*CST_AccountingPeriod_PUB.Close_Period(
                    p_api_version            => 1.0,
                    p_org_id                 => V_ORG_INV,
                    p_user_id                => to_number(1082),
                    p_login_id               => to_number(1082),
                    p_closing_acct_period_id => v_closing_acct_period_id,
                    p_period_close_date      => LAST_DAY(V_ABRIR_PERIODO),
                    p_schedule_close_date    => last_day(V_ABRIR_PERIODO)+1,
                    p_closing_rowid          => v_closing_rowid,
                    x_wip_failed             => v_wip_failed,
                    x_close_failed           => v_close_failed,
                    x_download_failed        => v_download_failed,
                    x_req_id                 => v_req_id,
                    x_return_status          => V_return_status
                  ) ;*/    

        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;        

END IF;
        
COMMIT;

END;