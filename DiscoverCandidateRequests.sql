/*Lists all requests that came from the discover tab*/
SELECT
    dr.Id,
    dr.CustomerId,
    cx.CompanyName AS Company,
    dr.CandidateId,
    CONCAT(TRIM(cpi.FirstName),' ',TRIM(cpi.LastName)) AS Candidate,
    dr.DateRequested,
    cx.customerUserName AS 'Requested By',
    dr.Created
    /*dr.CandidateTypeId,
    dr.CreatedBy,
    dr.LastModifiedBy,
    dr.LastModified,
    dr.StatusId*/
  FROM DiscoverCandidateRequests dr
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
  ) cx ON cx.Id = dr.CustomerId AND cx.UserId = dr.CreatedBy
  LEFT JOIN CandidateProfileInformations cpi ON cpi.Id = dr.CandidateId
 WHERE dr.CustomerId != 281 AND 
  (cx.CompanyName NOT LIKE 'codev%' 
  AND cx.CompanyName NOT LIKE '%breakthrough%' 
  AND cx.CompanyName NOT LIKE '%Test%')/**281 is the dummy customer*/ 