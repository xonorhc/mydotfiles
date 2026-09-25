function backup-gis --description 'Backup PostGIS database from podman container'
    argparse \
        'c/container=' \
        'd/database=' \
        'U/user=' \
        'f/file=' \
        'n/schema=' \
        't/table=' \
        'Z/compress=' \
        'h/help' \
        -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage:"
        echo "  backup-gis [options] [-- extra pg_dump args]"
        echo
        echo "Options:"
        echo "  -c, --container   podman container name"
        echo "  -d, --database    PostgreSQL database name"
        echo "  -U, --user        PostgreSQL user"
        echo "  -f, --file        Output backup file"
        echo "  -n, --schema      Backup only one schema"
        echo "  -t, --table       Backup only one table"
        echo "  -Z, --compress    Compression level 0-9"
        echo "  -h, --help        Show help"
        echo
        echo "Examples:"
        echo "  backup-gis"
        echo "  backup-gis -c postgis-container -d postgis -U postgres"
        echo "  backup-gis -f postgis.backup"
        echo "  backup-gis -n public"
        echo "  backup-gis -t public.roads"
        echo "  backup-gis -Z 9"
        echo "  backup-gis -- --verbose"
        return 0
    end

    # Defaults
    set -l container postgis-db
    set -l database postgis
    set -l user postgres
    set -l compress 6

    # Use environment variables if available
    set -q PG_CONTAINER; and set container $PG_CONTAINER
    set -q PGDATABASE; and set database $PGDATABASE
    set -q PGUSER; and set user $PGUSER

    # Override with function parameters
    set -q _flag_container; and set container $_flag_container
    set -q _flag_database; and set database $_flag_database
    set -q _flag_user; and set user $_flag_user
    set -q _flag_compress; and set compress $_flag_compress

    # Default output file
    set -l timestamp (date +%Y-%m-%d_%H-%M-%S)
    set -l file "$database"_"$timestamp".backup

    set -q _flag_file; and set file $_flag_file

    # Build pg_dump arguments
    set -l dump_args \
        -U $user \
        -d $database \
        -F c \
        -Z $compress

    if set -q _flag_schema
        set -a dump_args -n $_flag_schema
    end

    if set -q _flag_table
        set -a dump_args -t $_flag_table
    end

    echo ">> Starting backup..."
    echo ">> Container: $container"
    echo ">> Database:  $database"
    echo ">> User:      $user"
    echo ">> File:      $file"

    if podman exec -i $container pg_dump $dump_args $argv > "$file"
        echo ">> Backup finished: $file"
    else
        echo ">> Backup failed"
        test -f "$file"; and rm "$file"
        return 1
    end
end
