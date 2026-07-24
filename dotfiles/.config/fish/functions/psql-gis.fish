function psql-gis --description "Open psql inside the PostGIS Docker container"
    argparse \
        'c/container=' \
        'd/database=' \
        'U/user=' \
        'h/help' \
        -- $argv

    if set -q _flag_help
        echo "Usage:"
        echo "  psql-gis [-c container] [-d database] [-U user] [psql args]"
        echo
        echo "Examples:"
        echo "  psql-gis"
        echo "  psql-gis -c postgis-container"
        echo "  psql-gis -d postgis -U postgres"
        echo "  psql-gis -c my-postgis -d gisdb -U postgres -c 'SELECT version();'"
        return 0
    end

    set -l container $PG_CONTAINER
    set -l database $PGDATABASE
    set -l user $PGUSER

    set -q _flag_container; and set container $_flag_container
    set -q _flag_database; and set database $_flag_database
    set -q _flag_user; and set user $_flag_user

    docker exec -it $container psql -U $user -d $database $argv
end
