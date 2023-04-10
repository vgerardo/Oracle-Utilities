CREATE OR REPLACE PACKAGE SCOTT.EMPLOYEE
AS
   TYPE emp_t IS RECORD(
      empno     emp.empno%TYPE,
      ename     emp.ename%TYPE,
      JOB       emp.JOB%TYPE,
      mgr       emp.mgr%TYPE,
      hiredate  emp.hiredate%TYPE,
      SAL       emp.sal%TYPE,
      comm      emp.comm%TYPE,
      deptno    emp.deptno%TYPE
      );

   -- For SELECT
   TYPE rc_employee IS REF CURSOR 
      RETURN emp_t;
   -- For the DML - a table of records
   TYPE t_employee
      IS TABLE OF emp_t 
      INDEX BY BINARY_INTEGER;
   --
   PROCEDURE emp_select( p_employee IN OUT rc_employee);
   --
   PROCEDURE emp_insert( p_employee IN OUT t_employee);
   --
   PROCEDURE emp_update( p_employee IN OUT t_employee);
   --
   PROCEDURE emp_delete( p_employee IN OUT t_employee);
   --
   PROCEDURE emp_lock( p_employee IN OUT t_employee);
   --
END;
/
