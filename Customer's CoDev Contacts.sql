WITH cte AS (SELECT DISTINCT
        cc.Id,
        cc.CustomerId,
        emp.Id AS EmployeeId,
        concat(emp.FirstName,' ',emp.LastName) AS Name,
        iif(cast(cc.DateStart AS Date) = '0001-01-01','1970-01-01',cast(cc.DateStart AS Date)) AS DateStart,
        iif(cast(cc.DateStart AS Date) = '0001-01-01','1970-01-01',cc.DateStart ) AS DateStartTest,
        IIF(cc.DateEnd IS NULL AND c.Status = 2,CAST(lastP.endOfLastPlacement AS Date),DATEADD(day,-1,CAST(cc.DateEnd AS Date))) AS DateEndTest,
        ct.Name AS Assignment,
        iif(cast(cc.DateStart AS Date) = '0001-01-01' AND cc.DateEnd IS NULL AND cc.IsActive = 0,'Y','N') AS isInvalid,
        cc.IsActive
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
    cte.Id,
    cte.CustomerId,
    cte.EmployeeId,
    cte.Name,
    cte.DateStart,
    cte.DateEndTest,
    cte.Assignment,
    ROW_NUMBER() OVER(PARTITION BY cte.CustomerId,cte.Assignment ORDER BY cast(cte.DateStart AS Date) ASC) AS 'Contact RowNum',
    CASE
        WHEN cte.DateEndTest IS NULL THEN NULL
        WHEN DATEADD(day,1,LAG(cte.DateStart) OVER(PARTITION BY cte.CustomerId,cte.Assignment ORDER BY cast(cte.DateStart AS Date) DESC)) <> cte.DateStart 
            THEN DATEADD(day,-1,LAG(cte.DateStart) OVER(PARTITION BY cte.CustomerId,cte.Assignment ORDER BY cast(cte.DateStart AS Date) DESC))
        WHEN DATEADD(day,1,cte.DateEndTest) = LEAD(cte.DateStart) OVER(PARTITION BY cte.CustomerId,cte.Assignment ORDER BY cast(cte.DateStart AS Date) DESC)
            THEN cte.DateEndTest
    END
     AS DateEnd,
    CASE
        WHEN ROW_NUMBER() OVER(PARTITION BY cte.CustomerId,cte.Assignment ORDER BY cte.DateStartTest DESC) = 1 THEN 'Y'
        ELSE 'N'
    END AS isCurrent
FROM cte
WHERE cte.isInvalid = 'N'
