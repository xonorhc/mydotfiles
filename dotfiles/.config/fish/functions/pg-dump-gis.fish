# -----------------------------------------------------
# Functions - PostgreSQL / PostGIS in podman
# -----------------------------------------------------

function pg-dump-gis --description "Create plain SQL dump from PostGIS podman container"
    argparse \
        'c/container=' \
        'd/database=' \
        'U/user=' \
        'f/file=' \
        'h/help' \
        -- $argv

    if set -q _flag_help
        echo "Usage:"
        echo "  pg-dump-gis [-c container] [-d database] [-U user] [-f file] [pg_dump args]"
        echo
        echo "Examples:"
        echo "  pg-dump-gis"
        echo "  pg-dump-gis -f backup.sql"
        echo "  pg-dump-gis -c postgis-container -d postgis -U postgres -f postgis.sql"
        echo "  pg-dump-gis -- --schema public"
        return 0
    end

    set -l container $PG_CONTAINER
    set -l database $PGDATABASE
    set -l user $PGUSER
    set -l file "$database-"(date +%Y%m%d-%H%M%S)".sql"

    set -q _flag_container; and set container $_flag_container
    set -q _flag_database; and set database $_flag_database
    set -q _flag_user; and set user $_flag_user
    set -q _flag_file; and set file $_flag_file

    podman exec -i $container pg_dump -U $user -d $database $argv > $file

    echo "Dump saved to: $file"
end
