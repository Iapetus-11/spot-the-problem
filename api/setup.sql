CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    username    TEXT NOT NULl,
    login_hash  BYTEA NOT NULL
);

CREATE TABLE answers (
    id          SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(id) NOT NULL,
    problem_set TEXT NOT NULL,
    problem_id  TEXT NOT NULL,
    answer_line INT NOT NULL,
    answer      TEXT NOT NULL
);