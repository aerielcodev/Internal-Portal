SELECT
    f.Id,
    EndOfShiftReportId,
    EmployeeSupervisorId,
    CustomerUserId,
    SupervisorFeedback,
    CustomerUserFeedback,
    u.FirstName + ' ' + u.LastName AS Name,
    c.CompanyName AS Customer,
    f.Created
FROM dbo.EndOfShiftReportFeedbacks f
LEFT JOIN CustomerUsers u ON u.Id = f.CustomerUserId
LEFT JOIN Customers c ON c.Id = u.CustomerId
ORDER BY f.Created DESC