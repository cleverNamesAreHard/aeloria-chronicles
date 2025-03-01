DROP TABLE Player;
CREATE TABLE IF NOT EXISTS Player (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    character_class TEXT NOT NULL,
    race TEXT NOT NULL,
    faction TEXT NOT NULL,
    background TEXT NOT NULL,
    starting_area TEXT NOT NULL
);


INSERT INTO Player (name, character_class, race, faction, background, starting_area) 
VALUES ('Sarumae', 'Warrior', 'Human', 'Kingdom of Eldoria', 'Noble', 'Brighthearth');



select * from Player;
