function pg-dump-gis-custom --description "Create custom-format dump from PostGIS Docker container"
    argparse \
        'c/container=' \
        'd/database=' \
        'U/user=' \
        'f/file=' \
        'h/help' \
        -- $argv

    if set -q _flag_help
        echo "Usage:"
        echo "  pg-dump-gis-custom [-c container] [-d database] [-U user] [-f file] [pg_dump args]"
        echo
        echo "Examples:"
        echo "  pg-dump-gis-custom"
        echo "  pg-dump-gis-custom -f backup.dump"
        echo "  pg-dump-gis-custom -c postgis-container -d postgis -U postgres -f postgis.dump"
        echo "  pg-dump-gis-custom -- --schema public"
        return 0
    end

    set -l container $PG_CONTAINER
    set -l database $PGDATABASE
    set -l user $PGUSER
    set -l file "$database-"(date +%Y%m%d-%H%M%S)".dump"

    set -q _flag_container; and set container $_flag_container
    set -q _flag_database; and set database $_flag_database
    set -q _flag_user; and set user $_flag_user
    set -q _flag_file; and set file $_flag_file

    docker exec -i $container pg_dump -U $user -d $database -F c $argv > $file

    echo "Custom dump saved to: $file"
end
