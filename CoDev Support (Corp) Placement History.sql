SELECT
    ce.id,
    emp.Email,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    ce.JobTitle AS 'Job Title',
    c.CompanyName,
    CONVERT(date,ce.DateStart) AS Placement,
    CONVERT(date,ce.DateEnd) AS 'Placement End',
    upper(trim(cb.FirstName) + ' ' + trim(cb.LastName)) AS CreatedBy,
    upper(trim(cb.FirstName) + ' ' + trim(cb.LastName)) AS LastModifiedBy
FROM Customers c 
INNER JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
INNER JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cb ON cb.UserId = ce.CreatedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) mb ON mb.UserId = ce.LastModifiedBy
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND (c.CompanyName LIKE 'codev%' OR c.CompanyName LIKE '%breakthrough%') AND ce.IsDeleted = 0
ORDER BY [Team Member] ASC