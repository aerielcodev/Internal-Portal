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
    ri.NewRate AS Rate,
    emp.teamMember,
    j.Budget AS Budget,
    jon.Number AS 'Job Opening Number',
    t.Name AS 'Team Name',
    ps.placementSup AS 'Placement Supervisor',
    NULL AS Recruiter,  /*placeholder while waiting for Recruiter field*/
    ofc.location AS 'Office Location',
    CASE
        WHEN j.DifficultyId = 1 THEN 'Easy'
        WHEN j.DifficultyId = 2 THEN 'Medium'
        WHEN j.DifficultyId = 3 THEN 'Hard'
    END AS Difficulty,
    j.IsCustomerCreated AS IsCustomerCreated,
    j.Created AS Created,
    j.CreatedBy AS CreatedByUserId,
    jop.VerifiedStatusChangeDate AS VerifiedStatusChangeDate,
    j.RecruiterId AS placementSupervisorId
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
LEFT JOIN RateIncreases ri ON ri.EmployeeId = ce.EmployeeId AND ri.EffectiveDate = ce.DateStart
LEFT JOIN (
    SELECT
        Employees.Id AS eId,
        string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',') placementSup
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY Employees.Id) AS ps ON  ps.eId = j.RecruiterId /*Looks for the Recruiter assigned to the Job Opening*/
WHERE j.CustomerId != 281 AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%' AND c.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/ 
