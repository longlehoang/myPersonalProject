execute as login = 'sa'
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'CCVN4 Reporting',
    @recipients = 'knandarkyaw@coca-cola.com.mm; pkhaing@coca-cola.com.mm',
    @query = 
'SET NOCOUNT ON; 
SELECT oh.Order_Date, oh.Order_No, ''0090032412'' as Distributor_Code,p.* FROM [10.0.0.6].CCVN4.dbo.PICK_LIST p
JOIN [10.0.0.6].CCVN4.dbo.order_headers oh ON p.id = oh.pick_list_id 
WHERE p.CHAIN_ID = 1718
ORDER BY 1,2,3
SET NOCOUNT OFF;' ,
    @subject = 'New MLP (U Naung Naung Han- 90032412) pickslip daily report',
       @body = 
'Hi all,
       
Please see attached pickslip report for new MLP (U Naung Naung Han- 90032412) today.
       
Regards,
Minh',
	   @attach_query_result_as_file = 1,
       @query_attachment_filename = 'PickSlip_0090032412.csv',
       @query_result_separator = '	',
       @query_result_no_padding= 1,
       @query_result_width= 10000,
       @exclude_query_output =1
revert