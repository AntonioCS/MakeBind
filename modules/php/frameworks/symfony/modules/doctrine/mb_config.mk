## Doctrine connection name used by Symfony console (-c/--connection)
php_sy_conn ?= default

## Extra flags for doctrine:migrations:migrate
php_sy_doctrine_migrate_flags ?= --no-interaction

## Extra flags for doctrine:schema:update (add --dump-sql to preview)
php_sy_schema_update_flags ?= --complete

## Extra flags for doctrine:fixtures:load (e.g., --append)
php_sy_fixtures_flags ?=#

## Derived: expands to "-c <conn>" when php_sy_conn is set (used by Symfony console)
php_sy_conn_flag := $(if $(value php_sy_conn),-c $(php_sy_conn))
