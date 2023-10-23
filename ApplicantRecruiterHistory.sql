WITH cte AS (
    SELECT
    a.Id,
    a.Created,
    b.Created AS endDate,
    a.CreatedBy,
    a.ApplicantId,
    a.RecruiterId
FROM (
    SELECT
        Id,
        Created,
        RecruiterId,
        ApplicantId,
        CreatedBy,
        ROW_NUMBER() OVER(PARTITION BY ApplicantId ORDER BY Created) AS rn
FROM ApplicantRecruiters) AS a
LEFT JOIN (
    SELECT
        Id,
        Created,
        RecruiterId,
        ApplicantId,
        CreatedBy,
        ROW_NUMBER() OVER(PARTITION BY ApplicantId ORDER BY Created) AS rn
FROM ApplicantRecruiters) AS b ON b.ApplicantId = a.ApplicantId AND (a.rn + 1 = b.rn)
)
SELECT
    cte.Id,
    cte.ApplicantId,
    r.Id AS employeeId,
    CONCAT(TRIM(a.FirstName),' ',TRIM(a.LastName)) AS Name,
    r.name AS Recruiter,
    cte.Created AS 'Start Date',
    cte.endDate AS 'End Date',
    cb.name AS 'Created By',
    ROW_NUMBER() OVER(PARTITION BY cte.ApplicantId ORDER BY cte.Created) AS 'Row Number'
FROM cte
JOIN Applicants a ON a.Id = cte.ApplicantId
LEFT JOIN (
    SELECT
        Employees.Id,
        CONCAT(TRIM(UserDetails.FirstName) ,' ', TRIM(UserDetails.LastName)) AS name,
        Employees.UserId
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
) AS r ON  r.Id = cte.RecruiterId
LEFT JOIN (
    SELECT
        Employees.Id,
        CONCAT(TRIM(UserDetails.FirstName) ,' ' ,TRIM(UserDetails.LastName)) AS name,
        Employees.UserId
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
) AS cb ON  cb.UserId = cte.CreatedBy
