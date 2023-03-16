SELECT
    ce.EmployeeId,
    ce.id,
    emp.CoDevId,
    upper(emp.FirstName + ' ' + emp.LastName) AS 'Team Member',
    ce.jobTitle AS 'Job Title',
    c.CompanyName,
    ce.DateStart,
    ce.DateEnd,
    cb.FirstName + ' ' + cb.LastName AS 'Created By',
    m.FirstName + ' ' + m.LastName AS 'Modified By'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) m ON m.UserId = ce.LastModifiedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cb ON cb.UserId = ce.CreatedBy
WHERE c.Id = 1 AND ce.IsDeleted = 0
AND (emp.FirstName NOT LIKE '%demo%'  AND  emp.FirstName NOT LIKE '%demo%')
ORDER BY [Team Member] ASC