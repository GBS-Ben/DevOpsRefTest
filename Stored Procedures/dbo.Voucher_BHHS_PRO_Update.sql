﻿CREATE PROCEDURE [dbo].[Voucher_BHHS_PRO_Update]
AS

	-- ;WITH VoucherCTE
	-- AS
	-- (
 --		SELECT 
	--		[sVoucherUseID],
	--		[sVoucherID],
	--		[sVoucherCode],
	--		[sVoucherAmountApplied],
	--		[vDateTime],
	--		o.*
	--		FROM [dbo].[tblOrderview]  o 
	--		INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	--		LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId

	--		)
	--, AgentCte
	--AS
	--(
	--SELECT DISTINCT op.orderID AS OrderId,  AgentName FROM dbo.tblOrders_Products op WHERE AgentName IS NOT NULL
	--)

	-- UPDATE o 
	--  SET  [Used] = CASE WHEN [Used] = 1 THEN 1
	--				WHEN OrderNo IS NOT NULL THEN 1
	--				ELSE 0
	--				END
	--	  ,[Order No] = ISNULL(o.[Order No], vo.Orderno)
	--	  ,[Order Date] = ISNULL( o.[Order Date],  vo.OrderDate)
	--	  ,[Ship To] = ISNULL([Ship To], Shipping_FirstName + ISNULL(' ' + NULLIF(Shipping_Surname,''),''))
	--	  ,[Ship To City] = ISNULL( o.[Ship To City],  vo.shipping_Suburb )
	--	  ,[Ship To State] = ISNULL( o.[Ship To State],vo.shipping_State )
	--	  ,[Agent]  = ISNULL([Agent], (SELECT TOP 1 AgentName FROM AgentCte op WHERE op.orderID = vo.OrderId ))
	--  FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_EWM_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS EWM$]') o
	-- LEFT JOIN VoucherCTE vo 
	--		ON vo.[sVoucherCode] = o.[Voucher Code]


		
	-- ;WITH VoucherCTE
	-- AS
	-- (
 --		SELECT 
	--		[sVoucherUseID],
	--		[sVoucherID],
	--		[sVoucherCode],
	--		[sVoucherAmountApplied],
	--		[vDateTime],
	--		o.*
	--		FROM [dbo].[tblOrderview]  o 
	--		INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	--		LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	--		)
	-- UPDATE o 
	--  SET  [Order Status] =  ISNULL(o.[Order Status], 
	--				CASE  vo.OrderStatus WHEN  'Delivered' THEN 'Delivered'
	--					WHEN  	'Cancelled' THEN 'Cancelled' 
	--					WHEN  'In Production' THEN 'In Production' 
	--					WHEN  'In Transit' THEN 'In Transit' 
	--					WHEN  'In Transit USPS' THEN 'In Transit' 
	--					WHEN  'On HOM Dock' THEN 'On HOM Dock' 
	--				END)
	--  FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_EWM_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS EWM$]') o
	-- LEFT JOIN VoucherCTE vo 
	--		ON vo.[sVoucherCode] = o.[Voucher Code]

	--;WITH VoucherCTE
	--		AS
	--(
	--			SELECT sVoucherCode 
	--			FROM [gbsCore].[dbo].[tblVouchersSalesUse] v 
	--			WHERE sVoucherCode IN ('NHK1HJ71CZC','NHKQL1C8MN6','NHKQ0RA9KBD','NHK9JQF83CB','NHK7H1GUCAE','NHKWKFP3M17','NHKV98M4KME','NHKCWHHR5VF','NHKD7YP4ZBL','NHKYGWU2FDJ','NHKNJC30R3A','NHKPUT9LKHF','NHK95SCJ3KD','NHKQS308MSF','NHKZU1HT0WD','NHKG6ZNRRYC','NHK2EYSQ9ZA','NHK14PQR7MJ','NHKJCNVPNNG','NHKSFL5BASF','NHK94V1ZV2G','NHK8RMY1SPQ','NHKPEWTNCWR','NHKYHU3012Q','NHKD65ZYK0S','NHKCTVVZGW2','NHKUG7SL363','NHKKJL1UBUT','NHKK8DWV0G3','NHKJV6UW76A','NHK1JEQKRDC','NHKWKHEAR9P','NHKD9SAZAGR','NHKWQWU6P3E','NHKCC7RS90G','NHK3MRC0FG1','NHKJA29W1Q2','NHK3R6T4D0Q','NHKFTRFF2QV','NHKFDQRD9FU','NHKY31M2TPW','NHKU44ASTJ9','NHK472JDFN8','NHKJTAF22W9','NHKFVC5S2RL','NHKYHN1EL1M','NHK7LK9294L','NHKM0V6PTBM','NHKLWM3QQ1V','NHKHZPRGQU9','NHK1M1M5A40','NHK9PYVQY79','NHKQC8RDHE0','NHKMD0F5H0M','NHK43KBS3HN','NHK8V53SV2U','NHK7JV1TSP4','NHK4KZNKTJE','NHKK99K8CSF','NHKJW1G00EP','NHK0ZFPGK5G','NHK9M9MHHSQ','NHKNNT0V68U','NHKMBK7W3V4','NHKJCNVN3QF','NHK0E53VCE8','NHK4KDEM6G0','NHKK9PB0PPA','NHKJWF9AMCJ','NHK8C88919E','NHK72Z50WWN','NHKNN92YG6P','NHKMB2YZDTY','NHK41AUMZ2Z','NHK0FJTYPB3','NHK95ARZL1A','NHKQSLMM79B','NHKPECKN4WK','NHKEHTSVDKB','NHKD7KQYA9K','NHKVTULKVGM','NHKUGLJLS6V','NHKB6WE0CCW','NHKK8TNV2GV','NHKZ0EA9NW2','NHKVAHZZNRC','NHKSBKNPNMP','NHKSWSV5MH3','NHKRKJT6J7B','NHK89TPT5EC','NHK50WCJ50P','NHK5YNAL2YY','NHKWMSR59EL','NHKUL4SRJCP','NHKKNJ1ZU3F','NHK8AFC65F4','NHK5BH2V5BE','NHK6T6JP6FW','NHK5FWGQ356','NHKBQ23SWWG','NHK82GUB9KV','NHKED752153','NHKV62QAH5Z','NHKA42QTYMN','NHKP873SHUN','NHKL6P2WKY6','NHKUB9WCFYK','NHKR0QVGH22','NHKKEFYKFHL','NHK3175L41R','NHKQJHR6DMH','NHKYP2QD1HC','NHKL9CCYB64','NHKH7UB3C9K','NHK7Q71LPVA','NHKEVQV3KWR','NHK3E3HLWJG','NHKQYD76979','NHK8H4FZJHT','NHKYP4CTSZF','NHK7UM80PZV','NHKTDZVT1MM','NHKBVVHHM2Y','NHK1E863ZPN','NHKNZJTL0BE','NHKV53P37BU','NHKJNDBLGZL','NHKGLWAQJ43','NHKPRE0Z6ZW','NHKCARWHFLN','NHK1U4K3S9D','NHKNCE9L5V6','NHK6Y6EMQCA','NHKTGG37313','NHK3MZ2EMVV','NHKP7BNZZHM','NHKU0CHJWMJ','NHKHTP64800','NHK7C2TMJW2','NHKUVCG7VJR','NHKBF3Q18VB','NHK3M3MUFBZ','NHKJKSQTU26','NHKLRN8JQQE','NHKTY831LRV','NHKGFJQJYDL','NHKQM3NSJ0F','NHKC6DBBUW8','NHKA5WAFW1N','NHKZM9Z19ME','NHK574K68UY','NHKFLZ2ZMBL','NHKDJG14PE3','NHK5PGWYYVP','NHK09BH5W49','NHKYRN7N8QZ','NHKLA1U8JDQ','NHK4VP41VPA','NHKRE2RJ7C2','NHKDYCE4H1S','NHK3GP3MUMH','NHK92JNTTU3','NHK6Z3MYUYH','NHKTGDAG7K0','NHKG2QZ2H91','NHKG344N3PR','NHKD1K3S4S9','NHK3JWPBEFZ','NHKQ49CVR4Q','NHKVL4Z3QA9','NHKJ6FML2Y1','NHKF4YLQ42F','NHK5M000EN8','NHK075Y74R6','NHKYQFLQEDV','NHKVNYKUFGC','NHK4TGFBBGS','NHKRCT4VN6J','NHK261AD7T0','NHKRA289E0Y','NHK9VRD02Q4','NHK2NFKE81M','NHK8800BV3K','NHKUQLWV8PB','NHKUAS6A7LP','NHK1UMRG6T8','NHKQ1NNBD0V','NHKY67LJ16P','NHKLPH04ASF','NHKL0PGH0NT','NHKTE9CZ6P0','NHKGZK2HGB1','NHKP54ZR48U','NHKCNEMADUK','NHKC9LUQDRZ','NHKM2UZG7KA','NHKV7BWPSF6','NHKNSWE4JTH','NHKB9NESMJS','NHKPNKTUC72','FVBEDK','HD2CTH','FMG0KJ','RT6BGC','DR4E5P','0DT93M','JQTZ1C','A1NBJK','6SQRQQ','K4C2UA','MJEJJB','QWTR99','P1YW00','EE52JH','TZQALJ','9FNBF5','F1N4CW','958P84','FSTYJU','NCTR6R','9M2KG6','CV52G2','JKEH4U','3F5K3B','Q0JKHG','E1B78R','FMH55Q','TD4MDB','Z0QUQ7','ZA8L2B','59GBT6','9A9241','HHY20P','410JHQ','918HJK','ESBRDC','23KKQR','N41NV4','62B2TQ','7QCQYN','UPZ3U2','8DV4PN','RUENR3','LMG8D3','KQLDF3','B6SGQA','YAPKCN','UR6KTW','3B6AQP','D02KPB','34A6WM','SNS2VW','VZJQ49','17L734','9JMW1T','08ML5S','PLY88G','5WJHB3','PC43DF','RRG04C','N8Y7UF','WMKBH3','S7NQQ6','8NLRJQ','GU0RRE','2CGNS1','ZMZKJ2','C6KUNN','9VZ1KR','B43FKM','4FGDD6','UQBRYC','R54EEE','7FQPK1','0VS993','B06EYY','KRGWKP','9KYRJ2','VPVU7D','S70WDA','BS696R','5WNU1Y','AJA4CQ','0Q5KDW','SDN6EC','72WWZZ','ECWNWP','8MR2FW','L23KSW','2BPUWF','LS9EZV','P6LLNS','ENF3Y7','WNEUMN','QLU1HU','53R2CE','D0F2K6','ZSM1CE','W24W5F','LLKS5Q','8WTLF5','0H7S63','2UPHNE','3HQ7TD','ZYHUAF','D955E1','SP5TLK','V4H2AF','U7N7CG','KLTAMQ','Z6ENFF','487CPA','K7BE7T','MP3CLR','KZH0CS','J5AU6N','DTP14S','H3RF3N','RDR8ZD','2N5H60','VE8YBD','ART8FZ','V8CSHC','ZKRZ80','P3MBPZ','EGSFZ7','3MPJLJ','F5MKF6','NNMACY','98U8DG','7FA56J','V2SZ6S','GA1SG7','CYQLE6','LAQCBV','AYWFL7','9BN549','NNAD8S','Q4BYVU','TGQ5KR','SKVAMR','FCC6L4','BWFJT7','9ETSJJ','HLGSR9','K57Q76','HCNMY8','QYMFJ5','B9V0VH','EFYQVD','PTYFS5','Y40VQN','VG3J8R','J8U5W2','U98DDQ','V1WBSP','LGRR24','CWWVAB','9F10HE','CJR1S0','E567EM','6L1JZW','C0MSAP','TEWBP8','EQ663L','0CWV9U','JPWM6K','AZR1PS','6RUDVY','K3FN2H','NHG0F0','QVVG66','ZD8ZSW','PTC436','TYS5A6','7S2VUT','F1QV2H','HHETFF','FRVR8G','NA162U','0K91C9','DTAFB4','KJLYZW','L8ML4U','2LW97K','FWJHB5','2C44DJ','4RG04E','KU4GHT','A00LS3','7TB116','JNLRJT','TU0RQH','CCGNR3','28S0ZD','RS95YN','MGN0UR','9P0LPK','G30BLA','7PEFVL','UP2SSY','JETDG8','LUVW60','ET4T0F','WQKLGY','DRKD7E','Z0S9HV','56DLAJ','NR9W4Z','7FL9CF','NHES0Y','B03ZQD','VYLJRU','9KUABF','SB2CTY','07PESE','Y23KR1','5YHJBT','LRCU4A','P5R3S8','729UZP','WMKAQ5','S7NPW8','7NLQRS','GU0QZG','GRAE4G','7EENTL','MKQ886','8VY2KJ','B42GJE','4FJ84S','55JV8Q','ZVM0DV','D89KHE','J020QP','LMEFEL','KQJMGL','B6QRRU','SB1CVH','US4TUF','DDY5LV','FWM32S','V6K278','BBVKLQ','82APHU','A9C6GQ','HZNM5J','R92ZAD','PMTMSF','5YEWW2','NDZGZE','0Q19FE','FLMGS9','72SK3G','T6PNPU','8MMPJE','1TUNCS','3CJLRP','YZA99T','MJS584','9U2YKG','5GRRHE','CTRGE6','54LUZC','2GCHFF','ZTHR8M','GMC3Z5','K1R0N2','H4VEQ3','0H3J1A','N3NT3B','3JLUVW','04LLSP','BMAJ8L','0VRFZM','GFR0KJ','4Q14YY','8Z3JWT','DNC2HM','6Y8D4U','KCG4Y0','040PMJ','K5MY59','MG26T5','D1UK4H','3SBF3U','YBEU9Y','62VTTP','7N6BGW','ZSPYB5','7EB7PV','KZYFSH','60706V','2VY1A6','A9YR9V','3HR5S4','ZWJS06','BLGT4S','D3HEJJ','GEWL9F','QW84V8','FBC86F','KGS9DF','WB22Y5','8HQ25T','03EZJQ','8AVVAS','EUWL6Z','266EGC','3RHM7B','B4HD43','CSJ391','R7TNBP','7GFZF0','RY1JHN','UACQ8K','RSUMZN','18GSM0','VRK7TC','09H8NY','JE78VM','5YD5W8','1K7SCB','FQGASV','AEVFPZ','ENYWPU','9K0GPK','Y8FKZV','UM89FZ','AYUHKH','CDV39K','FR09YF','N0LQK8','C33LJJ','Z81N7W','VNDQDU','E00370','8DSN1F','E3EWC9','TL27GU','WVSZEV','0H2R1G','JU2GW8','A5VUFE','QH7DSE','485EM3','Q0C91D','SNQFPA','ZJCN25','YJVEB0','T4ZTJC','9KVUCY','HRKUKN','3ARUCY','1J8R6Z','NG1BTB','9S977P','C1AM6K','5BTBPZ','62U1TW','3ELNAZ','E5JP5L','1K4072','KZWNSP','J33TUQ','0G8Y5Z','72ABB3','T4K18J','03R3P3','BLF14Z','0UWWV2','Q18F0J','BAFAMY','8Y74KW','DNGK7P','6YBYQY','4B5L81','1M9UZ8','APL5FV','NF7LQH','TBSU3B','KRZZBK','WGPQD8','4CBYNF','56VM0E','E4QV04','APHJQ8','H0GCB5','U6JV5R','G7ZZ94','G5SDK4','9DMR6A','47Q6BF','AW1SD5','LYD3VS','YQYJ6E','MEWEMP','VUKGJK','QR1MER','DM4ZU3','DELNG3','FZALWZ','W6E3G4','MQVYFC','GEA3CG','J2N03E','HZHPDE','S9V2KA','PMMN3C','DCE0RM','PDSH9B','Q6HGMA','FMA1NE','73F5YM','4MJH5R','8PA8DL','0ANGSN','3D85MV','7E64NQ','MLFM49','9WPFEM','5HG4U7','CUGURW','65B8A5','3H4VS7','E82WMT','GN4EAV','K2FM1S','SJS5MH','JZY8WR','N5BBWG','3K0CR3','0605NU','BNZ33S','0WFZUT','GGESFQ','4SNLS5','81Q3R1','FCQTPQ','Z37PQE','TT04WK','06VC26','TLEY4J','WZT5SF','C3G0F5','3UY5EE','YD2HMJ','BVZJG5','M4NJNT','99JSS1','5UAE96','K2LZNN','EQ15KS','2YLJ7A','A0L042','3JFMM9','ZY8A5B','BM6BZZ','E49SVA','GFLZK7','QZYF8Y','GD4KG7','LHHLQ7','YCRD0U','GZMP2A','046BVG','GQSJ89','EWK526','ZK5P3L','B8CGL8','KJC8JY','CT8K46','R8G87V','7J5GBE','PCZS4W','SQC1ST','29NGDK','18AUW6','WRD959','A9B0YU','HSB1UL','KB2Y0J','1K1TN9','Q6GNMG','BEPHZV','ENSZZR','MC4FKK','63L64V','3FCTKY','GS14PG','38JNRW','MLET4F','LPK16F','AG3U5S','7269AV','A4WZKQ','CPA684','E814M2','CFF1D3','R14AHN','LPGEES','8W3U2A','G03LY2','9JWZG9','6YPLZB','40SYG9','K4M99Q','NF2FYM','WZCYKC','MDH3UL','RHY44L','71V5Y8','F7J56W','HQ03JT','YZ679M','LYYRW1','797L0D','KUECT1','T8E4QQ','4FSEWK','1VJ4DM','CKG580','Y12P0P','2DEVZK','GG24EZ','8W88P8','5FALVA','HY8MQV','QG8CMN','02E0N8','80W7E0','YUC2EJ','J5LVRW','6B88LQ','B3HP8J','5BC3RR','2Q6Q0T','QFYAZ5','HGTH3E','LV8QRB','TCH8D4','H613CD','DQ4FKG','2SB88P','KD7H15','CHQ6TB','K6CD74','ZPZN0Q','31PF9R','EMZ8TC','PZZZQ4','F9SB0A','VK8JKF','906KD4','TQP6FG','MPW2KN','5LDTS6','C23WN2','1711AD','DMW16Z','L8WR2R','EBFDVY','51KML4','TK2HLB','6F42C1','J4BSWL','QSN0JD','132LP0','7VZKR3','L7KUWM','W9Y5CA','R13HHV','FP2C16','5GG8ZG','22KL6K','PWPYKV','8PQLTG','HMLUT6','8FVF1F','NM71E1','FQWV27','BBMPZ6','A0F5A6','4JAGVC','1Y45CE','W08D4M','R5W0QS','SVM86R','QZRC7S','GDYGF2','LJ0R16','128SUQ','JM34L7','05WG6F','GSJPG8','EYC8HD','29K2VS','DUUSED','N8UJB5','WG7Y0P','R99CFU','8KVMLD','R2E8NT','UDTDCP','KVMUL4','3WLMAL','VU2S8S','0AYT2C','KHMT93','51VMHW','30BJ0Z','SUTD08','C528LL','EQEEAK','73Y5TY','8RZTZV','56QFFY','JFCRKH','MWDC10','MN4AE9','LR9FF0','C7DKQH','9QGZYL','VSRMT4','EDLZLJ','EAMMQJ','CJ4KGK','SPD4W5','7CETLB','AKH0L7','JYH1HW','9KN5S8','6ZFR00','4AK21G','NQ5K3W','R5HSRS','ZLT0DJ','82FE26','U7DHNH','9NAHH4','F8A0EV','HR28TS','Y1148G','NKFY8R','0UPRJ5','MGYJ4Q','DTG6VD','4FM05P','1VEYLR','F728RA','1MKSSQ','L1GY50','J4L57A','AHS8FH','5F7CCP','HW5D70','A50ERB','CMZC70','AVF0ZA','2FW5YK','J5FP12','6C35KJ','EP3UH0','7ZW93H','4CNVJK','05VN6M','K60YMA','LWZV2A','UD0CN3','KTFGY0','ZC2TR2','4FSJ2V','M2NUSA','F67GMG','K75FPC','JCW2G9','5N6UTM','H0DMD9','RMDCAZ','2WRPFT','VNU4NZ','A1FDSH','VE1YUY','ZTD6JU','PA9H2H','EQDMAR','3UBPW5','DPKGFS','NW9GNG','9EGDP3','7NYAF4','V9D6FC','GJMZSR','4R7F6Z','0GHZSS','A6HMWQ','9KAADS','NVWKHC','QBZ48E','TPCAWA','SSHGYB','FLZBYM','B63Q5Q','35ZDKZ','CBMDSN','DUBB8L','0G5ZNQ','QMEH49','4BBLL1','8JE3LV','FWETHL','97973T','4YBK0Z','10FWRW','KQ1GTA','N4DNH8','VLP66Y','51C92U','R60AN8','41H48U','MLDD1A','EQW2TG','5C4527','KJDNFQ','7TLGS5','JFV0BQ','ASDZV4','438BEA','1F11WC','ESL02Y','YLGKSE','H1BTVN','S5CKTB','8HN58Y','43QHE2','36VR77','TFKMVL','6DEWV9','KMDS0Y','CUKVJ5','PQMDBS','EWM8A1L0NJ8','EWMDQ0HTN1V','EWMTSTAPR6U','EWM2YB77M60','EWMHLM3T7DB','EWM16B9UTUG','EWMUHU0GBKV','EWM0KD3CDRU','EWMMA7B9CQR','EWM96176SHR','EWMYLS536DL','EWM8D10TZ8Y','EWMMEKW7LM4','EWM2F5P3NS2','EWMKNH5D835','EWMVFQ971VF','EWMB426TK5G','EWM963WBAU9','EWMJYA244NK','EWM6RBV9ZFC','EWMG789AP4L','EWMW8TVNBHQ','EWMB9EH11YV','EWM3AUQ90MM','EWMENYMQQ3E','EWM04B36T5V','EWMLH6NHNBB','EWMY6ZJAJBY','EWMC4YMKNQ2','EWMMV7RBGJC','EWM1A35D87L','EWM6UVW4K5Z','EWM19A9RZA1','EWM7PHAUDGG','EWMKQ5Y83WL','EWMY61B0RHU','EWMLLJEF55R','EWM8FJ0M1WH','EWMYLL5PHGR','EWMA2FNANUT','EWMP33AMA0Y','EWM3GZNP2W7','EWMQWQLMES3','EWM5Z0EHGY1','EWMLMJA7263','EWM2N5YHPL7','EWMRQK6RZ0Z','EWM7R7S5MP4','EWMFJDWVEHE','EWMVH63NTR5','EWMJZW1K7M1','EWMZ1HMYT36','EWMP3YU75RW','EWMWB3E9YH8','EWMDZBAWHR0','EWM3E3ECACY','EWMN9551REW','EWM2N2G3G36','EWMWTNZ76JR','EWMHMQNSLMQ','EWM0P7U2WAH','EWMNQSGDJQM','EWM4RC5R76S','EWME78NBBHU','EWMWUHJZWQV','EWMMWYR87EM','EWM5K9MVRNP','EWMJLT08D4T','EWM1047VZAU','EWMPPV5TB7Q','EWMLP598C18','EWMUUN5N91N','EWM5MUDYGJT','EWMKA5AL2SU','EWMBCKGUBGL','EWMQD657ZWR','EWM6ERRJLBW','EWMJG0JEPGU','EWM9Y3HC3CQ','EWMMZM6QPSU','EWM1CJHSED4','EWMBSFWU62B')
	--			)
	--	, RemoteVoucherCTE
	--	AS
	--	(
	--		SELECT vs.sVoucherCode AS sVoucherCode, vDateTime AS OrderDate, ISNULL(orderNo, 'OrderNo Not Known') AS Orderno
	--		FROM SQL01.HOMLIVE.dbo.tblVouchersSales vs
	--		LEFT JOIN  SQL01.HOMLIVE.dbo.tblVouchersSalesUse vsu ON vsu.sVoucherCode = vs.sVoucherCode
	--		LEFT  JOIN SQL01.HOMLIVE.dbo.tblOrders o ON o.OrderID = vsu.orderID 
	--		WHERE isDeleted=1 
	--			AND vs.sVoucherCode IN ('NHK1HJ71CZC','NHKQL1C8MN6','NHKQ0RA9KBD','NHK9JQF83CB','NHK7H1GUCAE','NHKWKFP3M17','NHKV98M4KME','NHKCWHHR5VF','NHKD7YP4ZBL','NHKYGWU2FDJ','NHKNJC30R3A','NHKPUT9LKHF','NHK95SCJ3KD','NHKQS308MSF','NHKZU1HT0WD','NHKG6ZNRRYC','NHK2EYSQ9ZA','NHK14PQR7MJ','NHKJCNVPNNG','NHKSFL5BASF','NHK94V1ZV2G','NHK8RMY1SPQ','NHKPEWTNCWR','NHKYHU3012Q','NHKD65ZYK0S','NHKCTVVZGW2','NHKUG7SL363','NHKKJL1UBUT','NHKK8DWV0G3','NHKJV6UW76A','NHK1JEQKRDC','NHKWKHEAR9P','NHKD9SAZAGR','NHKWQWU6P3E','NHKCC7RS90G','NHK3MRC0FG1','NHKJA29W1Q2','NHK3R6T4D0Q','NHKFTRFF2QV','NHKFDQRD9FU','NHKY31M2TPW','NHKU44ASTJ9','NHK472JDFN8','NHKJTAF22W9','NHKFVC5S2RL','NHKYHN1EL1M','NHK7LK9294L','NHKM0V6PTBM','NHKLWM3QQ1V','NHKHZPRGQU9','NHK1M1M5A40','NHK9PYVQY79','NHKQC8RDHE0','NHKMD0F5H0M','NHK43KBS3HN','NHK8V53SV2U','NHK7JV1TSP4','NHK4KZNKTJE','NHKK99K8CSF','NHKJW1G00EP','NHK0ZFPGK5G','NHK9M9MHHSQ','NHKNNT0V68U','NHKMBK7W3V4','NHKJCNVN3QF','NHK0E53VCE8','NHK4KDEM6G0','NHKK9PB0PPA','NHKJWF9AMCJ','NHK8C88919E','NHK72Z50WWN','NHKNN92YG6P','NHKMB2YZDTY','NHK41AUMZ2Z','NHK0FJTYPB3','NHK95ARZL1A','NHKQSLMM79B','NHKPECKN4WK','NHKEHTSVDKB','NHKD7KQYA9K','NHKVTULKVGM','NHKUGLJLS6V','NHKB6WE0CCW','NHKK8TNV2GV','NHKZ0EA9NW2','NHKVAHZZNRC','NHKSBKNPNMP','NHKSWSV5MH3','NHKRKJT6J7B','NHK89TPT5EC','NHK50WCJ50P','NHK5YNAL2YY','NHKWMSR59EL','NHKUL4SRJCP','NHKKNJ1ZU3F','NHK8AFC65F4','NHK5BH2V5BE','NHK6T6JP6FW','NHK5FWGQ356','NHKBQ23SWWG','NHK82GUB9KV','NHKED752153','NHKV62QAH5Z','NHKA42QTYMN','NHKP873SHUN','NHKL6P2WKY6','NHKUB9WCFYK','NHKR0QVGH22','NHKKEFYKFHL','NHK3175L41R','NHKQJHR6DMH','NHKYP2QD1HC','NHKL9CCYB64','NHKH7UB3C9K','NHK7Q71LPVA','NHKEVQV3KWR','NHK3E3HLWJG','NHKQYD76979','NHK8H4FZJHT','NHKYP4CTSZF','NHK7UM80PZV','NHKTDZVT1MM','NHKBVVHHM2Y','NHK1E863ZPN','NHKNZJTL0BE','NHKV53P37BU','NHKJNDBLGZL','NHKGLWAQJ43','NHKPRE0Z6ZW','NHKCARWHFLN','NHK1U4K3S9D','NHKNCE9L5V6','NHK6Y6EMQCA','NHKTGG37313','NHK3MZ2EMVV','NHKP7BNZZHM','NHKU0CHJWMJ','NHKHTP64800','NHK7C2TMJW2','NHKUVCG7VJR','NHKBF3Q18VB','NHK3M3MUFBZ','NHKJKSQTU26','NHKLRN8JQQE','NHKTY831LRV','NHKGFJQJYDL','NHKQM3NSJ0F','NHKC6DBBUW8','NHKA5WAFW1N','NHKZM9Z19ME','NHK574K68UY','NHKFLZ2ZMBL','NHKDJG14PE3','NHK5PGWYYVP','NHK09BH5W49','NHKYRN7N8QZ','NHKLA1U8JDQ','NHK4VP41VPA','NHKRE2RJ7C2','NHKDYCE4H1S','NHK3GP3MUMH','NHK92JNTTU3','NHK6Z3MYUYH','NHKTGDAG7K0','NHKG2QZ2H91','NHKG344N3PR','NHKD1K3S4S9','NHK3JWPBEFZ','NHKQ49CVR4Q','NHKVL4Z3QA9','NHKJ6FML2Y1','NHKF4YLQ42F','NHK5M000EN8','NHK075Y74R6','NHKYQFLQEDV','NHKVNYKUFGC','NHK4TGFBBGS','NHKRCT4VN6J','NHK261AD7T0','NHKRA289E0Y','NHK9VRD02Q4','NHK2NFKE81M','NHK8800BV3K','NHKUQLWV8PB','NHKUAS6A7LP','NHK1UMRG6T8','NHKQ1NNBD0V','NHKY67LJ16P','NHKLPH04ASF','NHKL0PGH0NT','NHKTE9CZ6P0','NHKGZK2HGB1','NHKP54ZR48U','NHKCNEMADUK','NHKC9LUQDRZ','NHKM2UZG7KA','NHKV7BWPSF6','NHKNSWE4JTH','NHKB9NESMJS','NHKPNKTUC72','FVBEDK','HD2CTH','FMG0KJ','RT6BGC','DR4E5P','0DT93M','JQTZ1C','A1NBJK','6SQRQQ','K4C2UA','MJEJJB','QWTR99','P1YW00','EE52JH','TZQALJ','9FNBF5','F1N4CW','958P84','FSTYJU','NCTR6R','9M2KG6','CV52G2','JKEH4U','3F5K3B','Q0JKHG','E1B78R','FMH55Q','TD4MDB','Z0QUQ7','ZA8L2B','59GBT6','9A9241','HHY20P','410JHQ','918HJK','ESBRDC','23KKQR','N41NV4','62B2TQ','7QCQYN','UPZ3U2','8DV4PN','RUENR3','LMG8D3','KQLDF3','B6SGQA','YAPKCN','UR6KTW','3B6AQP','D02KPB','34A6WM','SNS2VW','VZJQ49','17L734','9JMW1T','08ML5S','PLY88G','5WJHB3','PC43DF','RRG04C','N8Y7UF','WMKBH3','S7NQQ6','8NLRJQ','GU0RRE','2CGNS1','ZMZKJ2','C6KUNN','9VZ1KR','B43FKM','4FGDD6','UQBRYC','R54EEE','7FQPK1','0VS993','B06EYY','KRGWKP','9KYRJ2','VPVU7D','S70WDA','BS696R','5WNU1Y','AJA4CQ','0Q5KDW','SDN6EC','72WWZZ','ECWNWP','8MR2FW','L23KSW','2BPUWF','LS9EZV','P6LLNS','ENF3Y7','WNEUMN','QLU1HU','53R2CE','D0F2K6','ZSM1CE','W24W5F','LLKS5Q','8WTLF5','0H7S63','2UPHNE','3HQ7TD','ZYHUAF','D955E1','SP5TLK','V4H2AF','U7N7CG','KLTAMQ','Z6ENFF','487CPA','K7BE7T','MP3CLR','KZH0CS','J5AU6N','DTP14S','H3RF3N','RDR8ZD','2N5H60','VE8YBD','ART8FZ','V8CSHC','ZKRZ80','P3MBPZ','EGSFZ7','3MPJLJ','F5MKF6','NNMACY','98U8DG','7FA56J','V2SZ6S','GA1SG7','CYQLE6','LAQCBV','AYWFL7','9BN549','NNAD8S','Q4BYVU','TGQ5KR','SKVAMR','FCC6L4','BWFJT7','9ETSJJ','HLGSR9','K57Q76','HCNMY8','QYMFJ5','B9V0VH','EFYQVD','PTYFS5','Y40VQN','VG3J8R','J8U5W2','U98DDQ','V1WBSP','LGRR24','CWWVAB','9F10HE','CJR1S0','E567EM','6L1JZW','C0MSAP','TEWBP8','EQ663L','0CWV9U','JPWM6K','AZR1PS','6RUDVY','K3FN2H','NHG0F0','QVVG66','ZD8ZSW','PTC436','TYS5A6','7S2VUT','F1QV2H','HHETFF','FRVR8G','NA162U','0K91C9','DTAFB4','KJLYZW','L8ML4U','2LW97K','FWJHB5','2C44DJ','4RG04E','KU4GHT','A00LS3','7TB116','JNLRJT','TU0RQH','CCGNR3','28S0ZD','RS95YN','MGN0UR','9P0LPK','G30BLA','7PEFVL','UP2SSY','JETDG8','LUVW60','ET4T0F','WQKLGY','DRKD7E','Z0S9HV','56DLAJ','NR9W4Z','7FL9CF','NHES0Y','B03ZQD','VYLJRU','9KUABF','SB2CTY','07PESE','Y23KR1','5YHJBT','LRCU4A','P5R3S8','729UZP','WMKAQ5','S7NPW8','7NLQRS','GU0QZG','GRAE4G','7EENTL','MKQ886','8VY2KJ','B42GJE','4FJ84S','55JV8Q','ZVM0DV','D89KHE','J020QP','LMEFEL','KQJMGL','B6QRRU','SB1CVH','US4TUF','DDY5LV','FWM32S','V6K278','BBVKLQ','82APHU','A9C6GQ','HZNM5J','R92ZAD','PMTMSF','5YEWW2','NDZGZE','0Q19FE','FLMGS9','72SK3G','T6PNPU','8MMPJE','1TUNCS','3CJLRP','YZA99T','MJS584','9U2YKG','5GRRHE','CTRGE6','54LUZC','2GCHFF','ZTHR8M','GMC3Z5','K1R0N2','H4VEQ3','0H3J1A','N3NT3B','3JLUVW','04LLSP','BMAJ8L','0VRFZM','GFR0KJ','4Q14YY','8Z3JWT','DNC2HM','6Y8D4U','KCG4Y0','040PMJ','K5MY59','MG26T5','D1UK4H','3SBF3U','YBEU9Y','62VTTP','7N6BGW','ZSPYB5','7EB7PV','KZYFSH','60706V','2VY1A6','A9YR9V','3HR5S4','ZWJS06','BLGT4S','D3HEJJ','GEWL9F','QW84V8','FBC86F','KGS9DF','WB22Y5','8HQ25T','03EZJQ','8AVVAS','EUWL6Z','266EGC','3RHM7B','B4HD43','CSJ391','R7TNBP','7GFZF0','RY1JHN','UACQ8K','RSUMZN','18GSM0','VRK7TC','09H8NY','JE78VM','5YD5W8','1K7SCB','FQGASV','AEVFPZ','ENYWPU','9K0GPK','Y8FKZV','UM89FZ','AYUHKH','CDV39K','FR09YF','N0LQK8','C33LJJ','Z81N7W','VNDQDU','E00370','8DSN1F','E3EWC9','TL27GU','WVSZEV','0H2R1G','JU2GW8','A5VUFE','QH7DSE','485EM3','Q0C91D','SNQFPA','ZJCN25','YJVEB0','T4ZTJC','9KVUCY','HRKUKN','3ARUCY','1J8R6Z','NG1BTB','9S977P','C1AM6K','5BTBPZ','62U1TW','3ELNAZ','E5JP5L','1K4072','KZWNSP','J33TUQ','0G8Y5Z','72ABB3','T4K18J','03R3P3','BLF14Z','0UWWV2','Q18F0J','BAFAMY','8Y74KW','DNGK7P','6YBYQY','4B5L81','1M9UZ8','APL5FV','NF7LQH','TBSU3B','KRZZBK','WGPQD8','4CBYNF','56VM0E','E4QV04','APHJQ8','H0GCB5','U6JV5R','G7ZZ94','G5SDK4','9DMR6A','47Q6BF','AW1SD5','LYD3VS','YQYJ6E','MEWEMP','VUKGJK','QR1MER','DM4ZU3','DELNG3','FZALWZ','W6E3G4','MQVYFC','GEA3CG','J2N03E','HZHPDE','S9V2KA','PMMN3C','DCE0RM','PDSH9B','Q6HGMA','FMA1NE','73F5YM','4MJH5R','8PA8DL','0ANGSN','3D85MV','7E64NQ','MLFM49','9WPFEM','5HG4U7','CUGURW','65B8A5','3H4VS7','E82WMT','GN4EAV','K2FM1S','SJS5MH','JZY8WR','N5BBWG','3K0CR3','0605NU','BNZ33S','0WFZUT','GGESFQ','4SNLS5','81Q3R1','FCQTPQ','Z37PQE','TT04WK','06VC26','TLEY4J','WZT5SF','C3G0F5','3UY5EE','YD2HMJ','BVZJG5','M4NJNT','99JSS1','5UAE96','K2LZNN','EQ15KS','2YLJ7A','A0L042','3JFMM9','ZY8A5B','BM6BZZ','E49SVA','GFLZK7','QZYF8Y','GD4KG7','LHHLQ7','YCRD0U','GZMP2A','046BVG','GQSJ89','EWK526','ZK5P3L','B8CGL8','KJC8JY','CT8K46','R8G87V','7J5GBE','PCZS4W','SQC1ST','29NGDK','18AUW6','WRD959','A9B0YU','HSB1UL','KB2Y0J','1K1TN9','Q6GNMG','BEPHZV','ENSZZR','MC4FKK','63L64V','3FCTKY','GS14PG','38JNRW','MLET4F','LPK16F','AG3U5S','7269AV','A4WZKQ','CPA684','E814M2','CFF1D3','R14AHN','LPGEES','8W3U2A','G03LY2','9JWZG9','6YPLZB','40SYG9','K4M99Q','NF2FYM','WZCYKC','MDH3UL','RHY44L','71V5Y8','F7J56W','HQ03JT','YZ679M','LYYRW1','797L0D','KUECT1','T8E4QQ','4FSEWK','1VJ4DM','CKG580','Y12P0P','2DEVZK','GG24EZ','8W88P8','5FALVA','HY8MQV','QG8CMN','02E0N8','80W7E0','YUC2EJ','J5LVRW','6B88LQ','B3HP8J','5BC3RR','2Q6Q0T','QFYAZ5','HGTH3E','LV8QRB','TCH8D4','H613CD','DQ4FKG','2SB88P','KD7H15','CHQ6TB','K6CD74','ZPZN0Q','31PF9R','EMZ8TC','PZZZQ4','F9SB0A','VK8JKF','906KD4','TQP6FG','MPW2KN','5LDTS6','C23WN2','1711AD','DMW16Z','L8WR2R','EBFDVY','51KML4','TK2HLB','6F42C1','J4BSWL','QSN0JD','132LP0','7VZKR3','L7KUWM','W9Y5CA','R13HHV','FP2C16','5GG8ZG','22KL6K','PWPYKV','8PQLTG','HMLUT6','8FVF1F','NM71E1','FQWV27','BBMPZ6','A0F5A6','4JAGVC','1Y45CE','W08D4M','R5W0QS','SVM86R','QZRC7S','GDYGF2','LJ0R16','128SUQ','JM34L7','05WG6F','GSJPG8','EYC8HD','29K2VS','DUUSED','N8UJB5','WG7Y0P','R99CFU','8KVMLD','R2E8NT','UDTDCP','KVMUL4','3WLMAL','VU2S8S','0AYT2C','KHMT93','51VMHW','30BJ0Z','SUTD08','C528LL','EQEEAK','73Y5TY','8RZTZV','56QFFY','JFCRKH','MWDC10','MN4AE9','LR9FF0','C7DKQH','9QGZYL','VSRMT4','EDLZLJ','EAMMQJ','CJ4KGK','SPD4W5','7CETLB','AKH0L7','JYH1HW','9KN5S8','6ZFR00','4AK21G','NQ5K3W','R5HSRS','ZLT0DJ','82FE26','U7DHNH','9NAHH4','F8A0EV','HR28TS','Y1148G','NKFY8R','0UPRJ5','MGYJ4Q','DTG6VD','4FM05P','1VEYLR','F728RA','1MKSSQ','L1GY50','J4L57A','AHS8FH','5F7CCP','HW5D70','A50ERB','CMZC70','AVF0ZA','2FW5YK','J5FP12','6C35KJ','EP3UH0','7ZW93H','4CNVJK','05VN6M','K60YMA','LWZV2A','UD0CN3','KTFGY0','ZC2TR2','4FSJ2V','M2NUSA','F67GMG','K75FPC','JCW2G9','5N6UTM','H0DMD9','RMDCAZ','2WRPFT','VNU4NZ','A1FDSH','VE1YUY','ZTD6JU','PA9H2H','EQDMAR','3UBPW5','DPKGFS','NW9GNG','9EGDP3','7NYAF4','V9D6FC','GJMZSR','4R7F6Z','0GHZSS','A6HMWQ','9KAADS','NVWKHC','QBZ48E','TPCAWA','SSHGYB','FLZBYM','B63Q5Q','35ZDKZ','CBMDSN','DUBB8L','0G5ZNQ','QMEH49','4BBLL1','8JE3LV','FWETHL','97973T','4YBK0Z','10FWRW','KQ1GTA','N4DNH8','VLP66Y','51C92U','R60AN8','41H48U','MLDD1A','EQW2TG','5C4527','KJDNFQ','7TLGS5','JFV0BQ','ASDZV4','438BEA','1F11WC','ESL02Y','YLGKSE','H1BTVN','S5CKTB','8HN58Y','43QHE2','36VR77','TFKMVL','6DEWV9','KMDS0Y','CUKVJ5','PQMDBS','EWM8A1L0NJ8','EWMDQ0HTN1V','EWMTSTAPR6U','EWM2YB77M60','EWMHLM3T7DB','EWM16B9UTUG','EWMUHU0GBKV','EWM0KD3CDRU','EWMMA7B9CQR','EWM96176SHR','EWMYLS536DL','EWM8D10TZ8Y','EWMMEKW7LM4','EWM2F5P3NS2','EWMKNH5D835','EWMVFQ971VF','EWMB426TK5G','EWM963WBAU9','EWMJYA244NK','EWM6RBV9ZFC','EWMG789AP4L','EWMW8TVNBHQ','EWMB9EH11YV','EWM3AUQ90MM','EWMENYMQQ3E','EWM04B36T5V','EWMLH6NHNBB','EWMY6ZJAJBY','EWMC4YMKNQ2','EWMMV7RBGJC','EWM1A35D87L','EWM6UVW4K5Z','EWM19A9RZA1','EWM7PHAUDGG','EWMKQ5Y83WL','EWMY61B0RHU','EWMLLJEF55R','EWM8FJ0M1WH','EWMYLL5PHGR','EWMA2FNANUT','EWMP33AMA0Y','EWM3GZNP2W7','EWMQWQLMES3','EWM5Z0EHGY1','EWMLMJA7263','EWM2N5YHPL7','EWMRQK6RZ0Z','EWM7R7S5MP4','EWMFJDWVEHE','EWMVH63NTR5','EWMJZW1K7M1','EWMZ1HMYT36','EWMP3YU75RW','EWMWB3E9YH8','EWMDZBAWHR0','EWM3E3ECACY','EWMN9551REW','EWM2N2G3G36','EWMWTNZ76JR','EWMHMQNSLMQ','EWM0P7U2WAH','EWMNQSGDJQM','EWM4RC5R76S','EWME78NBBHU','EWMWUHJZWQV','EWMMWYR87EM','EWM5K9MVRNP','EWMJLT08D4T','EWM1047VZAU','EWMPPV5TB7Q','EWMLP598C18','EWMUUN5N91N','EWM5MUDYGJT','EWMKA5AL2SU','EWMBCKGUBGL','EWMQD657ZWR','EWM6ERRJLBW','EWMJG0JEPGU','EWM9Y3HC3CQ','EWMMZM6QPSU','EWM1CJHSED4','EWMBSFWU62B')
	--			AND vs.sVoucherCode NOT IN (SELECT sVoucherCode FROM  VoucherCTE v )
	--			)

	--UPDATE o 
	--SET [Used] = CASE WHEN [Used] = 1 THEN 1
	--				WHEN OrderNo IS NOT NULL THEN 1
	--				ELSE 0
	--				END
	--		 ,[Order No] = ISNULL(o.[Order No], vo.Orderno)
	--		,[Order Date] =  ISNULL( o.[Order Date] , TRY_CONVERT(date,vo.OrderDate))
	--  FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_EWM_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS EWM$]') o
	-- INNER JOIN RemoteVoucherCTE vo ON vo.[sVoucherCode] = o.[Voucher Code]




