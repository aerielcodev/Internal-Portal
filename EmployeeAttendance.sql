SELECT DISTINCT
ea.EmployeeId ,
ea.Id AS ID,
 ud.Email AS Email, 
 ud.CodevId AS 'Employee Number', 
 ud.FirstName AS 'First Name', 
 ud.LastName AS 'Last Name' , 
 ea.TimeIn AS 'Time In', 
 ea.TimeOut AS 'Time Out', 
 ea.TotalHours AS 'Total Hours', 
 s.ShiftStart AS 'PH Shift Start', 
 s.ShiftEnd AS 'PH Shift End', 
 s.ShiftSchedule AS 'Shift Schedule' 
 FROM EmployeeAttendances ea 
 INNER JOIN Employees e ON e.Id = ea.EmployeeId 
 INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
 LEFT JOIN EmployeeShifts s ON s.EmployeeId = e.Id


