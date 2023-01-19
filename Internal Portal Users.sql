SELECT DISTINCT
      u.UserId,
      u.Email,
      u.FirstName + ' ' + u.LastName AS Name,
      u.CodevId
  FROM UserDetails u
  WHERE (u.FirstName + ' ' + u.LastName IS NOT NULL) AND (u.FirstName + ' ' + u.LastName != ' ') 
