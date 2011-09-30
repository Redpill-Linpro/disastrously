-- \c template1;

-- Downgrade template1 from template database:
UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';

-- Drop it:
DROP DATABASE template1;

-- Recreate from template0 with correct encoding:
CREATE DATABASE template1 WITH template = template0 ENCODING = 'UTF8';

-- Upgrade template1 to template again:
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
