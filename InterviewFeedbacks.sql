
SELECT 
    jcs.Id,
    jcs.JobOpeningCandidateId,
    ifc.Name AS 'Interview Feedback Category',
    jcif.Feedback,
    jcs.DateStatusUpdated,
    coalesce(cb.Name,CONCAT(cb2.FirstName,' ',cb2.LastName)) AS UpdatedBy,
    jop.Id AS JobOpeningPositionId,
    jc.JobOpeningId,
    ROW_NUMBER() OVER(PARTITION BY jcs.JobOpeningCandidateId ORDER BY jcs.DateStatusUpdated) AS rn
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningCandidates jc ON jc.JobOpeningId  = j.Id
INNER JOIN dbo.JobOpeningCandidateEndorsementStatusChangeDates jcs ON jcs.JobOpeningCandidateId = jc.Id
LEFT JOIN InterviewFeedbackActionCategoryTypes ifc ON ifc.Id = jcs.InterviewFeedbackActionCategoryTypeId
LEFT JOIN JobOpeningCandidateInterviewFeedbacks jcif ON 
(jcif.JobOpeningCandidateId = jcs.JobOpeningCandidateId) 
AND (CAST(jcif.Created AS date) = CAST(jcs.DateStatusUpdated AS date)) 
AND (jcif.CreatedBy = jcs.ChangedBy)
LEFT JOIN (
    SELECT DISTINCT 
        UserId, 
        CONCAT(FirstName , ' ' , LastName) AS name
    FROM CustomerUserDetails
    )  cb ON cb.UserId = jcs.ChangedBy
LEFT JOIN UserDetails cb2 ON cb2.UserId = jcs.ChangedBy
WHERE ifc.Name IS NOT NULL
ORDER by jcs.DateStatusUpdated asc
