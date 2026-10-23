#!/bin/bash
set -euo pipefail

BASE_DE_DONNEES="${1:-telecom_infra}"
UTILISATEUR_PG="postgres"
DOSSIER_SAUVEGARDE="/var/backups/postgresql/${BASE_DE_DONNEES}"
LIMITE_CONSERVATION=7

mkdir -p "${DOSSIER_SAUVEGARDE}"

ID_TRANSACTION=$(psql -U "${UTILISATEUR_PG}" -d "${BASE_DE_DONNEES}" -t -A -c "SELECT txid_current();")
FICHIER_ARCHIVE="${DOSSIER_SAUVEGARDE}/sauvegarde_${BASE_DE_DONNEES}_tx${ID_TRANSACTION}.dump"

pg_dump -U "${UTILISATEUR_PG}" -Fc -Z 9 -f "${FICHIER_ARCHIVE}" "${BASE_DE_DONNEES}"
pg_restore -l "${FICHIER_ARCHIVE}" > /dev/null
psql -U "${UTILISATEUR_PG}" -d "${BASE_DE_DONNEES}" -c "VACUUM (VERBOSE, ANALYZE);"
ls -1t "${DOSSIER_SAUVEGARDE}"/sauvegarde_"${BASE_DE_DONNEES}"_*.dump 2>/dev/null \vert{} tail -n +$((LIMITE_CONSERVATION + 1)) | xargs -r rm -f
