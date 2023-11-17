WITH cte AS (
    SELECT
    a.Id,
    a.Created,
    b.Created AS endDate,
    a.CreatedBy,
    a.ApplicantId,
    a.SourcerId
FROM (
    SELECT
        Id,
        Created,
        SourcerId,
        ApplicantId,
        CreatedBy,
        ROW_NUMBER() OVER(PARTITION BY ApplicantId ORDER BY Created) AS rn
FROM ApplicantSourcers) AS a
LEFT JOIN (
    SELECT
        Id,
        Created,
        SourcerId,
        ApplicantId,
        CreatedBy,
        ROW_NUMBER() OVER(PARTITION BY ApplicantId ORDER BY Created) AS rn
FROM ApplicantSourcers) AS b ON b.ApplicantId = a.ApplicantId AND (a.rn + 1 = b.rn)
)
SELECT
    cte.Id,
    cte.ApplicantId,
    s.Id AS sourcerEmployeeId,
    CONCAT(TRIM(a.FirstName),' ',TRIM(a.LastName)) AS Name,
    s.name AS Sourcer,
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
) AS s ON  s.Id = cte.SourcerId
LEFT JOIN (
    SELECT
        Employees.Id,
        CONCAT(TRIM(UserDetails.FirstName) ,' ' ,TRIM(UserDetails.LastName)) AS name,
        Employees.UserId
    FROM Employees
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
) AS cb ON  cb.UserId = cte.CreatedBy
