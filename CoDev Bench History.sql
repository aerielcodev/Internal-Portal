SELECT
    ce.EmployeeId,
    ce.id,
    emp.CoDevId,
    upper(emp.FirstName + ' ' + emp.LastName) AS 'Team Member',
    ce.jobTitle AS 'Job Title',
    c.CompanyName,
    ce.DateStart,
    coalesce(ce.DateEnd, e.DeletedDate) AS DateEnd,
    coalesce(lRate.NewRate,lRate2.NewRate) AS 'Latest Rate',
    ePosn.teams AS 'Qualified Teams',
    ePosn.types AS 'Qualified Types',
    ePosn.posn AS 'Qualified Positions',
    cb.FirstName + ' ' + cb.LastName AS 'Created By',
    m.FirstName + ' ' + m.LastName AS 'Modified By',
    cs.Name AS 'Active Pool Status'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id, e.CandidateStatusId FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cb ON cb.UserId = ce.CreatedBy
LEFT JOIN Employees e ON e.Id = ce.EmployeeId AND e.Status = 3
LEFT JOIN CandidateStatuses cs ON cs.Id = emp.CandidateStatusId
LEFT JOIN (
    SELECT
        EmployeeId,
        string_agg(jp.Name,', ') AS posn,
        string_agg(jt.Name,', ') AS types,
        string_agg(jteam.Name,', ') AS teams
  FROM EmployeeJobPositions ep
  INNER JOIN JobPositions jp ON jp.Id = ep.JobPositionId
  INNER JOIN JobTypes jt ON jt.Id = jp.JobTypeId
  INNER JOIN JobTeams jteam ON jteam.Id = jt.JobTeamId
  GROUP BY EmployeeId
) AS ePosn ON ePosn.EmployeeId = ce.EmployeeId
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE CustomerEmployeeId = ce.Id ORDER BY EffectiveDate DESC
    ) AS lRate
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId ORDER BY EffectiveDate DESC
    ) AS lRate2
WHERE c.Id = 1 AND ce.IsDeleted = 0
AND (emp.FirstName NOT LIKE '%demo%'  AND  emp.FirstName NOT LIKE '%demo%')
ORDER BY ce.DateStart DESC