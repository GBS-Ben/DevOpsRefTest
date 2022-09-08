/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [dbo].[SearchNopTopic]

AS
SELECT   t.[Id] as TopicId
      ,[SystemName]
	        ,[Title]
      ,[Body]
      --,[IncludeInSitemap]
      --,[IncludeInTopMenu]
      --,[IncludeInFooterColumn1]
      --,[IncludeInFooterColumn2]
      --,[IncludeInFooterColumn3]
 --     ,t.[DisplayOrder]
 ---     ,[AccessibleWhenStoreClosed]
 --     ,[IsPasswordProtected]
      ,[Password]

      ,tt.[Name] AS [TopicTemplate]
      ,[MetaKeywords]
      ,[MetaDescription]
      ,[MetaTitle]
      ,[SubjectToAcl]
      ,[LimitedToStores]
      ,[Published]
	  , tt.ViewPath AS TopicTemplateViewPath
  FROM dbo.[nopcommerce_Topic] t
  INNER JOIN dbo.nopcommerce_TopicTemplate tt ON tt.id = t.TopicTemplateId