SELECT 
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
        s.ShiftSchedule AS 'Shift Schedule' ,
        sup.FirstName + ' ' + sup.LastName AS Supervisor,
        sup.Email AS SupEmail
FROM EmployeeAttendances ea 
INNER JOIN Employees e ON e.Id = ea.EmployeeId 
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
LEFT JOIN EmployeeShifts s ON s.EmployeeId = e.Id
LEFT JOIN (SELECT es.EmployeeId,u.* 
FROM EmployeeSupervisors es 
LEFT JOIN Employees e2 ON e2.id = es.SupervisorId 
LEFT JOIN UserDetails u ON  e2.UserId = u.UserId) sup ON sup.EmployeeId = e.Id
