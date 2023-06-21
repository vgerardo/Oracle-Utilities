
Select Distinct Variable_Name "TOP_NAME"
,Value "PATH"
From Fnd_Env_Context Fec ,
Fnd_Concurrent_Processes Fcp,
fnd_concurrent_requests fcr
Where 1=1
And Fec.Concurrent_Process_Id=Fcp.Concurrent_Process_Id
And Fec.Concurrent_Process_Id=Fcr.Controlling_Manager
And Fec.Variable_Name like'%APPLCSF%' ;

select *
from Fnd_Env_Context;