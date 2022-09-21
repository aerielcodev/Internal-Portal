SELECT 
    ce.Id,
    ud.CodevId AS 'Employee Number',
    ud.FirstName + ' ' + ud.LastName AS Name,
    ce.JobTitle,
    ce.DateStart,
    ce.DateEnd   
FROM [dbo].[CustomerEmployees] ce
INNER JOIN Employees e ON e.Id = ce.EmployeeId
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
where CustomerId = 3