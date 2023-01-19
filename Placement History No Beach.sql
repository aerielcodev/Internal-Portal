SELECT
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    ce.JobTitle AS 'Job Title',
    c.CompanyName,
    ce.DateStart AS Placement,
    CONVERT(date,ce.DateEnd  AT TIME ZONE 'Mountain Standard Time') AS 'Placement End',
    current_timezone()
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%' 
ORDER BY [Team Member] ASC