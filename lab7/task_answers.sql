CREATE ROLE auditor_nm;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO auditor_nm;
SET ROLE auditor_nm;
SELECT * FROM clients;   
SELECT * FROM invoices;  
RESET ROLE;



CREATE TABLE payments (pay_id char(2), paid int);
INSERT INTO payments VALUES ('P1', 450000);
SET ROLE auditor;
SELECT * FROM payments;  -- ERROR: permission denied for table payments
RESET ROLE;



ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO auditor
CREATE TABLE receipt (num int);
INSERT INTO receipt VALUES (1);
SET ROLE auditor;
SELECT * FROM receipt;
RESET ROLE;



SET ROLE auditor;
SELECT * FROM payments;  -- ERROR: permission denied
RESET ROLE;

-- Part B

CREATE ROLE temp_staff_nm;
GRANT SELECT ON invoices TO PUBLIC;
SET ROLE temp_staff_nm;
SELECT * FROM invoices;
RESET ROLE;


REVOKE SELECT ON invoices FROM temp_staff_nm;
SET ROLE temp_staff_nm;
SELECT * FROM invoices; -- Nothing
RESET ROLE;



SELECT relname, relacl FROM pg_class
WHERE relname = 'invoices';
-- Before: invoices,"{postgres=arwdDxtm/postgres,auditor=r/postgres,=r/postgres}"
REVOKE SELECT ON invoices FROM PUBLIC;
SELECT relname, relacl FROM pg_class WHERE relname = 'invoices';
-- After: invoices,"{postgres=arwdDxtm/postgres,auditor=r/postgres}"
SET ROLE temp_staff_nm;
SELECT * FROM invoices;  -- ERROR: permission denied
RESET ROLE;


-- Part C
CREATE ROLE desk_clerk_nm;
GRANT SELECT (client_id, client_name, city) ON clients TO desk_clerk_nm;
SET ROLE desk_clerk_nm;
SELECT client_id, client_name, city FROM clients;
SELECT * FROM clients; -- ERROR: permission denied for table clients
SELECT client_name, credit_limit FROM clients; -- ERROR: permission denied for table clients



RESET ROLE;
CREATE VIEW clients_public as SELECT client_id, client_name, city FROM clients;
CREATE VIEW clients_public_inv with (security_invoker = true) as SELECT client_id, client_name, city FROM clients;
GRANT SELECT ON clients_public, clients_public_inv to desk_clerk_nm;



CREATE ROLE viewer_nm;
GRANT SELECT ON clients_public, clients_public_inv TO viewer_nm;
SET ROLE viewer_nm;
SELECT * FROM clients_public; -- works
SELECT * FROM clients_public_inv; -- ERROR
