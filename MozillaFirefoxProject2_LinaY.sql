/*1. How many of the total users completed the survey?*/
SELECT
COUNT(distinct user_id) AS total_users_tookSurvey
FROM survey
--ANSWER: 4,081

SELECT
COUNT( distinct id) AS sample_size_users
FROM users
--ANSWER: 27,267

/*2. Of users who completed the survey, identify the number of users who are new to Firefox, as well as those who are longtime users.*/
SELECT
  CASE 
	  WHEN (q1 :: INTEGER) BETWEEN 0 AND 2 THEN 'new_user' 
	  WHEN (q1 :: INTEGER) BETWEEN 3 AND 4 THEN 'intermediate_user' 
	  WHEN (q1 :: INTEGER) BETWEEN 5 AND 6 THEN 'longtime_user' 
	  ELSE 'other' 
  END AS user_type,
  COUNT(q1) :: INTEGER AS number_users
FROM
  survey
GROUP BY
  1
ORDER BY
  1 asc;
--ANSWER: new users: 356, longtime users: 2830

/*3. What’s the median number of bookmarks? What’s the average number?*/
SELECT
  AVG (
    CAST(
      TRIM(
        TRAILING 'total bookmarks'
        FROM
          data1
      ) AS INTEGER
    )
  ) AS avg_Bookmarks
FROM
  events
WHERE
  event_code = 8;
--
SELECT
  distinct user_id,
  AVG (
    cast(
      trim(
        TRAILING 'total bookmarks'
        FROM
          data1
      ) AS INTEGER
    )
  ) AS avg_Bookmarks
FROM
  events
WHERE
  event_code = 8
GROUP BY
  1;

/*4. What fraction of users launched at least one bookmark during the sample week?*/
SELECT
  CASE 
  	WHEN event_code = 10 THEN 'launched_bookmark' 
  	ELSE 'other' 
  END AS Bookmark_Activity,
  COUNT(distinct user_id) AS total
FROM
  events
GROUP BY
  1;

/*4a. What fraction of users launched a tab during the sample week?*/
SELECT
  CASE 
  	WHEN event_code = 26 THEN 'launched_tab' 
  	ELSE 'other' 
  END AS Tab_Activity,
  COUNT(distinct user_id) AS total
FROM
  events
GROUP BY
  1;

/*5. What fraction of users created new bookmarks?*/
SELECT
  CASE 
  	WHEN event_code = 9 AND data1 = 'New Bookmark Added' THEN 'created_bookmark' 
  	WHEN event_code = 10 THEN 'launched_bookmark' 
  END AS Bookmark_Activity,
  COUNT (distinct user_id) AS total
FROM
  events
GROUP BY
  1;

/*6. What's the distribution of how often bookmarks are used?*/

SELECT
  survey.user_id,
  CASE 
  	WHEN (survey.q1 :: INTEGER) BETWEEN 0 AND 2 THEN 'new_user' 
  	WHEN (survey.q1 :: INTEGER) BETWEEN 3 AND 4 THEN 'intermediate_user' 
  	WHEN (survey.q1 :: INTEGER) BETWEEN 5 AND 6 THEN 'longtime_user' 
  	ELSE 'other' 
  END AS user_type,
  events.event_code,
  (
    cast(
      trim(
        TRAILING 'total bookmarks'
        FROM
          events.data1
      ) AS INTEGER
    )
  ) AS bookmarks
FROM
  survey
  inner join events on survey.user_id = events.user_id
WHERE
  event_code = 8
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  4 desc;


/*7. How does number of bookmarks correlate with how long the user has been using Firefox?*/
SELECT
CASE
	WHEN (survey.q1::INTEGER) BETWEEN 0 AND 2 THEN 'new_user'
	WHEN (survey.q1::INTEGER) BETWEEN 3 AND 4 THEN 'intermediate_user'
	WHEN (survey.q1::INTEGER) BETWEEN 5 AND 6 THEN 'longtime_user'
	ELSE 'other'
END AS user_type,
events.event_code,
COUNT(q1) :: INTEGER AS number_users,
  AVG(
    cast(
      trim(
        TRAILING 'total bookmarks'
        FROM
          events.data1
      ) AS INTEGER
    )
  ) AS avg_bookmarks
FROM
  survey
  left join events ON survey.user_id = events.user_id
WHERE
  events.event_code = 8
GROUP BY
  1,
  2
ORDER BY
  2 asc;


/*7a. How does number of tabs correlate with how long the user has beeing using Firefox?*/
SELECT
CASE
	WHEN (survey.q1::INTEGER) BETWEEN 0 AND 2 THEN 'new_user'
	WHEN (survey.q1::INTEGER) BETWEEN 3 AND 4 THEN 'intermediate_user'
	WHEN (survey.q1::INTEGER) BETWEEN 5 AND 6 THEN 'longtime_user'
	ELSE 'other'
