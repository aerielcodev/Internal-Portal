SELECT     
    cp.Id AS 'Id',     
    cp.FirstName + ' ' + cp.LastName AS Name,     
    s.Name AS Status,     
CASE         
    WHEN cp.GenderId  = 1 THEN 'Male'         
    WHEN cp.GenderId = 2 THEN 'Female'         
    ELSE 'Not Specified'     
END AS Gender,     
    isnull(cp.QualifiedDate,cp.Created) AS 'Qualified Date',     
    r.recruiter AS Recruiter,     
    cp.Created,     
    cp.CountryId  
FROM CandidateProfileInformations cp 
LEFT JOIN CandidateStatuses s ON s.Id = cp.CandidateStatusId 
LEFT JOIN (     
    SELECT         
    Employees.Id AS eId,         
    UserDetails.FirstName + ' ' + UserDetails.LastName AS recruiter     
    FROM Employees     
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId) AS r ON r.eId = cp.RecruiterId
    WHERE cp.FirstName NOT LIKE '%demo%'  AND  cp.LastName NOT LIKE '%demo%'  