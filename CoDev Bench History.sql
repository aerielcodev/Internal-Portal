SELECT
    emp.CoDevId,
    upper(emp.FirstName + ' ' + emp.LastName) AS 'Team Member',
    c.CompanyName,
    ce.DateStart,
    ce.DateEnd
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
WHERE c.Id = 1