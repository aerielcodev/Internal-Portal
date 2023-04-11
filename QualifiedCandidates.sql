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
    cp.Email,  
    r.recruiter AS Recruiter,     
    cp.Created,     
    o.offices AS 'Preferred Office',
    c.Name AS Country,  
    c.Code AS CountryCode
FROM CandidateProfileInformations cp 
LEFT JOIN CandidateStatuses s ON s.Id = cp.CandidateStatusId 
LEFT JOIN (     
    SELECT         
    Employees.Id AS eId,         
    UserDetails.FirstName + ' ' + UserDetails.LastName AS recruiter     
    FROM Employees     
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId) AS r ON r.eId = cp.RecruiterId
LEFT JOIN (
    SELECT
        CandidatePreferredOfficeLocations.CandidateProfileInformationId AS cpId,
        string_agg(Offices.Location,',') AS offices
    FROM CandidatePreferredOfficeLocations
    LEFT JOIN Offices ON Offices.Id = CandidatePreferredOfficeLocations.OfficeId
GROUP BY CandidatePreferredOfficeLocations.CandidateProfileInformationId) AS o ON o.cpId = cp.Id
LEFT JOIN Countries c ON c.Id = cp.CountryId
    WHERE cp.FirstName NOT LIKE '%demo%'  AND  cp.LastName NOT LIKE '%demo%'  