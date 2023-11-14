SELECT DISTINCT
    j.Id AS Id,
    c.id AS CustomerId,
    jop.Id AS JobOpeningPositionId,
    jop.JobOpeningStatusId,
    jt.Name AS 'Job Type',
    j.JobTitle AS 'Job Title',
    c.CompanyName AS Customer,
    jp.Name AS 'Position',
    joType.Name AS 'Type',
    joTeam.Name AS 'Team',
    CASE
        WHEN c.TypeId = 1 THEN 'Customer'
        WHEN c.TypeId = 2 THEN 'Prospect'
    END AS 'Customer Type',
    js.Name AS 'Job Opening Status',
    j.IdealStartDate AS 'Ideal Start Date',
    ce.DateStart,
    fRate.NewRate AS Rate,
    emp.teamMember,
    j.Budget AS Budget,
    jon.Number AS 'Job Opening Number',
    t.Name AS 'Team Name',
    ps.placementSup AS 'Placement Supervisor',
    r.recruiter AS Recruiter,
    ofc.location AS 'Office Location',
    CASE
        WHEN j.DifficultyId = 1 THEN 'Easy'
        WHEN j.DifficultyId = 2 THEN 'Medium'
        WHEN j.DifficultyId = 3 THEN 'Hard'
    END AS Difficulty,
    j.IsCustomerCreated AS IsCustomerCreated,
    COALESCE(cb.createdBy,CONCAT(cbc.createdByCustomer,' (',c.CompanyName,')')) AS 'Created By',
    j.Created AS Created,
    j.CreatedBy AS CreatedByUserId,
    jop.VerifiedStatusChangeDate AS VerifiedStatusChangeDate,
    j.RecruiterId AS placementSupervisorId,
    j.LastModified,
    mb.lastModified AS 'Last Modified By',
    emp.eId AS teamMemberEmployeeId,
    ce.Id AS customerEmployeesId,
    jop.HubSpotDealId
FROM JobOpeningNumbers jon
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
LEFT JOIN JobOpenings j ON j.Id = jop.JobOpeningId
LEFT JOIN JobOpeningStatuses js ON js.Id = jop.JobOpeningStatusId
LEFT JOIN JobPositions jp ON jp.Id = j.JobPositionId
LEFT JOIN JobTypes joType ON joType.Id = jp.JobTypeId
LEFT JOIN JobTeams joTeam ON joTeam.Id = joType.JobTeamId
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
LEFT JOIN (
    SELECT
    JobOpeningLocations.JobOpeningId AS JobOpeningId,
    string_agg(Offices.Location,',') AS location
FROM JobOpeningLocations
INNER JOIN Offices ON Offices.Id = JobOpeningLocations.OfficeId
GROUP BY JobOpeningLocations.JobOpeningId) AS ofc ON ofc.JobOpeningId = j.Id
LEFT JOIN Customers c ON c.Id = j.CustomerId
LEFT JOIN Teams t ON t.Id = j.TeamId
LEFT JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id AND ce.IsDeleted = 0
LEFT JOIN (
    SELECT
        Employees.Id AS eId,
        string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',') teamMember
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY Employees.Id) AS emp ON  emp.eId = ce.EmployeeId
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId AND customerid = ce.customerid ORDER BY EffectiveDate ASC
    ) AS fRate
LEFT JOIN (
    SELECT
        Employees.Id AS eId,
        UPPER(string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',')) placementSup
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY Employees.Id) AS ps ON  ps.eId = j.RecruiterId /*Looks for the Placement Supervisor assigned to the Job Opening*/
LEFT JOIN (
    SELECT
        STRING_AGG(CONCAT(TRIM(ud.FirstName),' ',TRIM(ud.LastName)),', ') AS Recruiter,
        jr.JobOpeningId
    FROM JobOpeningRecruiters jr
    JOIN Employees e ON e.Id = jr.RecruiterId
    JOIN UserDetails ud ON ud.userId = e.userId
    GROUP BY jr.JobOpeningId) AS r ON  r.JobOpeningId = j.Id/*Looks for the Recruiter assigned to the Job Opening*/
LEFT JOIN (
    SELECT
        UserId,
        concat(UserDetails.FirstName ,' ' ,UserDetails.LastName) lastModified
    FROM  UserDetails
) AS mb ON  mb.UserId = j.LastModifiedBy
LEFT JOIN (
    SELECT DISTINCT
        UserId,
        concat(UserDetails.FirstName ,' ' ,UserDetails.LastName) createdBy
    FROM  UserDetails
) AS cb ON cb.UserId = j.CreatedBy
LEFT JOIN (SELECT DISTINCT
    UserId,
    concat(FirstName ,' ' ,LastName) AS createdByCustomer
FROM CustomerUserDetails) cbc ON cbc.UserId = j.CreatedBy
WHERE j.CustomerId != 281 AND 
(c.CompanyName NOT LIKE 'codev%' 
AND c.CompanyName NOT LIKE '%breakthrough%' 
AND c.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/ 
