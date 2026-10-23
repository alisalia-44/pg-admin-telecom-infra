\c telecom_infra

CREATE TABLE audit.journal_modifications (
    id_evenement BIGSERIAL PRIMARY KEY,
    id_transaction BIGINT DEFAULT txid_current(),
    schema_cible TEXT NOT NULL,
    table_cible TEXT NOT NULL,
    type_operation TEXT NOT NULL,
    utilisateur_sql TEXT DEFAULT SESSION_USER,
    adresse_client INET DEFAULT inet_client_addr(),
    anciennes_valeurs JSONB,
    nouvelles_valeurs JSONB
);

REVOKE UPDATE, DELETE, TRUNCATE ON audit.journal_modifications FROM PUBLIC, role_application, role_analyste, role_auditeur;

CREATE OR REPLACE FUNCTION audit.tracer_modifications()
RETURNS TRIGGER AS $$ BEGIN IF (TG_OP = 'DELETE') THEN INSERT INTO audit.journal_modifications (schema_cible, table_cible, type_operation, anciennes_valeurs, nouvelles_valeurs) VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, to_jsonb(OLD), NULL); RETURN OLD; ELSIF (TG_OP = 'UPDATE') THEN INSERT INTO audit.journal_modifications (schema_cible, table_cible, type_operation, anciennes_valeurs, nouvelles_valeurs) VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW)); RETURN NEW; ELSIF (TG_OP = 'INSERT') THEN INSERT INTO audit.journal_modifications (schema_cible, table_cible, type_operation, anciennes_valeurs, nouvelles_valeurs) VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, NULL, to_jsonb(NEW)); RETURN NEW; END IF; RETURN NULL; END; $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER declencheur_audit_abonnes
AFTER INSERT OR UPDATE OR DELETE ON production.abonnes
FOR EACH ROW EXECUTE FUNCTION audit.tracer_modifications();
