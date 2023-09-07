SELECT DISTINCT
pto.Id AS Id, 
pto.EmployeeId,
s.Name AS 'Status', 
ud.Email AS Email, 
ud.CodevId AS 'Employee Number', 
CONCAT(ud.FirstName,' ',ud.LastName) AS 'Team Member',
ec.Name AS 'Member Category',
pto.Created AS 'PTO File Date', 
ft.Name AS 'Filing Type', 
lt.Name AS 'Leave Type', 
CAST(pto.DateFrom AS date) AS 'Date From', 
CAST(pto.DateTo AS date) AS 'Date To', 
pto.LeaveCount AS 'Leave Qty', 
pto.ApprovalDate AS 'Approval Date' ,
CASE
WHEN cu.UserId IS NULL
THEN app.FirstName + ' ' + app.LastName
ELSE cu.FirstName + ' ' + cu.LastName
END AS Approver,
cu.UserId AS 'Customer UserId',
iif(e.DeletedDate IS NULL,'Y','N') AS isActive

FROM [dbo].[Ptos] pto 
LEFT JOIN [dbo].[FilingTypes] ft ON ft.Id = pto.FilingTypeId 
LEFT JOIN [dbo].[PtoStatuses] s ON s.Id = pto.StatusId 
LEFT JOIN [dbo].[LeaveTypes] lt ON lt.Id = pto.LeaveTypeId 
INNER JOIN Employees e ON e.Id = pto.EmployeeId 
INNER JOIN UserDetails ud ON ud.UserId = e.UserId 
LEFT JOIN UserDetails app ON app.UserId = pto.ApprovalBy
LEFT JOIN CustomerUserDetails cu ON cu.UserId = pto.ApprovalBy
LEFT JOIN EmployeeCategories ec ON ec.Id = e.CategoryId
ORDER BY Id DESC