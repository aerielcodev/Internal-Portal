SELECT DISTINCT
    ce.CustomerId,
    ce.DateStart AS 'Placement/Offboard',
    ce.id,
    emp.CoDevId,
    jon.Number AS 'Job Opening Number',
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    jt.Name AS 'Job Opening Type',
    c.CompanyName,
    ce.DateStart AS 'Start',
    ce.PartTimeDate,
    isnull(ft.EffectiveDate,ce.DateStart) AS FullTimeDate,    fRate.NewRate AS 'Rate',
    ce.DateEnd AS 'End',
    'Placement' AS 'Group',
    cr.FirstName + ' ' + cr.LastName AS 'Created By',
    m.FirstName + ' ' + m.LastName AS 'Modified By'
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id
LEFT JOIN Customers c ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId AND customerid = ce.customerid ORDER BY EffectiveDate ASC
    ) AS fRate
LEFT JOIN RateIncreases ft ON ft.CustomerEmployeeId = ce.Id AND ft.ReasonId = 4
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%' ) AND c.Id != 281 AND ce.IsDeleted = 0
UNION ALL
SELECT DISTINCT
ce.CustomerId,
    ce.DateEnd,
    ce.id,
    emp.CoDevId,
    jon.Number,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)),
    jt.Name,
    c.CompanyName,
   ce.DateStart ,
    ce.PartTimeDate,
    isnull(ft.EffectiveDate,ce.DateStart),
   lRate.NewRate,
   ce.DateEnd ,
    'Offboard' AS 'Group',
    cr.FirstName + ' ' + cr.LastName,
    m.FirstName + ' ' + m.LastName
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id
LEFT JOIN Customers c ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId AND CustomerId = ce.CustomerId ORDER BY EffectiveDate DESC
    ) AS lRate
    LEFT JOIN RateIncreases ft ON ft.CustomerEmployeeId = ce.Id AND ft.ReasonId = 4

WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%')  AND ce.DateEnd IS NOT NULL AND c.Id != 281 AND ce.IsDeleted = 0
