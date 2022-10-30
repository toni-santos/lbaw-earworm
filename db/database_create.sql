-- Drop schema if existant
DROP SCHEMA lbaw22123 CASCADE;


-- Create group schema and set it as search path
CREATE SCHEMA lbaw22123;
SET search_path TO lbaw22123;

-- Enumerations
CREATE TYPE PRODUCT_FORMAT AS ENUM('Vinyl', 'CD', 'Cassette', 'DVD', 'Box Set');
CREATE TYPE ORDER_STATE AS ENUM('Order Placed', 'Processing', 'Preparing to Ship', 'Shipped', 'Delivered', 'Ready for Pickup', 'Picked up');
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
    rating      INTEGER DEFAULT NULL,
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

-- Indexes

CREATE INDEX product_artist ON Product USING hash (artist_id);

-- Full text search
-- On Product

ALTER TABLE Product
ADD COLUMN tsvectors TSVECTOR;

CREATE FUNCTION product_search_update() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', NEW.description), 'C')
        );
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.name <> OLD.name) THEN
            NEW.tsvectors = (
                setweight(to_tsvector('english', NEW.name), 'A') ||
                setweight(to_tsvector('english', NEW.description), 'C')
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

-- Triggers
-- Trigger 01 - Removing Artist products on Artist deletion

CREATE FUNCTION delete_artist_products() RETURNS TRIGGER AS 
$BODY$
BEGIN

    DELETE FROM Product
    WHERE artist_id = OLD.id;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER delete_artist_products
    BEFORE DELETE ON Artist
    FOR EACH ROW
    EXECUTE PROCEDURE delete_artist_products();

-- Trigger 02 - Update a product's rating after a new review

CREATE FUNCTION review_product()
RETURNS TRIGGER AS 
$BODY$
BEGIN

    IF ((SELECT COUNT(*) FROM Product WHERE NEW.product_id = id) = 0) THEN 
        UPDATE Product
        SET rating = (SELECT SUM(rating) FROM Product WHERE NEW.product_id = id) + NEW.score;
    ELSE
        UPDATE Product
        SET rating = ((SELECT SUM(rating) FROM Product WHERE NEW.product_id = id) + NEW.score) / (SELECT COUNT(*) FROM Product WHERE NEW.product_id = id);
    END IF;

    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER review_product
    AFTER INSERT OR UPDATE ON Review
    FOR EACH ROW
    EXECUTE PROCEDURE review_product();

-- Trigger 03 - Notifications should not exceed 25

CREATE FUNCTION limit_notification()
RETURNS TRIGGER AS 
$BODY$
BEGIN 

    IF ((SELECT COUNT(*) FROM Notif WHERE NEW.user_id = user_id) > 25) THEN 
        DELETE FROM Notif
        WHERE notification_id = (SELECT MIN(id) FROM Notif WHERE user_id = NEW.user_id);
    END IF;

    RETURN NEW;
END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER limit_notification
    AFTER INSERT ON Notif
    FOR EACH ROW
    EXECUTE PROCEDURE limit_notification();

-- Trigger 04 - Update a product's stock on purchase

CREATE FUNCTION update_stock()
RETURNS TRIGGER AS 
$BODY$
BEGIN 

    UPDATE Product
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER update_stock
    AFTER INSERT ON OrderProduct
    FOR EACH ROW
    EXECUTE PROCEDURE update_stock();
