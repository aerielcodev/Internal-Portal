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
    IIF(ub.FirstName IS NULL,ajp.CreatedBy,CONCAT(ub.FirstName,' ',ub.LastName)) AS 'Status Updated By',
    CASE
        WHEN ap.StatusId = 1 THEN 'Active'
        WHEN ap.StatusId = 2 THEN 'Inactive'
        WHEN ap.StatusId = 3 THEN 'Deleted'
    END AS Class,
    r.recruiter AS 'Current Recruiter',
    IIF(ar.Id IS NULL,'N','Y') AS 'Has Recruiter'
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
ORDER BY ajp.Created DESC