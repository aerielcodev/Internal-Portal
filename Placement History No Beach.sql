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
        WHEN DATEADD(day,1,DateEndTest) = LEAD(DateStart) OVER(PARTITION BY CustomerId,CustomerCodevContactTypeId ORDER BY cast(DateStart AS Date) DESC)
            THEN DateEndTest
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
    COALESCE(ae.Name,ae2.Name) AS 'Account Executive - Placement',
    ts.Name AS 'Talent Supervisor - Placement',
    ce.DateStart,
    ce.DateEnd,
    ce.PartTimeDate,
    isnull(ft.EffectiveDate,ce.DateStart) AS FullTimeDate,
    jt.Name AS 'Job Opening Type',
    fRate.NewRate AS 'First Rate',
    lRate.NewRate AS 'Latest Rate',
    o.Cat AS 'Offboarding Category',
    sub.subCat AS 'Offboarding SubCategory',
    r.secondarySubCat AS 'Offboarding Secondary SubCategory',
    eo.Note AS 'Offboarding Note',
    emp.Location AS 'Assigned Office',
    coalesce(candidateLoc.country,emp.Name) AS Country,
    lRate.Id AS lRateId,
    CONCAT(cb.FirstName , ' ' , cb.LastName) AS CreatedBy,
    CONCAT(mb.FirstName , ' ' , mb.LastName) AS ModifiedBy,
    ce.Created,
    ce.LastModified,
eo.Created AS 'Offboarding Log Date',
CONCAT(ocb.FirstName , ' ' , ocb.LastName) AS 'Offboarding Log Created By',
CONCAT(omb.FirstName , ' ' , omb.LastName) AS 'Offboarding Log Last Modified By',
LAG(ce.id) OVER (PARTITION BY jon.Number ORDER BY ce.DateStart) AS 'Previous CustomerEmployeeId',
LEAD(ce.id) OVER (PARTITION BY jon.Number ORDER BY ce.DateStart) AS 'Next CustomerEmployeeId',
CASE
    WHEN ce.DateEnd IS NOT NULL THEN
        CASE
            WHEN LEAD(ce.id) OVER (PARTITION BY jon.Number ORDER BY ce.DateStart) IS NOT NULL THEN 'Yes'
            ELSE 'No'
        END
END AS 'Replaced'
FROM dbo.JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id
INNER JOIN Customers c ON ce.CustomerId = c.Id
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
LEFT JOIN (
    SELECT 
        emp.CodevId,
        upper(CONCAT(trim(emp.FirstName) ,' ' , trim(emp.LastName))) AS teamMember,
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
LEFT JOIN EmployeeOffboardings eo ON eo.CustomerEmployeeId = ce.Id AND eo.IsCancelled = 0
LEFT JOIN (/*grabs the subcategory*/
    SELECT
        o.Id,
        STRING_AGG(r.subCat,' ; ') AS subCat
    FROM EmployeeOffboardings o
    INNER JOIN (
        SELECT DISTINCT
            s.EmployeeOffboardingId,
            s3.Name AS subCat
        FROM EmployeeOffboardingSecondarySubCategories s 
        INNER JOIN OffboardingSecondarySubCategories s2 ON s2.Id = s.OffboardingSecondarySubCategoryId
        INNER JOIN OffboardingSubCategories s3 ON s3.Id = s2.SubCategoryId
    ) AS r ON r.EmployeeOffboardingId = o.Id
    GROUP BY o.Id
) AS sub ON sub.Id = eo.Id
LEFT JOIN ( /*grabs the category and subcategory*/
    SELECT DISTINCT
        eossc.EmployeeOffboardingId,
        STRING_AGG(oc.Name,' ; ') AS Cat,
        STRING_AGG(osc.Name,' ; ') AS subCat
    FROM EmployeeOffboardingSecondarySubCategories eossc 
    INNER JOIN OffboardingSecondarySubCategories ossc ON ossc.Id = eossc.OffboardingSecondarySubCategoryId
    INNER JOIN OffboardingSubCategories osc ON osc.Id = ossc.SubCategoryId
    INNER JOIN OffboardingCategories oc ON oc.Id = osc.OffboardingCategoryId
    GROUP BY eossc.EmployeeOffboardingId
    ) AS o ON o.EmployeeOffboardingId = eo.Id
LEFT JOIN (/*concatenates the offboarding's secondary subcategory*/
    SELECT 
        eossc.EmployeeOffboardingId,
        STRING_AGG(ossc.Name,' ; ') AS secondarySubCat
    FROM EmployeeOffboardingSecondarySubCategories eossc 
    INNER JOIN OffboardingSecondarySubCategories ossc ON ossc.Id = eossc.OffboardingSecondarySubCategoryId
    GROUP BY eossc.EmployeeOffboardingId
    ) AS r ON r.EmployeeOffboardingId = o.EmployeeOffboardingId
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
) AS ae2 ON ae2.CustomerId = c.Id  AND ae2.CustomerCodevContactTypeId = 1
AND (ae2.DateStart >= cast(ce.DateStart AS date) 
AND (ae2.DateEnd <= cast(ce.DateStart AS date) OR ae2.DateEnd IS NULL))
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
LEFT JOIN UserDetails ocb ON ocb.UserId = eo.CreatedBy AND eo.IsCancelled = 0
LEFT JOIN UserDetails omb ON omb.UserId = eo.LastModifiedBy AND eo.IsCancelled = 0
WHERE
    c.Id NOT IN (1, 281)
    AND ce.IsDeleted = 0
    AND c.CompanyName NOT LIKE 'codev%'
    AND c.CompanyName NOT LIKE '%breakthrough%'
    AND ce.Id IS NOT NULL 
