/*displays all applicants who are qualified and sent to the Active Pool tab*/
SELECT
    a.Id AS ApplicantId,
    cp.Id AS CandidateId,
    CONCAT(TRIM(a.FirstName),' ',TRIM(a.LastName)) AS Applicant,
    iif(cb.UserId IS NULL,a.CreatedBy,CONCAT(cb.FirstName,' ',cb.LastName)) AS CreatedBy,
    ap.DateApplied AS ApplicationDate,
    cp.QualifiedDate,
    r.recruiter AS Recruiter,     
    jp.Title AS 'Associated Job Posting',
    jp.Number,
    DATEDIFF(day,ap.DateApplied,cp.QualifiedDate) AS 'Days from Application to Qualified',
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
    END AS 'Source of Candidate'
FROM Applicants a
LEFT JOIN UserDetails cb ON cb.UserId = a.CreatedBy
LEFT JOIN ApplicantJobPostings ap ON ap.ApplicantId = a.Id
LEFT JOIN JobPostings jp ON jp.Id = ap.JobPostingId
INNER JOIN CandidateProfileInformations cp ON cp.Id = ap.CandidateId
LEFT JOIN (     
    SELECT         
    Employees.Id AS eId,         
    UserDetails.FirstName + ' ' + UserDetails.LastName AS recruiter     
    FROM Employees     
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId) AS r ON r.eId = cp.RecruiterId
WHERE  
    a.Created >= CONVERT(DATE,'2023-05-17') /*date v2 careers was launched*/
AND
(
        LOWER(a.FirstName) NOT LIKE '%test%'
        AND LOWER(a.LastName) NOT LIKE '%test%'
        AND LOWER(a.FirstName) NOT LIKE '%demo%'
        AND LOWER(a.LastName) NOT LIKE '%demo%'
    ) AND ap.StatusId <> 3 /*StatusId = 3 are deleted profiles*/
ORDER BY a.Created DESC