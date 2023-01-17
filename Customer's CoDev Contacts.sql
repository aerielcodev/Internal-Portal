SELECT 
    cc.Id,
    cc.CustomerId,
    emp.FirstName + ' ' + emp.LastName AS Name,
    ct.Name AS Assignment
FROM dbo.CustomerCodevContacts cc
LEFT JOIN (
    SELECT emp.*,e.Id 
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = cc.EmployeeId
LEFT JOIN dbo.CustomerCodevContactTypes ct ON ct.Id = cc.CustomerCodevContactTypeId
WHERE cc.CustomerId != 281 /*281 is the dummy customer's id*/