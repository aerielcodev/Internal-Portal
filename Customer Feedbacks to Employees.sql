SELECT DISTINCT
    f.Id,
    ft.Name AS 'Feedback Type',
    EmployeeId,
    emp.CodevId AS 'Employee Number', 
    emp.FirstName + ' ' + emp.LastName AS Name,
    c.CompanyName AS Company,
    Message,
    f.CreatedBy,
    cu.FirstName + ' ' + cu.LastName AS 'Created By',
    f.Created,
    LastUpdated,
    IsEscalate
FROM dbo.EmployeeFeedbacks f
INNER JOIN FeedbackTypes ft ON ft.Id = f.FeedbackTypeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = f.EmployeeId
LEFT JOIN Customers c ON c.Id = f.CustomerId
LEFT JOIN CustomerUsers cu ON cu.UserId = f.CreatedBy
WHERE f.IsCustomerCreated = 1
ORDER BY f.Created DESC