--Get All Vouchers from the files
IF OBJECT_ID('tempdb..#SheetVouchers') IS NOT NULL
	DROP TABLE #SheetVouchers;
		CREATE TABLE #SheetVouchers ( 
		rownumber int IDENTITY(1,1), 
		VoucherCode varchar(100), 
		Used BIT, 
		OrderNo VARCHAR(100), 
		OrderTotal VARCHAR(100), 
		OrderDate VARCHAR(100), 
		OrderStatus VARCHAR(100),
		ShipTo VARCHAR(255),
		ShipToCity VARCHAR(255),
		ShipToState VARCHAR(255),
		Agent VARCHAR(255)
	)

INSERT #SheetVouchers  ([VoucherCode] , Used , [OrderNo] , [OrderTotal] , [OrderDate], [OrderStatus], [ShipTo], [ShipToCity], [ShipToState], [Agent])
SELECT [Voucher Code] , Used , [Order No] , [Order Total] , [Order Date] , [Order Status],[Ship To], [Ship To City], [Ship To State], [Agent]
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_PRO_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS PRO$]') o
WHERE [Voucher Code] IS NOT NULL

	;WITH VoucherCTE
	AS
	(
 	SELECT 
		[sVoucherUseID],
		[sVoucherID],
		[sVoucherCode],
		[sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = v.sVoucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
	UNION
	SELECT 
		v.voucherUseID AS  [sVoucherUseID],
		vs.voucherId  AS [sVoucherID],
		vs.voucherCode AS [sVoucherCode],
		v.valueApplied AS [sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVoucherUse] v ON o.OrderId = v.OrderID
	INNER JOIN dbo.tblVouchers vs ON vs.voucherID = v.voucherID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = vs.voucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
		)
, AgentCte
AS
(
SELECT DISTINCT op.orderID AS OrderId,  AgentName FROM dbo.tblOrders_Products op WHERE AgentName IS NOT NULL
)

	UPDATE o 
	SET  [Used] = CASE WHEN [Used] = 1 THEN 1
				WHEN OrderNo IS NOT NULL THEN 1
				ELSE 0
				END
		,[Order No] = ISNULL(o.[Order No], vo.Orderno)
	    ,[Order Total] =  ISNULL( o.[Order Total],vo.orderTotal )
		,[Order Date] = ISNULL( o.[Order Date],  vo.OrderDate)
		,[Order Status] =  ISNULL(o.[Order Status], 
				CASE  vo.OrderStatus WHEN  'Delivered' THEN 'Delivered'
					WHEN  	'Cancelled' THEN 'Cancelled' 
					WHEN  'In Production' THEN 'In Production' 
					WHEN  'In Transit' THEN 'In Transit' 
					WHEN  'In Transit USPS' THEN 'In Transit' 
					WHEN  'On HOM Dock' THEN 'On MRK Dock' 
					WHEN  'On MRK Dock' THEN 'On MRK Dock' 
				END)
		,[Ship To] = ISNULL([Ship To], Shipping_FirstName + ISNULL(' ' + NULLIF(Shipping_Surname,''),''))
		,[Ship To City] = ISNULL( o.[Ship To City],  vo.shipping_Suburb )
		,[Ship To State] = ISNULL( o.[Ship To State],vo.shipping_State )
		,[Agent]  = ISNULL([Agent], (SELECT TOP 1 AgentName FROM AgentCte op WHERE op.orderID = vo.OrderId )) --businesss card first and the
	--  , --Add Job Status column 
	-- ,vo.*
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_PRO_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS PRO$]') o
INNER JOIN VoucherCTE vo 
ON vo.[sVoucherCode] = o.[Voucher Code]

		
;WITH VoucherCTE
AS
(
SELECT 
	[sVoucherUseID],
	[sVoucherID],
	[sVoucherCode],
	[sVoucherAmountApplied],
	[vDateTime],
	o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVouchersSalesUse] v ON o.OrderId = v.OrderID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = v.sVoucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')
	UNION
	SELECT 
		v.voucherUseID AS  [sVoucherUseID],
		vs.voucherId  AS [sVoucherID],
		vs.voucherCode AS [sVoucherCode],
		v.valueApplied AS [sVoucherAmountApplied],
		[vDateTime],
		o.*
	FROM [dbo].[tblOrderview]  o 
	INNER JOIN [dbo].[tblVoucherUse] v ON o.OrderId = v.OrderID
	INNER JOIN dbo.tblVouchers vs ON vs.voucherID = v.voucherID
	LEFT JOIN [dbo].[tblCustomer] c ON c.CustomerID = o.CustomerId
	INNER JOIN #SheetVouchers sv ON sv.VoucherCode = vs.voucherCode
	WHERE o.orderStatus NOT IN ('Cancelled')		

	)
