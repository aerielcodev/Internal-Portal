SELECT DISTINCT
      u.Id,
      u.UserId,
      u.Email,
      u.FirstName + ' ' + u.LastName AS Name,
      c.CompanyName AS Customer,
      cr.Name AS 'Role Name',
      u.[Status],
      u.IsActive
  FROM CustomerUsers u
  LEFT JOIN Customers c ON c.Id = u.CustomerId
  LEFT JOIN CustomerUserRoles cr ON cr.Id = u.CustomerUserRoleId
  WHERE (u.FirstName + ' ' + u.LastName IS NOT NULL) AND (u.FirstName + ' ' + u.LastName != ' ') AND u.CustomerId != 281
