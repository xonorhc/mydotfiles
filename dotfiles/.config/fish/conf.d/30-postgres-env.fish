# -----------------------------------------------------
# Database Context - PostgreSQL / PostGIS
# -----------------------------------------------------
set -gx PGHOST localhost
set -gx PGPORT 5432
set -gx PGDATABASE postgis
set -gx PGUSER postgres
set -gx PGPASSFILE $HOME/.pgpass
set -gx PSQL_PAGER pspg

# Default Docker container for PostGIS
set -gx PG_CONTAINER postgis-db