UPDATE o 
SET  [Order Status] =  ISNULL(o.[Order Status], 
			CASE  vo.OrderStatus WHEN  'Delivered' THEN 'Delivered'
				WHEN  	'Cancelled' THEN 'Cancelled' 
				WHEN  'In Production' THEN 'In Production' 
				WHEN  'In Transit' THEN 'In Transit' 
				WHEN  'In Transit USPS' THEN 'In Transit' 
				WHEN  'On HOM Dock' THEN 'On HOM Dock' 
			END)
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_PRO_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS PRO$]') o
INNER JOIN VoucherCTE vo 
	ON vo.[sVoucherCode] = o.[Voucher Code]


;WITH   RemoteVoucherCTE
	AS
	(
	---Discounts
	SELECT vs.CouponCode AS sVoucherCode,  o.CreateDate AS OrderDate,  GbsOrderID  AS Orderno
			FROM  dbo.nopcommerce_Discount vs
				LEFT JOIN  dbo.nopcommerce_DiscountUsageHistory vsu ON vsu.DiscountId = vs.Id
				LEFT  JOIN   dbo.nopcommerce_tblNopOrder  o ON vsu.OrderId = o.nopId 
				WHERE vs.CouponCode  IN (SELECT VoucherCode FROM  #SheetVouchers v )
	UNION
		--Gift Cards
		SELECT vs.GiftCardCouponCode AS sVoucherCode,  o.CreateDate AS OrderDate,  GbsOrderID  AS Orderno 
			FROM  dbo.nopcommerce_GiftCard vs
				LEFT JOIN  dbo.nopCommerce_GiftCardUsageHistory vsu ON vsu.GiftCardId = vs.Id
				LEFT  JOIN   dbo.nopcommerce_tblNopOrder  o ON vsu.UsedWithOrderId = o.nopId 
				WHERE [GiftCardCouponCode]  IN (SELECT VoucherCode FROM  #SheetVouchers v )
				
	)

UPDATE o 
SET [Used] = CASE WHEN o.[Used] = 1 THEN 1
				WHEN OrderNo = 'OrderNo Not Known' THEN 0
				WHEN OrderNo IS NOT NULL AND OrderNo <> 'OrderNo Not Known' THEN 1
				END
			,[Order No] = CASE WHEN vo.OrderNo <> 'OrderNo Not Known'  THEN ISNULL(o.[Order No], vo.Orderno)
				WHEN vo.OrderNo = 'OrderNo Not Known' THEN ''
				ELSE ''
				END
		,[Order Date] =  ISNULL( o.[Order Date] , TRY_CONVERT(date,vo.OrderDate))
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=c:\Excel\BHHS_PRO_Voucher_Bank.xlsx;HDR=YES', 'SELECT * FROM [BHHS PRO$]') o 
INNER JOIN RemoteVoucherCTE vo ON vo.[sVoucherCode] = o.[Voucher Code]