# Administration, Sécurité et Optimisation d'une Base de Données PostgreSQL

## Présentation du Projet
Ce projet met en œuvre une architecture complète d'administration de base de données sous **PostgreSQL** pour la gestion des infrastructures et des abonnés d'un opérateur de télécommunications (500 000 lignes).

## Objectifs Techniques
1. **Isolation et Sécurité** : Séparation stricte des schémas (`production`, `audit`, `supervision`), gestion granulaire des rôles et sécurité au niveau des lignes.
2. **Haute Volumétrie (Partitionnement)** : Découpage physique des tables critiques par région (`NORD`, `SUD`, `EST`, `OUEST`).
3. **Traçabilité Totale (Audit PL/pgSQL & JSONB)** : Enregistrement automatique et immuable des opérations `INSERT`, `UPDATE` et `DELETE`.
4. **Supervision et Optimisation** : Index partiels, index GIN et vues d'administration surveillant la fragmentation (`VACUUM`) et les verrous actifs.
5. **Automatisation (Bash & Docker)** : Déploiement conteneurisé et script de sauvegarde compressée avec rotation automatique.

## Déploiement Rapide (Docker)
~~~bash
docker compose up -d
~~~

## Preuve de Performance (500 000 lignes)
Recherche d'un abonné actif dans la région `NORD` :
~~~sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_abonne, nom_complet, consommation_mo
FROM production.abonnes
WHERE code_zone = 'NORD' AND statut_ligne = 'ACTIF' AND numero_ligne = '0600124001';
~~~

| Métrique | Sans Partitionnement ni Index | Avec Partitionnement + Index Partiel | Gain |
| :--- | :--- | :--- | :--- |
| **Opération** | Parcours séquentiel complet | Lecture d'index sur `abonnes_zone_nord` | Ciblage chirurgical |
| **Blocs mémoire lus** | ~ 6 450 blocs (~ 51,6 Mo) | **4 blocs (32 Ko)** | **- 99,93 % d'entrées/sorties** |
| **Temps d'exécution** | ~ 48,50 ms | **0,068 ms** | **~ 713x plus rapide** |
