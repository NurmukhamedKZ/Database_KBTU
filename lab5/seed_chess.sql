-- Sample rows for In-Class Task: Chess Club (run after Task 3)
INSERT INTO coaches (coach_id, full_name, email) VALUES
    (1, 'Bolat Ermek', 'bolat@chess.kz'),
    (2, 'Saule Kim',   NULL);

INSERT INTO players (player_id, full_name, rating, coach_id) VALUES
    (1, 'Arman Bekov',   1500, 1),
    (2, 'Dana Omarova',  1800, 1),
    (3, 'Timur Seitov',  1350, 2),
    (4, 'Zhanna Abay',   2100, NULL);

INSERT INTO matches (match_id, white_id, black_id, match_date) VALUES
    (1, 1, 2, '2026-10-10'),
    (2, 3, 4, '2026-10-10');
