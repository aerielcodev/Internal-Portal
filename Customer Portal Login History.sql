SELECT DISTINCT
      l.[Id],
      l.[UserId],
      l.[Email],
      l.[DateTime] AS 'UTC DateTime',
      ud.FirstName + ' ' + ud.LastName AS Name,
      c.CompanyName AS Customer,
      c.Id AS customerId,
      cr.Name AS 'Role Name',
      u.IsActive
  FROM [dbo].[CustomerPortalLogins] l
  INNER JOIN CustomerUserDetails ud ON ud.UserId = l.UserId
  INNER JOIN CustomerUsers u ON u.CustomerUserDetailsId = ud.Id
  LEFT JOIN Customers c ON c.Id = u.CustomerId
  LEFT JOIN CustomerUserRoles cr ON cr.Id = u.CustomerUserRoleId
  WHERE ud.Status = 1
  AND c.Id != 281 AND 
  (c.CompanyName NOT LIKE 'codev%' 
  AND c.CompanyName NOT LIKE '%breakthrough%' 
  AND c.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/ 
  ORDER BY l.[DateTime] DESC
