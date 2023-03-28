SELECT DISTINCT
    r.Id,
    r.TicketNumber,
    cx.Id AS CustomerId,
    cx.CompanyName,
    tm.teamMember,
    rt.Name AS Type,
    r.Message AS Message,
    CASE
       WHEN r.UrgencyTypeId = 1 THEN 'Low'
       WHEN r.UrgencyTypeId = 2 THEN 'Medium'
       WHEN r.UrgencyTypeId = 3 THEN 'High'
    END AS Urgency,
    t.Name AS Team,
    r.DueDate,
    coalesce(cb.FirstName + ' ' + cb.LastName,cu.FirstName + ' ' + cu.LastName) AS 'Created By',
    r.CreatedBy,
    r.Created,
     ud.FirstName + ' ' + ud.LastName AS 'Resolved By',
     mb.FirstName + ' ' + mb.LastName AS 'Last Modified By',
    grt.Created AS 'Resolution',
    'General Request' AS Category
   
FROM GeneralRequests r
LEFT JOIN GeneralRequestThreads grt ON grt.GeneralRequestId = r.Id AND grt.GeneralRequestThreadType = 2
LEFT JOIN Customers cx ON cx.Id = r.CustomerId
LEFT JOIN GeneralRequestTypes rt ON rt.Id = r.GeneralRequestTypeId
LEFT JOIN Teams t ON t.Id = r.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = grt.CreatedBy
LEFT JOIN UserDetails cb ON cb.UserId = r.CreatedBy
LEFT JOIN UserDetails mb ON mb.UserId = r.LastModifiedBy
LEFT JOIN CustomerUsers cu ON cu.UserId = r.CreatedBy
LEFT JOIN (
    SELECT
        GeneralRequestMembers.Id AS genReqId,
        string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',') teamMember
    FROM GeneralRequestMembers
    INNER JOIN Employees ON Employees.Id = GeneralRequestMembers.EmployeeId
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY GeneralRequestMembers.Id) AS tm ON  tm.genReqId = r.Id
UNION ALL
SELECT DISTINCT
    c.Id,
    c.TicketNumber,
    cx.Id ,
    cx.CompanyName,
    tm.teamMember,
    ct.Name,
    cxt.Message,
    CASE
       WHEN c.UrgencyId = 1 THEN 'Low'
       WHEN c.UrgencyId = 2 THEN 'Medium'
       WHEN c.UrgencyId = 3 THEN 'High'
    END,
    t.Name,
    c.DueDate,
    coalesce(cb.FirstName + ' ' + cb.LastName,cu.FirstName + ' ' + cu.LastName),
    c.CreatedBy,
    c.Created,
     ud.FirstName + ' ' + ud.LastName ,
     mb.FirstName + ' ' + mb.LastName,
    cct.Created,
   'Concern'
FROM CustomerConcerns c
LEFT JOIN CustomerConcernThreads cxt ON cxt.CustomerConcernId = c.Id AND cxt.CustomerConcernThreadType = 1 /*customer information*/
LEFT JOIN CustomerConcernThreads cct ON cct.CustomerConcernId = c.Id AND cct.CustomerConcernThreadType = 2
LEFT JOIN Customers cx ON cx.Id = c.CustomerId
LEFT JOIN ConcernTypes ct ON ct.Id = c.ConcernTypeId
LEFT JOIN Teams t ON t.Id = c.TeamId
LEFT JOIN UserDetails ud ON ud.UserId = cct.CreatedBy
LEFT JOIN UserDetails cb ON cb.UserId = c.CreatedBy
LEFT JOIN UserDetails mb ON mb.UserId = c.LastModifiedBy
LEFT JOIN CustomerUsers cu ON cu.UserId = c.CreatedBy
LEFT JOIN (
    SELECT
        CustomerConcernEmployees.CustomerConcernId AS concernId,
        string_agg(UserDetails.FirstName + ' ' + UserDetails.LastName,',') teamMember
    FROM CustomerConcernEmployees
    INNER JOIN Employees ON CustomerConcernEmployees.EmployeeId = Employees.Id
    INNER JOIN UserDetails ON UserDetails.UserId = Employees.UserId
GROUP BY CustomerConcernEmployees.CustomerConcernId) AS tm ON  tm.concernId = c.Id