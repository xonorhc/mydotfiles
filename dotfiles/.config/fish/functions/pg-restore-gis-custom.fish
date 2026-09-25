function pg-restore-gis-custom --description "Restore custom-format dump into PostGIS podman container"
    argparse \
        'c/container=' \
        'd/database=' \
        'U/user=' \
        'h/help' \
        -- $argv

    if set -q _flag_help; or test (count $argv) -lt 1
        echo "Usage:"
        echo "  pg-restore-gis-custom [-c container] [-d database] [-U user] file.dump [pg_restore args]"
        echo
        echo "Examples:"
        echo "  pg-restore-gis-custom backup.dump"
        echo "  pg-restore-gis-custom -c postgis-container -d postgis -U postgres backup.dump"
        echo "  pg-restore-gis-custom backup.dump -- --clean --if-exists"
        return 0
    end

    set -l container $PG_CONTAINER
    set -l database $PGDATABASE
    set -l user $PGUSER
    set -l file $argv[1]

    set -e argv[1]

    set -q _flag_container; and set container $_flag_container
    set -q _flag_database; and set database $_flag_database
    set -q _flag_user; and set user $_flag_user

    cat $file | podman exec -i $container pg_restore -U $user -d $database $argv
end
