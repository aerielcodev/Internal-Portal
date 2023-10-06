/*displays what the customer user has done in the Discover tab*/
SELECT 
    da.Id,
    da.CustomerId,
    cx.CompanyName AS Company,
    cx.customerUserName AS 'Customer User',
    da.CustomerUserId,
    da.CandidateId,
    CASE
      WHEN c.FirstName IS NULL THEN e.Name
      ELSE CONCAT(TRIM(c.FirstName),' ',TRIM(c.LastName))
    END AS Candidate,
    da.DiscoverAuditActionTypeId,
    dat.Name,
    da.IsBench,
    da.CreatedBy,
    da.Created,
    da.LastModifiedBy,
    da.LastModified
FROM DiscoverAuditTrails da
JOIN DiscoverAuditActionTypes dat ON dat.Id = da.DiscoverAuditActionTypeId
LEFT JOIN (
    SELECT
        c.CompanyName,
        c.Id,
        CONCAT(trim(cud.FirstName),' ',trim(cud.LastName)) AS customerUserName,
        cu.Id AS customerUserId,
        cud.UserId
    FROM Customers c
    JOIN CustomerUsers cu ON c.Id = cu.CustomerId 
    JOIN CustomerUserDetails cud ON cud.Id = cu.CustomerUserDetailsId
  ) cx ON cx.Id = da.CustomerId AND cx.customerUserId = da.CustomerUserId
LEFT JOIN CandidateProfileInformations c ON c.Id = da.CandidateId
AND (c.FirstName NOT LIKE '%demo%'  OR  c.LastName NOT LIKE '%demo%' )
LEFT JOIN (
    SELECT 
    CONCAT(TRIM(emp.FirstName),' ',TRIM(emp.LastName)) AS Name,
    emp.CodevId,
    e.Id 
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId
    WHERE FirstName NOT LIKE '%demo%'  OR  LastName NOT LIKE '%demo%') e ON e.Id = da.CandidateId
WHERE da.CustomerId != 281 AND 
  (cx.CompanyName NOT LIKE 'codev%' 
  AND cx.CompanyName NOT LIKE '%breakthrough%' 
  AND cx.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/
