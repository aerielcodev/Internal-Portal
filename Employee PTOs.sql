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
WHEN c.userId IS NULL
THEN app.FirstName + ' ' + app.LastName
ELSE c.Name
END AS Approver,
c.userId AS 'Customer UserId'
FROM [dbo].[Ptos] pto 
LEFT JOIN [dbo].[FilingTypes] ft ON ft.Id = pto.FilingTypeId 
LEFT JOIN [dbo].[PtoStatuses] s ON s.Id = pto.StatusId 
LEFT JOIN [dbo].[LeaveTypes] lt ON lt.Id = pto.LeaveTypeId 
INNER JOIN Employees e ON e.Id = pto.EmployeeId 
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
LEFT JOIN EmployeeHRReferences hr ON hr.Id = e.EmployeeHrReferenceId
LEFT JOIN UserDetails app ON app.UserId = pto.ApprovalBy
LEFT JOIN 
(SELECT u.FirstName + ' ' + u.LastName AS Name,
l.UserId AS userId
FROM CustomerPortalLogins l
LEFT JOIN CustomerUsers u ON u.UserId = l.UserId) c ON c.userId = pto.ApprovalBy
ORDER BY Id DESC
