SELECT DISTINCT
      l.[Id],
      l.[UserId],
      l.[Email],
      l.[DateTime] AS 'UTC DateTime',
      u.FirstName + ' ' + u.LastName AS Name,
      c.CompanyName AS Customer,
      cr.Name AS 'Role Name',
      u.IsActive
  FROM [dbo].[CustomerPortalLogins] l
  INNER JOIN CustomerUsers u ON u.UserId = l.UserId
  LEFT JOIN Customers c ON c.Id = u.CustomerId
  LEFT JOIN CustomerUserRoles cr ON cr.Id = u.CustomerUserRoleId
  ORDER BY l.[DateTime] DESC
