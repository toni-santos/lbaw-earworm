-- Drop schema if existant
DROP SCHEMA lbaw22123 CASCADE;


-- Create group schema and set it as search path
CREATE SCHEMA lbaw22123;
SET search_path TO lbaw22123;

-- Enumerations
CREATE TYPE PRODUCT_FORMAT AS ENUM('Vinyl', 'CD', 'Cassette', 'DVD', 'Box Set');
CREATE TYPE ORDER_STATE AS ENUM('Processing', 'Shipped', 'Delivered');
CREATE TYPE NOTIF_TYPE AS ENUM('Order', 'Wishlist', 'Misc');

-- Drop existent tables
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Artist;
DROP TABLE IF EXISTS FavArtist;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS ProductGenre;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderProduct;
DROP TABLE IF EXISTS CartProduct;
DROP TABLE IF EXISTS WishlistProduct;
DROP TABLE IF EXISTS Notif;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Report;


-- Table creation

CREATE TABLE Users(
    id          SERIAL PRIMARY KEY,
    cart_id     SERIAL UNIQUE,
    wishlist_id SERIAL UNIQUE,
    email       VARCHAR(255) UNIQUE NOT NULL,
    username    VARCHAR(30) NOT NULL,
    password    VARCHAR(30) NOT NULL,
    is_blocked  BOOLEAN NOT NULL,
    is_admin    BOOLEAN NOT NULL
);

CREATE TABLE Artist(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,
    description TEXT DEFAULT NULL
);

CREATE TABLE FavArtist(
    user_id     INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    artist_id   INTEGER REFERENCES Artist(id) ON UPDATE CASCADE,
    CONSTRAINT favArtistPK PRIMARY KEY (user_id, artist_id)
);

CREATE TABLE Genre(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR (100) UNIQUE NOT NULL
);

CREATE TABLE Product(
    id          SERIAL PRIMARY KEY,
    artist_id   INTEGER REFERENCES Artist(id) ON UPDATE CASCADE,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    stock       INTEGER NOT NULL DEFAULT 1,
    price       BIGINT NOT NULL,
    format      PRODUCT_FORMAT NOT NULL,
    year        INTEGER,
    rating      FLOAT DEFAULT NULL,
    CHECK (stock >= 0)
);

CREATE TABLE ProductGenre(
    product_id  INTEGER REFERENCES Product(id) ON UPDATE CASCADE,
    genre_id    INTEGER REFERENCES Genre(id) ON UPDATE CASCADE,
    CONSTRAINT productGenrePK PRIMARY KEY (product_id, genre_id)
);

CREATE TABLE Review(
    reviewer_id INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES Product(id) ON UPDATE CASCADE,
    score       INTEGER NOT NULL,
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    message     TEXT DEFAULT NULL,
    CHECK (score BETWEEN 0 AND 5),
    CONSTRAINT reviewPK PRIMARY KEY (reviewer_id, product_id)
);

CREATE TABLE Orders(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    state       ORDER_STATE NOT NULL
);

