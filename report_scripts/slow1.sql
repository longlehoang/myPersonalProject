  select DISTINCT visits.ID  VisitId
        ,org.Name OrgName
		,users.code as RepCode
		,person.Name as RepName	
		,customers.Code	as CustomerCode
		,customers.Name as CustomerName
		,convert(varchar(10),visits.START_TIME ,120) as VisitDate
		,isNull(normalCooler.ctsCount,0) NormalCount
		,isNull(abnormalCooler.ctsCount,0) AbnormalCount
        ,isNull(normalCooler.ctsCount,0)+isNull(abnormalCooler.ctsCount,0) as totleCount
         from Users users
	         inner join PERSONS person on person.ID=users.ID
             inner join ORGANIZATION org on org.ID=users.org_ID
	         inner join VISITS visits on users.ID=visits.user_Id
	         inner join CUSTOMERS customers on customers.Id=visits.CUSTOMER_ID
	         left join (select count(GUID) ctsCount,Visit_ID  from CTS_Result where IS_Normal = 1 group by Visit_ID) normalCooler on normalCooler.Visit_ID=visits.ID 
	         left join (select count(GUID) ctsCount,Visit_ID  from CTS_Result where IS_Normal = 0 group by Visit_ID) abnormalCooler on abnormalCooler.Visit_ID=visits.ID 
             inner join (select  GUID,RFID,Exception_Lvl,Reason_Code,Visit_ID,scan_time from CTS_Result )  cts_result on  cts_result.Visit_ID=visits.ID 
             inner join (SELECT MAX(Visit_ID) VisitId,Customer_ID from CTS_Result group by Customer_ID ,CONVERT(varchar(10),Scan_Time,120)  ) C2  on  C2.VisitId=visits.ID
             
where 1=1   AND (users.org_id In ('1','8','144','155','179','156','157','158','159','160','161','185','186','192','167','187','181','174','170','171','173','175','176','177','178','168','169','172','180','162','163','164','165','166','145','146','147','148','149','150','151','35','142','143','54','55','56','136','137','138','182','190','191','183','184','189','141','140','188','139','82','154','81','153','80','152'))  AND visits.START_TIME>='2016-04-27' AND visits.START_TIME<'2016-04-28'