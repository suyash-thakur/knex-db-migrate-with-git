# knex-db-migrate-with-git
This is a bash script for managing database migrations when switching between different branches in a project that uses [Knex.js](http://knexjs.org/) for migrations.

## Usage

```bash
./git-db-checkout.sh <target-branch>
```

Replace `<target-branch>` with the name of the branch you want to check out.

## What it does

When you run the script, it does the following:

* Checks if the target branch exists and is not currently checked out.
* Gets the list of migration files in the current branch and the target branch.
* Finds the differences between the migrations in both branches.
* If a migration is present in the current branch but not in the target branch, it rolls back that migration.
* If a migration is present in the target branch but not in the current branch, it runs that migration.
* Checks out the target branch and runs any new migrations in that branch.

## Requirements

* You need to have Knex.js installed and set up in your project.
* Your migration files should be located in the `api/db/migrations` directory. Edit the migration folder according to your need.

## Note

This script assumes that you are using Git for version control and that your database supports transactions. If your database does not support transactions, rolling back a migration could leave your database in an inconsistent state.
