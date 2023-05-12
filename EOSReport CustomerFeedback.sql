SELECT
    f.Id,
    EndOfShiftReportId,
    EmployeeSupervisorId,
    CustomerUserId,
    SupervisorFeedback,
    CustomerUserFeedback,
    ud.FirstName + ' ' + ud.LastName AS Name,
    c.CompanyName AS Customer,
    f.Created
FROM dbo.EndOfShiftReportFeedbacks f
LEFT JOIN CustomerUsers u ON u.Id = f.CustomerUserId
LEFT JOIN CustomerUserDetails ud ON u.CustomerUserDetailsId = ud.Id
LEFT JOIN Customers c ON c.Id = u.CustomerId
ORDER BY f.Created DESC