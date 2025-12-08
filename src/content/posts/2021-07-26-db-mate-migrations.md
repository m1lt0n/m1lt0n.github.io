---
title: 'Database migrations with Dbmate'
published: 2021-07-26 08:00:00 +0300
tags: ['migrations', 'database', 'sql']
---

There are some tools that are quite essentials for web applications. When working on the back end side of your application, you'll most probably need to use a database.

This means that you will somehow need to create a database and some tables (assuming an SQL database) and, over time, the needs of your application will change, so the schema of your database will have to change.

Several web frameworks (e.g. Ruby on Rails, Django, etc) include a built-in ORM for working with the database (if you are not familiar with ORMs, here is a <a href="https://www.fullstackpython.com/object-relational-mappers-orms.html" target="_blank" rel="noopener nofollow">nice article</a> about them).

Some frameworks also include tools for performing database migrations, which make it easier to keep track of the state of your database. So, instead of updating the schema of your database on your servers by hand or with custom scripts, database migration tools allow you to version your database schema and move from one version to another (if need be).

A downside of these tools is sometimes that they might have a small learning curve or require the use of a DSL (domain-specific language) instead of plain SQL to write the migrations. In companies where there are several services written in (perhaps) different languages, this means using a different tool for performing database migrations depending on the language (or framework) the service is written in.

Recently, I found <a href="https://github.com/amacneil/dbmate" target="_blank" rel="noopener nofollow">Dbmate</a>, a database migration tool that is based on some decisions that resolve the issues mentioned above:

- It is a standalone tool that can be installed independently from the framework you use
- It is language agnostic
- You can use plain SQL instead of a domain specific language to create database migrations

Dbmate is a single binary file, so after downloading it, you're ready to use it:

```bash
# instructions for linux
sudo curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64
sudo chmod +x /usr/local/bin/dbmate
```

There is also a docker image available, if you prefer running the tool via docker and not install it in your system.

Running `dbmate` or `dbmate --help`, you get information about the available commands. Let's go through an example to see how some of the commands work. We'll assume that we want to create a new database for a Todos app project, so we need to create a todos table:

```bash
# create the database
# We use -u or --url to provide the database URL.
# Another option is to use -e and have it available in an environment variable DATABASE_URL
dbmate -u "sqlite:todos.db" create

# create the migration
dbmate -u "sqlite:todos.db" new create_todos_table
```

The last command creates a file in a folder `db/migrations` in the format of `{timestamp}_{migration name}.sql`. This is a plain sql file with 2 comment lines that indicate the start of the migration and of the SQL to rollback that migration. Let's create our table:

```sql
-- migrate:up
CREATE TABLE IF NOT EXISTS todos (title VARCHAR(50), content TEXT);

-- migrate:down
DROP TABLE IF EXISTS todos;
```

Now, to run the migration, we simply run `dbmate -u "sqlite:todos.db" up`. If you examine the created table in sqlite (for this specific example we're using sqlite), you'll see that there are 2 tables in the database: the todos table that we have created and a `schema_migrations` table that keeps track of the migrations that have ran.

To undo the migration, we run `dbmate -u "sqlite:todos.db" down`. Checking sqlite again, we'll see that the table does not exist and the schema_migrations table does not have any records (since no migrations have ran).

Another useful command is the `dump` command, which creates an sql file with all the schema changes in the database. For example, if I rerun the migration that creates the todos table and run `dbmate -u "sqlite:todos.db" dump`, I get a schema.sql file in the db folder with these contents:

```sql
CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(255) primary key);
CREATE TABLE todos (title VARCHAR(50), content TEXT);
-- Dbmate schema migrations
INSERT INTO "schema_migrations" (version) VALUES
  ('20210728054415');
```

These are the main commands you'll probably need with dbmate (there are a few more like `wait` or `status`, but I won't go through them here). As you can see, the tool is pretty simple to use and it is not coupled to your framework/language. This way, it can be reused in many projects by engineers with different backgrounds and it only requires knowledge of plain SQL.

That's all for now folks!
