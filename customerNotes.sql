/*Notes saved in the customer's profile*/
SELECT
    cn.Id,
    cn.CustomerId,
    c.CompanyName AS Customer,
    nt.Name AS 'Note Type',
    cn.Message,
    CONCAT(TRIM(cb.FirstName),' ',TRIM(cb.LastName)) AS 'Created By',
    cn.Created AS 'Created Date',
    CONCAT(TRIM(mb.FirstName),' ',TRIM(mb.LastName)) AS 'Last Modified By',
    cn.LastModified AS 'Last Modified Date',
    cn.CustomerConcernId,
    cn.GeneralRequestId,
    cn.JobOpeningPositionId,
	cn.HubSpotId
FROM CustomerNotes cn
JOIN NoteTypes nt ON nt.Id = cn.NoteTypeId
JOIN UserDetails cb ON cb.UserId = cn.CreatedBy
LEFT JOIN UserDetails mb ON mb.UserId = cn.LastModifiedBy
LEFT JOIN Customers c ON c.Id = cn.CustomerId
ORDER BY cn.Created DESC