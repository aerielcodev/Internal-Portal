SELECT DISTINCT
pto.Id AS Id, 
s.Name AS 'Status', 
ud.Email AS Email, 
ud.CodevId AS 'Employee Number', 
ud.FirstName AS 'First Name', 
ud.LastName AS 'Last Name' , 
pto.Created AS 'PTO File Date', 
ft.Name AS 'Filing Type', 
lt.Name AS 'Leave Type', 
pto.DateFrom AS 'Date From', 
pto.DateTo AS 'Date To', 
pto.LeaveCount AS 'Leave Qty', 
pto.ApprovalDate AS 'Approval Date' ,
CASE
WHEN cu.UserId IS NULL
THEN app.FirstName + ' ' + app.LastName
ELSE cu.FirstName + ' ' + cu.LastName
END AS Approver,
cu.UserId AS 'Customer UserId'
FROM [dbo].[Ptos] pto 
LEFT JOIN [dbo].[FilingTypes] ft ON ft.Id = pto.FilingTypeId 
LEFT JOIN [dbo].[PtoStatuses] s ON s.Id = pto.StatusId 
LEFT JOIN [dbo].[LeaveTypes] lt ON lt.Id = pto.LeaveTypeId 
INNER JOIN Employees e ON e.Id = pto.EmployeeId 
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
LEFT JOIN EmployeeHRReferences hr ON hr.Id = e.EmployeeHrReferenceId
LEFT JOIN UserDetails app ON app.UserId = pto.ApprovalBy
LEFT JOIN CustomerUserDetails cu ON cu.UserId = pto.ApprovalBy
ORDER BY Id DESC