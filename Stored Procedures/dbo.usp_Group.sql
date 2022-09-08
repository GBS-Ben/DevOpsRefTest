CREATE proc usp_Group 
@coordinator varchar(255), 
@firstName varchar(255), @lastName varchar(255), @company varchar(255), 
@address1 varchar(255), @address2 varchar(255), 
@city varchar(255), @state varchar(255), @zip varchar(255), 
@officePhone varchar(255), @cellPhone varchar(255), 
@email varchar(255), @numAgents varchar(255), 
@jobTitle varchar(255), @numLocations varchar(255),
@otherJob varchar (255), @brokerOwnerCode varchar (255), @comments text
--,@uniqueID varchar(255) OUTPUT
as
declare @uniqueID varchar(255)
insert into tblGroupOrders (coordinator,firstName,lastName,company,address1,address2,city,state,zip,officePhone,cellPhone,email,numAgents,jobTitle,numLocations,insertdate, otherJob, brokerOwnerCode, comments)
select @coordinator, @firstName, @lastName , @company , @address1 , @address2 , @city , @state , @zip , 
@officePhone , @cellPhone , @email , convert(int,@numAgents), @jobTitle , convert(int,@numLocations) , getdate(), @otherJob, @brokerOwnerCode, @comments

set @uniqueID=(select top 1 convert(varchar(255),uniqueID) from tblGroupOrders where coordinator=@coordinator
		and firstName=@firstName and lastName=@lastName and company=@company and zip=@zip and officePhone=@officePhone
		order by insertDate desc)

select @uniqueID as 'uniqueID'