SELECT 
    es.Id,
    es.ShiftStart,
    es.ShiftEnd,
    es.ShiftSchedule,
    ud.Email AS Email, 
    ud.CodevId AS 'Employee Number', 
    upper(ud.FirstName +' ' + ud.LastName) AS Name,
    [EffectiveDate]
  FROM [dbo].[EmployeeShifts] es
  INNER JOIN Employees e ON e.Id = es.EmployeeId
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 