SELECT

    CONVERT(date,ce.DateStart) AS 'Placement/Offboard',
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    c.CompanyName,
    CONVERT(date,ce.DateStart) AS Placement,
    CONVERT(date,ce.DateEnd) AS 'Placement End',
    'Placement' AS 'Group',
    cr.FirstName + ' ' + cr.LastName AS 'Created By',
    m.FirstName + ' ' + m.LastName AS 'Modified By'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%' )
UNION ALL
SELECT
    CONVERT(date,ce.DateEnd),
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)),
    c.CompanyName,
    CONVERT(date,ce.DateStart) ,
    CONVERT(date,ce.DateEnd) ,
    'Offboard' AS 'Group',
    cr.FirstName + ' ' + cr.LastName,
    m.FirstName + ' ' + m.LastName
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%')  AND ce.DateEnd IS NOT NULL
