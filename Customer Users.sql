SELECT DISTINCT
      u.Id,
      ud.UserId,
      ud.Email,
      ud.FirstName + ' ' + ud.LastName AS Name,
      c.CompanyName AS Customer,
      cr.Name AS 'Role Name',
      ud.[Status],
      u.IsActive,
      IIF(cr.CustomerId IS NOT NULL,'Y','N') AS 'Custom Role'
  FROM CustomerUsers u
  INNER JOIN CustomerUserDetails ud ON u.CustomerUserDetailsId = ud.Id
  LEFT JOIN Customers c ON c.Id = u.CustomerId
  LEFT JOIN CustomerUserRoles cr ON cr.Id = u.CustomerUserRoleId
  WHERE (ud.FirstName + ' ' + ud.LastName IS NOT NULL) AND (ud.FirstName + ' ' + ud.LastName != ' ') AND u.CustomerId != 281
