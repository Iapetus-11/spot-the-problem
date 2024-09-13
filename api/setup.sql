CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    username    TEXT,
    login_hash  BYTEA
);