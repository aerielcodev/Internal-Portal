SELECT
    ce.id,
    c.Id AS CustomerId,
    jop.Id AS JobOpeningPositionId,
    ce.EmployeeId,
    jon.Number AS 'Job Opening Number',
    emp.CoDevId,
    emp.teamMember AS 'Team Member',
    ce.JobTitle AS 'Job Title',
    c.CompanyName,
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
    lRate.Id AS lRateId
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
    LEFT JOIN EmployeeHRReferences ehr ON ehr.Id = e.EmployeeHrReferenceId
    LEFT JOIN Offices AS ofc ON ofc.Id = ehr.OfficeId
    LEFT JOIN Countries AS co ON co.Id = ofc.CountryId) emp ON emp.Id = ce.EmployeeId
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
WHERE
    c.Id NOT IN (1, 281)
    AND ce.IsDeleted = 0
    AND c.CompanyName NOT LIKE 'codev%'
    AND c.CompanyName NOT LIKE '%breakthrough%'
    AND ce.Id IS NOT NULL
