DELETE e1 FROM REMINDERS_RESPONSIBLE_LINK e1, REMINDERS_RESPONSIBLE_LINK e2 
WHERE e1.ReminderID = e2.ReminderID 
AND e1.ResponsibleID = e2.ResponsibleID 
AND e1.id > e2.id;

ALTER TABLE REMINDERS_RESPONSIBLE_LINK
CHANGE COLUMN ID ID VARCHAR(25) NULL,
CHANGE COLUMN ReminderID ReminderID VARCHAR(25) NOT NULL,
CHANGE COLUMN ResponsibleID ResponsibleID VARCHAR(25) NOT NULL,
DROP PRIMARY KEY,
ADD PRIMARY KEY (ReminderID, ResponsibleID);