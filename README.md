# prisma-migrate-commit

The missing `prisma migrate commit` command! Change your schema interactively,
iterate with `prisma db push` and then write all the differences in the
database since the last migration to a new migration file and mark it as
applied in the migrations table.

```
./migrate-commit.sh migration_name [--schema=/path/to/schema.prisma] [--migrations=/path/to/migrations_directory] [--help]

  migration_name                The name of the migration to create
  --schema=<schema_path>        The path to the schema.prisma file
  --migrations=<migrations_dir> The path to the migrations directory
  --help
```

Not an official Prisma project, no guarantees, use at your own risk.
