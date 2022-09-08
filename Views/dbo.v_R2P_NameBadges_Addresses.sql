create view v_R2P_NameBadges_Addresses
as
select * from tblBadges_Addresses
where orderNo in
(select distinct orderNo from tblR2P_NameBadges where orderNo is not NULL)