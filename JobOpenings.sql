SELECT
    j.Id AS Id,
    j.JobTitle AS 'Job Title',
    c.CompanyName AS Customer,
    joPosn.Name AS 'Position',
    joType.Name AS 'Type',
    joTeam.Name AS 'Team',
    js.Name AS 'Job Opening Status',
    j.IdealStartDate AS 'Ideal Start Date',
    j.Budget AS Budget,
    jp.JobOpeningNumber AS 'Job Opening Number',
    t.Name AS 'Team Name',
    r.recruiter AS Recruiter,
    ofc.location AS 'Office Location',
    CASE
        WHEN j.DifficultyId = 1 THEN 'Easy'
        WHEN j.DifficultyId = 2 THEN 'Medium'
        WHEN j.DifficultyId = 3 THEN 'Hard'
    END AS Difficulty,
    j.IsCustomerCreated AS IsCustomerCreated,
    j.Created AS Created,
    jp.VerifiedStatusChangeDate AS VerifiedStatusChangeDate
FROM JobOpenings j
LEFT JOIN JobOpeningPositions jp ON j.Id = jp.JobOpeningId
LEFT JOIN JobOpeningStatuses js ON js.Id = jp.JobOpeningStatusId
LEFT JOIN JobPositions joPosn ON joPosn.Id = j.JobPositionId
LEFT JOIN JobTypes joType ON joType.Id = joPosn.JobTypeId
LEFT JOIN JobTeams joTeam ON joTeam.Id = joType.JobTeamId
LEFT JOIN (
    SELECT
    JobOpeningLocations.JobOpeningId AS JobOpeningId,
    string_agg(Offices.Location,',') AS location
FROM JobOpeningLocations
INNER JOIN Offices ON Offices.Id = JobOpeningLocations.OfficeId
GROUP BY JobOpeningLocations.JobOpeningId) AS ofc ON ofc.JobOpeningId = j.Id
LEFT JOIN Customers c ON c.Id = j.CustomerId
LEFT JOIN Teams t ON t.Id = j.TeamId
LEFT JOIN (
    SELECT
        Employees.Id AS eId,
        string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',') recruiter
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY Employees.Id) AS r ON  r.eId = j.RecruiterId /*Looks for the Recruiter assigned to the Job Opening*/

