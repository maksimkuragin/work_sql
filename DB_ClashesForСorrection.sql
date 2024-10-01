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
	cr.ClashGuid
	,cr.Item1Guid AS ItemGuid
FROM ClashResultsLastUnloading cr
),
ClashResults2 AS (
SELECT DISTINCT
	cr.ClashGuid
	,cr.Item2Guid AS ItemGuid
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
	,o.SourceFile AS SourceFile
	,o.RevitId AS RevitId
	--,o.DocumentationSet AS DocumentationSet
	--,o.WorksetName ASWorksetName
	--,o.Category AS Category
	--,o.FamilyName AS FamilyName
FROM ClashResultsForFilter cr
LEFT JOIN Objects o ON cr.ItemGuid = o.ItemGuid