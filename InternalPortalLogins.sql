SELECT 
    il.Id,
    il.DateTime AS 'Date',
    il.Email,
    ud.CodevId AS 'Employee Number',
    CONCAT(trim(ud.FirstName),' ',trim(ud.LastName)) AS Name
  FROM InternalPortalLogins il
  JOIN UserDetails ud ON ud.UserId = il.UserId