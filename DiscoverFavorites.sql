/*Lists those that have been favorited by a customer portal user*/
SELECT
    df.Id,
    CASE
        WHEN df.CandidateProfileInformationId IS NOT NULL THEN CONCAT(TRIM(cpi.FirstName),' ',TRIM(cpi.LastName))
        ELSE e.Name
    END AS Name,
    df.CustomerUserId,
    fb.Name AS 'Customer User',
    fb.CompanyName AS Company,
    df.Created,
    df.LastModifiedBy,
    df.LastModified,
    iif(df.CandidateProfileInformationId IS NULL,'Y','N') AS isTeamMember
  FROM DiscoverFavorites df
  LEFT JOIN CandidateProfileInformations cpi ON cpi.Id = df.CandidateProfileInformationId
  LEFT JOIN (
    SELECT
        emp.Id,
        CONCAT(TRIM(ud.FirstName), ' ', TRIM(ud.LastName)) AS Name
    FROM Employees emp
    JOIN UserDetails ud ON emp.UserId = ud.UserId
  ) e ON e.Id = df.EmployeeId
LEFT JOIN (
    SELECT
        cu.Id,
        CONCAT(TRIM(cud.FirstName),' ',TRIM(cud.LastName)) AS Name,
        c.CompanyName
    FROM CustomerUsers cu
    JOIN CustomerUserDetails cud ON cud.Id = cu.CustomerUserDetailsId
    JOIN Customers c ON c.Id = cu.CustomerId
    WHERE cud.Status = 1 AND
    (c.Id != 281 AND 
    (c.CompanyName NOT LIKE 'codev%' 
    AND c.CompanyName NOT LIKE '%breakthrough%' 
    AND c.CompanyName NOT LIKE '%Test%'))/**281 is the dummy customer*/ 
  ) AS fb ON fb.Id = df.CustomerUserId
 