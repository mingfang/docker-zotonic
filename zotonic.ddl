CREATE USER zotonic WITH PASSWORD 'zotonic';
CREATE DATABASE zotonic WITH OWNER zotonic ENCODING 'UTF8' TEMPLATE template0;
GRANT ALL ON DATABASE zotonic TO zotonic;
