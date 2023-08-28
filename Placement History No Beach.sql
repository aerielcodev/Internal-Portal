WITH cte_custContacts AS (
    SELECT DISTINCT
        cc.Id,
        cc.CustomerId,
        concat(emp.FirstName,' ',emp.LastName) AS Name,
        cc.CustomerCodevContactTypeId,
        iif(cast(cc.DateStart AS Date) = '0001-01-01','1970-01-01',cast(cc.DateStart AS Date)) AS DateStart,
        IIF(cc.DateEnd IS NULL AND c.Status = 2,CAST(lastP.endOfLastPlacement AS Date),DATEADD(day,-1,CAST(cc.DateEnd AS Date))) AS DateEndTest,
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
),
cte_result AS (
    SELECT
        *,
    CASE
        WHEN DateEndTest IS NULL THEN NULL
        WHEN DATEADD(day,1,LAG(DateStart) OVER(PARTITION BY CustomerId,CustomerCodevContactTypeId ORDER BY cast(DateStart AS Date) DESC)) <> DateStart THEN DATEADD(day,-1,LAG(DateStart) OVER(PARTITION BY CustomerId,CustomerCodevContactTypeId ORDER BY cast(DateStart AS Date) DESC))
    END
     AS DateEnd
    FROM cte_custContacts
    WHERE isInvalid = 'N'
) 

SELECT DISTINCT
    ce.id,
    c.Id AS CustomerId,
    jop.Id AS JobOpeningPositionId,
    ce.EmployeeId,
    jon.Number AS 'Job Opening Number',
    emp.CoDevId,
    emp.teamMember AS 'Team Member',
    ce.JobTitle AS 'Job Title',
    c.CompanyName,
    csm.Name AS 'Customer Success Manager - Placement',
    ae.Name AS 'Account Executive - Placement',
    ts.Name AS 'Talent Supervisor - Placement',
    ce.DateStart,
    ce.DateEnd,
    ce.PartTimeDate,
    isnull(ft.EffectiveDate,ce.DateStart) AS FullTimeDate,
    jt.Name AS 'Job Opening Type',
    fRate.NewRate AS 'First Rate',
    lRate.NewRate AS 'Latest Rate',
    oc.Name AS 'Offboarding Category',
    r.subCat AS 'Offboarding SubCategory',
    o.Note AS 'Offboarding Note',
    emp.Location AS 'Assigned Office',
    coalesce(candidateLoc.country,emp.Name) AS Country,
    lRate.Id AS lRateId,
    cb.FirstName + ' ' + cb.LastName AS CreatedBy,
    mb.FirstName + ' ' + mb.LastName AS ModifiedBy,
    ce.Created,
    ce.LastModified,
ol.Created AS 'Offboarding Log Date',
ocb.FirstName + ' ' + ocb.LastName AS 'Offboarding Log Created By',
omb.FirstName + ' ' + omb.LastName AS 'Offboarding Log Last Modified By'
FROM dbo.JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id
INNER JOIN Customers c ON ce.CustomerId = c.Id
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
LEFT JOIN (
    SELECT 
        emp.CodevId,
        upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS teamMember,
        e.Id,
        e.CandidateProfileInformationId, 
        ofc.Location,
        co.Name
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId
    LEFT JOIN Offices AS ofc ON ofc.Id = e.OfficeId
    LEFT JOIN EmployeeAddresses ea ON ea.EmployeeId = e.Id
    LEFT JOIN Countries AS co ON co.Id = ea.CountryId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (
    SELECT
        cp.Id,
        cp.State,
        c.Name AS country,  
        c.Code AS countryCode,
        cp.City AS city,
        cp.ZipCode
    FROM CandidateProfileInformations cp 
    INNER JOIN Countries c ON c.Id = cp.CountryId
) AS candidateLoc ON candidateLoc.Id = emp.CandidateProfileInformationId
LEFT JOIN EmployeeOffboardings o ON o.CustomerEmployeeId = ce.Id
LEFT JOIN (
    SELECT 
    s2.OffboardingCategoryId,
    s.EmployeeOffboardingId, 
    STRING_AGG(s2.Name,';') AS subCat 
FROM EmployeeOffboardingSubCategories s 
INNER JOIN OffboardingSubCategories s2 ON s.OffboardingSubCategoryId = s2.Id GROUP BY s.EmployeeOffboardingId,s2.OffboardingCategoryId)  AS r ON r.EmployeeOffboardingId = o.Id
LEFT JOIN OffboardingCategories oc ON oc.Id = r.OffboardingCategoryId
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId AND customerid = ce.customerid ORDER BY EffectiveDate ASC
    ) AS fRate
OUTER APPLY (
    SELECT TOP 1 * FROM RateIncreases WHERE EmployeeId = ce.EmployeeId AND customerid = ce.customerid ORDER BY EffectiveDate DESC
    ) AS lRate
LEFT JOIN RateIncreases ft ON ft.CustomerEmployeeId = ce.Id AND ft.ReasonId = 4
LEFT JOIN UserDetails cb ON cb.UserId = ce.CreatedBy
LEFT JOIN UserDetails mb ON mb.UserId = ce.LastModifiedBy
LEFT JOIN (
    SELECT
        *
    FROM cte_result
) AS ae ON ae.CustomerId = c.Id  AND ae.CustomerCodevContactTypeId = 1
AND (ae.DateStart <= cast(ce.DateStart AS date) 
AND (ae.DateEnd >= cast(ce.DateStart AS date) OR ae.DateEnd IS NULL))
LEFT JOIN (
    SELECT
        *
    FROM cte_result
)  AS ts ON ts.CustomerId = c.Id  AND ts.CustomerCodevContactTypeId = 2
AND (ts.DateStart  <= cast(ce.DateStart AS date) 
AND (ts.DateEnd  >= cast(ce.DateStart AS date) OR ts.DateEnd IS NULL))
LEFT JOIN (
    SELECT
        *
    FROM cte_result
)  AS  csm ON csm.CustomerId = c.Id AND csm.CustomerCodevContactTypeId = 3
AND (csm.DateStart <= cast(ce.DateStart AS date) 
AND (csm.DateEnd  >= cast(ce.DateStart AS date) OR csm.DateEnd IS NULL))
LEFT JOIN EmployeeOffboardings ol ON ol.CustomerEmployeeId = ce.Id
LEFT JOIN UserDetails ocb ON ocb.UserId = ol.CreatedBy
LEFT JOIN UserDetails omb ON omb.UserId = ol.LastModifiedBy
WHERE
    c.Id NOT IN (1, 281)
    AND ce.IsDeleted = 0
    AND c.CompanyName NOT LIKE 'codev%'
    AND c.CompanyName NOT LIKE '%breakthrough%'
    AND ce.Id IS NOT NULL
