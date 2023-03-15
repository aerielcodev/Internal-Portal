SELECT
    ce.id,
    c.Id AS CustomerId,
    jop.Id AS JobOpeningPositionId,
    ce.EmployeeId,
    jon.Number AS 'Job Opening Number',
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
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
    lRate.Id AS lRateId
FROM dbo.JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
LEFT JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId
INNER JOIN CustomerEmployees ce ON ce.JobOpeningPositionId = jop.Id
INNER JOIN Customers c ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
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
WHERE c.Id != 1 AND c.Id != 281 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%') AND ce.IsDeleted = 0
