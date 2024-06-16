#!/bin/sh

set -eu

print_help () {
    >&2 echo "Commit all changes interactively created with \`prisma db push\` to a new"
    >&2 echo "applied migration without schema drift errors and without losing any data."
    >&2 echo
    >&2 echo "Usage: $0 migration_name [--schema=/path/to/schema.prisma] [--migrations=/path/to/migrations_directory] [--help]"
    >&2 echo
    >&2 echo "  migration_name                The name of the migration to create"
    >&2 echo "  --schema=<schema_path>        The path to the schema.prisma file"
    >&2 echo "  --migrations=<migrations_dir> The path to the migrations directory"
    >&2 echo "  --help                        Print this help message"
}

if [ $# -lt 1 ]; then
    print_help
    exit 1
fi

migration_name="$(date -u +"%Y%m%d%H%M%S")_$1"
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --schema=*)
            schema_file="${1#*=}"
            shift
            ;;
        --migrations=*)
            migrations_directory="${1#*=}"
            shift
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            >&2 echo "Error: unexpected argument \`$1\`"
            exit 1
            ;;
    esac
done

schema_file="${schema_file:-$(pwd)/prisma/schema.prisma}"
migrations_directory="${migrations_directory:-$(pwd)/prisma/migrations}"

npx prisma migrate diff \
    --from-schema-datasource="$schema_file" \
    --to-schema-datamodel="$schema_file" \
    --exit-code > /dev/null || {
        if [ $? -eq 2 ]; then
            >&2 echo "Error: the database and the schema are not in sync. Please run \`prisma db push\` first."
        fi
        exit 1
    }

echo "Creating migration \`$migration_name\`"

migrate_diff () {
    set +e
    npx prisma migrate diff \
        --from-migrations="$migrations_directory" \
        --to-schema-datasource="$schema_file" \
        --exit-code \
        "$@"
    error_code=$?
    set -e

    case $error_code in
        0)
            >&2 echo "Error: no changes in the database since the last migration."
            return 1
            ;;
        2)
            # Non-empty diff, continuing
            return 0
            ;;
        *)
            return $?
            ;;
    esac
}

# Print the human-readable summary to the screen
migrate_diff

mkdir -p "$migrations_directory/$migration_name"

# Write the actual SQL migration to the disk
migrate_diff --script > "$migrations_directory/$migration_name/migration.sql"

npx prisma migrate resolve --applied "$migration_name" --schema="$schema_file"
