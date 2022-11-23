-- Drop schema if existant
DROP SCHEMA IF EXISTS lbaw22123 CASCADE;


-- Create group schema and set it as search path
CREATE SCHEMA lbaw22123;
SET search_path TO lbaw22123;

-- Enumerations
CREATE TYPE PRODUCT_FORMAT AS ENUM('Vinyl', 'CD', 'Cassette', 'DVD', 'Box Set');
CREATE TYPE ORDER_STATE AS ENUM('Processing', 'Shipped', 'Delivered');
CREATE TYPE NOTIF_TYPE AS ENUM('Order', 'Wishlist', 'Misc');

-- Drop existent tables
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS fav_artist;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS product_genre;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_product;
DROP TABLE IF EXISTS wishlist_product;
DROP TABLE IF EXISTS notif;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS report;


-- Table creation

CREATE TABLE users(
    id          SERIAL PRIMARY KEY,
    email       VARCHAR(255) UNIQUE NOT NULL,
    username    VARCHAR(60) NOT NULL,
    password    VARCHAR(255) NOT NULL,
    is_blocked  BOOLEAN NOT NULL DEFAULT FALSE,
    is_admin    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE artist(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,
    description TEXT DEFAULT NULL
);

CREATE TABLE fav_artist(
    user_id     INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    artist_id   INTEGER REFERENCES artist(id) ON UPDATE CASCADE,
    CONSTRAINT favArtistPK PRIMARY KEY (user_id, artist_id)
);

CREATE TABLE genre(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR (100) UNIQUE NOT NULL
);

CREATE TABLE product(
    id          SERIAL PRIMARY KEY,
    artist_id   INTEGER REFERENCES artist(id) ON UPDATE CASCADE,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    stock       INTEGER NOT NULL DEFAULT 1,
    price       BIGINT NOT NULL,
    format      PRODUCT_FORMAT NOT NULL,
    year        INTEGER,
    rating      FLOAT DEFAULT NULL,
    CHECK (stock >= 0)
);

CREATE TABLE product_genre(
    product_id  INTEGER REFERENCES product(id) ON UPDATE CASCADE,
    genre_id    INTEGER REFERENCES genre(id) ON UPDATE CASCADE,
    CONSTRAINT productGenrePK PRIMARY KEY (product_id, genre_id)
);

CREATE TABLE review(
    reviewer_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES product(id) ON UPDATE CASCADE,
    score       INTEGER NOT NULL,
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    message     TEXT DEFAULT NULL,
    CHECK (score BETWEEN 0 AND 5),
    CONSTRAINT reviewPK PRIMARY KEY (reviewer_id, product_id)
);

CREATE TABLE orders(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    state       ORDER_STATE NOT NULL
);

CREATE TABLE order_product(
    order_id    INTEGER REFERENCES orders(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES product(id) ON UPDATE CASCADE,
    quantity    INTEGER NOT NULL,
    CONSTRAINT orderProductPK PRIMARY KEY (order_id, product_id)
);

CREATE TABLE wishlist_product(
    wishlist_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES product(id) ON UPDATE CASCADE,
    CONSTRAINT wishlistProductPK PRIMARY KEY (wishlist_id, product_id)
);

CREATE TABLE notif(
    id          SERIAL PRIMARY KEY,
	user_id		INTEGER REFERENCES users(id),
    date        DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT DEFAULT NULL,
    type        NOTIF_TYPE NOT NULL
);

CREATE TABLE ticket(
    id          SERIAL PRIMARY KEY,
    ticketer_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    message     VARCHAR(255) NOT NULL
);

CREATE TABLE report(
    id          SERIAL PRIMARY KEY,
    reporter_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    reported_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    message     VARCHAR(255) NOT NULL
);

-- Performance Indexes

CREATE INDEX product_artist_idx ON product USING hash (artist_id);

CREATE INDEX product_price_idx ON product USING btree (price);
CLUSTER product USING product_price_idx;

CREATE INDEX product_genre_idx ON product_genre USING hash (genre_id);

-- Full text search

ALTER TABLE product
ADD COLUMN tsvectors TSVECTOR;

CREATE FUNCTION product_search_update() RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', COALESCE((SELECT DISTINCT artist.name AS artist FROM artist JOIN product ON artist.id = NEW.artist_id), '')), 'B') ||
            setweight(to_tsvector('english', COALESCE((SELECT string_agg(genre.name, ' ') AS genres FROM genre JOIN product_genre ON genre.id = product_genre.genre_id AND product_genre.product_id = NEW.id), '')), 'C') ||
            setweight(to_tsvector('english', COALESCE(NEW.description, ' ')), 'C')
        );
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.name), 'A') ||
            setweight(to_tsvector('english', COALESCE((SELECT DISTINCT artist.name AS artist FROM artist JOIN product ON artist.id = NEW.artist_id), '')), 'B') ||
            setweight(to_tsvector('english', COALESCE((SELECT string_agg(genre.name, ' ') AS genres FROM genre JOIN product_genre ON genre.id = product_genre.genre_id AND product_genre.product_id = NEW.id), '')), 'C') ||
            setweight(to_tsvector('english', COALESCE(NEW.description, ' ')), 'C')
        );
    END IF;
    RETURN NEW;

