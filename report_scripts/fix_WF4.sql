select * from wf_taskhead where pARAMETERVALUE in (select convert(VARCHAR,id) from cUSTOMERS WHERE CODE = '0090038485')
select * from wf_taskdetail where TASKHEADid = '7CEC5A4B-DF67-4AE4-9286-2F566843C1D3'
select * from users where id = 5027