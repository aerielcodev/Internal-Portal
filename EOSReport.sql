SELECT 
        eosR.[Id], 
        eosR.[EmployeeId], 
        ud.Email AS Email, 
        ud.CodevId AS 'Employee Number', 
        ud.FirstName AS 'First Name', 
        ud.LastName AS 'Last Name' , 
        eosR.[CreatedBy], 
        eosR.[Created], 
        eosR.[LastModifiedBy], 
        eosR.[LastModified], 
        eosR.[CustomerId], 
        eosR.[EOSDate],
        s.FirstName + ' ' + s.LastName AS Supervisor,
        s.Email AS SupEmail
FROM [dbo].[EndOfShiftReports] eosR 
INNER JOIN Employees e ON e.Id = eosR.EmployeeId 
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
LEFT JOIN (SELECT es.EmployeeId,u.* 
FROM EmployeeSupervisors es 
LEFT JOIN Employees e2 ON e2.id = es.SupervisorId 
LEFT JOIN UserDetails u ON  e2.UserId = u.UserId) s ON s.EmployeeId = e.Id
ORDER BY EOSDate DESC
