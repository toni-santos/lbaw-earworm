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
DROP TABLE IF EXISTS ArtistProduct;
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
    name        VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL
);

CREATE TABLE FavArtist(
    user_id     INTEGER REFERENCES Users(id),
    artist_id   INTEGER REFERENCES Artist(id),
    CONSTRAINT favArtistPK PRIMARY KEY (user_id, artist_id)
);

CREATE TABLE Product(
    id          SERIAL PRIMARY KEY,
    artist_id   INTEGER REFERENCES Artist(id),
    name        VARCHAR(255) NOT NULL,
    price       BIGINT NOT NULL,
    genre       VARCHAR(100) NOT NULL DEFAULT 'Unknown',
    format      PRODUCT_FORMAT NOT NULL,
    year        INTEGER,
    rating      INTEGER DEFAULT NULL
);

CREATE TABLE Review(
    reviewer_id INTEGER REFERENCES Users(id),
    product_id  INTEGER REFERENCES Product(id),
    score       INTEGER NOT NULL,
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT DEFAULT NULL,
    CHECK (score BETWEEN 0 AND 5),
    CONSTRAINT reviewPK PRIMARY KEY (reviewer_id, product_id)
);

CREATE TABLE Orders(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES Users(id),
    state       ORDER_STATE NOT NULL
);

CREATE TABLE OrderProduct(
    order_id    INTEGER REFERENCES Orders(id),
    product_id  INTEGER REFERENCES Product(id),
    quantity    INTEGER NOT NULL,
    CONSTRAINT orderProductPK PRIMARY KEY (order_id, product_id)
);

CREATE TABLE CartProduct(
    cart_id     INTEGER REFERENCES Users(cart_id),
    product_id  INTEGER REFERENCES Product(id),
    quantity    INTEGER NOT NULL,
    CONSTRAINT cartProductPK PRIMARY KEY (cart_id, product_id)
);

CREATE TABLE WishlistProduct(
    wishlist_id INTEGER REFERENCES Users(wishlist_id),
    product_id  INTEGER REFERENCES Product(id),
    CONSTRAINT wishlistProductPK PRIMARY KEY (wishlist_id, product_id)
);

CREATE TABLE Notif(
    id          SERIAL PRIMARY KEY,
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT DEFAULT NULL,
    type        NOTIF_TYPE NOT NULL
);

CREATE TABLE Ticket(
    id          SERIAL PRIMARY KEY,
    ticketer_id INTEGER REFERENCES Users(id),
    message     VARCHAR(255) NOT NULL
);

CREATE TABLE Report(
    id          SERIAL PRIMARY KEY,
    reporter_id INTEGER REFERENCES Users(id),
    reported_id INTEGER REFERENCES Users(id),
    message     VARCHAR(255) NOT NULL
);