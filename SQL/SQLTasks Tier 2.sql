/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT NAME 
FROM Facilities 
WHERE MEMBERCOST >0;

/* Q2: How many facilities do not charge a fee to members? */
-- There are 4 facilities that do not charge their members
SELECT COUNT(FACID)
FROM Facilities 
WHERE MEMBERCOST=0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
    FACID,
    NAME, 
    MEMBERCOST,
    MONTHLYMAINTENANCE
FROM Facilities 
WHERE MEMBERCOST < .2*MONTHLYMAINTENANCE;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE FACID IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
    NAME,
    MONTHLYMAINTENANCE,
    CASE WHEN MONTHLYMAINTENANCE<100 THEN 'cheap'
    ELSE 'expensive' END AS LABEL
FROM Facilities;



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT
    FIRSTNAME,
    SURNAME
FROM Members
WHERE JOINDATE = (
                    SELECT MAX(JOINDATE)
                    FROM Members
                );
    

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
    F.Name,
    CONCAT (M.FIRSTNAME, ' ', M.SURNAME) FULL_NAME
FROM Members M
INNER JOIN Bookings as B
ON B.MEMID = M.MEMID
INNER JOIN Facilities as F
ON F.FACID = B.FACID
WHERE F.NAME LIKE 'Tennis Court%'
ORDER BY FULL_NAME;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name, concat (Members.firstname,' ', Members.surname) as mem_name, 
CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots END AS total_cost
FROM Members, Facilities, Bookings
WHERE
Bookings.facid = Facilities.facid
AND Members.memid = Bookings.memid
AND Bookings.starttime LIKE '2012-09-14%'
HAVING total_cost > 30
ORDER BY total_cost desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT B.NAME, concat (M.FIRSTNAME,' ', M.SURNAME) as mem_name, B.TOTAL_COST
FROM Members as M
RIGHT JOIN (SELECT B.BOOKID,B.MEMID, F.NAME,
CASE WHEN B.MEMID = 0 THEN F.GUESTCOST * B.SLOTS
ELSE F.MEMBERCOST * B.SLOTS END AS TOTAL_COST
FROM Bookings B
INNER JOIN Facilities F
ON B.FACID = F.FACID
WHERE B.starttime LIKE '2012-09-14%'
Having total_cost>30
) as B
ON M.MEMID=B.MEMID
ORDER BY B.TOTAL_COST desc