END $$
LANGUAGE plpgsql;

CREATE TRIGGER product_search_update
    BEFORE INSERT OR UPDATE ON product
    FOR EACH ROW
    EXECUTE PROCEDURE product_search_update();

CREATE FUNCTION product_genre_update() RETURNS TRIGGER AS $$
BEGIN

    UPDATE product SET id = NEW.product_id WHERE id = NEW.product_id;
    RETURN NEW;

END $$
LANGUAGE plpgsql;

CREATE TRIGGER product_genre_update
    AFTER INSERT OR UPDATE ON product_genre
    FOR EACH ROW
    EXECUTE PROCEDURE product_genre_update();

CREATE INDEX product_fts ON product USING GIN(tsvectors);

-- Triggers
-- Trigger 01 - Removing artist while removing all its associations

CREATE FUNCTION delete_artist() RETURNS TRIGGER AS 
$BODY$
BEGIN

    DELETE FROM product
    WHERE artist_id = OLD.id;

    DELETE FROM fav_artist
    WHERE artist_id = OLD.id;

    RETURN OLD;
    
END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER delete_artist
    BEFORE DELETE ON artist
    FOR EACH ROW
    EXECUTE PROCEDURE delete_artist();

-- Trigger 02 - Update a product's rating after a new review

CREATE FUNCTION review_product()
RETURNS TRIGGER AS 
$BODY$
BEGIN

    IF TG_OP = 'INSERT' THEN
        UPDATE product
        SET rating = ((SELECT SUM(score) FROM review WHERE NEW.product_id = product_id))::float / (SELECT COUNT(*) FROM review WHERE NEW.product_id = product_id)
        WHERE id = NEW.product_id;
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.score <> OLD.score) THEN
            UPDATE product
            SET rating = ((SELECT SUM(score) FROM review WHERE NEW.product_id = product_id))::float / (SELECT COUNT(*) FROM review WHERE NEW.product_id = product_id)
            WHERE id = NEW.product_id;
        END IF;
    END IF;
    IF TG_OP = 'DELETE' THEN
        IF ((SELECT COUNT(*) FROM review WHERE OLD.product_id = product_id) = 0) THEN
            UPDATE product
            SET rating = NULL
            WHERE id = OLD.product_id;
        ELSE
            UPDATE product
            SET rating = ((SELECT SUM(score) FROM review WHERE OLD.product_id = product_id))::float / (SELECT COUNT(*) FROM review WHERE OLD.product_id = product_id)
            WHERE id = OLD.product_id;
        END IF;
    END IF;
    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER review_product
    AFTER INSERT OR UPDATE ON review
    FOR EACH ROW
    EXECUTE PROCEDURE review_product();

-- Trigger 03 - Update a product's stock on purchase

CREATE FUNCTION update_stock()
RETURNS TRIGGER AS 
$BODY$
BEGIN 

    UPDATE product
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
    RETURN NEW;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER update_stock
    AFTER INSERT ON order_product
    FOR EACH ROW
    EXECUTE PROCEDURE update_stock();

-- Trigger 04 - Remove a product and all its associations

