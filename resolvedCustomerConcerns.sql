SELECT
    c.Id,
    c.TicketNumber,
    cx.CompanyName,
    ct.Name AS Type,
    CASE
       WHEN c.UrgencyId = 1 THEN 'Low'
       WHEN c.UrgencyId = 2 THEN 'Medium'
       WHEN c.UrgencyId = 3 THEN 'High'
    END AS Urgency,
    t.Name AS Team,
    c.DueDate,
    c.CreatedBy,
    c.Created,
     ud.FirstName + ' ' + ud.LastName AS 'Resolved By',
    cct.Created AS 'Resolution Date'
   
FROM CustomerConcerns c
LEFT JOIN CustomerConcernThreads cct ON cct.CustomerConcernId = c.Id AND cct.CustomerConcernThreadType = 2
LEFT JOIN Customers cx ON cx.Id = c.CustomerId
LEFT JOIN ConcernTypes ct ON ct.Id = c.ConcernTypeId
LEFT JOIN Teams t ON t.Id = c.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = cct.CreatedBy