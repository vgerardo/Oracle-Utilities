CREATE OR REPLACE PACKAGE BODY SCOTT.employee AS

   PROCEDURE emp_select( p_employee IN OUT rc_employee) IS
   BEGIN
      -- This can be more complex and include conditional
      -- logic to select from one source or another.
      OPEN p_employee
      FOR
         SELECT empno, 
                ename,
                JOB, 
                mgr,
                hiredate, 
                sal,
                comm,
                deptno
         FROM   scott.emp;
   END emp_select;

   PROCEDURE emp_insert( p_employee IN OUT t_employee) IS

   BEGIN
      FOR i IN 1 .. p_employee.count
      LOOP
         -- Straight INSERT - No pre checks.
         -- If duplicates, the standard DUP_VAL_ON_INDEX exception
         -- will automatically be raised.
         INSERT INTO scott.emp (
               empno
              ,ename
              ,JOB
              ,mgr
              ,hiredate
              ,sal
              ,comm
              ,deptno)
         VALUES (
              p_employee(i).empno
             ,p_employee(i).ename
             ,p_employee(i).JOB
             ,p_employee(i).mgr
             ,p_employee(i).hiredate
             ,p_employee(i).sal
             ,p_employee(i).comm
             ,p_employee(i).deptno 
         );
      END LOOP;
   END emp_insert;

   PROCEDURE emp_update ( p_employee IN OUT t_employee ) IS
   BEGIN
      FOR i IN 1..p_employee.count LOOP
         -- Again, no prechecks are done here.  
         -- All unhandled errors will propogate.
         UPDATE scott.emp 
            SET ename = p_employee(i).ename
               ,JOB = p_employee(i).JOB
               ,mgr = p_employee(i).mgr
               ,hiredate = p_employee(i).hiredate
               ,sal = p_employee(i).sal
               ,comm = p_employee(i).comm
               ,deptno = p_employee(i).deptno
          WHERE empno = p_employee(i).empno;
           
      END LOOP;
   END emp_update;
   
   PROCEDURE emp_delete ( p_employee IN OUT t_employee ) IS
   BEGIN
      FOR i IN 1..p_employee.count LOOP
         -- Again, no prechecks are done here.  
         -- All unhandled errors will propogate.
         DELETE FROM scott.emp 
          WHERE empno = p_employee(i).empno;
           
      END LOOP;
   END emp_delete;

   PROCEDURE emp_lock( p_employee IN OUT t_employee) IS
      v_empno    emp.empno%TYPE;
   BEGIN
      FOR v_ct IN 1 .. p_employee.count
      LOOP
         SELECT empno
         INTO   v_empno
         FROM   scott.emp
         WHERE  empno = p_employee(v_ct).empno
         FOR UPDATE;
      END LOOP;
   END emp_lock;

END employee;
/
