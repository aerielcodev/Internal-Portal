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
    i.ScheduleDate AS 'UTC Schedule Date',
    CONVERT(DATETIMEOFFSET,CONCAT(CAST(i.ScheduleDate AS Date), ' ', CAST(i.ScheduleTime AS Time), ' ', 
		CASE tz.Abbreviation
			WHEN 'ET' THEN '-05:00'
			WHEN 'CT' THEN '-06:00'
			WHEN 'MT' THEN '-07:00'
			WHEN 'PT' THEN '-08:00'
			WHEN 'PHT' THEN '+08:00'
			WHEN 'IST' THEN '+05:30'
		 END)) AT TIME ZONE 'Mountain Standard Time' AS ScheduleDate,
    i.InterviewFeedback AS 'Interview Feedback',
    i.Created AS Created,
    ud.FirstName + ' ' + ud.LastName AS 'Created By',
    jc.JobOpeningId AS JobOpeningId,
    i.LastModified,
    mb.FirstName + ' ' + mb.LastName AS 'Last Modified By',
    IIF(jc.InterviewRequestedBy IS NOT NULL, 'Y','N') AS 'Interview Requested',
    ROW_NUMBER() OVER(PARTITION BY jc.Id ORDER BY i.ScheduleDate DESC) AS rn,
    tz.TimeZoneName AS 'Scheduled Timezone'
FROM JobOpeningCandidateScheduleInterviews i 
INNER JOIN JobOpeningCandidates jc ON jc.Id = i.JobOpeningCandidateId
INNER JOIN JobOpenings j ON j.Id = jc.JobOpeningId
INNER JOIN JobOpeningPositions jop ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningNumbers jon ON jop.JobOpeningNumberId = jon.Id
INNER JOIN Customers cx ON cx.Id = j.CustomerId
LEFT JOIN TimeZones tz ON tz.Id = i.TimezoneId
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