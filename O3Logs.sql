SELECT 
    f.Id AS Id, 
    f.O3FeedbackDate AS 'O3 Date', 
    ft.Name AS 'Feedback Type', 
    s.Id AS SupervisorEmployeeId,
    s.FirstName + ' ' + s.LastName AS 'Talent Supervisor', 
    e2.FirstName +' ' + e2.LastName AS 'Team Member', 
    s.Email AS 'Talent Supervisor email', 
    e2.Email AS 'Team Member email' ,
    e2.CodevId AS 'Team Member CoDev Id'
FROM [dbo].[EmployeeFeedbacks] AS f 
LEFT JOIN [dbo].[FeedbackTypes] AS ft ON ft.[Id] = f.[FeedbackTypeId] 
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) 
    s ON s.UserId = f.CreatedBy
/*LEFT JOIN [dbo].[UserDetailsView] s ON f.CreatedBy = s.UserId */
LEFT JOIN [dbo].[Employees] e ON f.EmployeeId = e.Id 
LEFT JOIN [dbo].[UserDetails] e2 ON e.UserId = e2.UserId 
WHERE f.FeedbackTypeId = 3 
