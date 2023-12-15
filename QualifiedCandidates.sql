WITH placedTeamMembers AS (
    SELECT
        e.CandidateProfileInformationId,
        ud.CodevId,
        jop.Id AS JobOpeningPositionId,
        c.CompanyName,
        jon.Number AS jobOpeningNumber,
        ce.JobTitle,
        CAST(ce.DateStart AS date) AS firstPlacementDate
    FROM dbo.JobOpeningNumbers jon 
    JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
    JOIN JobOpenings j ON j.Id = jop.JobOpeningId
    JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id AND ce.isDeleted = 0
    JOIN Employees e ON e.Id = ce.EmployeeId
    JOIN UserDetails ud ON ud.UserId = e.UserId
    JOIN Customers c ON c.Id = ce.CustomerId
    LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
    WHERE 
        c.Id NOT IN (1, 281)
    AND c.CompanyName NOT LIKE 'codev%'
    AND c.CompanyName NOT LIKE '%breakthrough%'
    AND ce.Id IS NOT NULL 
), 
recruitersWithPods AS (
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

SELECT DISTINCT
    cp.Id AS 'Id',   
    ap.Id AS ApplicantJobPostingId,
    CONCAT(trim(REPLACE(cp.FirstName,char(9),'')) , ' ' , trim(cp.LastName)) AS Name,     
    s.Name AS Status,     
    CASE         
        WHEN cp.GenderId  = 1 THEN 'Male'         
        WHEN cp.GenderId = 2 THEN 'Female'         
        ELSE 'Not Specified'     
    END AS Gender,     
        isnull(cp.QualifiedDate,cp.Created) AS 'Qualified Date',   
        cp.Email,  
        cp.ContactNumber,
        r.recruiter AS Recruiter,     
    pt.firstPlacementDate AS 'First Placement',
    pt.CompanyName AS Customer,
    pt.jobOpeningNumber AS 'Job Opening Number',
    pt.CodevId AS 'CoDev Id',
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
    rp.Pod,
    cp.Created,     
    o.offices AS 'Preferred Office',
    ps.preferredShifts AS 'Shift Availability',
    ao.Name AS Availability,
    cp.AvailabilityCustomDate AS 'Availability Custom Date',
    qPosn.posn AS 'Qualified Positions',
    qPosn.types AS 'Qualified Types',
    qPosn.teams AS 'Qualified Teams',
    cp.CurrentSalary,
    cp.DesiredSalaryMin,
    cp.DesiredSalaryMax,
    st.Name AS State,
    c.Name AS Country,  
    c.Code AS CountryCode,
    cp.City,
    cp.ZipCode,
    cp.RecruiterId
FROM CandidateProfileInformations cp 
LEFT JOIN CandidateStatuses s ON s.Id = cp.CandidateStatusId 
LEFT JOIN (     
    SELECT         
    Employees.Id AS eId,         
    UPPER(CONCAT(TRIM(UserDetails.FirstName) , ' ' , TRIM(UserDetails.LastName))) AS recruiter     
    FROM Employees     
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId) AS r ON r.eId = cp.RecruiterId
LEFT JOIN (
    SELECT
        CandidatePreferredOfficeLocations.CandidateProfileInformationId AS cpId,
        string_agg(Offices.Location,',') AS offices
    FROM CandidatePreferredOfficeLocations
    LEFT JOIN Offices ON Offices.Id = CandidatePreferredOfficeLocations.OfficeId
GROUP BY CandidatePreferredOfficeLocations.CandidateProfileInformationId) AS o ON o.cpId = cp.Id
LEFT JOIN (
    SELECT
        CandidateProfileInformationId,
        string_agg(jp.Name,', ') AS posn,
        string_agg(jt.Name,', ') AS types,
        string_agg(jteam.Name,', ') AS teams
  FROM CandidateQualifiedPositions qp
  INNER JOIN JobPositions jp ON jp.Id = qp.JobPositionId
  INNER JOIN JobTypes jt ON jt.Id = jp.JobTypeId
  INNER JOIN JobTeams jteam ON jteam.Id = jt.JobTeamId
  GROUP BY CandidateProfileInformationId
) AS qPosn ON qPosn.CandidateProfileInformationId = cp.Id
LEFT JOIN (
    SELECT
        STRING_AGG(
            CASE
                WHEN ShiftScheduleId = 1 THEN 'Morning'
                WHEN ShiftScheduleId = 2 THEN 'Mid'
                WHEN ShiftScheduleId = 3 THEN 'Night'
            END,
            ', '
        ) AS preferredShifts,
        CandidateProfileInformationId
    FROM CandidatePreferredShifts
    GROUP BY CandidateProfileInformationId
) AS ps ON ps.CandidateProfileInformationId = cp.Id
LEFT JOIN AvailabilityOptions ao ON ao.Id = cp.AvailabilityId
LEFT JOIN ApplicantJobPostings ap ON cp.Id = ap.CandidateId
LEFT JOIN Countries c ON c.Id = cp.CountryId
LEFT JOIN States st ON st.Id = cp.StateId
LEFT JOIN recruitersWithPods rp ON rp.EmployeeId = cp.RecruiterId 
AND (CONVERT(date,cp.Created) >= rp.Placement 
 AND (CONVERT(date,cp.Created) <= rp.PlacementEnd OR rp.PlacementEnd IS NULL))
OUTER APPLY (
    SELECT TOP 1 *  FROM placedTeamMembers WHERE CandidateProfileInformationId = cp.Id ORDER BY firstPlacementDate ASC
) AS pt
WHERE (cp.FirstName NOT LIKE '%demo%' AND cp.FirstName NOT LIKE '%test%' AND cp.LastName NOT LIKE '%demo%')
ORDER BY 'Qualified Date' DESC
