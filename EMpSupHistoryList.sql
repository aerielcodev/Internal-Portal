SELECT 
    es.Id,
    emp.CodevId AS 'Team Member CoDev Emp Num',
    sup.CodevId AS 'Supervisor CoDev Emp Num',
    emp.FirstName + ' ' + emp.LastName AS 'Team Member',
    sup.FirstName + ' ' + sup.LastName AS Supervisor,
    es.EffectiveDate AS EffectiveDate
FROM dbo.EmployeeSupervisors es
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = es.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) sup ON sup.Id = es.SupervisorId
LEFT JOIN dbo.CustomerEmployees ce ON ce.Id = es.CustomerEmployeeId