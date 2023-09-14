SELECT  DISTINCT
    jcs.Id,
    jcs.JobOpeningCandidateId,
    CASE
        WHEN jcs.RecommendationId = 1 THEN 'Endorse'
        WHEN jcs.RecommendationId = 2 THEN 'Do Not Endorse'
        WHEN jcs.RecommendationId = 3 THEN 'Not a Fit'
    END AS Recommendation, 
    jcs.DateStatusUpdated,
    COALESCE(cb.Name,CONCAT(cb2.FirstName,' ',cb2.LastName)) AS UpdatedBy,
    jop.Id AS JobOpeningPositionId,
    jc.JobOpeningId,
    ROW_NUMBER() OVER(PARTITION BY jcs.JobOpeningCandidateId ORDER BY jcs.DateStatusUpdated) AS rn,
    cb.UserId AS customerUserId
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningCandidates jc ON jc.JobOpeningId  = j.Id
INNER JOIN dbo.JobOpeningCandidateEndorsementStatusChangeDates jcs ON jcs.JobOpeningCandidateId = jc.Id
LEFT JOIN NotAFitCategoryTypes nct ON nct.Id = jcs.NotAFitCategoryTypeId
LEFT JOIN (
    SELECT DISTINCT 
        UserId, 
        CONCAT(FirstName , ' ' , LastName) AS name
    FROM CustomerUserDetails
    )  cb ON cb.UserId = jcs.ChangedBy
LEFT JOIN UserDetails cb2 ON cb2.UserId = jcs.ChangedBy
WHERE jcs.RecommendationId IS NOT NULL AND jcs.NotAFitCategoryTypeId IS NULL  and jcs.RecommendationId <> 1
ORDER by jcs.DateStatusUpdated asc
