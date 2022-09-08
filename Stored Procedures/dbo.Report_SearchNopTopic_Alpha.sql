/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROCEDURE [dbo].[Report_SearchNopTopic_Alpha]
AS
SELECT   t.[Id] as TopicId
      ,[SystemName]
	        ,[Title]
      ,[Body]
      ,[Password]
      ,tt.[Name] AS [TopicTemplate]
      ,[MetaKeywords]
      ,[MetaDescription]
      ,[MetaTitle]
      ,[SubjectToAcl]
      ,[LimitedToStores]
      ,[Published]
	  ,tt.ViewPath AS TopicTemplateViewPath
  FROM oldstone.[nopcommercealpha].[dbo].[Topic] t
  INNER JOIN oldstone.nopcommercealpha.dbo.TopicTemplate tt ON tt.id = t.TopicTemplateId