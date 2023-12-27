WITH recruitersWithPods AS (
    SELECT
    ce.id AS customerEmployeesId,
    ce.EmployeeId,
    emp.CoDevId,
    emp.recruiter,
    ce.JobTitle,
    CASE /*Assign Alyssa and Julie to their respective pods*/
        WHEN emp.CoDevId = '2019-1189' THEN 'CoDev Recruitment (Alyssa)' 
        WHEN emp.CoDevId = '2020-1293' THEN 'CoDev Recruitment (Julie)'
        ELSE c.CompanyName
    END AS Pod,
    CONVERT(date,ce.DateStart) AS Placement,
    COALESCE(CONVERT(date,ce.DateEnd),CONVERT(date,emp.DeletedDate)) AS placementEnd
FROM Customers c 
JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
JOIN (
    SELECT 
    UPPER(CONCAT(TRIM(emp.FirstName),' ',TRIM(emp.LastName))) as recruiter,
    e.Id, 
    e.DeletedDate,
    emp.CodevId 
    FROM Employees e 
    JOIN UserDetails emp ON emp.UserId = e.UserId
    ) emp ON emp.Id = ce.EmployeeId
WHERE ce.IsDeleted = 0 
    AND LOWER(c.CompanyName) LIKE 'codev recruit%' 
    AND LOWER(ce.JobTitle) LIKE 'recruit%'
)


SELECT
    jop.Id AS JobOpeningPositionId,
    j.Id AS JobOpeningId,
    jon.Number AS 'Job Opening Number',
    j.JobTitle AS 'Job Title',
    c.CompanyName AS Customer,
    jt.Name AS 'Job Type',
    js.Name AS 'Job Opening Status',
    ce.DateStart,
    UPPER(CONCAT(TRIM(ud.FirstName),' ',TRIM(ud.LastName))) AS 'Team Member',
    r.Recruiter AS 'Job Opening Assigned Recruiter',
    r.Pod AS 'Job Opening Assigned Pod'
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
INNER JOIN JobOpeningStatuses js ON js.Id = jop.JobOpeningStatusId
INNER JOIN Customers c ON c.Id = j.CustomerId
LEFT JOIN (
    SELECT
        STRING_AGG(rp.recruiter,', ') AS Recruiter,
        STRING_AGG(rp.Pod,', ') AS Pod,
        jr.JobOpeningId
    FROM JobOpeningRecruiters jr
    JOIN recruitersWithPods rp ON rp.EmployeeId = jr.RecruiterId
    WHERE CONVERT(date,jr.Created) >= rp.Placement 
        AND (CONVERT(date,jr.Created) <= rp.placementEnd OR rp.placementEnd IS NULL)
    GROUP BY jr.JobOpeningId) AS r ON  r.JobOpeningId = j.Id /*Looks for the Recruiter assigned to the Job Opening*/
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id AND ce.IsDeleted = 0
INNER JOIN Employees e ON e.Id = ce.EmployeeId AND e.CandidateProfileInformationId IS NOT NULL
INNER JOIN CandidateProfileInformations cpi ON e.CandidateProfileInformationId = cpi.Id
INNER JOIN JobOpeningCandidates jc ON (jc.CandidateId = cpi.Id AND jc.JobOpeningId  = j.Id) AND jc.CandidateId IS NOT NULL
INNER JOIN UserDetails ud ON ud.UserId = e.UserId
WHERE j.CustomerId != 281 AND 
(c.CompanyName NOT LIKE 'codev%' 
AND c.CompanyName NOT LIKE '%breakthrough%' 
AND c.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/ 
AND j.isDeleted = 0
ORDER BY ce.DateStart DESC