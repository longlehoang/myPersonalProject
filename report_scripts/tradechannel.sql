SELECT CodeCategory, CodeValue, CodeDesc, (DeleteFlag - 1)*(-1) Valid, DeleteFlag
FROM SFACodeDesc WHERE CodeCategory IN ('TradeChannel','SubTradeChannel')
AND CountryID = '8'