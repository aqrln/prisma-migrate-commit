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

## Why

To avoid losing the data when creating a new migration with `prisma migrate
dev` once you are happy with the changes in the schema which often requires
multiple iterations of `prisma db push`.

## Couldn't `prisma migrate dev` just not reset the database if database schema and Prisma schema are in sync?

It probably could, yeah.

One way to look at it is that if the database schema is in sync with the Prisma
schema, then it is also in some sense in sync with the migration history — just
not with the current state of it but with the future state that is exactly
being created right now.

But it would also make the mental model more complicated:

- It would have somewhat different behavior depending on whether the schema is
  in sync or not.
- You'd still get the schema drift warning and the reset prompt if you applied
  some changes with `db push`, then edited the schema file once more and ran
  `migrate dev` to migrate to the final state of the schema file, which may be
  confusing and/or annoying.

To me it feels like these two are separate commands after all but improving
`migrate dev` ergonomics is also a valid approach.
