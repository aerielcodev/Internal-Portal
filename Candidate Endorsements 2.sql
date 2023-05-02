SELECT
    pivot_table.*
FROM (SELECT 
    jcs.JobOpeningCandidateId,
    coalesce(jos.Name,ifc.Name,nct.Name ) AS category,
    jcs.DateStatusUpdated
FROM JobOpeningCandidates jc 
INNER JOIN dbo.JobOpeningCandidateEndorsementStatusChangeDates jcs ON jcs.JobOpeningCandidateId = jc.Id
LEFT JOIN JobOpeningEndorsementStatuses jos ON jos.Id = jcs.JobOpeningEndorsementStatusId
LEFT JOIN InterviewFeedbackActionCategoryTypes ifc ON ifc.Id = jcs.InterviewFeedbackActionCategoryTypeId
LEFT JOIN NotAFitCategoryTypes nct ON nct.Id = jcs.NotAFitCategoryTypeId
LEFT JOIN UserDetails cb ON cb.UserId = jcs.ChangedBy
WHERE coalesce(jos.Name,ifc.Name,nct.Name ) IS NOT NULL) AS src
PIVOT
(
    MAX(DateStatusUpdated)
    FOR category IN (
        [Waiting for Client Decision],
        [Job Offer Requested],
        [Schedule Additional Interview],
        [Waiting for Onboarding],
        [Not a Fit],
        [Placed],
        [Interview Cancelled],
        [Cancelled Job Offer],
        [Job Offer Declined]
    )
) AS pivot_table
