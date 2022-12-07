SELECT
    c.Id AS Id,
    CASE
        WHEN jobC.CandidateId IS NOT NULL THEN c.FirstName + ' ' + c.LastName
        ELSE e.FirstName + ' ' + e.LastName
    END AS Name,
    i.ScheduleDate AS 'Schedule Date',
    i.InterviewFeedback AS 'Interview Feedback',
    i.Created AS Created,
    ud.FirstName + ' ' + ud.LastName AS 'Created By',
    jobC.JobOpeningId AS JobOpeningId,
    IIF(jobC.InterviewRequestedBy IS NOT NULL, 'Y','N') AS 'Interview Requested'
FROM JobOpeningCandidateScheduleInterviews i 
INNER JOIN JobOpeningCandidates jobC ON jobC.Id = i.JobOpeningCandidateId
LEFT JOIN CandidateProfileInformations c ON c.Id = jobC.CandidateId 
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) e ON e.Id = jobC.EmployeeId
LEFT JOIN UserDetails AS ud ON ud.UserId = i.CreatedBy