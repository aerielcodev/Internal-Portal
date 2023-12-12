/*
*This SQL code retrieves customer information and contact details, 
*including supervisors, account executives, and customer success managers.
*/

WITH currentCoDevContact AS (
    SELECT DISTINCT
        cc.Id,
        cc.CustomerId,
        emp.Id AS EmployeeId,
        emp.Name AS contactName,
        ct.Name AS Assignment,
        ROW_NUMBER() OVER(PARTITION BY cc.CustomerId,ct.Name ORDER BY iif(cast(cc.DateStart AS Date) = '0001-01-01','1970-01-01',cc.DateStart ) ASC) AS contactRowNum
    FROM INTERNALSERVICEDB.dbo.CustomerCodevContacts cc
    LEFT JOIN (
        SELECT 
        CONCAT(emp.FirstName,' ',emp.LastName) AS Name,
        e.Id 
        FROM INTERNALSERVICEDB.dbo.Employees e 
        INNER JOIN INTERNALSERVICEDB.dbo.UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = cc.EmployeeId
    LEFT JOIN INTERNALSERVICEDB.dbo.CustomerCodevContactTypes ct ON ct.Id = cc.CustomerCodevContactTypeId
    WHERE cc.CustomerId != 281 /*281 is the dummy customer's id*/
)

SELECT
    c.Id,
    c.CompanyName,
    CASE
        WHEN c.[Status] = 1 THEN 'Active'
        ELSE 'Inactive'
    END AS Status,
    c.CustomerSince AS 'Customer Since',
    it.Name AS Industry,
    CASE
        WHEN c.TypeId = 1 THEN 'Customer'
        WHEN c.TypeId = 2 THEN 'Prospect'
    END AS Type,
    sup.contactName AS Supervisor,
    ae.contactName AS 'Account Executive',
    csm.contactName AS 'Customer Success Manager',
    ir.Name AS 'Inactive Reason',
    c.OtherReason AS 'Other Inactive Reason'
FROM Customers c
LEFT JOIN IndustryTypes it ON it.Id = c.IndustryTypeId
LEFT JOIN InactiveReasons ir ON ir.Id = c.InactiveReasonId
LEFT JOIN currentCoDevContact AS sup ON 
    sup.CustomerId = c.Id AND sup.contactRowNum = 1 AND sup.Assignment = 'Supervisor'
LEFT JOIN currentCoDevContact AS csm ON 
    csm.CustomerId = c.Id AND csm.contactRowNum = 1 AND csm.Assignment = 'Customer Success Manager'
LEFT JOIN currentCoDevContact AS ae ON
     ae.CustomerId = c.Id AND ae.contactRowNum = 1 AND ae.Assignment = 'Account Manager'
WHERE c.TypeId <> 3 /*new type customers listed as CoDev*/
AND (c.CustomerSince IS NOT NULL AND c.TypeId = 1)
