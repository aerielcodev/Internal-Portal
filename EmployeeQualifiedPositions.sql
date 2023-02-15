SELECT
    ep.Id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    jTeam.Name AS Team,
    jt.Name AS 'Type',
    jp.Name AS Position
FROM EmployeeJobPositions ep
LEFT JOIN JobPositions jp ON ep.JobPositionId = jp.id
LEFT JOIN JobTypes jt ON jt.id = jp.JobTypeId
LEFT JOIN JobTeams jTeam ON jTeam.id = jt.JobTeamId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ep.EmployeeId
