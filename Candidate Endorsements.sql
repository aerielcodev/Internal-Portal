/*List of all endrosed candidates for job openings. Job Opening Information is not available on this table. */
SELECT DISTINCT
    jc.Id Id,
    jc.EmployeeId,
    jc.CandidateId,
    e.CodevId,
    CASE
        WHEN jc.CandidateId IS NOT NULL THEN c.FirstName + ' ' + c.LastName
        ELSE e.FirstName + ' ' + e.LastName
    END AS Name,
    CASE
        WHEN jft.Name IS NOT NULL OR naft.Name IS NOT NULL THEN 'Not A Fit'
        WHEN js.Id = 10 THEN 'JO Requested' 
        WHEN js.Id = 6 THEN 'JO Extended' 
        WHEN js.Id = 5 THEN 'JO Made' 
        WHEN js.Id = 8 THEN 'JO Declined'
        ELSE js.Name
    END  AS 'Job Opening Endorsement Status',
    jc.Created AS Created,
    CASE
        WHEN jc.Recommendation = 1 THEN 'Endorse'
        WHEN jc.Recommendation = 2 THEN 'Do Not Endorse'
        WHEN jc.Recommendation = 3 THEN 'Not A Fit'
    END AS Recommendation,  
    coalesce(jft.Name,naft.Name) AS 'Not A Fit Category',
    coalesce(jf.Details,jc.Note) AS Note,
    eb.FirstName + ' ' + eb.LastName AS 'Endorsed By',
    jc.EndorsementStatusChangeDate AS 'Endorsement Status Change Date',
    ir.name AS 'Interview Requested By',
    jc.CustomerNote AS 'Customer Visible Note',
    cxNote.name AS 'Customer Visible Note Added By',    
    COALESCE(d.name,CONCAT(d2.FirstName,' ',d2.LastName)) AS 'Declined By',
    IIF(jc.InterviewRequestedBy IS NOT NULL,'Y','N') AS 'Interview Requested',
    jc.InitialInterviewRequestDate,
    jc.JobOfferExtended,
    jc.DateJobOfferAccepted,
    jc.FullTimeStartDate,
    jc.PartTimeStartDate,
    jc.JobOpeningId AS JobOpeningId,
    jop.Id AS JobOpeningPositionId,
    jc.LastModified,
    jc.InterviewRequestedBy,
    d.Email AS declinerEmail
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
LEFT JOIN JobOpeningRecommendationFeedbacks jf ON jf.Id = jc.JobOpeningRecommendationFeedbackId
LEFT JOIN JobOpeningRecommendationFeedbackTypes jft ON jft.Id = jf.RecommendationFeedbackTypeId
LEFT JOIN (
    SELECT DISTINCT 
        UserId, 
        FirstName + ' ' + LastName AS name,
        Email
    FROM CustomerUserDetails
    )  d ON d.UserId = jc.DeclinedBy
LEFT JOIN UserDetails d2 ON d2.UserId = jc.DeclinedBy
LEFT JOIN Customers cx ON cx.Id = j.CustomerId
LEFT JOIN (
    SELECT DISTINCT 
        UserId, 
        FirstName + ' ' + LastName AS name
    FROM CustomerUserDetails
    WHERE Status = 1
    )  cxNote ON cxNote.UserId = jc.CustomerNoteAddedBy
LEFT JOIN (
    SELECT DISTINCT 
        UserId, 
        FirstName + ' ' + LastName AS name
    FROM CustomerUserDetails
    WHERE Status = 1
    )  ir ON ir.UserId = jc.InterviewRequestedBy
/*remove any dummy candidate endorsements and any endorsements coming for codev/breakthrough*/
 WHERE j.CustomerId != 281 AND 
 (cx.CompanyName NOT LIKE 'codev%' AND cx.CompanyName NOT LIKE '%breakthrough%' ) 
  AND jc.Created >= CONVERT(DATE,'2022-12-06') /*Dec. 6, 2022 is the official day that we started endorsing candidates to customers*/


