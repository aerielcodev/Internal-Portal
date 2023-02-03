SELECT
    ce.DateStart AS 'Placement/Offboard',
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    c.CompanyName,
    ce.DateStart AS Start,
    ce.DateEnd AS End,
    'Placement' AS 'Group',
    cr.FirstName + ' ' + cr.LastName AS 'Created By',
    m.FirstName + ' ' + m.LastName AS 'Modified By'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%' ) AND c.Id != 281
UNION ALL
SELECT
    ce.DateEnd,
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)),
    c.CompanyName,
   ce.DateStart ,
   ce.DateEnd ,
    'Offboard' AS 'Group',
    cr.FirstName + ' ' + cr.LastName,
    m.FirstName + ' ' + m.LastName
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cr ON cr.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%')  AND ce.DateEnd IS NOT NULL AND c.Id != 281
