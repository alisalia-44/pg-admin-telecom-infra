\c telecom_infra

CREATE INDEX idx_abonnes_actifs_numero ON production.abonnes (numero_ligne) WHERE statut_ligne = 'ACTIF';
CREATE INDEX idx_audit_jsonb_nouvelles_valeurs ON audit.journal_modifications USING GIN (nouvelles_valeurs);

CREATE OR REPLACE VIEW supervision.etat_fragmentation_tables AS
SELECT 
    schemaname AS nom_schema,
    relname AS nom_table,
    n_live_tup AS lignes_actives,
    n_dead_tup AS lignes_mortes,
    CASE WHEN n_live_tup > 0 THEN ROUND((n_dead_tup::NUMERIC / n_live_tup::NUMERIC) * 100, 2) ELSE 0 END AS ratio_fragmentation_pourcent
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

CREATE OR REPLACE VIEW supervision.index_inutilises AS
SELECT 
    schemaname AS nom_schema,
    relname AS nom_table,
    indexrelname AS nom_index,
    pg_size_pretty(pg_relation_size(indexrelid)) AS taille_index,
    idx_scan AS nombre_utilisations
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND indexrelname NOT LIKE '%pkey%';

CREATE OR REPLACE VIEW supervision.verrous_actifs AS
SELECT 
    pid AS identifiant_processus,
    usename AS utilisateur,
    client_addr AS adresse_ip,
    state AS etat_session,
    wait_event_type AS type_attente,
    query AS requete_en_cours
FROM pg_stat_activity
WHERE state != 'idle' AND pid != pg_backend_pid();