END AS user_type,
events.event_code,
COUNT(q1)::INTEGER as number_users,
AVG(
    cast(
      trim(
        TRAILING 'tabs'
        FROM
          data2
      ) AS INTEGER
    )
  ) AS avgNumber_tabs
FROM
  survey
  left join events ON survey.user_id = events.user_id
WHERE
  event_code = 26
GROUP BY
  1,
  2
ORDER BY
  2 asc;


/*8. What's the distribution of the maximum number of tabs (by survey sample size)?*/
SELECT  
survey.user_id,
CASE
	WHEN (survey.q1::INTEGER) BETWEEN 0 AND 2 THEN 'new_user'
	WHEN (survey.q1::INTEGER) BETWEEN 3 AND 4 THEN 'intermediate_user'
	WHEN (survey.q1::INTEGER) BETWEEN 5 AND 6 THEN 'longtime_user'
	ELSE 'other'
END AS user_type,
events.event_code,
  (
    cast(
      trim(
        TRAILING 'tabs'
        FROM
          data2
      ) AS INTEGER
    )
  ) AS tabs
FROM
  survey
  inner join events on survey.user_id = events.user_id
WHERE
  event_code = 26
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  4 desc;

/*9.What fraction of user have ever had more than five tabs open? What fraction of users have ever had more than 10 tabs open? What fraction of users have had more than 15 tabs open?*/
SELECT
CASE 
	WHEN tabs BETWEEN 5 AND 9 THEN '5orMoreTabs'
	WHEN tabs BETWEEN 10 AND 14 THEN '10orMoreTabs'
	WHEN tabs > 15 THEN '15orMoreTabs'
	ELSE 'other'
END AS number_tabs,
COUNT (distinct user_id) AS totalnumberofusers
FROM
  (
    SELECT
      user_id,
      sum(
        cast(
          trim(
            TRAILING 'tabs'
            FROM
              data2
          ) AS INTEGER
        )
      ) AS tabs
    FROM
      events
    WHERE
      event_code = 26
    GROUP BY
      1
    ORDER BY
      1
  ) AS subquery
GROUP BY
  1;

--What are the characteristics of Firefox users? 
--% of users who ONLY use Firefox or use Firefox as their primary browser?
SELECT
CASE
	WHEN (q4::INTEGER) = 0 THEN 'Only_Firefox'
	WHEN (q4::INTEGER) = 1 THEN 'Firefox_primary'
	WHEN (q4::INTEGER) = 2 THEN 'Chrome_primary'
	WHEN (q4::INTEGER) = 3 THEN 'Safari_primary'
	WHEN (q4::INTEGER) = 4 THEN 'Opera_primary'
	WHEN (q4::INTEGER) = 5 THEN 'IE_primary'
	ELSE 'n/a'
END AS number_users_per_primary_browser,
COUNT(distinct user_id) AS number_users
FROM survey
GROUP BY 1;

--
SELECT 
CASE
	WHEN (q4::INTEGER) = 0 THEN 'Only_Firefox'
	WHEN (q4::INTEGER) = 1 THEN 'Firefox_primary'
	WHEN (q4::INTEGER) BETWEEN 2 AND 5 THEN 'other_browser_primary'
ELSE 'n/a'
END AS number_users_per_primary_browser,
COUNT(distinct user_id) AS number_users
FROM survey
GROUP BY 1;

--% female vs male?
SELECT 
CASE 
	WHEN (q5::INTEGER) = 0 THEN 'male'
	WHEN (q5::INTEGER) = 1 THEN 'female'
	ELSE 'n/a'
END AS gender,
COUNT (q5)::INTEGER AS number_users
FROM survey
GROUP BY 1;

--% of users who use Firefox for work vs school vs leisure? 
SELECT
CASE 
	WHEN q9 like '0%0' THEN 'Home'
	WHEN q9 like '%1%'THEN 'Work'
	WHEN q9 like '%2%' THEN 'School'
	WHEN q9 like '%3%' THEN 'Mobile'
	ELSE 'n/a'
END AS type_of_usage,
COUNT (user_id) AS number_users
FROM survey
GROUP BY 1;

--Correlation BETWEEN # tabs vs bookmark by user? 
SELECT
  *
FROM
  (
    SELECT
      user_id,
      sum(
        cast(
          trim(
            TRAILING 'total bookmarks'
            FROM
              data1
          ) AS INTEGER
        )
      ) AS avg_bookmarks
    FROM
      events
    WHERE
      event_code = 8
    GROUP BY
      1
  ) t1
  left join (
    SELECT
      user_id,
      sum(
        cast(
          trim(
            TRAILING 'tabs'
            FROM
              data2
          ) AS INTEGER
        )
      ) AS tabs
    FROM
      events
    WHERE
      event_code = 26
    GROUP BY
      1
  ) t2 ON t1.user_id = t2.user_id
ORDER BY
  1;



