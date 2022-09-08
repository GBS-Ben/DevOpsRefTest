create view v_R2P_NameBadges_Rectangle
as
select * from tblR2P_NameBadges
where RO like '%R%'