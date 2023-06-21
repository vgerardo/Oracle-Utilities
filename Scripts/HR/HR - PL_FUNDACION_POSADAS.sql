DECLARE
CURSOR emp_asig IS
 SELECT ppf.PERSON_ID, ppf.EMPLOYEE_NUMBER, ppf.FULL_NAME, pas.ASSIGNMENT_ID, PPF.ATTRIBUTE2, pad.ADDRESS_LINE1,
        pad.ADDRESS_LINE2, pad.ADDRESS_LINE3, pad.POSTAL_CODE
 FROM   per_all_people_f ppf, per_all_assignments_f pas, pay_all_payrolLs_f pyf, per_addresses pad
 WHERE  PPF.PERSON_TYPE_ID = 120
 AND    PPF.EFFECTIVE_END_DATE = TO_DATE('4712/12/31','YYYY/MM/DD')
 AND    PPF.PERSON_ID = PAD.PERSON_ID(+)
 AND    PPF.PERSON_ID = PAS.PERSON_ID
-- AND    PPF.EMPLOYEE_NUMBER = 5531
 AND    PAS.EFFECTIVE_END_DATE = TO_DATE('4712/12/31','YYYY/MM/DD')
 AND    PAS.PAYROLL_ID = PYF.PAYROLL_ID
 AND    PYF.PAYROLL_NAME LIKE '%&v_payroll%'
 ORDER BY 2;
 v_fecha_fin DATE;
 x NUMBER ;
 v_payroll VARCHAR2(30);
 v_saldo VARCHAR(50);
 v_dimension VARCHAR2(15);

BEGIN
 FOR emas IN emp_asig LOOP
  dbms_session.set_nls('NLS_LANGUAGE','AMERICAN');
  dbms_session.set_nls('NLS_TERRITORY','AMERICA');
  hr_session_utilities.insert_session_row(SYSDATE);
  x := balance_fetch_A  (emas.ASSIGNMENT_ID, '&v_saldo' ,'&v_dimension',  '&v_fecha_fin', '');
  INSERT INTO CSA_HR_BALANCES_TEMP (emp_number, emp_name, pay_bal_nam, pay_bal_val, pay_bal_date, pay_bal_frc, pay_bal_address )
  VALUES ( emas.EMPLOYEE_NUMBER, emas.FULL_NAME, '&v_saldo' ||'&v_dimension', x, '&v_fecha_fin', emas.attribute2, emas.ADDRESS_LINE1||' '||emas.ADDRESS_LINE2||' '||emas.ADDRESS_LINE3||' '||emas.POSTAL_CODE );
 END LOOP;
END;


CREATE TABLE CSA_HR_BALANCES_TEMP
  (emp_number  VARCHAR2(30),
   emp_name    VARCHAR2(240),
   pay_bal_nam VARCHAR2(240),
   pay_bal_val NUMBER(10),
   pay_bal_date DATE)

select * from CSA_HR_BALANCES_TEMP
ORDER BY 4

delete CSA_HR_BALANCES_TEMP

commit
