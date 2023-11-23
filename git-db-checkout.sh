#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <target-branch>"
  exit 1
fi

target_branch=$1
migration_dir="api/db/migrations"

# Function to handle if migration is not in the any branch but is in the db
# function handle_migration_not_in_branch {
#   echo "Migration $1 is not in any branch but is in the db"
#   # remove migration from knex_migrations table
#   npm run knex raw "delete from knex_migrations where name = '$1'" --env $target_branch
# }



# Check if the target branch exists
if ! git show-ref --verify --quiet refs/heads/$target_branch; then
  echo "Branch $target_branch does not exist"
  exit 1
fi

# Check if the target branch is checked out
if git symbolic-ref --short HEAD | grep -q "^$target_branch$"; then
  echo "Branch $target_branch is already checked out"
  exit 1
fi

# Get list of migration files in the current branch
current_migrations=$(git ls-tree --name-only HEAD $migration_dir/*.js)

# Get list of migration files in the target branch
target_migrations=$(git ls-tree --name-only $target_branch $migration_dir/*.js)

# Find differences between both branches
added_migrations=$(comm -23 <(echo "$current_migrations" | sort) <(echo "$target_migrations" | sort))
deleted_migrations=$(comm -13 <(echo "$current_migrations" | sort) <(echo "$target_migrations" | sort))

# db_migrations=$(npm run knex migrate:list --env $target_branch 2>&1)



# echo "db_migrations: $db_migrations"




echo "added_migrations number: $(echo "$added_migrations" | wc -l)"
echo "deleted_migrations number: $(echo "$deleted_migrations" | wc -l)"

if [ -n "$added_migrations" ] || [ -n "$deleted_migrations" ]; then
  echo "Branch $target_branch has different migrations"
  echo "Added migrations: $added_migrations"
  echo "Deleted migrations: $deleted_migrations"
fi

#rollback added migrations using knex migrate:rollback
for migration in $added_migrations; do
  echo "Rolling back migration $migration"
  npm run knex migrate:down $migration --env $target_branch
done

for migration in $deleted_migrations; do
  echo "Rolling back migration $migration"
  npm run knex migrate:up $migration --env $target_branch
done

#checkout target branch
git checkout $target_branch

npm run knex migrate:latest --env $target_branch
done





