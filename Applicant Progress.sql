/*displays various applicant touchpoints*/
WITH EarliestRecord AS (
    SELECT
        ApplicantJobPostingId,
        MIN(Created) AS EarliestCreated,
        ApplicationStageId
    FROM
        ApplicantJobPostingProgresses
    GROUP BY
        ApplicantJobPostingId,ApplicationStageId
)

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
    IIF(ub.FirstName IS NULL,ajp.CreatedBy,CONCAT(ub.FirstName,' ',ub.LastName)) AS 'Status Updated By'
FROM Applicants a
LEFT JOIN UserDetails cb ON cb.UserId = a.CreatedBy
LEFT JOIN ApplicantJobPostings ap ON ap.ApplicantId = a.Id
LEFT JOIN JobPostings jp ON jp.Id = ap.JobPostingId
LEFT JOIN CandidateProfileInformations cp ON cp.Id = ap.CandidateId
/*LEFT JOIN ApplicantJobPostingProgresses ajp ON ajp.ApplicantJobPostingId = ap.Id*/
LEFT JOIN (
    SELECT
     t.*
FROM
    ApplicantJobPostingProgresses t
JOIN
    EarliestRecord er
ON
    t.ApplicantJobPostingId = er.ApplicantJobPostingId
    AND t.Created = er.EarliestCreated
    AND t.Created >= er.EarliestCreated
    AND t.Created <= DATEADD(HOUR, 24, er.EarliestCreated) 
) ajp ON ajp.ApplicantJobPostingId = ap.Id 
LEFT JOIN ApplicationStages ast ON ast.Id = ajp.ApplicationStageId
/*LEFT JOIN (     
    SELECT         
    Employees.Id AS eId,         
    UserDetails.FirstName + ' ' + UserDetails.LastName AS recruiter     
    FROM Employees     
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId) AS r ON r.eId = cp.RecruiterId*/
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