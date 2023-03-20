SELECT 
    cc.Id,
    cc.CustomerId,
    emp.Id AS EmployeeId,
    emp.FirstName + ' ' + emp.LastName AS Name,
    cast(cc.DateStart AS Date) AS DateStart,
    cast(cc.DateEnd AS Date) AS DateEnd,
    ct.Name AS Assignment
FROM INTERNALSERVICEDB.dbo.CustomerCodevContacts cc
LEFT JOIN (
    SELECT emp.*,e.Id 
    FROM INTERNALSERVICEDB.dbo.Employees e 
    INNER JOIN INTERNALSERVICEDB.dbo.UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = cc.EmployeeId
LEFT JOIN INTERNALSERVICEDB.dbo.CustomerCodevContactTypes ct ON ct.Id = cc.CustomerCodevContactTypeId
WHERE cc.CustomerId != 281 /*281 is the dummy customer's id*/