SELECT u.UserCode, u.FirstName +' '+ u.LastName UserName, Date,PlannedCall,TotalCall,CallRate,ComplianceCall,ComplianceRate,OnRouteCall,OffRouteCall,AvgVisitTimeOutlet,AvgVisitTimeDay
 FROM [Biz_SummaryDailyKPI] d JOIN MAS_USER u on d.userid = u.id
