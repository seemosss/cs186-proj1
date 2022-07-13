-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS slg;
DROP VIEW IF EXISTS totalslg;
DROP VIEW IF EXISTS maxid;

-- Question 0
CREATE VIEW q0(era)
AS
 SELECT MAX(era)
 FROM pitching
; -- replace this line


-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst like '% %'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*)
  FROM people
  GROUP BY birthyear
  HAVING avg(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, a.playerid, yearid
  FROM 
  halloffame AS a INNER JOIN people AS b 
  ON a.playerid = b.playerid
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, a.playerid ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, a.playerid, c.schoolid, yearid
  FROM 
  halloffame AS a, people AS b, schools AS c, collegeplaying AS d
  WHERE a.playerid = b.playerid and a.playerid = d.playerid and c.schoolid = d.schoolid
  and c.schoolstate = 'CA' and inducted = 'Y'
  ORDER BY yearid DESC, c.schoolid ASC, a.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT a.playerid, namefirst, namelast, c.schoolid
  FROM 
  halloffame AS a, 
  people AS b LEFT OUTER JOIN collegeplaying AS c ON b.playerid = c.playerid
  WHERE a.playerid= b.playerid and inducted = 'Y'
  ORDER BY a.playerid DESC, c.schoolid ASC
;

CREATE VIEW slg(playerid, yearid, ab, slgval)
AS
  SELECT playerid, yearid, ab, 1.0 * (H + H2B + 2 * H3B + 3 * HR) / AB 
  FROM batting
  WHERE ab > 50
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT a.playerid, namefirst, namelast, yearid, slgval
  FROM people AS a, slg AS b
  WHERE a.playerid = b.playerid
  ORDER BY slgval DESC, yearid, a.playerid
  LIMIT 10
;

CREATE VIEW totalslg(playerid, ab, h, h2b, h3b, hr)
AS
  SELECT playerid, SUM(ab), SUM(h), SUM(h2b), SUM(h3b), SUM(hr) 
  FROM batting
  GROUP BY playerid
  HAVING SUM(ab) > 50
;


-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT a.playerid, namefirst, namelast, 1.0 * (H + H2B + 2 * H3B + 3 * HR) / AB AS lslg
  FROM people AS a, totalslg AS b
  WHERE a.playerid = b.playerid
  ORDER BY lslg DESC, a.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, 1.0 * (H + H2B + 2 * H3B + 3 * HR) / AB AS lslg
  FROM people AS a, totalslg AS b
  WHERE a.playerid = b.playerid and lslg > 
    (SELECT 1.0 * (H + H2B + 2 * H3B + 3 * HR) / AB
    FROM totalslg
    WHERE totalslg.playerid = 'mayswi01')
  
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT a.yearid, a.min - b.min, a.max - b.max, a.avg - b.avg
  FROM q4i AS a, q4i AS b
  WHERE a.yearid - 1 = b.yearid
  ORDER BY a.yearid
;

CREATE VIEW maxid(playerid, salary, yearid)
AS
  SELECT playerid, salary, yearid
    FROM salaries 
    WHERE (yearid = 2000 AND salary = 
          (SELECT MAX(salary)
          FROM salaries s1
          WHERE s1.yearid = 2000)
          )
          OR 
          (yearid = 2001 AND salary =
          (SELECT MAX(salary)
          FROM salaries s2
          WHERE s2.yearid = 2001)
          )
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, m.salary, m.yearid
  FROM people p INNER JOIN maxid m
  ON p.playerid = m.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT b.teamid, max(salary) - min(salary)
  FROM salaries a INNER JOIN AllstarFull b 
  ON a.playerid = b.playerid and a.yearid = b.yearid
  WHERE a.yearid = 2016
  GROUP BY b.teamid
;