CREATE FUNCTION delete_product() RETURNS TRIGGER AS 
$BODY$
BEGIN

    DELETE FROM product_genre
    WHERE product_id = OLD.id;

    DELETE FROM review
    WHERE product_id = OLD.id;

    DELETE FROM order_product
    WHERE product_id = OLD.id;

    DELETE FROM wishlist_product
    WHERE product_id = OLD.id;

    RETURN OLD;

END
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER delete_product
    BEFORE DELETE ON product
    FOR EACH ROW
    EXECUTE PROCEDURE delete_product();

INSERT INTO genre (name) VALUES ('Math Rock');
INSERT INTO genre (name) VALUES ('Prog Rock');
INSERT INTO genre (name) VALUES ('Jazz-Rock');
INSERT INTO genre (name) VALUES ('Jazz');
INSERT INTO genre (name) VALUES ('Rock');
INSERT INTO genre (name) VALUES ('Post-Punk');
INSERT INTO genre (name) VALUES ('Art Rock');
INSERT INTO genre (name) VALUES ('Noise');
INSERT INTO genre (name) VALUES ('Experimental');
INSERT INTO genre (name) VALUES ('Post Rock');
INSERT INTO genre (name) VALUES ('Lo-Fi');
INSERT INTO genre (name) VALUES ('Shoegaze');
INSERT INTO genre (name) VALUES ('Space Rock');
INSERT INTO genre (name) VALUES ('Indie Rock');
INSERT INTO genre (name) VALUES ('Alternative Rock');
INSERT INTO genre (name) VALUES ('Pop Rock');
INSERT INTO genre (name) VALUES ('Indie Pop');
INSERT INTO genre (name) VALUES ('Folk');
INSERT INTO genre (name) VALUES ('Pop');
INSERT INTO genre (name) VALUES ('Folk, World, & Country');
INSERT INTO genre (name) VALUES ('Heavy Metal');
INSERT INTO genre (name) VALUES ('Cloud Rap');
INSERT INTO genre (name) VALUES ('Contemporary R&B');
INSERT INTO genre (name) VALUES ('Electronic');
INSERT INTO genre (name) VALUES ('Hip Hop');
INSERT INTO genre (name) VALUES ('Funk / Soul');

