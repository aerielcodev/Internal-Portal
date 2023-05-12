SELECT DISTINCT
      l.[Id],
      l.[UserId],
      l.[Email],
      l.[DateTime] AS 'UTC DateTime',
      ud.FirstName + ' ' + ud.LastName AS Name,
      c.CompanyName AS Customer,
      cr.Name AS 'Role Name',
      u.IsActive
  FROM [dbo].[CustomerPortalLogins] l
  INNER JOIN CustomerUserDetails ud ON ud.UserId = l.UserId
  INNER JOIN CustomerUsers u ON u.CustomerUserDetailsId = ud.Id
  LEFT JOIN Customers c ON c.Id = u.CustomerId
  LEFT JOIN CustomerUserRoles cr ON cr.Id = u.CustomerUserRoleId
  ORDER BY l.[DateTime] DESC
