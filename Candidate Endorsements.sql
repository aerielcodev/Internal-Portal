/*List of all endrosed candidates for job openings. Job Opening Information is not available on this table. */
SELECT
    jc.Id Id,
    jc.EmployeeId,
    jc.CandidateId,
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
    eb.FirstName + ' ' + eb.LastName AS 'Endorsed By',
    jc.EndorsementStatusChangeDate AS 'Endorsement Status Change Date',
    d.FirstName + ' ' + d.LastName AS 'Declined By',
    IIF(jc.InterviewRequestedBy IS NOT NULL,'Y','N') AS 'Interview Requested',
    jc.InitialInterviewRequestDate,
    jc.JobOfferExtended,
    jc.DateJobOfferAccepted,
    jc.FullTimeStartDate,
    jc.PartTimeStartDate,
    jc.JobOpeningId AS JobOpeningId,
    jop.Id AS JobOpeningPositionId,
    jc.LastModified,
    jc.InterviewRequestedBy AS 'Interview Requested By'
FROM JobOpeningNumbers jon 
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
INNER JOIN JobOpenings j ON j.Id = jop.JobOpeningId
INNER JOIN JobOpeningCandidates jc ON jc.JobOpeningId  = j.Id
LEFT JOIN CandidateProfileInformations c ON c.Id = jc.CandidateId 
AND (c.FirstName NOT LIKE '%demo%'  OR  c.LastName NOT LIKE '%demo%' )
LEFT JOIN (
    SELECT 
    emp.FirstName,
    emp.LastName,
    emp.CodevId,
    e.Id 
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId)
     e ON e.Id = jc.EmployeeId 
     AND (e.FirstName NOT LIKE '%demo%'  OR  e.LastName NOT LIKE '%demo%' )
LEFT JOIN JobOpeningEndorsementStatuses js ON js.Id = jc.JobOpeningEndorsementStatusId
LEFT JOIN NotAFitCategoryTypes naft ON naft.Id = jc.NotAFitCategoryTypeId
LEFT JOIN UserDetails eb ON eb.UserId = jc.CreatedBy /*user who endorsed the candidate*/ 
LEFT JOIN CustomerUsers d ON d.UserId = jc.DeclinedBy
LEFT JOIN Customers cx ON cx.Id = j.CustomerId
/*remove any dummy candidate endorsements and any endorsements coming for codev/breakthrough*/
 WHERE j.CustomerId != 281 AND 
 (cx.CompanyName NOT LIKE 'codev%' AND cx.CompanyName NOT LIKE '%breakthrough%' ) 
  AND jc.Created >= CONVERT(DATE,'2022-12-06') /*Dec. 6, 2022 is the official day that we started endorsing candidates to customers*/