INSERT INTO artist (name, description) VALUES ('Black Midi', 'Experimental rock band from London, UK. Met whilst studying at The BRIT School for Performing Arts & Technology, Croydon UK. Formed "properly" in 2017 as the four members graduated.');
INSERT INTO artist (name, description) VALUES ('Black Country, New Road', 'A six-piece post-rock group from England who released their first sell-out single "Athens, France" in early 2019 on the label Speedy Wunderground and follow-up single ''Sunglasses'' on Blank Editions. Subsequent releases include albums ''For The First Time'' in early 2021 and the critically-acclaimed ''Ants From Up There'' in early 2022. 
');
INSERT INTO artist (name, description) VALUES ('Duster (2)', 'Duster is an American rock band from San-Jose California, consisting of multi-instrumentalists Clay Parton, Canaan Dove Amber, and Jason Albertini. Generally seen as indie rock, the group has been also associated with the space rock and slowcore movements by critics due to their unique sound. To produce this, the band typically recorded on cheap and older recording equipment, such as cassette decks, in their Low Earth Orbit studio. Years active 1996–2001 / 2018–present
');
INSERT INTO artist (name, description) VALUES ('beabadoobee', 'Born June 3, 2000, Iloilo City, Phillippines. Emigrated to England with her parents two years later. 

Also known as Bea Kristi or professionally as Beabadoobee, she released her first two singles, "Coffee" and a cover version of Karen O''s "The Moon Song", digitally in September of 2017, followed by a four-song EP, Lice, in March of 2018.
She signed with Dirty Hit, who reissued her back catalog and released her next two EPs, Patched Up and Loveworm, while she was finishing high school.
The latter EP started to point to a more electric sound, and in interviews beabadoobee namedropped the likes of Pavement, Sonic Youth, and Dinosaur Jr as influences on the songs.
A solo acoustic version of the latter EP, called Loveworm (Bedroom Sessions), was released in June of 2019, followed by two singles, "She Plays Bass" and "I Wish I Was Stephen Malkmus" in August and September of 2019. beabadoobee undertook her first US tour opening for Clairo, during which her fourth EP Space Cadet, now fully dominated by electric indie rock arrangements, was released.');
INSERT INTO artist (name, description) VALUES ('Clairo (2)', 'American singer-songwriter born August 18, 1998 in Atlanta, Georgia.');
INSERT INTO artist (name, description) VALUES ('Trivium', 'Heavy metal / thrash / metalcore band from Orlando, Florida, USA.

Trivium was formed as a trio in 1999 by Brad Lewter (vocals, bass), Jarred Bonaparte (guitar) and Travis Smith (drums).

Matt Heafy joined the band only in late 1999 as a guitarist/backing vocalist.
When lead vocalist/bassist Brad Lewter left Trivium in 2000, Matt Heafy started to perform lead vocals as well.
Second founding member Jarred Bonaparte switched from guitar to bass - but left anyway in 2001.

Last founding member Travis Smith left the band in late 2009.

Current members
Matt Heafy – guitars (1999–present); backing vocals (1999–2000); lead vocals (2000–present)
Corey Beaulieu – guitars, unclean backing vocals (2003–present)
Paolo Gregoletto – bass, clean backing vocals (2004–present)
Alex Bent – drums, percussion (2016–present)

Former members:
Brad Lewter – lead vocals, bass (1999–2000)
Jarred Bonaparte – guitars (1999–2000); bass (2000–2001)
Travis Smith – drums, percussion (1999–2010)
Brent Young – guitars (2000–2001); backing vocals (2000–2004); bass (2001–2004)
Richie Brown – bass (2001)
George Moore – guitars (2003)
Nick Augusto – drums, percussion (2010–2014)
Mat Madiro – drums, percussion (2014–2015)
Paul Wandtke – drums, percussion (2015–2016)');
INSERT INTO artist (name, description) VALUES ('Tokio Hotel', 'Tokio Hotel is a German band founded in Magdeburg, Germany in 2001 by guitarist Tom Kaulitz, singer Bill Kaulitz, drummer Gustav Schäfer and bassist Georg Listing. The quartet has scored four number one singles and has released two number one albums in their native Germany, selling nearly 5 million CDs and DVDs there. After recording an unreleased demo-CD under the name "Devilish" and having their contract with Sony BMG terminated, the band released their first German-language album, Schrei, as Tokio Hotel on Island Records in 2005. Schrei sold more than half a million copies worldwide and spawned four top five singles in both Germany and Austria. In 2007, the band released their second German album Zimmer 483 and their first English album Scream which have combined album sales of over one million copies worldwide and helped win the band their first MTV European Music Award for Best InterAct. The former, Zimmer 483, spawned three top five singles in Germany while the latter, Scream, spawned two singles that reached the top twenty in new territories such as Portugal, Spain and Italy. Their first live album, Zimmer 483 - Live in Europe, was released near the end of 2007.');
INSERT INTO artist (name, description) VALUES ('Japanese Breakfast', 'A solo moniker for Philadelphia musician Michelle Zauner, Japanese Breakfast began as a monthlong, song-a-day writing challenge during a break from her indie rock band Little Big League. That resulted in 2013''s June, an intimate set of melodic, electric guitar-accompanied lo-fi tunes issued on cassette by Ranch Records. She continued to write solo and with her band, with Japanese Breakfast''s self-released Where Is My Great Big Feeling? and the Seagreen Records cassette American Sound both following in the summer of 2014 before Little Big League''s Tropical Jinx arrived that October. With a varied palette including markedly bigger, synth-boosted sounds that bridged lo-fi and indie pop, Japanese Breakfast''s Yellow K Records debut, Psychopomp, was released in the spring of 2016.');
INSERT INTO artist (name, description) VALUES ('Slint', 'Slint was an American rock band formed in Louisville, KY in 1986. They disbanded following the recording of their second full-length album, Spiderland, in 1991. 

In 2005, 2007 and 2014 the band reunited to play a number of live shows. On the 2007 tour dates, in addition to performing songs from Spiderland and the untitled 10", they also debuted a new composition called "King''s Approach." Their 2014 tour coincided with the release of a box set compiling a remastered version of the Spiderland LP, previously unreleased studio outtakes and demos, and a new documentary film about their origins and the Louisville music scene.');
INSERT INTO artist (name, description) VALUES ('Ecco2k', 'ECCO2K (Ecco) also known under Aloegarten and Zak, is an Swedish/English rapper, producer, designer from Stockholm, Sweden.

For profile see [a6928847].');
INSERT INTO artist (name, description) VALUES ('My Bloody Valentine', 'My Bloody Valentine are an Irish-English rock band.

Initially active from 1985 to 1993, MBV reunited for an international tour in 2007, and, after a gap of 21 years, released its third LP in 2013. In addition to a steady stream of remasters, mainstay and leader [a20085] has promised, on numerous occasions, a variety of forthcoming EPs and full-lengths.');

INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Hellfire', 'Hellfire
Sugar / Tzu
Eat Men Eat
Welcome To Hell
Still
Half Time
The Race Is About To Begin
Dangerous Liaisons
The Defence
27 Questions', 100, 814, 'CD', 2022, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Hellfire', 'Hellfire
Sugar/Tzu
Eat Men, Eat
Welcome To Hell
Still        dd()

Half Time
The Race Is About To Begin
Dangerous Liaisons
The Defence
27 Questions', 100, 2399, 'Vinyl', 2022, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Schlagenheim', '953
Speedway
Reggae
Near DT, MI
Western
Of Schlagenheim
BMBMBM
Years Ago
Ducter', 100, 800, 'CD', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Schlagenheim', '953
Speedway
Reggae
Near DT,MI
Western
Of Schlagenheim
bmbmbm
Years Ago
Ducter', 100, 1500, 'Vinyl', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (2, 'For The First Time', 'Instrumental
Athens, France
Science Fair
Sunglasses
Track X
Opus', 100, 808, 'CD', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (2, 'For The First Time', 'Instrumental
Athens, France
Science Fair
Sunglasses
Track X
Opus', 100, 1855, 'Vinyl', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (3, 'Together', 'New Directions
Retrograde
N
Time Glitch
Teeth
Escalator
Familiar Fields
Moonroam
Sleepyhead
Making Room
Drifter
Feel No Joy
Sad Boys', 100, 1795, 'Vinyl', 2022, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (3, 'Contemporary Movement', 'Get The Dutch
Operations
Diamond
Me And The Birds
Travelogue
The Phantom Facing Me
Cooking
Unrecovery
The Breakup Suite
Everything You See (Is Your Own)
Now It''s Coming Back
Auto-Mobile', 100, 11000, 'Vinyl', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (3, 'Stratosphere', 'Moon Age
Heading For The Door
Gold Dust
Topical Solution
Docking The Pod
The Landing
Constellations
The Queen Of Hearts
Two Way Radio
Inside Out
Stratosphere
Reed To Hillsborough
Shadows Of Planes
Earth Moon Transit
The Twins/Romantica
Sideria', 100, 23140, 'Vinyl', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (3, 'Stratosphere', 'Moon Age
Heading For The Door
Gold Dust
Topical Solution
Docking The Pod
The Landing
Echo, Bravo
Constellations
The Queen Of Hearts
Two Way Radio
Inside Out
Stratosphere
Reed To Hillsborough
Shadows Of Planes
Earth Moon Transit
The Twins / Romantica
Sideria', 100, 3499, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (4, 'Fake It Flowers', 'Care
Worth It
Dye It Red
Back To Mars
Charlie Brown
Emo Song
Sorry
Further Away 
Horen Sarrison
How Was Your Day?
Together
Yoshimi, Forest, Magdalene ', 100, 1900, 'Vinyl', 2020, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (5, 'Sling', 'Bambi
Amoeba
Partridge
Zinnias
Blouse
Wade
Harbor
Just For Today
Joanie
Reaper
Little Changes
Management', 100, 1250, 'Vinyl', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (6, 'Shogun', 'Kirisute Gomen
Torn Between Scylla And Charybdis
Down From The Sky
Into The Mouth Of Hell We March
Throes Of Perdition
Insurrection
The Calamity
He Who Spawned The Furies
Of Prometheus And The Crucifix
Like Callisto To A Star In Heaven
Shogun', 100, 220, 'CD', 2008, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (7, 'Humanoid ', 'Noise
Darkside Of The Sun
Automatic
World Behind My Wall
Humanoid
Forever Now
Pain Of Love
Dogs Unleashed
Human Connect To Human
Hey You
Love & Death
Zoom Into Me', 100, 114, 'CD', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (8, 'Jubilee ', 'Paprika 
Be Sweet 
Kokomo, IN
Slide Tackle 
Posing In Bondage
Sit
Savage Good Boy
In Hell
Tactics 
Posing For Cars', 100, 5814, 'Vinyl', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (9, 'Spiderland', 'Breadcrumb Trail
Nosferatu Man
Don, Aman
Washer
For Dinner...
Good Morning, Captain', 100, 1054, 'CD', 0, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (9, 'Spiderland', 'Breadcrumb Trail
Nosferatu Man
Don, Aman
Washer
For Dinner...
Good Morning, Captain', 100, 2000, 'Vinyl', 0, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (10, 'E', 'AAA Powerline
Peroxide
Fragile
Bliss Fields
Fruit Bleed Juice
Cc
Calcium
Sugar & Diesel
Don''t Ask
Security!
Time
Blue Eyes
Life After Life', 100, 13110, 'CD', 2020, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (11, 'Loveless', 'Only Shallow
Loomer
Touched
To Here Knows When
When You Sleep
I Only Said
Come In Alone
Sometimes
Blown A Wish
What You Want
Soon
Only Shallow
Loomer
Touched
To Here Knows When
When You Sleep
I Only Said
Come In Alone
Sometimes
Blown A Wish
What You Want
Soon', 100, 2299, 'CD', 2021, NULL);

INSERT INTO product_genre (product_id, genre_id) VALUES (1, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 3);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 8);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 11);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 12);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 11);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (10, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (10, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 16);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 17);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (13, 21);
INSERT INTO product_genre (product_id, genre_id) VALUES (13, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (14, 16);
INSERT INTO product_genre (product_id, genre_id) VALUES (14, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (19, 12);
INSERT INTO product_genre (product_id, genre_id) VALUES (19, 5);

INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('vgritsunov0@jigsy.com', 'fharniman0', 'Bw4Zz9I', true, true);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('ocowope1@mail.ru', 'jspitell1', 'DUyfyhZdT', false, true);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('ehampe2@howstuffworks.com', 'ssoldan2', 'SucaFYzEoyR', true, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('rresun3@amazon.de', 'mpenniall3', 'JvCTegKpU', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('bblesdill4@oakley.com', 'wwyman4', 'cVo4PcTMH', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('wwheelband5@msu.edu', 'tfeatherstone5', 'CtTLXAqk', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('lairy6@princeton.edu', 'ykeetley6', 'UjhgQLeyX', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('ccasper7@usatoday.com', 'bocurrigan7', 'pY6cdAFi7gF', true, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('bfarry8@blogs.com', 'gcoulter8', 'zMrvIF', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('hquainton9@google.de', 'njobb9', '9AstPKE1', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('rclipshama@tumblr.com', 'rhaingea', 'qwFNPyp', true, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('lofihilyb@bloomberg.com', 'kdoyleyb', 'oq4ysf5LyEB5', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('fellamc@cafepress.com', 'mbilstonc', 'Rll7YQEHjx', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('nbaystond@springer.com', 'hfairholmed', 'gt7hUW', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('jjoppe@flickr.com', 'vstreake', 'sZZfRop', true, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('melmsf@sciencedaily.com', 'abeauvaisf', 'XLYHJV', true, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('svezeyg@google.it', 'btolputtg', 'r4MOaMCvzv', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('bdulantyh@usgs.gov', 'gcrookesh', 'dmbKPWOu3t7', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('pjessetti@japanpost.jp', 'cheffroni', 'qADH94j', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('jcoathamj@4shared.com', 'cdodimeadj', '7fqv5gPRyST', false, false);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('insectlover@gmail.com', 'insectlover3000', '$2a$10$FaHcdytZiRLl.sNcNzKz.OAHAMzZm6PKKWmEwunHkkfPHYle0QpEW', false, false);

INSERT INTO fav_artist (user_id, artist_id) VALUES (13,1);
INSERT INTO fav_artist (user_id, artist_id) VALUES (3,4);
INSERT INTO fav_artist (user_id, artist_id) VALUES (12,5);
INSERT INTO fav_artist (user_id, artist_id) VALUES (4,7);
INSERT INTO fav_artist (user_id, artist_id) VALUES (5,10);
INSERT INTO fav_artist (user_id, artist_id) VALUES (6,6);
INSERT INTO fav_artist (user_id, artist_id) VALUES (7,3);
INSERT INTO fav_artist (user_id, artist_id) VALUES (10,11);
INSERT INTO fav_artist (user_id, artist_id) VALUES (12,2);

INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (15, 5, 2, '2022-08-21', 'Terrible');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (11, 11, 3, '2022-06-24', 'It''s okay ig');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (7, 12, 5, '2022-07-12', 'AOTY');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (8, 10, 2, '2022-08-01', 'Atrocious');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (5, 6, 3, '2022-09-20', 'Decent tbh');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (20, 15, 4, '2022-10-20', 'Pretty good');
INSERT INTO review (reviewer_id, product_id, score, date, message) VALUES (10, 12, 1, '2022-11-02', 'I''d rather die than listen to this again');

INSERT INTO report (reporter_id, reported_id, message) VALUES (18, 13, 'Bad review');
INSERT INTO report (reporter_id, reported_id, message) VALUES (3, 11, 'Worst taste');
INSERT INTO report (reporter_id, reported_id, message) VALUES (4, 15, 'Advertising');
INSERT INTO report (reporter_id, reported_id, message) VALUES (5, 10, 'I just don''t like them');
INSERT INTO report (reporter_id, reported_id, message) VALUES (11, 20, 'I don''t care what they think');
INSERT INTO report (reporter_id, reported_id, message) VALUES (6, 7, 'Advertising');
INSERT INTO report (reporter_id, reported_id, message) VALUES (20, 12, 'Terrible human');
INSERT INTO report (reporter_id, reported_id, message) VALUES (17, 12, 'Terrible human');

INSERT INTO ticket (ticketer_id, message) VALUES (20, 'Missing package');
INSERT INTO ticket (ticketer_id, message) VALUES (1, 'I''m testing too');
INSERT INTO ticket (ticketer_id, message) VALUES (2, 'Tickets please xD In all seriousness my package didn''t arrive :(');
INSERT INTO ticket (ticketer_id, message) VALUES (6, 'Scaaaarryyyyy');
INSERT INTO ticket (ticketer_id, message) VALUES (14, 'Boo');
INSERT INTO ticket (ticketer_id, message) VALUES (5, 'I''m also testing');
INSERT INTO ticket (ticketer_id, message) VALUES (7, 'I''m testing to see what happens');
INSERT INTO ticket (ticketer_id, message) VALUES (18, 'Wrong order');

INSERT INTO orders (user_id, state) VALUES (3, 'Processing');
INSERT INTO orders (user_id, state) VALUES (11, 'Processing');
INSERT INTO orders (user_id, state) VALUES (12, 'Shipped');
INSERT INTO orders (user_id, state) VALUES (10, 'Delivered');
INSERT INTO orders (user_id, state) VALUES (4, 'Processing');
INSERT INTO orders (user_id, state) VALUES (8, 'Shipped');
INSERT INTO orders (user_id, state) VALUES (20, 'Delivered');

INSERT INTO notif (date, description, type) VALUES ('2022-08-21', 'Order has been sent', 'Order');
INSERT INTO notif (date, description, type) VALUES ('2022-06-24', 'Order has been sent', 'Order');
INSERT INTO notif (date, description, type) VALUES ('2022-07-12', 'Order has been sent', 'Order');
INSERT INTO notif (date, description, type) VALUES ('2022-08-01', 'Order has been sent', 'Order');
INSERT INTO notif (date, description, type) VALUES ('2022-09-20', 'Item on sale', 'Wishlist');
INSERT INTO notif (date, description, type) VALUES ('2022-10-20', 'WOW new sale', 'Wishlist');
INSERT INTO notif (date, description, type) VALUES ('2022-11-02', 'Test message', 'Misc');

INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (8, 13);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (20, 14);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (15, 10);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (18, 3);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (7, 5);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (5, 12);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (6, 1);

INSERT INTO order_product (order_id, product_id, quantity) VALUES (1, 2, 1);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (2, 12, 2);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (3, 13, 1);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (3, 11, 1);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (3, 19, 3);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (4, 2, 2);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (5, 10, 1);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (6, 7, 2);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (6, 8, 1);
INSERT INTO order_product (order_id, product_id, quantity) VALUES (7, 1, 1);