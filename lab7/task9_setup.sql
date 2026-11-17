-- ===========================================================================
--  In-Class Task: Three Grants That Do Not Work  --  database setup
--  Database Systems, Laboratory Work 7 (SQL Views and Roles)
--
--  Usage:  createdb billing
--          psql -d billing -f task9_setup.sql
--
--  Every part creates roles, so you need CREATEROLE or superuser rights.
--  Role names belong to the whole PostgreSQL server, not to one database:
--  if the class shares a server, end every role name with your initials.
--
--  3 clients, 4 invoices.  clients.credit_limit is the column that must
--  stay private in Part C.
-- ===========================================================================

DROP TABLE IF EXISTS invoices, clients CASCADE;

CREATE TABLE clients (
    client_id    char(2)     PRIMARY KEY,
    client_name  varchar(14) NOT NULL,
    city         varchar(10) NOT NULL,
    credit_limit int         NOT NULL      -- keep this one hidden
);

CREATE TABLE invoices (
    invoice_id char(2) PRIMARY KEY,
    client_id  char(2) REFERENCES clients,
    amount     int  NOT NULL,
    issued     date NOT NULL
);

INSERT INTO clients VALUES
('C1','Astana Tech',   'Astana',   5000000),
('C2','Almaty Foods',  'Almaty',   2500000),
('C3','Shymkent Build','Shymkent', 8000000);

INSERT INTO invoices VALUES
('I1','C1',450000,'2026-01-15'),
('I2','C1',320000,'2026-02-10'),
('I3','C2',180000,'2026-02-20'),
('I4','C3',900000,'2026-03-01');

-- Tidy up afterwards (roles outlive the database):
--   DROP OWNED BY <each role you made>;
--   DROP ROLE <each role you made>;
