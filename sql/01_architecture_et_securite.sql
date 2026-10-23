CREATE DATABASE telecom_infra;
\c telecom_infra

REVOKE ALL ON SCHEMA public FROM PUBLIC;

CREATE SCHEMA production;
CREATE SCHEMA audit;
CREATE SCHEMA supervision;

CREATE ROLE role_administrateur NOLOGIN;
CREATE ROLE role_application NOLOGIN;
CREATE ROLE role_analyste NOLOGIN;
CREATE ROLE role_auditeur NOLOGIN;

GRANT ALL PRIVILEGES ON SCHEMA production, audit, supervision TO role_administrateur;

GRANT USAGE ON SCHEMA production TO role_application;
ALTER DEFAULT PRIVILEGES IN SCHEMA production GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_application;
ALTER DEFAULT PRIVILEGES IN SCHEMA production GRANT USAGE, SELECT ON SEQUENCES TO role_application;

GRANT USAGE ON SCHEMA production TO role_analyste;
ALTER DEFAULT PRIVILEGES IN SCHEMA production GRANT SELECT ON TABLES TO role_analyste;

GRANT USAGE ON SCHEMA audit, supervision TO role_auditeur;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO role_auditeur;
ALTER DEFAULT PRIVILEGES IN SCHEMA supervision GRANT SELECT ON TABLES TO role_auditeur;

CREATE USER app_backend WITH PASSWORD 'MotDePasseComplexe_App!' IN ROLE role_application;
CREATE USER analyste_bi WITH PASSWORD 'MotDePasseComplexe_BI!' IN ROLE role_analyste;
CREATE USER auditeur_secu WITH PASSWORD 'MotDePasseComplexe_Audit!' IN ROLE role_auditeur;
