SELECT 
    jcs.Id,
    jcs.JobOpeningCandidateId,
    nct.Name AS 'Job Opening Endorsement Status',
    jcs.DateStatusUpdated,
    COALESCE(CONCAT(cb2.FirstName,' ',cb2.LastName),cb.Name) AS UpdatedBy,
    jop.Id AS JobOpeningPositionId,
    jc.JobOpeningId,
    ROW_NUMBER() OVER(PARTITION BY jcs.JobOpeningCandidateId ORDER BY jcs.DateStatusUpdated) AS rn
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
WHERE jcs.NotAFitCategoryTypeId IS NOT NULL
ORDER by jcs.DateStatusUpdated asc
