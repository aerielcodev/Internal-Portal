WITH cte AS (SELECT DISTINCT
        cc.Id,
        cc.CustomerId,
        emp.Id AS EmployeeId,
        concat(emp.FirstName,' ',emp.LastName) AS Name,
        cast(cc.DateStart AS Date) AS DateStart,
        IIF(cc.DateEnd IS NULL AND c.Status = 2,CAST(lastP.endOfLastPlacement AS Date),cast(cc.DateEnd AS Date)) AS DateEnd,
        ct.Name AS Assignment,
        iif(cast(cc.DateStart AS Date) = '0001-01-01' AND cc.DateEnd IS NULL AND cc.IsActive = 0,'Y','N') AS isInvalid
    FROM INTERNALSERVICEDB.dbo.CustomerCodevContacts cc
    LEFT JOIN Customers c ON c.Id = cc.CustomerId
    LEFT JOIN (
        SELECT 
        emp.FirstName,
        emp.LastName,
        e.Id 
        FROM INTERNALSERVICEDB.dbo.Employees e 
        INNER JOIN INTERNALSERVICEDB.dbo.UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = cc.EmployeeId
    LEFT JOIN INTERNALSERVICEDB.dbo.CustomerCodevContactTypes ct ON ct.Id = cc.CustomerCodevContactTypeId
    LEFT JOIN (
        SELECT
            max(DateEnd) AS endOfLastPlacement,
            CustomerId
        FROM CustomerEmployees
        GROUP BY CustomerId
    ) AS lastP ON lastP.CustomerId = cc.CustomerId
    WHERE cc.CustomerId != 281 /*281 is the dummy customer's id*/)
SELECT
    *
FROM cte
WHERE cte.isInvalid = 'N'
