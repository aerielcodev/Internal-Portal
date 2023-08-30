SELECT
    o.Id,
    o.CustomerEmployeeId,
    r.Cat AS 'Offboarding Category',
    r.PrimCat AS 'Subcategory',
    r.SubCat AS 'Secondary SubCategory', 
    o.Note
FROM EmployeeOffboardings o
INNER JOIN (
    SELECT 
        s.EmployeeOffboardingId,
        oc.Name AS Cat,
        s3.Name AS PrimCat,
        s2.Name AS SubCat
    FROM EmployeeOffboardingSecondarySubCategories s 
    INNER JOIN OffboardingSecondarySubCategories s2 ON s2.Id = s.OffboardingSecondarySubCategoryId
    INNER JOIN OffboardingSubCategories s3 ON s3.Id = s2.SubCategoryId
    INNER JOIN OffboardingCategories oc ON oc.Id = s3.OffboardingCategoryId
    ) AS r ON r.EmployeeOffboardingId = o.Id
    ORDER BY o.CustomerEmployeeId ASC
