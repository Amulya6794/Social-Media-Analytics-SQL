-- ==============================================================
-- SQL + GenAI Mini Project : Social Media Analytics
-- Dataset : Social_Media
-- Student Name : ______________________
-- ==============================================================

-- 🚀 SETUP INSTRUCTIONS (MUST DO FIRST)
-- ==============================================================
-- Before solving this project, make sure you create and load the dataset.
--
-- STEP 1: Open your SQL client (MySQL Workbench, DBeaver, or SQLite Studio).
-- STEP 2: Run the provided dataset file:
--         social_media_analytics_dataset.sql
--
-- This script will:
--   ✅ Create a new database named `Social_Media`
--   ✅ Create all 7 tables (users, posts, comments, likes, followers, hashtags, post_hashtags)
--   ✅ Insert ~7,000 synthetic rows for analysis
--
-- STEP 3: After successful execution, Your Code the database:
--         USE Social_Media;
--
-- STEP 4: Verify the tables:
--         SHOW TABLES;
--         Your Code COUNT(*) FROM users;
--         Your Code COUNT(*) FROM posts;
--
-- Once you confirm the data is loaded, you can proceed to attempt all project queries.
-- ==============================================================

USE Social_Media;

-- ==============================================================
-- IMPORTANT: BEFORE USING GenAI FOR QUERY GENERATION
-- ==============================================================
-- To help the AI generate accurate SQL, you MUST first share your schema.
-- Paste the following context into ChatGPT (or any GenAI tool) BEFORE you ask your prompts:

/*
You are an expert SQL assistant.  
Before answering any question, refer strictly to the database schema provided below.  
All SQL queries, joins, and analyses must be based ONLY on this schema — table names, column names, and relationships mentioned here.  
Do not assume any extra tables or columns unless explicitly stated.  
If a question is ambiguous, clarify it using the schema context rather than inventing new fields.  
Once you understand the schema, wait for my analytical question and generate the most accurate SQL query for it.

Tables and Key Columns:
  1. users(user_id, username, join_date, country)
  2. posts(post_id, user_id, content, created_at)
  3. comments(comment_id, post_id, user_id, comment_text, created_at)
  4. likes(like_id, post_id, user_id, created_at)
  5. followers(follower_id, user_id, follower_user_id, follow_date)
  6. hashtags(hashtag_id, tag_name, category)
  7. post_hashtags(id, post_id, hashtag_id)

Relationships:
  • Each user can create multiple posts.
  • Each post can have multiple likes and comments.
  • Users can follow each other (self-join in followers table).
  • Posts can be tagged with multiple hashtags (many-to-many via post_hashtags).
*/

-- Once you paste the schema, THEN use prompts like:
--   "Generate SQL to find top 10 active users combining posts and comments."
--   "Find trending hashtags used in more than 20 posts."
-- ==============================================================




-- ==============================================================
-- Q1. Most Active Users (Posts + Comments)
-- ==============================================================
-- Objective : Find top 10 users based on combined number of posts and comments.
-- Example GenAI Prompt :
--   "Write SQL to find top 10 active users combining posts and comments count."
-- Write your query below 👇
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id) AS total_activity
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
ORDER BY total_activity DESC
LIMIT 10;


-- Solution Summary -- 
-- This query joins the users, posts, and comments tables.
-- It counts the total posts and comments made by each user,
-- calculates their combined activity, and displays the top
-- 10 most active users in descending order.

-- ==============================================================
-- Q2. Most Liked Posts and Creators
-- ==============================================================
-- Objective : Identify posts with maximum likes along with their creator.
-- Example GenAI Prompt :
--   "Show top 10 posts with most likes and username."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    p.post_id,
    u.username,
    COUNT(l.like_id) AS total_likes
FROM posts p
JOIN users u
    ON p.user_id = u.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
GROUP BY p.post_id, u.username
ORDER BY total_likes DESC
LIMIT 10;


-- Solution Summary -- 
-- This query joins the posts, users, and likes tables.
-- It counts the total likes received by each post,
-- displays the creator's username, and shows the
-- top 10 most liked posts.

-- ==============================================================
-- Q3. Top Countries by Average Engagement
-- ==============================================================
-- Objective : Find countries with the highest average likes per post.
-- Example GenAI Prompt :
--   "Which countries have highest average likes per post?"
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    u.country,
    AVG(COALESCE(l.like_count, 0)) AS avg_likes_per_post
FROM users u
JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN
(
    SELECT
        post_id,
        COUNT(*) AS like_count
    FROM likes
    GROUP BY post_id
) l
ON p.post_id = l.post_id
GROUP BY u.country
ORDER BY avg_likes_per_post DESC;


-- Solution Summary -- 
-- This query joins the users and posts tables and calculates
-- the total likes for each post using a subquery. It then
-- computes the average likes per post for each country and
-- displays the countries in descending order of average engagement.

-- ==============================================================
-- Q4. Trending Hashtags (Used in >20 Posts)
-- ==============================================================
-- Objective : Find hashtags that appear in more than 20 posts.
-- Example GenAI Prompt :
--   "Find hashtags used in more than 20 posts."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    h.tag_name,
    COUNT(ph.post_id) AS total_posts
FROM hashtags h
JOIN post_hashtags ph
    ON h.hashtag_id = ph.hashtag_id
GROUP BY h.tag_name
HAVING COUNT(ph.post_id) > 20
ORDER BY total_posts DESC;


-- Solution Summary -- 
-- This query joins the hashtags and post_hashtags tables.
-- It counts how many posts use each hashtag, filters hashtags
-- that appear in more than 20 posts using HAVING, and displays
-- them in descending order based on usage.

