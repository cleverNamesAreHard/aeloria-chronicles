-- Table Definitions
CREATE TABLE IF NOT EXISTS Player (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    character_class TEXT NOT NULL,
    race TEXT NOT NULL,
    faction TEXT NOT NULL,
    background TEXT NOT NULL,
    starting_area TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS quests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    game_mode TEXT NOT NULL, -- e.g., 'story', 'faction_war'
    chapter INTEGER NOT NULL,
    episode INTEGER NOT NULL,
    scene_file TEXT NOT NULL UNIQUE, -- e.g., 'story_1_1.tscn'
    description TEXT NOT NULL, -- Quest summary
    prerequisite_quest_id INTEGER DEFAULT NULL, -- NULL for first quests
    PRIMARY KEY (id),
    FOREIGN KEY (prerequisite_quest_id) REFERENCES quests(id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS player_quests (
    player_id INTEGER NOT NULL,
    quest_id INTEGER NOT NULL,
    status TEXT CHECK( status IN ('not_started', 'in_progress', 'completed') ) DEFAULT 'not_started',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    PRIMARY KEY (player_id, quest_id),
    FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE CASCADE,
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS player_choices (
    player_id INTEGER NOT NULL,
    choice_key TEXT NOT NULL,
    choice_value TEXT NOT NULL,
    PRIMARY KEY (player_id, choice_key),
    FOREIGN KEY (player_id) REFERENCES Player(id) ON DELETE CASCADE
);


CREATE TABLE starting_quests (
    starting_area TEXT PRIMARY KEY,
    quest_id INTEGER NOT NULL,
    FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE
);


-- Player Queries
	select * from Player;
	delete from Player where name != 'Sarumae';
	-- Insert default player (required for the server to start successfully)
	INSERT INTO Player (name, character_class, race, faction, background, starting_area) 
	VALUES ('Sarumae', 'Warrior', 'Human', 'Kingdom of Eldoria', 'Noble', 'Brighthearth');



-- Quest Queries
	-- Insert default quests
	INSERT INTO player_quests (player_id, quest_id, status)
	SELECT Player.id, quests.id, 'in_progress'
	FROM Player
	JOIN quests ON quests.scene_file = 'story_1_1.tscn'
	WHERE Player.id = 2; -- Replace with player ID of your test user
	
	





