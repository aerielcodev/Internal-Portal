SELECT DISTINCT
    r.Id,
    r.TicketNumber,
    cx.Id AS CustomerId,
    cx.CompanyName,
    rt.Name AS Type,
    r.Message AS Message,
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
    grt.Created AS 'Resolution',
    'General Request' AS Category
   
FROM GeneralRequests r
LEFT JOIN GeneralRequestThreads grt ON grt.GeneralRequestId = r.Id AND grt.GeneralRequestThreadType = 2
LEFT JOIN Customers cx ON cx.Id = r.CustomerId
LEFT JOIN GeneralRequestTypes rt ON rt.Id = r.GeneralRequestTypeId
LEFT JOIN Teams t ON t.Id = r.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = grt.CreatedBy
UNION ALL
SELECT
    c.Id,
    c.TicketNumber,
    cx.Id ,
    cx.CompanyName,
    ct.Name,
    cct.Message,
    CASE
       WHEN c.UrgencyId = 1 THEN 'Low'
       WHEN c.UrgencyId = 2 THEN 'Medium'
       WHEN c.UrgencyId = 3 THEN 'High'
    END,
    t.Name,
    c.DueDate,
    c.CreatedBy,
    c.Created,
     ud.FirstName + ' ' + ud.LastName ,
    cct.Created,
   'Concern'
FROM CustomerConcerns c
LEFT JOIN CustomerConcernThreads cct ON cct.CustomerConcernId = c.Id AND cct.CustomerConcernThreadType = 2
LEFT JOIN Customers cx ON cx.Id = c.CustomerId
LEFT JOIN ConcernTypes ct ON ct.Id = c.ConcernTypeId
LEFT JOIN Teams t ON t.Id = c.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = cct.CreatedBy