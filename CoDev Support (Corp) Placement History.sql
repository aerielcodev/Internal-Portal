SELECT
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    c.CompanyName,
    CONVERT(date,ce.DateStart) AS Placement,
    CONVERT(date,ce.DateEnd) AS 'Placement End'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName LIKE 'codev%' OR c.CompanyName LIKE '%breakthrough%')
ORDER BY [Team Member] ASC