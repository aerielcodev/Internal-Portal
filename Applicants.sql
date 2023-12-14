/*displays various applicant touchpoints*/
SELECT
    a.Id AS ApplicantId,
    ap.Id AS ApplicantJobPostingsId,
    cp.Id AS CandidateId,
    CONCAT(TRIM(a.FirstName),' ',TRIM(a.LastName)) AS Applicant,
    jp.Title AS 'Associated Job Posting',
    jp.Number,
    iif(cb.UserId IS NULL,a.CreatedBy,CONCAT(cb.FirstName,' ',cb.LastName)) AS CreatedBy,
    cp.QualifiedDate,
    ast.Name AS 'Status',
    ap.DateApplied AS 'Date Applied',
    ajp.Created AS 'Status Updated On',
    CASE
        WHEN ap.SourceId = 1 THEN 'CoDev Career Site'
        WHEN ap.SourceId = 2 THEN 'Facebook'
        WHEN ap.SourceId = 3 THEN 'Google'
        WHEN ap.SourceId = 4 THEN 'Indeed'
        WHEN ap.SourceId = 5 THEN 'Job Fair'
        WHEN ap.SourceId = 6 THEN 'JobStreet'
        WHEN ap.SourceId = 7 THEN 'LinkedIn'
        WHEN ap.SourceId = 8 THEN 'Mynimo'
        WHEN ap.SourceId = 9 THEN 'Naukri'
        WHEN ap.SourceId = 10 THEN 'Organizational Partnership'
        WHEN ap.SourceId = 11 THEN 'Applicant Referral'
        WHEN ap.SourceId = 12 THEN 'Employee Referral'
        WHEN ap.SourceId = 13 THEN 'External Referral'
        WHEN ap.SourceId = 14 THEN 'Word of Mouth'
        WHEN ap.SourceId = 15 THEN 'Other'
    END AS 'Source of Candidate',
    IIF(ub.FirstName IS NULL,ajp.CreatedBy,CONCAT(ub.FirstName,' ',ub.LastName)) AS 'Status Updated By',
    CASE
        WHEN ap.StatusId = 1 THEN 'Active'
        WHEN ap.StatusId = 2 THEN 'Inactive'
        WHEN ap.StatusId = 3 THEN 'Deleted'
    END AS Class,
    r.recruiter AS 'Current Recruiter',
    a.Email,
    a.ContactNumber,
    IIF(ar.Id IS NULL,'N','Y') AS 'Has Recruiter',
    a.HubSpotId
FROM Applicants a
LEFT JOIN UserDetails cb ON cb.UserId = a.CreatedBy
LEFT JOIN ApplicantJobPostings ap ON ap.ApplicantId = a.Id
LEFT JOIN JobPostings jp ON jp.Id = ap.JobPostingId
LEFT JOIN CandidateProfileInformations cp ON cp.Id = ap.CandidateId
OUTER APPLY (/*retrieves the latest status*/
    SELECT TOP 1 * FROM ApplicantJobPostingProgresses WHERE ApplicantJobPostingId = ap.Id ORDER BY Created DESC
    ) AS ajp
LEFT JOIN ApplicationStages ast ON ast.Id = ajp.ApplicationStageId
OUTER APPLY (/*retrieves the latest recruiter*/
    SELECT TOP 1 * FROM ApplicantRecruiters WHERE ApplicantId = a.Id ORDER BY Created DESC
    ) AS ar
LEFT JOIN (
    SELECT
        e.Id,
        CONCAT(ud.FirstName,' ',ud.LastName) AS recruiter
    FROM Employees e
    JOIN UserDetails ud ON e.UserId = ud.UserId
) AS r ON r.Id = ar.RecruiterId
LEFT JOIN UserDetails ub ON ub.UserId = ajp.CreatedBy
WHERE  
    a.Created >= CONVERT(DATE,'2023-05-17') /*date v2 careers was launched*/ 
AND
(
        LOWER(a.FirstName) NOT LIKE '%test%'
        AND LOWER(a.LastName) NOT LIKE '%test%'
        AND LOWER(a.FirstName) NOT LIKE '%demo%'
        AND LOWER(a.LastName) NOT LIKE '%demo%'
    ) 
    AND ap.StatusId <> 3 /*StatusId = 3 are deleted profiles*/
ORDER BY ajp.Created DESC