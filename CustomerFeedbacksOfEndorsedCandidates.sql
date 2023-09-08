/*Messages under the Customer Feedback of Endorsed Candidates of Job Openings*/
SELECT 
    jct.Id,
    jct.JobOpeningCandidateId,
    jct.Text,
    jct.IsDeleted,
    jct.IsInternalUser,
    iif(jct.IsInternalUser = 1,CONCAT(ud.FirstName,' ',ud.LastName),CONCAT(cu.FirstName,' ',cu.LastName)) AS 'Created By',
    jct.Created,
    jct.IsSeenByUser
  FROM JobOpeningCandidateNoteThreads jct
  LEFT JOIN CustomerUserDetails cu ON cu.UserId = jct.CreatedBy
  LEFT JOIN UserDetails ud ON ud.UserId = jct.CreatedBy
