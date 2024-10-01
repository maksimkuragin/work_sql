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
WHERE UnloadingNumber >= (SELECT MAX(UnloadingNumber) FROM ClashResults) - 10
--WHERE UnloadingNumber > (SELECT MAX(UnloadingNumber) FROM ClashResults) - "&Number.ToText(Count_unloading)&"
),
NonClashes AS (
SELECT 
    ClashGuid,
    Approved,
    Comment
FROM ClashData.dbo.NonClashes AS nc1
WHERE ProjectId = (SELECT Id FROM Project) 
AND Id = (
        SELECT MIN(Id)
        FROM ClashData.dbo.NonClashes AS nc2
        WHERE nc2.ClashGuid = nc1.ClashGuid)
),
DefinedEliminationClashes AS (
SELECT 
	ClashGuid,
	FileToSolveIn,
	Comment
FROM ClashData.dbo.DefinedEliminationClashes AS dec1
WHERE ProjectId = (SELECT Id FROM Project) 
AND Id = (
		SELECT MAX(Id)
		FROM ClashData.dbo.DefinedEliminationClashes AS dec2
		WHERE dec2.ClashGuid = dec1.ClashGuid)
)
SELECT DISTINCT
	cr.Name
    ,cr.ClashGuid
    ,cr.ClashLevel
    ,cr.Item1Guid
    ,cr.Item2Guid
    ,CAST(cr.CreateDate AS DATE) AS ClashDate
    ,cr.Volume
    ,nc.Approved 
    ,nc.Comment AS ApprovedComment
	,de.FileToSolveIn
	,de.Comment AS FileToSolveInComment
FROM ClashResultsLastUnloading cr
LEFT JOIN NonClashes nc ON cr.ClashGuid = nc.ClashGuid 
LEFT JOIN DefinedEliminationClashes de ON cr.ClashGuid = de.ClashGuid 




