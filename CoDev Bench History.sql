SELECT
    ce.id,
    emp.CoDevId,
    upper(emp.FirstName + ' ' + emp.LastName) AS 'Team Member',
    c.CompanyName,
    ce.DateStart,
    ce.DateEnd,
    cb.FirstName + ' ' + cb.LastName,
    m.FirstName + ' ' + m.LastName
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cb ON c.UserId = ce.LastModifiedBy
WHERE c.Id = 1 
ORDER BY [Team Member] ASC