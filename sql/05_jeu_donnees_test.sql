\c telecom_infra

ALTER TABLE production.abonnes DISABLE TRIGGER declencheur_audit_abonnes;

INSERT INTO production.abonnes (numero_ligne, nom_complet, code_zone, statut_ligne, consommation_mo, forfait_mensuel, gestionnaire_compte)
SELECT
    '06' || LPAD(serie::TEXT, 8, '0'),
    'Abonne_Telecom_' || serie,
    (ARRAY['NORD', 'SUD', 'EST', 'OUEST'])[1 + (serie % 4)],
    CASE WHEN (serie % 20) < 16 THEN 'ACTIF' WHEN (serie % 20) < 19 THEN 'SUSPENDU' ELSE 'RESILIE' END,
    ROUND((RANDOM() * 50000)::NUMERIC, 2),
    (ARRAY[1500.00, 2500.00, 4000.00, 6000.00])[1 + (serie % 4)],
    'app_backend'
FROM generate_series(1, 500000) AS serie;

ALTER TABLE production.abonnes ENABLE TRIGGER declencheur_audit_abonnes;
ANALYZE production.abonnes;

UPDATE production.abonnes SET consommation_mo = consommation_mo + 500.00 WHERE code_zone = 'NORD' AND id_abonne <= 8000;
DELETE FROM production.abonnes WHERE code_zone = 'SUD' AND statut_ligne = 'RESILIE' AND id_abonne <= 40000;
