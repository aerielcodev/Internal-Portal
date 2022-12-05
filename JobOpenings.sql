SELECT
    j.Id AS Id,
    j.JobTitle AS 'Job Title',
    joPosn.Name AS 'Position',
    joType.Name AS 'Type',
    joTeam.Name AS 'Team',
    js.Name AS 'Job Opening Status',
    j.IdealStartDate AS 'Ideal Start Date',
    j.Budget AS Budget,
    jp.JobOpeningNumber AS 'Job Opening Number',
    t.Name AS 'Team Name',
    r.FirstName + ' ' + r.LastName AS Recruiter,
    CASE
    WHEN j.DifficultyId = 1 THEN 'Easy'
    WHEN j.DifficultyId = 2 THEN 'Medium'
    WHEN j.DifficultyId = 3 THEN 'Hard'
    END AS Difficulty,
    j.IsCustomerCreated AS IsCustomerCreated,
    j.Created AS Created,
    ud.FirstName + ' ' + ud.LastName AS 'Created By',
    md.FirstName + ' ' + md.LastName AS 'Modified By',
    jp.VerifiedStatusChangeDate AS VerifiedStatusChangeDate
FROM JobOpenings j
LEFT JOIN JobOpeningPositions jp ON j.Id = jp.JobOpeningId
LEFT JOIN JobOpeningStatuses js ON js.Id = jp.JobOpeningStatusId
LEFT JOIN JobPositions joPosn ON joPosn.Id = j.JobPositionId
LEFT JOIN JobTypes joType ON joType.Id = joPosn.JobTypeId
LEFT JOIN JobTeams joTeam ON joTeam.Id = joType.JobTeamId
LEFT JOIN Customers c ON c.Id = j.CustomerId
LEFT JOIN UserDetails ud ON ud.UserId = j.CreatedBy /*Created by User*/
LEFT JOIN UserDetails md ON md.UserId = j.CreatedBy /*Modified by User*/
LEFT JOIN Teams t ON t.Id = j.TeamId
LEFT JOIN (
    SELECT
        Employees.Id AS eId,
        UserDetails.*
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
) AS r ON  r.eId = j.RecruiterId /*Looks for the Recruiter assigned to the Job Opening*/
