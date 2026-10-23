\c telecom_infra

CREATE TABLE production.abonnes (
    id_abonne BIGSERIAL,
    numero_ligne VARCHAR(20) NOT NULL,
    nom_complet VARCHAR(150) NOT NULL,
    code_zone VARCHAR(10) NOT NULL,
    statut_ligne VARCHAR(20) NOT NULL CHECK (statut_ligne IN ('ACTIF', 'SUSPENDU', 'RESILIE')),
    consommation_mo NUMERIC(12, 2) DEFAULT 0.00,
    forfait_mensuel NUMERIC(10, 2) NOT NULL,
    gestionnaire_compte VARCHAR(50) DEFAULT CURRENT_USER,
    PRIMARY KEY (id_abonne, code_zone)
) PARTITION BY LIST (code_zone);

CREATE TABLE production.abonnes_zone_nord PARTITION OF production.abonnes FOR VALUES IN ('NORD');
CREATE TABLE production.abonnes_zone_sud PARTITION OF production.abonnes FOR VALUES IN ('SUD');
CREATE TABLE production.abonnes_zone_est PARTITION OF production.abonnes FOR VALUES IN ('EST');
CREATE TABLE production.abonnes_zone_ouest PARTITION OF production.abonnes FOR VALUES IN ('OUEST');
CREATE TABLE production.abonnes_zone_defaut PARTITION OF production.abonnes DEFAULT;

ALTER TABLE production.abonnes ENABLE ROW LEVEL SECURITY;

CREATE POLICY politique_acces_gestionnaire ON production.abonnes
    FOR ALL TO role_application
    USING (gestionnaire_compte = CURRENT_USER);
