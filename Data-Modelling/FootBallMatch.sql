-- Major League Soccer

CREATE TABLE team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city_id INT,
    coach_id INT,
    FOREIGN KEY (coach_id) REFERENCES coach (coach_id) ON DELETE SET NULL,
    FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE SET NULL
);

CREATE TABLE coach (
    coach_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE player (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT,
    position VARCHAR(50),
    is_captain BOOLEAN DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES team (team_id) ON DELETE CASCADE
);

CREATE TABLE city (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
    FOREIGN KEY (city_id) REFERENCES team (city_id) ON DELETE SET NULL
);

CREATE TABLE match (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    match_date DATE NOT NULL,
    score VARCHAR(10),
    FOREIGN KEY (home_team_id) REFERENCES team (team_id) ON DELETE CASCADE,
    FOREIGN KEY (away_team_id) REFERENCES team (team_id) ON DELETE CASCADE
);


-- Each row here is a single goal by a player in a given match for a specific team. So we can join the goal table to the match table and get the total number of goals per match, join it to the player table and get the number of goals per player or join to both and we can get the score by team.
CREATE TABLE goal (
    goal_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    FOREIGN KEY (match_id) REFERENCES match (match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE
);



-- Create some tables for this that can answer the following

-- How many games has a team played?
-- How many goals did each player make?
-- How many wins did each team make?
-- How many matches did each team win/lose per month and year?


-- 1)
SELECT
    team_id, COUNT(*) AS games_played
FROM
(
	SELECT home_team_id AS team_id FROM Matches
	UNION ALL
	SELECT away_team_id AS team_id FROM Matches
) AS AllMatches
WHERE team_id = 1
GROUP BY team_id;

-- 2)

SELECT
    m.match_id,
    m.match_date,
    CASE
        WHEN m.home_team_id = p.team_id THEN m.home_team_score
        WHEN m.away_team_id = p.team_id THEN m.away_team_score
        ELSE NULL
    END AS player_score
FROM
    Matches m
JOIN
    Players p ON p.team_id IN (m.home_team_id, m.away_team_id)
WHERE
    p.player_id = <player_id>;

-- 3/4)

SELECT
    team_id, team_name,
    EXTRACT(YEAR FROM match_date) AS year, EXTRACT(MONTH FROM match_date) AS month,
    COUNT(*) FILTER (WHERE is_win = 1) AS wins, COUNT(*) FILTER (WHERE is_win = 0) AS losses
FROM
(
	SELECT team_id, match_date,
		CASE
			WHEN home_team_id = team_id AND home_team_score > away_team_score THEN 1
			WHEN away_team_id = team_id AND away_team_score > home_team_score THEN 1
			ELSE 0 END AS is_win
	FROM Matches
) AS TeamMatches
JOIN
    Teams ON TeamMatches.team_id = Teams.team_id
GROUP BY team_id, team_name, year, month
ORDER BY year, month;

