SELECT
    i.Id AS Id,
    jc.Id AS JobOpeningCandidatesId,
    j.JobTitle AS 'Job Title',
    cx.CompanyName AS Customer,
    e.CodevId,
    CASE
        WHEN jc.CandidateId IS NOT NULL THEN c.FirstName + ' ' + c.LastName
        ELSE e.FirstName + ' ' + e.LastName
    END AS Name,
    i.ScheduleDate AS ScheduleDate,
    i.InterviewFeedback AS 'Interview Feedback',
    i.Created AS Created,
    ud.FirstName + ' ' + ud.LastName AS 'Created By',
    jc.JobOpeningId AS JobOpeningId,
    i.LastModified,
    mb.FirstName + ' ' + mb.LastName AS 'Last Modified By',
    IIF(jc.InterviewRequestedBy IS NOT NULL, 'Y','N') AS 'Interview Requested',
    ROW_NUMBER() OVER(PARTITION BY jc.Id ORDER BY i.ScheduleDate DESC) AS rn

FROM JobOpeningCandidateScheduleInterviews i 
INNER JOIN JobOpeningCandidates jc ON jc.Id = i.JobOpeningCandidateId
INNER JOIN JobOpenings j ON j.Id = jc.JobOpeningId
INNER JOIN JobOpeningPositions jop ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningNumbers jon ON jop.JobOpeningNumberId = jon.Id
INNER JOIN Customers cx ON cx.Id = j.CustomerId
LEFT JOIN CandidateProfileInformations c ON c.Id = jc.CandidateId 
LEFT JOIN (
    SELECT emp.FirstName,emp.LastName,emp.CodevId,e.Id 
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId
    ) e ON e.Id = jc.EmployeeId
LEFT JOIN UserDetails AS ud ON ud.UserId = i.CreatedBy
LEFT JOIN UserDetails AS mb ON mb.UserId = i.LastModifiedBy

WHERE j.CustomerId != 281 
AND (cx.CompanyName NOT LIKE 'codev%' 
AND cx.CompanyName NOT LIKE '%breakthrough%' )/**281 is the dummy customer*/ 
