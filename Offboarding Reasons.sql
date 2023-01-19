SELECT
    o.Id,
    o.CustomerEmployeeId,
    r.Cat AS 'Offboarding Category',
    r.SubCat AS 'SubCategory', 
    o.Note
FROM EmployeeOffboardings o
INNER JOIN (
    SELECT 
        s.EmployeeOffboardingId,
        oc.Name AS Cat,
        s2.Name AS SubCat
    FROM EmployeeOffboardingSubCategories s 
    INNER JOIN OffboardingSubCategories s2 ON s.OffboardingSubCategoryId = s2.Id
    INNER JOIN OffboardingCategories oc ON oc.Id = s2.OffboardingCategoryId
    ) AS r ON r.EmployeeOffboardingId = o.Id
    ORDER BY o.CustomerEmployeeId ASC
