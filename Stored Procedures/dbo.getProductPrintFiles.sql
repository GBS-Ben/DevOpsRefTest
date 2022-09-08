CREATE PROCEDURE "dbo"."getProductPrintFiles" AS

-- Get printfile file name from product options trying a vareiety of configurations since each platform works slightly differently.
-- We could, at a later date, change this to be an ongoing procedure that adds the printfile names (front/back/inside for NCs) to a dedicated productPrintfiles table, and have this SPROC just pull specific rows from that table.

-- how to deal with broken product options? 0-1.pdf? missing flags? 

-- Custom Insertion > no flags, orderNo_OPID.pdf

-- Gluon > Gluon flag, OPC flag? optionCaption: "file name 2" value: Inproduction/.../filename.pdf?

-- Chili > Chili flag, OPC flag? optionCaption: "file name 2/intranet PDF" whatever Chili's printfile product option looks like.

-- Canvas > Canvas flag, OPC flag? optionCaption: "file name 2/Intranet PDF" whatever chili's printfile product option looks like.