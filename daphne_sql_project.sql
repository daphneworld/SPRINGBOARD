
/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name, membercost
FROM  `Facilities` 
WHERE membercost <> 0.0
GROUP BY name
ORDER BY membercost 

/* Q2: How many facilities do not charge a fee to members? */
SELECT name, membercost
FROM  `Facilities` 
WHERE membercost = 0.0
GROUP BY name
ORDER BY membercost DESC
/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < monthlymaintenance * 0.2
GROUP BY facid, name
ORDER BY membercost DESC 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance <=100
THEN  'cheap'
ELSE  'expensive'
END AS demand
FROM  `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT memid, firstname, surname, MAX( joindate ) 
FROM  `Members` 
WHERE memid <>0
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT 
CASE 
WHEN book.facid =0
THEN  'Tennis Court 1'
ELSE  'Tennis Court 2'
END AS facid, 
CASE 
WHEN mem.firstname <>  'GUEST'
THEN CONCAT( mem.firstname,  ", ", mem.surname ) 
ELSE mem.firstname
END AS member_name
FROM  `Bookings` book
INNER JOIN  `Members` mem ON book.memid = mem.memid
WHERE (
`facid` =0
OR  `facid` =1
)
ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT fac.name, 
CASE WHEN book.memid =0
THEN fac.guestcost * book.slots
ELSE fac.membercost * book.slots
END AS cost, 
CASE WHEN mem.firstname =  'GUEST'
THEN mem.firstname
ELSE CONCAT( mem.firstname,  ", ", mem.surname ) 
END AS member
FROM  `Bookings` book
INNER JOIN  `Facilities` fac ON book.facid = fac.facid
INNER JOIN  `Members` mem ON book.memid = mem.memid
WHERE book.starttime
BETWEEN  '2012-09-14'
AND  '2012-09-15'
HAVING cost >30
ORDER BY cost DESC 
/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT fac.name, 
CASE WHEN book.memid =0
THEN fac.guestcost * book.slots
ELSE fac.membercost * book.slots
END AS cost, 
CASE WHEN mem.firstname =  'GUEST'
THEN mem.firstname
ELSE CONCAT( mem.firstname,  ", ", mem.surname ) 
END AS member
FROM (
SELECT * 
FROM  `Bookings` 
WHERE starttime
BETWEEN  '2012-09-14'
AND  '2012-09-15'
)book
INNER JOIN  `Facilities` fac ON book.facid = fac.facid
INNER JOIN  `Members` mem ON book.memid = mem.memid
HAVING cost >30
ORDER BY cost DESC 

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT fac.name, SUM( 
CASE 
WHEN book.memid =0
THEN fac.guestcost * book.slots
ELSE fac.membercost * book.slots
END ) AS revenue
FROM  `Bookings` book
INNER JOIN  `Facilities` fac ON book.facid = fac.facid
GROUP BY fac.name
HAVING revenue <1000
ORDER BY revenue