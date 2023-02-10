/*List of all endrosed candidates for job openings. Job Opening Information is not available on this table. */
SELECT
    jc.Id Id,
    e.CodevId,
    CASE
        WHEN jc.CandidateId IS NOT NULL THEN c.FirstName + ' ' + c.LastName
        ELSE e.FirstName + ' ' + e.LastName
    END AS Name,
    js.Name AS 'Job Opening Endorsement Status',
    jc.Created AS Created,
    CASE
        WHEN jc.Recommendation = 1 THEN 'Endorse'
        WHEN jc.Recommendation = 2 THEN 'Do Not Endorse'
        WHEN jc.Recommendation = 3 THEN 'Not A Fit'
    END AS Recommendation,    
    naft.Name AS 'Not A Fit Category',
    jc.Note,
    en.FirstName + ' ' + en.LastName AS 'Endorsed By',
    jc.EndorsementStatusChangeDate AS 'Endorsement Status Change Date',
    IIF(jc.InterviewRequestedBy IS NOT NULL,'Y','N') AS 'Interview Requested',
    jc.JobOpeningId AS JobOpeningId,
    jc.InterviewRequestedBy AS 'Interview Requested By',
    jc.InitialInterviewRequestDate 
FROM JobOpeningCandidates jc
LEFT JOIN CandidateProfileInformations c ON c.Id = jc.CandidateId 
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) e ON e.Id = jc.EmployeeId
LEFT JOIN JobOpeningEndorsementStatuses js ON js.Id = jc.JobOpeningEndorsementStatusId
LEFT JOIN NotAFitCategoryTypes naft ON naft.Id = jc.NotAFitCategoryTypeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) en ON en.UserId = jc.CreatedBy /*user who endorsed the candidate*/
WHERE jc.Created >= CONVERT(DATE,'2022-12-06') /*Dec. 6, 2022 is the official day that we started endorsing candidates to customers*/

