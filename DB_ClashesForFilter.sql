WITH Project AS (
SELECT Id FROM ClashData.dbo.Projects
WHERE Name = 'ÁÈÐ_1_1'
--WHERE Name = '"&Project_code&"'
), 
ClashResults AS (
SELECT *,
DENSE_RANK() OVER (ORDER BY CAST(CreateDate AS DATE)) AS UnloadingNumber
FROM ClashData.dbo.ClashResults
WHERE ProjectId IN (SELECT Id FROM Project)
),
ClashResultsLastUnloading AS (
SELECT * FROM ClashResults
WHERE UnloadingNumber >= (SELECT MAX(UnloadingNumber) FROM ClashResults) - 8
--WHERE UnloadingNumber > (SELECT MAX(UnloadingNumber) FROM ClashResults) - "&Number.ToText(Count_unloading)&"
),
ClashResults1 AS (
SELECT DISTINCT
	cr.Name
	,cr.ClashGuid
	,cr.Item1Guid
	,cr.Item2Guid
	,CAST(cr.CreateDate AS DATE) AS ClashDate
	,SUBSTRING(Name, CHARINDEX('. ', Name) + 2, CHARINDEX('-', Name) - CHARINDEX('. ', Name) - 2) AS SearchSetLeft
    ,SUBSTRING(Name, CHARINDEX('-', Name) + 1, LEN(Name)) AS SearchSetRight
FROM ClashResultsLastUnloading cr
),
ClashResults2 AS (
SELECT DISTINCT
	cr.Name
	,cr.ClashGuid
	,cr.Item2Guid AS Item1Guid
	,cr.Item1Guid AS Item2Guid
	,CAST(cr.CreateDate AS DATE) AS ClashDate
	,SUBSTRING(Name, CHARINDEX('-', Name) + 1, LEN(Name)) AS SearchSetLeft 
	,SUBSTRING(Name, CHARINDEX('. ', Name) + 2, CHARINDEX('-', Name) - CHARINDEX('. ', Name) - 2) AS SearchSetRight
FROM ClashResultsLastUnloading cr
),
ClashResultsForFilter AS (
SELECT * FROM ClashResults1
UNION ALL
SELECT * FROM ClashResults2
),
Objects AS (
SELECT * FROM ClashData.dbo.Objects
WHERE ProjectId IN (SELECT Id FROM Project)
)
SELECT
	cr.ClashGuid
	,cr.SearchSetLeft 
	,cr.SearchSetRight 
	,cr.ClashDate
	,o1.SourceFile AS SourceFileLeft
	,o2.SourceFile AS SourceFileRight
	,o1.RevitId AS RevitIdLeft
	,o2.RevitId AS RevitIdRight
	,o1.DocumentationSet AS DocumentationSetLeft
	,o2.DocumentationSet AS DocumentationSetRight
	,o1.WorksetName ASWorksetName1Left
	,o2.WorksetName ASWorksetName2Right
	,o1.Category AS Category1Left
	,o2.Category AS Category2Right
	,o1.FamilyName AS FamilyNameLeft
	,o2.FamilyName AS FamilyNameRight
FROM ClashResultsForFilter cr
LEFT JOIN Objects o1 ON cr.Item1Guid = o1.ItemGuid 
LEFT JOIN Objects o2 ON cr.Item2Guid = o2.ItemGuid 


