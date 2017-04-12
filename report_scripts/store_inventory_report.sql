select	TOp 10 org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME as mdc_name
		,cc.CHAINS_CODE as mdc_code
		,c.name as customer_name
		,c.code as customer_code
		,p.DESCRIPTION as product
		,convert(char,si.Count_Date,1) as Count_Date
		,sum(isnull(Stock_Front,0)) as Stock_Front_CS
		,sum(isnull(Stock_Back,0)) as Stock_Back_CS
		,sum(isnull(Stock_Room,0)) as Stock_Room_CS
		,SUM(isnull(Stock_Front,0)+isnull(Stock_Back,0)+isnull(Stock_Room,0)) as total_stock
		,SUM(isnull(Stock_Front_EC,0)+isnull(Stock_BACK_EC,0)+isnull(Stock_ROOM_EC,0)) as total_stock_ec
		,users.code userid
		,users.Name usercode
		,sum(isnull(Stock_Front_EA,0)) as Stock_Front_EA
		,sum(isnull(Stock_Back_EA,0)) as Stock_Back_EA
		,sum(isnull(Stock_Room_EA,0)) as Stock_Room_EA
		,SUM(isnull(Stock_Front_EA,0)+isnull(Stock_Back_EA,0)+isnull(Stock_Room_EA,0)) as total_stock_EA
		,SUM(isnull(Total,0)) as total
	from Store_Inventory si inner join Users
		on si.USER_ID=users.User_ID inner join View_PositionOrg org
		on users.User_ID=org.salesRepID inner join PRODUCTS p
		on si.PRODUCT_ID=p.ID inner join customers c
		on si.customer_id=c.id left join CUSTOMER_CHAINS cc
		on c.id=cc.customer_id left join CHAINS
		on cc.CHAINS_ID=CHAINS.id
	where si.Count_Date BETWEEN '31May16' AND '1Jun16'
	group by org.country,org.company,org.salesOrg,org.RegionManager,org.SalesManager
		,org.salesOffice,org.AreaManager,org.TerritorySalesManager
		,cc.CHAINS_NAME,cc.CHAINS_CODE,p.DESCRIPTION,c.name,c.code
		,si.Count_Date,users.User_ID,users.code,Users.Name
	order by si.Count_Date