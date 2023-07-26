/*displays all applicants who are qualified and sent to the Active Pool tab*/
SELECT
    a.Id AS ApplicantId,
    cp.CandidateId,
    CONCAT(TRIM(a.FirstName),' ',TRIM(a.LastName)) AS Applicant,
    iif(cb.UserId IS NULL,a.CreatedBy,CONCAT(cb.FirstName,' ',cb.LastName)) AS CreatedBy,
    a.Created AS ApplicationDate,
    cp.QualifiedDate,
    r.recruiter AS Recruiter,     
    DATEDIFF(day,a.Created,cp.QualifiedDate) AS 'Days from Application to Qualified'
FROM Applicants a
LEFT JOIN UserDetails cb ON cb.UserId = a.CreatedBy
INNER JOIN ApplicantJobPostings ap ON ap.ApplicantId = a.Id
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
    ) 
ORDER BY a.Created DESC