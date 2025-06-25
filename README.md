# bd-final

## Trabalho de Bases de Dados - Grupo 12

Para rodar:
```
sudo -u postgres psql -c "DROP DATABASE IF EXISTS projeto_final WITH (FORCE);"
sudo -u postgres psql -c "CREATE USER grupo12 WITH PASSWORD 'grupo12';"
sudo -u postgres psql -c "CREATE DATABASE projeto_final OWNER grupo12;"
sudo -u postgres psql -d projeto_final -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public AUTHORIZATION grupo12;"
```