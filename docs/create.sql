DROP TABLE IF EXISTS Test;

CREATE TABLE Test(
    id          INTEGER,
    name        VARCHAR(255) NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT primaryKey PRIMARY KEY (id)
);