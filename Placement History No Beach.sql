SELECT
    ce.id,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    ce.JobTitle AS 'Job Title',
    c.CompanyName,
    ce.DateStart,
    ce.DateEnd,
    oc.Name AS 'Offboarding Category',
    r.subCat AS 'Offboarding SubCategory',
    o.Note AS 'Offboarding Note'
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
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
WHERE c.Id != 1 AND ce.Id IS NOT NULL AND c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%'