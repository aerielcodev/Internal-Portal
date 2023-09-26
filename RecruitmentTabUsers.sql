SELECT 
CONCAT(trim(ud.FirstName),' ',trim(ud.LastName)) AS Name,
ep.Name AS Position,
p.Name AS Permission,
ce.DateStart,
ce.DateEnd,
ce.JobTitle,
c.CompanyName
FROM Employees e
JOIN EmployeePositions ep on e.EmployeePositionId = ep.Id
JOIN RolePermissions rp on rp.EmployeePositionId = ep.Id
JOIN UserDetails ud on e.UserId = ud.UserId
JOIN Permissions p ON p.Id = rp.PermissionId
JOIN CustomerEmployees ce ON ce.EmployeeId = e.Id AND ce.IsDeleted = 0
JOIN Customers c ON c.Id = ce.CustomerId
WHERE rp.PermissionId = 13 AND c.Id IN (161,173) /*CoDev Corp and CoDev Recruiting Company IDs*/