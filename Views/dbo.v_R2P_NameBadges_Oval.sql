create view v_R2P_NameBadges_Oval
as
select * from tblR2P_NameBadges
where RO like '%O%'