-- ==============================================================
-- Q5. Top Influencers (Users with Most Followers)
-- ==============================================================
-- Objective : List users with the highest follower count.
-- Example GenAI Prompt :
--   "Find users with maximum followers."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    u.user_id,
    u.username,
    COUNT(f.follower_user_id) AS total_followers
FROM users u
LEFT JOIN followers f
    ON u.user_id = f.user_id
GROUP BY u.user_id, u.username
ORDER BY total_followers DESC
LIMIT 10;


-- Solution Summary -- 
-- This query joins the users and followers tables.
-- It counts the number of followers for each user,
-- sorts them in descending order, and displays the
-- top 10 users with the highest follower count.

-- ==============================================================
-- Q6. Followers Who Never Interacted
-- ==============================================================
-- Objective : Identify users who follow others but have never liked or commented.
-- Example GenAI Prompt :
--   "Show users who follow others but never interacted."
-- --------------------------------------------------------------
-- Your Code ...
SELECT DISTINCT
    u.user_id,
    u.username
FROM users u
JOIN followers f
    ON u.user_id = f.follower_user_id
LEFT JOIN likes l
    ON u.user_id = l.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
WHERE l.user_id IS NULL
  AND c.user_id IS NULL;


-- Solution Summary -- 
-- This query identifies users who follow other users but have
-- never liked any post or written any comment. DISTINCT removes
-- duplicate users who follow multiple accounts.
-- ==============================================================

-- Q7. Hashtags with Highest Engagement
-- ==============================================================
-- Objective : Calculate total engagement (likes + comments) for each hashtag.
-- Example GenAI Prompt :
--   "Calculate engagement score per hashtag."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    h.tag_name,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS engagement_score
FROM hashtags h
JOIN post_hashtags ph
    ON h.hashtag_id = ph.hashtag_id
JOIN posts p
    ON ph.post_id = p.post_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY h.tag_name
ORDER BY engagement_score DESC;


-- Solution Summary -- 
-- This query joins hashtags, post_hashtags, posts, likes,
-- and comments tables. It calculates the total engagement
-- for each hashtag by adding the number of likes and comments
-- received on posts containing that hashtag, then displays
-- the hashtags in descending order of engagement.

-- ==============================================================
-- Q8. Busiest Posting Hours or Days
-- ==============================================================
-- Objective : Find which hour/day sees most posting activity.
-- Example GenAI Prompt :
--   "Write SQL to show which hour or weekday sees most posts."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    HOUR(created_at) AS posting_hour,
    COUNT(post_id) AS total_posts
FROM posts
GROUP BY HOUR(created_at)
ORDER BY total_posts DESC;


-- Solution Summary -- 
-- This query extracts the hour from the post creation timestamp
-- using the HOUR() function. It counts the number of posts
-- created in each hour and sorts the results in descending
-- order to identify the busiest posting hours.

-- ==============================================================
-- Q9. Inactive Users
-- ==============================================================
-- Objective : Find users who have never posted, liked, or commented.
-- Example GenAI Prompt :
--   "Find users who have never posted, liked, or commented."
-- --------------------------------------------------------------
-- Your Code ...
SELECT DISTINCT
    u.user_id,
    u.username
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON u.user_id = l.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
WHERE p.user_id IS NULL
  AND l.user_id IS NULL
  AND c.user_id IS NULL;


-- Solution Summary -- 
-- This query uses LEFT JOIN to connect the users table with
-- posts, likes, and comments. It returns only those users who
-- have no matching records in any of these tables, identifying
-- users who have never posted, liked, or commented.

-- ==============================================================
-- Q10. Top Countries with Most Influencers
-- ==============================================================
-- Objective : Identify countries with the highest number of influencers.
-- Example GenAI Prompt :
--   "Generate SQL to find countries that have the most followed users."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    u.country,
    COUNT(*) AS total_influencers
FROM users u
JOIN (
    SELECT
        user_id,
        COUNT(follower_user_id) AS follower_count
    FROM followers
    GROUP BY user_id
) f
ON u.user_id = f.user_id
GROUP BY u.country
ORDER BY total_influencers DESC;


-- Solution Summary -- 
-- This query first calculates the follower count for each user
-- using the followers table. It then joins the result with the
-- users table to determine each user's country. Finally, it
-- counts the number of users with followers in each country
-- and displays the countries in descending order of influencers.


-- ==============================================================
-- BONUS CHALLENGES
-- ==============================================================
-- 1. Engagement rate = (likes + comments) / posts
-- 2. Mutual followers
-- 3. Most used hashtags by top 5 influencers
-- 4. Country-wise engagement leaderboard
-- --------------------------------------------------------------

-- ==============================================================
-- REFLECTION
-- ==============================================================
-- 1. How did GenAI assist you in solving these queries?
-- GenAI helped me understand the SQL requirements, generate
-- appropriate queries, explain JOINs, GROUP BY, HAVING,
-- aggregate functions, and resolve errors during execution.
-- It also helped me optimize and verify the correctness of
-- each query.
-- 2. What optimization tips did you learn?
-- - Use JOINs only when required.
-- - Use LEFT JOIN to find missing records.
-- - Use COUNT(DISTINCT ...) to avoid duplicate counts.
-- - Apply GROUP BY with aggregate functions correctly.
-- - Use HAVING to filter grouped results.
-- - Sort results using ORDER BY and limit output using LIMIT.
-- - Write clear and readable SQL queries for better maintenance.
-- 3. What business insights stood out to you?
-- - Active users generate more engagement on the platform.
-- - Some posts receive significantly more likes than others.
-- - Popular hashtags improve engagement and content visibility.
-- - Certain hours have higher posting activity, helping determine
--   the best time to publish content.
-- - Some users are inactive and may require re-engagement
--   strategies.
-- - Countries with more influencers can be targeted for
--   marketing and promotional campaigns.
-- ==============================================================
