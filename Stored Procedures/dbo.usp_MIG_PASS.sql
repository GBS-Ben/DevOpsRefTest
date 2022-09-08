CREATE PROC [dbo].[usp_MIG_PASS]
AS
DELETE FROM tblCustomers_Password
INSERT INTO tblCustomers_Password (customerID, firstName, surName, company, street, street2, suburb, postCode, [state], country, 
phone, fax, mobilePhone, email, website, customerPassword, newsletter, membershipType, membershipNo, login)
SELECT  customerID+444333222 as 'customerID', firstName, surName, company, street, street2, suburb, postCode, [state], country, 
left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(phone,'z',''),'y',''),'x',''),'w',''),'v',''),'u',''),'t',''),'s',''),'r',''),'q',''),'p',''),'o',''),'n',''),'m',''),'l',''),'k',''),'j',''),'i',''),'h',''),'g',''),'f',''),'e',''),'d',''),'c',''),'b',''),'a',''),'#',''),'_',''),',',''),'.',''),'/',''),')',''),'(',''),' ',''),'-',''),10) as 'phone', 
left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(fax,'z',''),'y',''),'x',''),'w',''),'v',''),'u',''),'t',''),'s',''),'r',''),'q',''),'p',''),'o',''),'n',''),'m',''),'l',''),'k',''),'j',''),'i',''),'h',''),'g',''),'f',''),'e',''),'d',''),'c',''),'b',''),'a',''),'#',''),'_',''),',',''),'.',''),'/',''),')',''),'(',''),' ',''),'-',''),10) as 'fax', 
left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(mobilePhone,'z',''),'y',''),'x',''),'w',''),'v',''),'u',''),'t',''),'s',''),'r',''),'q',''),'p',''),'o',''),'n',''),'m',''),'l',''),'k',''),'j',''),'i',''),'h',''),'g',''),'f',''),'e',''),'d',''),'c',''),'b',''),'a',''),'#',''),'_',''),',',''),'.',''),'/',''),')',''),'(',''),' ',''),'-',''),10) as 'mobilePhone', 
email, website, customerPassword, newsletter, membershipType, membershipNo, login
--// into tblCustomers_Password
FROM dbo.HOMLIVE_tblCustomers
ORDER BY customerID DESC

update tblCustomers
set customerPassword=b.customerPassword
from tblCustomers a join tblCustomers_Password b
on a.customerID=b.customerID
where a.customerPassword<>b.customerPassword
and a.customerPassword is NOT NULL
and b.customerPassword is NOT NULL