CREATE TABLE coaches (
    coach_id   integer PRIMARY KEY,
    full_name  text NOT NULL,
    email      text CONSTRAINT unique_email UNIQUE
)

CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL ,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 100 AND 3000) DEFAULT 1200,
    coach_id INTEGER REFERENCES coaches (coach_id) ON DELETE SET NULL
)

CREATE TABLE matches (
    match_id INTEGER PRIMARY KEY ,
    white_id INTEGER NOT NULL REFERENCES players (player_id),
    black_id INTEGER NOT NULL REFERENCES players (player_id),
    match_date DATE not null,
    CONSTRAINT different_players CHECK (white_id <> black_id),
    UNIQUE (white_id, black_id, match_id)
)


task 4
1 OK
2 ERROR: new row for relation "matches" violates check constraint "different_players"
3 ERROR: relation "unique_email" already exists
4 OK
5 ERROR: update or delete on table "players" violates foreign key constraint "matches_black_id_fkey" on table "matches"
6 ERROR: new row for relation "players" violates check constraint "players_rating_check"