CREATE TABLE OrderProduct(
    order_id    INTEGER REFERENCES Orders(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES Product(id) ON UPDATE CASCADE,
    quantity    INTEGER NOT NULL,
    CONSTRAINT orderProductPK PRIMARY KEY (order_id, product_id)
);

CREATE TABLE CartProduct(
    cart_id     INTEGER REFERENCES Users(cart_id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES Product(id) ON UPDATE CASCADE,
    quantity    INTEGER NOT NULL,
    CONSTRAINT cartProductPK PRIMARY KEY (cart_id, product_id)
);

CREATE TABLE WishlistProduct(
    wishlist_id INTEGER REFERENCES Users(wishlist_id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES Product(id) ON UPDATE CASCADE,
    CONSTRAINT wishlistProductPK PRIMARY KEY (wishlist_id, product_id)
);

CREATE TABLE Notif(
    id          SERIAL PRIMARY KEY,
	user_id		INTEGER REFERENCES Users(id),
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT DEFAULT NULL,
    type        NOTIF_TYPE NOT NULL
);

CREATE TABLE Ticket(
    id          SERIAL PRIMARY KEY,
    ticketer_id INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    message     VARCHAR(255) NOT NULL
);

CREATE TABLE Report(
    id          SERIAL PRIMARY KEY,
    reporter_id INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    reported_id INTEGER REFERENCES Users(id) ON UPDATE CASCADE,
    message     VARCHAR(255) NOT NULL
);

-- Performance Indexes

CREATE INDEX product_artist ON Product USING hash (artist_id);

CREATE INDEX product_price ON Product USING btree (price);
CLUSTER Product USING product_price;

CREATE INDEX product_genre ON ProductGenre USING hash (genre_id);

-- Full text search

ALTER TABLE Product
ADD COLUMN tsvectors TSVECTOR;

CREATE FUNCTION product_search_update() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C')
        );
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.name <> OLD.name) THEN
            NEW.tsvectors = (
                setweight(to_tsvector('english', NEW.name), 'A') ||
                setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C')
            );
        END IF;
    END IF;
    RETURN NEW;

END $$
LANGUAGE plpgsql;

CREATE TRIGGER product_search_update
    BEFORE INSERT OR UPDATE ON Product
    FOR EACH ROW
    EXECUTE PROCEDURE product_search_update();

CREATE INDEX product_fts ON Product USING GIN(tsvectors);

-- Triggers
-- Trigger 01 - Removing Artist while removing all its associations

CREATE FUNCTION delete_artist() RETURNS TRIGGER AS 
$BODY$
BEGIN

    DELETE FROM Product
    WHERE artist_id = OLD.id;

    DELETE FROM FavArtist
    WHERE artist_id = OLD.id;

    RETURN NEW;
    
END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER delete_artist
    BEFORE DELETE ON Artist
    FOR EACH ROW
    EXECUTE PROCEDURE delete_artist();

-- Trigger 02 - Update a product's rating after a new review

CREATE FUNCTION review_product()
RETURNS TRIGGER AS 
$BODY$
BEGIN

    IF TG_OP = 'INSERT' THEN
        UPDATE Product
        SET rating = ((SELECT SUM(score) FROM Review WHERE NEW.product_id = product_id))::float / (SELECT COUNT(*) FROM Review WHERE NEW.product_id = product_id)
        WHERE id = NEW.product_id;
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.score <> OLD.score) THEN
            UPDATE Product
            SET rating = ((SELECT SUM(score) FROM Review WHERE NEW.product_id = product_id))::float / (SELECT COUNT(*) FROM Review WHERE NEW.product_id = product_id)
            WHERE id = NEW.product_id;
        END IF;
    END IF;
    IF TG_OP = 'DELETE' THEN
        IF ((SELECT COUNT(*) FROM Review WHERE OLD.product_id = product_id) = 0) THEN
            UPDATE Product
            SET rating = NULL
            WHERE id = OLD.product_id;
        ELSE
            UPDATE Product
            SET rating = ((SELECT SUM(score) FROM Review WHERE OLD.product_id = product_id))::float / (SELECT COUNT(*) FROM Review WHERE OLD.product_id = product_id)
            WHERE id = OLD.product_id;
        END IF;
    END IF;
    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER review_product
    AFTER INSERT OR UPDATE ON Review
    FOR EACH ROW
    EXECUTE PROCEDURE review_product();

-- Trigger 03 - Update a product's stock on purchase

CREATE FUNCTION update_stock()
RETURNS TRIGGER AS 
$BODY$
BEGIN 

    UPDATE Product
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER update_stock
    AFTER INSERT ON OrderProduct
    FOR EACH ROW
    EXECUTE PROCEDURE update_stock();

-- Trigger 04 - Remove a Product and all its associations

CREATE FUNCTION delete_product() RETURNS TRIGGER AS 
$BODY$
BEGIN

    DELETE FROM ProductGenre
    WHERE product_id = OLD.id;

    DELETE FROM Review
    WHERE product_id = OLD.id;

    DELETE FROM OrderProduct
    WHERE product_id = OLD.id;

    DELETE FROM CartProduct
    WHERE product_id = OLD.id;

    DELETE FROM WishlistProduct
    WHERE product_id = OLD.id;

    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER delete_product
    BEFORE DELETE ON Product
    FOR EACH ROW
    EXECUTE PROCEDURE delete_product();
