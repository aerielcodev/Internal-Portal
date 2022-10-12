SELECT DISTINCT
    r.Id,
    r.TicketNumber,
    cx.CompanyName,
    rt.Name AS Type,
    CASE
       WHEN r.UrgencyTypeId = 1 THEN 'Low'
       WHEN r.UrgencyTypeId = 2 THEN 'Medium'
       WHEN r.UrgencyTypeId = 3 THEN 'High'
    END AS Urgency,
    t.Name AS Team,
    r.DueDate,
    r.CreatedBy,
    r.Created,
     ud.FirstName + ' ' + ud.LastName AS 'Resolved By',
    grt.Created AS 'Resolution Date'
   
FROM GeneralRequests r
LEFT JOIN GeneralRequestThreads grt ON grt.GeneralRequestId = r.Id AND grt.GeneralRequestThreadType = 2
LEFT JOIN Customers cx ON cx.Id = r.CustomerId
LEFT JOIN GeneralRequestTypes rt ON rt.Id = r.GeneralRequestTypeId
LEFT JOIN Teams t ON t.Id = r.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = grt.CreatedBy
