# Architecture du Tableau de Bord de Supervision Power BI

## Connexion Sécurisée
* **Serveur** : `localhost:5432` | **Base** : `telecom_infra`
* **Utilisateur** : `auditeur_secu` (accès restreint aux schémas `audit` et `supervision`).

## Mesures DAX Principales
~~~dax
Total Lignes Mortes = SUM('supervision etat_fragmentation_tables'[lignes_mortes])

Taux Fragmentation Global (%) = 
DIVIDE(
    SUM('supervision etat_fragmentation_tables'[lignes_mortes]),
    SUM('supervision etat_fragmentation_tables'[lignes_actives]) + SUM('supervision etat_fragmentation_tables'[lignes_mortes]),
    0
) * 100
~~~
