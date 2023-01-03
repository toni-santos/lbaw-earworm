-- Drop schema if existant
DROP SCHEMA IF EXISTS lbaw22123 CASCADE;


-- Create group schema and set it as search path
CREATE SCHEMA lbaw22123;
SET search_path TO lbaw22123;

-- Enumerations
CREATE TYPE PRODUCT_FORMAT AS ENUM('Vinyl', 'CD', 'Cassette', 'DVD', 'Box Set');
CREATE TYPE ORDER_STATE AS ENUM('Processing', 'Shipped', 'Delivered', 'Canceled');
CREATE TYPE NOTIF_TYPE AS ENUM('Order', 'Wishlist', 'Misc');

-- Drop existent tables
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS password_resets;
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
    last_fm     VARCHAR(60) DEFAULT NULL,
    password    VARCHAR(255) NOT NULL,
    is_blocked  BOOLEAN NOT NULL DEFAULT FALSE,
    is_admin    BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE password_resets (
    email       VARCHAR(255) PRIMARY KEY,
    token       VARCHAR(64) NOT NULL,
    created_at  timestamp NOT NULL DEFAULT NOW()
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
    discount    INTEGER NOT NULL DEFAULT 0,
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
    created_at  DATE NOT NULL DEFAULT CURRENT_DATE,
    message     TEXT DEFAULT NULL,
    CHECK (score BETWEEN 0 AND 5),
    CONSTRAINT reviewPK PRIMARY KEY (reviewer_id, product_id)
);

CREATE TABLE orders(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    address     TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    state       ORDER_STATE NOT NULL
);

CREATE TABLE order_product(
    order_id    INTEGER REFERENCES orders(id) ON UPDATE CASCADE,
    product_id  INTEGER REFERENCES product(id) ON UPDATE CASCADE,
    quantity    INTEGER NOT NULL,
    price       INTEGER NOT NULL,
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
    content_id  INTEGER DEFAULT NULL,
    sent_at     TIMESTAMP NOT NULL DEFAULT NOW(),
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
    reported_id INTEGER REFERENCES users(id) ON UPDATE CASCADE
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
    AFTER INSERT OR UPDATE OR DELETE ON review
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
INSERT INTO genre (name) VALUES ('Art Rock');
INSERT INTO genre (name) VALUES ('Experimental');
INSERT INTO genre (name) VALUES ('Post-Punk');
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
INSERT INTO genre (name) VALUES ('Blues Rock');
INSERT INTO genre (name) VALUES ('Blues');
INSERT INTO genre (name) VALUES ('Funk Metal');
INSERT INTO genre (name) VALUES ('Country Rock');
INSERT INTO genre (name) VALUES ('Nu Metal');
INSERT INTO genre (name) VALUES ('Hard Rock');
INSERT INTO genre (name) VALUES ('Punk');
INSERT INTO genre (name) VALUES ('Pop Punk');
INSERT INTO genre (name) VALUES ('Grunge');
INSERT INTO genre (name) VALUES ('Progressive Metal');
INSERT INTO genre (name) VALUES ('Post-Metal');
INSERT INTO genre (name) VALUES ('Ethereal');
INSERT INTO genre (name) VALUES ('Folk Rock');
INSERT INTO genre (name) VALUES ('Soundtrack');
INSERT INTO genre (name) VALUES ('Stage & Screen');
INSERT INTO genre (name) VALUES ('Acoustic');
INSERT INTO genre (name) VALUES ('Soft Rock');
INSERT INTO genre (name) VALUES ('House');
INSERT INTO genre (name) VALUES ('Techno');
INSERT INTO genre (name) VALUES ('Disco');
INSERT INTO genre (name) VALUES ('Dance-pop');
INSERT INTO genre (name) VALUES ('Electro');
INSERT INTO genre (name) VALUES ('Synth-pop');
INSERT INTO genre (name) VALUES ('Downtempo');
INSERT INTO genre (name) VALUES ('Ambient');
INSERT INTO genre (name) VALUES ('Classic Rock');
INSERT INTO genre (name) VALUES ('Ballad');
INSERT INTO genre (name) VALUES ('Garage Rock');
INSERT INTO genre (name) VALUES ('Southern Rock');
INSERT INTO genre (name) VALUES ('Progressive House');
INSERT INTO genre (name) VALUES ('Breaks');
INSERT INTO genre (name) VALUES ('Big Beat');
INSERT INTO genre (name) VALUES ('Conscious');
INSERT INTO genre (name) VALUES ('Leftfield');
INSERT INTO genre (name) VALUES ('Trip Hop');
INSERT INTO genre (name) VALUES ('Metalcore');
INSERT INTO genre (name) VALUES ('Country');
INSERT INTO genre (name) VALUES ('Rhythm & Blues');
INSERT INTO genre (name) VALUES ('Funk');
INSERT INTO genre (name) VALUES ('Soul');
INSERT INTO genre (name) VALUES ('Reggae');
INSERT INTO genre (name) VALUES ('Acid Jazz');
INSERT INTO genre (name) VALUES ('Thrash');
INSERT INTO genre (name) VALUES ('Avantgarde');
INSERT INTO genre (name) VALUES ('Abstract');
INSERT INTO genre (name) VALUES ('Drum n Bass');
INSERT INTO genre (name) VALUES ('IDM');
INSERT INTO genre (name) VALUES ('Acid');
INSERT INTO genre (name) VALUES ('Breakbeat');
INSERT INTO genre (name) VALUES ('Symphonic Metal');
INSERT INTO genre (name) VALUES ('UK Garage');
INSERT INTO genre (name) VALUES ('Dancehall');
INSERT INTO genre (name) VALUES ('Groove Metal');
INSERT INTO genre (name) VALUES ('Industrial');
INSERT INTO genre (name) VALUES ('Psychedelic Rock');
INSERT INTO genre (name) VALUES ('Minneapolis Sound');
INSERT INTO genre (name) VALUES ('Glam');
INSERT INTO genre (name) VALUES ('AOR');
INSERT INTO genre (name) VALUES ('Rock & Roll');
INSERT INTO genre (name) VALUES ('New Wave');
INSERT INTO genre (name) VALUES ('Power Pop');
INSERT INTO genre (name) VALUES ('Pop Rap');
INSERT INTO genre (name) VALUES ('Britpop');
INSERT INTO genre (name) VALUES ('Gangsta');
INSERT INTO genre (name) VALUES ('G-Funk');
INSERT INTO genre (name) VALUES ('Vocal');
INSERT INTO genre (name) VALUES ('Neo Soul');
INSERT INTO genre (name) VALUES ('Jazzy Hip-Hop');
INSERT INTO genre (name) VALUES ('Hardcore Hip-Hop');
INSERT INTO genre (name) VALUES ('Boom Bap');
INSERT INTO genre (name) VALUES ('Arena Rock');
INSERT INTO genre (name) VALUES ('Speed Metal');
INSERT INTO genre (name) VALUES ('Jangle Pop');
INSERT INTO genre (name) VALUES ('Score');
INSERT INTO genre (name) VALUES ('Neo-Romantic');
INSERT INTO genre (name) VALUES ('Classical');
INSERT INTO genre (name) VALUES ('Europop');
INSERT INTO genre (name) VALUES ('Modal');
INSERT INTO genre (name) VALUES ('Cool Jazz');
INSERT INTO genre (name) VALUES ('Trap');

INSERT INTO artist (name, description) VALUES ('Black Midi', 'Experimental rock band from London, UK. Met whilst studying at The BRIT School for Performing Arts & Technology, Croydon UK. Formed "properly" in 2017 as the four members graduated.');
INSERT INTO artist (name, description) VALUES ('Black Country, New Road', 'A six-piece post-rock group from England who released their first sell-out single "Athens, France" in early 2019 on the label Speedy Wunderground and follow-up single ''Sunglasses'' on Blank Editions. Subsequent releases include albums ''For The First Time'' in early 2021 and the critically-acclaimed ''Ants From Up There'' in early 2022. 
');
INSERT INTO artist (name, description) VALUES ('Duster ', 'Duster is an American rock band from San-Jose California, consisting of multi-instrumentalists Clay Parton, Canaan Dove Amber, and Jason Albertini. Generally seen as indie rock, the group has been also associated with the space rock and slowcore movements by critics due to their unique sound. To produce this, the band typically recorded on cheap and older recording equipment, such as cassette decks, in their Low Earth Orbit studio. Years active 1996–2001 / 2018–present
');
INSERT INTO artist (name, description) VALUES ('beabadoobee', 'Born June 3, 2000, Iloilo City, Phillippines. Emigrated to England with her parents two years later. 

Also known as Bea Kristi or professionally as Beabadoobee, she released her first two singles, "Coffee" and a cover version of Karen O''s "The Moon Song", digitally in September of 2017, followed by a four-song EP, Lice, in March of 2018.
She signed with Dirty Hit, who reissued her back catalog and released her next two EPs, Patched Up and Loveworm, while she was finishing high school.
The latter EP started to point to a more electric sound, and in interviews beabadoobee namedropped the likes of Pavement, Sonic Youth, and Dinosaur Jr as influences on the songs.
A solo acoustic version of the latter EP, called Loveworm (Bedroom Sessions), was released in June of 2019, followed by two singles, "She Plays Bass" and "I Wish I Was Stephen Malkmus" in August and September of 2019. beabadoobee undertook her first US tour opening for Clairo, during which her fourth EP Space Cadet, now fully dominated by electric indie rock arrangements, was released.');
INSERT INTO artist (name, description) VALUES ('Clairo ', 'American singer-songwriter born August 18, 1998 in Atlanta, Georgia.');
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
INSERT INTO artist (name, description) VALUES ('Tool ', 'Tool is an American rock band from Los Angeles, California, USA, formed in 1990. They emerged with a heavy metal sound on their first studio album, Undertow (1993), and later became a dominant act in the alternative metal movement, with the release of their second album, Ænima in 1996. Their efforts to unify musical experimentation, visual arts, and a message of personal evolution continued with Lateralus (2001), 10,000 Days (2006) and the most recent album, Fear Inoculum (2019).

[b][u]Line-up:[/u][/b]
Maynard James Keenan – vocals (1990–)
Adam Jones – guitar (1990–)
Danny Carey – drums, percussion (1990–)
Justin Chancellor – bass (1995–)

[u][b]Former Members:[/b][/u]
Paul D''Amour – bass (1990–1995)');
INSERT INTO artist (name, description) VALUES ('The Black Keys', 'American blues rock duo founded in 2001 in Akron, Ohio.');
INSERT INTO artist (name, description) VALUES ('Red Hot Chili Peppers', 'Funk/alternative rock band formed in 1983 in Los Angeles, California, United States.

[b]Current members:[/b]
Anthony Kiedis: Lead Vocals, Additional Guitar* (1983-present)
Michael "Flea" Balzary: Bass, Trumpet, Piano, Backing Vocals (1983-present)
Chad Smith: Drums, Percussion (1988-present)
John Frusciante: Lead Guitar, Keyboards, Backing Vocals (1988-92, 1998-2009, 2019-present)

* Live Only 1991-1998

[b]Former members:[/b]
Hillel Slovak: Guitar, Backing Vocals (1983, 1985-88)
Jack Irons: Drums, Percussion (1983, 1986-88)
Jack Sherman: Guitar, Backing Vocals (1983-85)
Cliff Martinez: Drums, Percussion, Backing Vocals (1984-86)
DeWayne McKnight: Lead Guitar, Backing Vocals (1988)
D.H. Peligro: Drums, Percussion (1988)
Arik Marshall: Lead Guitar, Backing Vocals (1992-93)
Jesse Tobias: Lead Guitar, Backing Vocals (1993)
Dave Navarro: Lead Guitar, Backing Vocals (1993-98)
Josh Klinghoffer: Lead Guitar, Keyboards, Six-String Bass, Organ, Percussion, Banjo, Backing Vocals (2009-2019)');
INSERT INTO artist (name, description) VALUES ('Wilco', 'American alternative rock band formed in 1994 and based in Chicago, Illinois. Wilco is a sextet formed by singer-songwriter and guitarist Jeff Tweedy. The band’s current lineup solidified in 2004 when guitarist Nels Cline and guitarist/keyboardist Patrick Sansone joined Tweedy, founding bassist John Stirratt, drummer Glenn Kotche and keyboardist Mikael Jorgensen. Wilco’s brand of classic roots rock incorporates folk, pop and genre-spanning experimentalism.

The band’s catalog includes 2002’s Yankee Hotel Foxtrot (named one of the 500 greatest albums of all time by Rolling Stone), 2005’s Grammy award-winning A Ghost is Born, the Grammy-nominated Wilco (The Album) and The Whole Love and more. NPR has called Wilco “the best rock band in America” and the band has been heralded by the Los Angeles Times as “an amazing machine whose six players seem more at one with their music than any rock group working today.” The Wilco catalog includes Mermaid Avenue Volumes 1, 2 and 3, which, in collaboration with British folk singer Billy Bragg, sets original music to song lyrics by the iconic Woody Guthrie.');
INSERT INTO artist (name, description) VALUES ('Metallica', 'Thrash Metal (Heavy Metal) band from Los Angeles, California (USA).

Metallica formed in 1981 by vocalist/guitarist [a251874] and drummer [a251550].  The duo first met through an ad in a Los Angeles-based music newspaper.  At the time, Ulrich had little musical experience and no band but managed to secure a slot on an upcoming compilation record called “[m=63482]”.   Metallica’s contribution, “Hit The Lights”, featured Hetfield, Ulrich and lead guitarist [a648330].  Afterwards, [a509874] became the band''s bassist and [a251808] joined the band as lead guitarist.  This line-up would re-record "Hit The Lights" for subsequent re-pressings of "Metal Massacre" and would also issue several demos.  In 1983, McGovney quit the group and was replaced by [a364982], which also saw the band relocate to San Francisco.  Metallica then traveled to New York after signing a deal with [l=Megaforce Records].  However, once in New York, the band fired Mustaine.  It would mark the beginning of a long feud between Mustaine and Metallica, mostly fueled by remarks Mustaine would make to the press.  Mustaine was replaced by Kirk Hammett of [a=Exodus (6)].

Metallica''s debut LP, "Kill ''Em All", was released in 1983.  It was followed in 1984 by "Ride The Lightning".  This led to a major label deal with [l=Elektra].  In 1986, the band released "Master Of Puppets", which is considered by many to be one of the greatest heavy metal records of all time.  In September of that year, while on tour in Sweden, the band was involved in a bus accident which took the life of Cliff Burton.  Eventually, [a390503] (of [a=Flotsam And Jetsam]) was hired as the band''s new bassist and he made his debut on 1987''s "Garage Days Re-Revisited", an EP of cover tunes.  The full-length "...And Justice For All" followed in 1988, featuring the track "One" which was chosen as the subject for their first promotional music video.

In 1990, Metallica hooked up with producer [a=Bob Rock] for a self-titled release that would become better known as "The Black Album", due to its cover art. Released in 1991, the black album would become one of the best-selling rock albums of all time, selling over 16 million copies in the US alone.

In 1996, the band experimented with Rock music style Alternative Rock, this could be heard on the album "Load".  The following year, "Reload" appeared which had the similiar formula as ''''Load''''. The albums continued the band’s trend of more accessible music.  In 1999, the group released an album and accompanying film called "S&M", which featured Metallica performing their songs with the San Francisco Symphony Orchestra.

In 2001, as the band was preparing to begin work on a new album, Newsted quit the group, citing personal and musical reasons.  Work on the new album was further complicated when Hetfield entered rehab for alcohol abuse.  The album, called "St. Anger", was eventually completed in 2003 with producer Bob Rock handling the bass.  Upon its release, "St. Anger" drew mostly negative reviews.  Following the recording, Robert Trujillo, formerly of [a=Suicidal Tendencies], was hired as bassist.  The making of the album was captured in the documentary “Some Kind Of Monster”.

In 2008, "Death Magnetic", produced by [a=Rick Rubin], would surface and was hailed by many as Metallica''s return to thrash metal.  The following year, Metallica was inducted into Rock And Roll Hall of Fame.  Former bassist Jason Newsted was present and Cliff Burton''s father appeared on Cliff''s behalf.  Dave Mustaine, who was not inducted, was invited to the ceremony by the band but declined to attend.  In 2011, Metallica collaborated with [a=Lou Reed] on the album, “Lulu”, which was largely panned by critics and ignored by consumers.');
INSERT INTO artist (name, description) VALUES ('Radiohead', 'Alternative Rock (Modern Rock) band from Oxfordshire, England (United Kingdom).

The name Radiohead comes from the [a=Talking Heads] song, "Radio Head", from the "[url=http://www.discogs.com/Talking-Heads-True-Stories/master/39386]True Stories[/url]" album. 

Formed by school friends in 1986, Radiohead did not release their first single until 1992''s "[r=767600]". The cathartic "[url=http://www.discogs.com/Radiohead-Creep/master/21481]Creep[/url]", from the debut album "[url=http://www.discogs.com/Radiohead-Pablo-Honey/master/13344]Pablo Honey[/url]" (1993), became a worldwide hit as grunge music dominated radio airwaves. 

Radiohead were initially branded as a one-hit wonder abroad, but caught on at home in the UK with their second album, "[url=http://www.discogs.com/Radiohead-The-Bends/master/17008]The Bends[/url]" (1995), earning fans with their dense guitar atmospheres and front man [a=Thom Yorke]''s expressive singing. The album featured the hits "[url=http://www.discogs.com/Radiohead-High-Dry-Planet-Telex/release/199387]High & Dry[/url]", "[r=1463625]" and "[url=http://www.discogs.com/Radiohead-Fake-Plastic-Trees/master/21526]Fake Plastic Trees[/url]". 

The band''s third album, "[url=http://www.discogs.com/Radiohead-OK-Computer/master/21491]OK Computer[/url]" (1997), propelled them to greater attention. Popular both for its expansive sound and themes of modern alienation, the album has been acclaimed by critics as a landmark record of the 1990''s, some critics go as far to consider it one of the best of all time. "[url=http://www.discogs.com/Radiohead-Kid-A/master/21501]Kid A[/url]" (2000) marked further evolution, containing influences from experimental electronic music.

"[url=http://www.discogs.com/Radiohead-Hail-To-The-Thief/master/16962]Hail To The Thief[/url]" (2003) was seen as a conventional return to the guitar and piano-led rock sound. After fulfilling their contract with EMI, Radiohead released "[url=http://www.discogs.com/Radiohead-In-Rainbows/master/21520]In Rainbows[/url]" (2007) famously via a pay-what-you-want model. Their latest album,  "[url=https://www.discogs.com/Radiohead-A-Moon-Shaped-Pool/master/998252]A Moon Shaped Pool[/url]", was released in May 2016.
 
Radiohead''s original influences were cited as alternative rock and post-punk bands like [url=http://www.discogs.com/artist/Smiths,+The]The Smiths[/url], [a=Pixies], [a=Magazine], [a=Joy Division], [a=Siouxsie & The Banshees], who Thom Yorke claims inspired him to become a performer, and [a=R.E.M.] (with lead singer of the band, Thom Yorke, refering to himself as an ''R.E.M. groupie'').');
INSERT INTO artist (name, description) VALUES ('System Of A Down', 'System of a Down, sometimes shortened to System and abbreviated as SOAD, is an Armenian-American heavy metal band from Glendale, California, formed in 1994. The band currently consists of Serj Tankian (lead vocals, keyboards), Daron Malakian (vocals, guitar), Shavo Odadjian (bass, backing vocals) and John Dolmayan (drums).

The band achieved commercial success with the release of five studio albums, three of which debuted at number one on the Billboard 200. System of a Down has been nominated for four Grammy Awards, and their song "B.Y.O.B." won the Best Hard Rock Performance of 2006. The group went on hiatus in August 2006 and came together again in November 2010, embarking on a tour for the following three years. System of a Down has sold over 40 million records worldwide, and two of their singles, "Aerials" and "Hypnotize", reached number one on Billboard''s Alternative Songs chart.');
INSERT INTO artist (name, description) VALUES ('AC/DC', 'Hard Rock band from Australia, formed in 1973 by Angus and Malcolm Young, they teamed up with Dave Evans (vocals), Larry Van Kriedt (bass) and Colin Burgess (drums).

In 1974 both Larry Van Kriedt and Colin Burgess left and were replaced by Rob Bailey (bass) and Peter Clack (drums), a further change in 1974 saw Peter Clack leave and Tony Currenti (drums) join the band. In June 1974 they were signed by Harry Vanda & George Young (Malcolm & Angus''s brother) to Albert Productions. In November 1974, Dave Evans left the band and was replaced by Bon Scott (vocals & bagpipes). Rob Bailey also left in 1974 and was replaced by George Young (bass). In 1975 Phil Rudd (drums) replaced Tony Currenti and Mark Evans (bass) replaced George Young.  In June 1977 Mark Evans left and is replaced by Cliff Williams (bass) for their first tour of the USA. On the 19 Feb 1980 Bon Scott died at the age of 33. Brian Johnson (ex Geordie) joined the band to replace him on vocals and the album "Back In Black" was released, a tribute to Bon Scott, this album became the 2nd largest selling album of all time with over 40 million copies sold worldwide. In May 1983, Phil Rudd had a parting of the ways and was replaced by Simon Wright (drums), aged 20 then. November 1989 Simon Wright left and is replaced by Chris Slade (ex Manfred Mann''s Earth Band, Uriah Heep & The Firm). In summer 1994 Phil Rudd "quietly" rejoined the band, but left again in 2015, which led to Slade''s return. Malcolm Young left AC/DC in 2014 for health reasons. Brian Johnson was forced to stop touring in April 2016 because of hearing issues. To complete the 2016 tour dates, Axl Rose was recruited as a guest singer. In September 2016 Cliff Williams retired from the group. In 2020 it was announced that the band had reunited with Brian Johnson, Phil Rudd and Cliff Williams.

AC/DC are Australia''s most successful rock band ever, and are popular around the world. The band was inducted into Rock And Roll Hall Of Fame in 2003 as a performer.

Current line-up:
Angus Young - Lead guitar (1973 - )
Phil Rudd - Drums (1974 - 1983, 1994 - 2015, 2020- )
Steve Young - Rhythm guitar (1988, 2014 - )
Cliff Williams - Bass (1977 - 2016, 2020 - )
Brian Johnson - Vocals (1980 - 2016, 2020 - )');
INSERT INTO artist (name, description) VALUES ('Linkin Park', 'Alternative/Modern Rock band from Agoura Hills, California.

Linkin Park are one of the most popular bands of the so called "nü-metal" movement, along with [a108722], [a18837] and several others. Their sound is a wide range of influences, including metal, alternate rock, hip-hop, electronica and industrial. Linkin Park''s debut album "[m=74519]" was a multi-platinum smash worldwide, selling over 30 million copies, 12 million of them in the US alone. [m=61489] is the correspondent remix album.

Formed as [a1118966] in the winter of 1995/96, the band was renamed to Hybrid Theory in 1999. They were signed as a developing artist to [l1000] in late 1999, but the label advised them to change their name to avoid confusion with [a5513], a popular House music group.

Looking for a new name, Hybrid Theory briefly considered "Lotus Foundation Project" and "Plear", before settling on "[a40029]" in May 2000. This name was suggested by [a241527] after seeing a street sign for the park named "Lincoln Park" in Los Angeles. The spelling was changed to "Linkin Park" to acquire the internet domain "linkinpark.com".

Frontman Chester Bennington died from suicide on July 20, 2017.');
INSERT INTO artist (name, description) VALUES ('David Bowie', 'British pop/rock singer, musician, songwriter, and actor.

Born: 8 January 1947 in Brixton, London, England, UK.
Died: 10 January 2016 in Manhattan, New York City, USA (aged 69).

Bowie is recognized as one of the most respected contemporary musicians of his period. He was a leading figure in the music industry and is considered one of the most influential musicians of the 20th century.
Inducted into Rock And Roll Hall of Fame in 1996.

For a list of all band and group involvement, please see [b][a1240431][/b].');
INSERT INTO artist (name, description) VALUES ('Audioslave', 'Alternative Rock (Modern Rock) band from Los Angeles, California (USA).

Audioslave formed in in 2001 and disbanded in 2007. The four-piece band consisted of then-former Soundgarden lead singer/rhythm guitarist [a=Chris Cornell], and then-former [a=Rage Against the Machine] members [a=Tom Morello] (lead guitar), [a=Tim Commerford] (bass/backing vocals) and [a=Brad Wilk] (drums).');
INSERT INTO artist (name, description) VALUES ('Coldplay', 'Coldplay is an English rock band from London, England. They''ve been a band since January 16, 1998 when they lost a demotape competition on XFM in London. Philip Christopher Harvey is the band''s manager.

[b][u]Line-up:[/u][/b]
Jonny Buckland (Jonathan Mark Buckland) - Guitar
Will Champion (William Champion) - Drums
Guy Berryman (Guy Rupert Berryman) - Bass
Chris Martin (Christopher Anthony John Martin) - Vocals');
INSERT INTO artist (name, description) VALUES ('The Offspring', 'American punk rock band from Garden Grove, California, formed in 1984. Originally called Manic Subsidal, they began performing in 1984, composed of Bryan Holland (vocals, guitar), Greg Kriesel (bass, vocals) and James Frederick Lilja (drums). Changed their name to The Offspring in 1986.

Bryan "Dexter" Holland : Vocals, guitar
Kevin "Noodles" Wasserman : Guitar, vocals
Todd Morse: Bass
Pete Parada : Drums
Gregory "Greg K" Kriesel : Bass, vocals (1984–2018)
James Lilja: Drums (1984-1987)
Ron Welty : Drums, vocals (1987-2003)
Adam "Atom" Willard: Drums (2003-2007)');
INSERT INTO artist (name, description) VALUES ('Nirvana', 'Rock band from Aberdeen, Washington, USA, formed in 1987. Emerging from the Seattle grunge scene of the late 1980s/early 1990s, Nirvana was a power trio of musicians who brought a new aesthetic to the rock scene of the time. They had already released their debut LP "[m=13773]" with Sub Pop, but their 1991 major-label debut for [l=DGC]/[l=Geffen Records], "[m=13814]" broke the band and grunge into the mainstream of America. Singer/guitarist [a=Kurt Cobain]''s death by suicide in April 1994 brought the band to an end.

The band''s names in a chronological order:
[b][a=Skid Row (6)][/b] (start (1987) - June 27, 1987)
[b]Pen Cap Chew[/b] (June 27, 1987 - August 9, 1987)
[b][a=Bliss (108)][/b] (August 9, 1987 - January 1988)
[b][a=Ted Ed Fred][/b] (January 1988 - March 19, 1988)
[b][a=Nirvana][/b] (March 19, 1988 - end)

There were two other short-used band names before Nirvana: [b]Throat Oyster[/b] and [b]Windowpane[/b]');
INSERT INTO artist (name, description) VALUES ('Pearl Jam', 'Alternative Rock (Modern Rock) band from Seattle, Washington (USA). Inducted to the Rock and Roll Hall of Fame in 2017.

Formed from the ashes of Jeff and Stone''s previous band [a=Mother Love Bone] and the [a=Temple of the Dog] tribute project (featuring [a262214] on a number of tracks), Pearl Jam were catapulted straight to international superstardom with the release of the album "Ten" and the single ''Alive''. One of the Seattle grunge scene a-list bands, their star faded considerably when that scene fell out of fashion. 

This appears to have suited the band fine as they''ve continued to record increasingly experimental music with their line-up almost intact (they have had a number of drummers over the years - [a712166], [a518880], [a365506] and, now, the drummer who played on their original demos and with Temple of the Dog - [a284484], who also plays drums for [a=Soundgarden]. In 1995, they played as the backing band on [a=Neil Young]''s "[m=38666]" album and the subsequent tour.

Among the band members'' many side projects over the years are [a=Brad] ([a377057]); [a=Mad Season] & [a888052] ([a275980]); [a=Three Fish] & [a2990495] ([a377056]); [a=The Wellwater Conspiracy] ([a284484]).

Fan club:
-[l64797] (label entry).
-[a6976748] (artist entry).');
INSERT INTO artist (name, description) VALUES ('The XX', '[b]The xx[/b] [i](constantly credited with lower case "xx")[/i] are an English indie pop band from Wandsworth, London, formed in 2005.

[a1567403] - vocals, guitar
[a1541944] - vocals, bass
[a1545576] - beats, production, keyboards

On November 11, 2009 it was officially announced that [a1541942] (guitar, keyboard) was no longer part of the band citing exhaustion and personal differences.
');
INSERT INTO artist (name, description) VALUES ('Various Production', '');
INSERT INTO artist (name, description) VALUES ('Alanis Morissette', 'Canadian singer born on June 1, 1974 in Ottawa, Ontario, Canada. She has two brothers, older brother [a3451660] and twin brother [a3451661]. She is married to [a2899545] (aka [a837800]).

Previously worked as an envelope stuffer.');
INSERT INTO artist (name, description) VALUES ('R.E.M.', 'R.E.M. was an American rock band from Athens, Georgia, formed in 1980 by singer Michael Stipe, guitarist Peter Buck, bassist Mike Mills, and drummer Bill Berry. One of the first popular alternative rock bands, R.E.M. gained early attention due to Buck''s ringing, arpeggiated guitar style and Stipe''s unclear vocals. R.E.M. released its first single, "Radio Free Europe", in 1981 on the independent record label Hib-Tone. The single was followed by the Chronic Town EP in 1982, the band''s first release on I.R.S. Records. In 1983, the group released its critically acclaimed debut album, Murmur, and built its reputation over the next few years through subsequent releases, constant touring, and the support of college radio. Following years of underground success, R.E.M. achieved a mainstream hit in 1987 with the single "The One I Love". The group signed to Warner Bros. Records in 1988, and began to espouse political and environmental concerns while playing large arenas worldwide.

By the early 1990s, when alternative rock began to experience broad mainstream success, R.E.M. was viewed by subsequent acts such as Nirvana and Pavement as a pioneer of the genre and released its two most commercially successful albums, Out of Time (1991) and Automatic for the People (1992), which veered from the band''s established sound. R.E.M.''s 1994 release, Monster, was a digression into a more rock-oriented sound. The band began its first tour in six years to support the album; the tour was marred by medical emergencies suffered by three band members. In 1996, R.E.M. re-signed with Warner Bros. for a reported US $80 million, at the time the most expensive recording contract in history. The following year, Bill Berry left the band, while Buck, Mills, and Stipe continued the group as a trio. Through some changes in musical style, the band continued its career into the next decade with mixed critical and commercial success. In 2007, the band was inducted into the Rock and Roll Hall of Fame. R.E.M. disbanded in September 2011, announcing the split on its website.');
INSERT INTO artist (name, description) VALUES ('Daft Punk', 'Daft Punk were a French electronic music duo formed in 1993 by [a=Thomas Bangalter] (born January 3, 1975) and [a=Guy-Manuel de Homem-Christo] (born February 8, 1974). Bangalter and de Homem-Christo were previously in the rock band [a=Darlin''] with [a=Laurent Brancowitz]. After Brancowitz left the group to join his brother''s band, [a=Phoenix], the remaining duo formed Daft Punk. On February 22, 2021, it was announced that they had disbanded for unknown reasons.');
INSERT INTO artist (name, description) VALUES ('Madonna', 'American singer, entertainer, songwriter, actress, producer, director and businesswoman. Born August 16, 1958 in Bay City, Michigan. After performing in the music groups [a=Breakfast Club] and [url=http://www.discogs.com/artist/Emmy+(7)]Emmy[/url], she signed with [l27031] in 1982 and released her debut album, [i][m=5319][/i], the following year. She followed it with a series of commercially successful albums, has sold more than 300 million records worldwide and is recognized as the best-selling female recording artist of all time by Guinness World Records.

Madonna was inducted into the Rock and Roll Hall of Fame in her first year of eligibility. She was ranked at number one on VH1''s list of 100 Greatest Women in Music, and at number two on Billboard''s list of Greatest Hot 100 Artists of All Time (behind only The Beatles), the latter making her the most successful solo artist in the history of American singles chart.');
INSERT INTO artist (name, description) VALUES ('Led Zeppelin', 'Led Zeppelin formed out of the ashes of [url=http://www.discogs.com/artist/262455-Yardbirds-The]The Yardbirds[/url]. [a180585] had joined the band in its final days, playing a pivotal role on the group''s final album, 1967''s [m=86344], which also featured string arrangements from [a60149]. During 1967, the Yardbirds were fairly inactive.  Whilst the band members decided the group''s future, Page returned to session work in 1967. In the spring of 1968, he played on Jones'' arrangement of [a=Donovan]''s "Hurdy Gurdy Man." During the sessions, Jones requested to be part of any future project Page would develop. Page would have to assemble a band sooner than he had planned. In the summer of 1968, the Yardbirds'' [a=Keith Relf] and [a=Jim McCarty] left, leaving Page and bassist [a=Chris Dreja] with the rights to the name, as well as the obligation of fulfilling an upcoming fall tour. Page set out to find a replacement vocalist and drummer. Initially, he wanted to enlist singer Terry Reid and Procol Harum''s drummer B.J. Wilson, but neither musician was able to join the group. Reid suggested that Page contact Robert Plant, who was singing with a band called Hobbstweedle.

Inducted into Rock And Roll Hall of Fame in 1995 (Performer).');
INSERT INTO artist (name, description) VALUES ('Dream Theater', 'American progressive metal band, formed in Boston, Massachusetts, USA in 1985.');
INSERT INTO artist (name, description) VALUES ('The White Stripes', 'Bluesy garage rock band from Detroit, Michigan (USA).

The band comprising the bass-free duo of [a278763] [vocals, guitar, keyboards] and [a367269] [drums, percussion]. The Whites, once married and divorced in March 2000, formed their lo-fi garage band in 1997. They officially ceased to perform in Feb 2011.

Previously the guitarist in garage band [a=The Go], Jack White''s musical output in this fused twosome was heavily laced with folk blues, country, 60s Britpop and Broadway show tunes. Dressed in minimalist red and white outfits, the Stripes'' striking stage presence was allied to their undeniable grasp of the rudiments of timeless rock music. Their debut was the 1997 single "Let''s Shake Hands", followed by "Lafayette Blues" [[l105510]]. They then moved to the label [l13828] and began to receive acclaim for their act and eponymous [url=http://www.discogs.com/White-Stripes-The-White-Stripes/master/10338]1st album[/url], mixing astute cover versions ([a=Robert Johnson]''s "Stop Breaking Down Blues" and [a=Josh White]''s "St. James Infirmary") with some devastating originals.

By the time of the following year''s [url=http://www.discogs.com/White-Stripes-De-Stijl/master/399]De Stijl[/url] [The Style], the media buzz surrounding the White Stripes had reached new heights. Of particular note was the duo''s reception in the UK, where their music was lauded in national media, including [i]The Daily Telegraph, The Sun[/i] and even Radio 4''s [i]Today[/i] programme - not normally known for its liberal music policy. The influential John Peel was quoted as comparing their importance to that of Jimi Hendrix and the Sex Pistols - although both those acts were originators, whereas the Whites clearly powerful interpreters. They certainly dispelled any question of hype, upon release of a third album, "[url=http://www.discogs.com/White-Stripes-White-Blood-Cells/master/10332]White Blood Cells[/url]", followed by "[url=http://www.discogs.com/White-Stripes-Elephant/master/10341]Elephant[/url]" in 2003. The latter recorded at London''s tiny Toe Rag Studios, using pre-60s analogue equipment and only eight tracks. Produced by Jack White, the highly-successful album offered a contrast to the digital conformity of music emerging in the new millennium, reaching the top-ten in the US & going platinum in the UK.
');
INSERT INTO artist (name, description) VALUES ('The Chemical Brothers', 'Tom & Ed met in history class at Manchester University in 1989. They started off as DJs known as "The 237 Turbo Nutters" (named after the number of their house on Dickenson Road in Manchester and a reference to their Blackburn raving days). They then opted for "The Dust Brothers" which they nicked from the L.A. producers of "Pauls Boutique" (as they thought they would never be famous). In 1995 they changed their name to "The Chemical Brothers" after the real Dust Brothers threatened to sue.');
INSERT INTO artist (name, description) VALUES ('Rage Against The Machine', 'Alternative Rock / Modern Rock band formed in 1991 in Los Angeles, California (often abbreviated as RATM, R.A.T.M. or shortened to Rage). They are noted for their blend of hip hop, heavy metal, punk and funk as well as their revolutionary politics and lyrics. They split up in October 2000 after Zack de la Rocha decided to leave the band for a solo career, the rest of the members of the band joined [a=Audioslave] (formed by [a=Soundgarden]''s frontman [a=Chris Cornell]). After seven years of absence, Rage Against the Machine reunited in 2007 for a number of shows. In 2017, the band members other than Zack de la Rocha formed the supergroup Prophets of Rage with Public Enemy''s Chuck D and DJ Lord and Cypress Hill''s B-Real. After the announcement of RATM''s return in 2019, Prophets of Rage disbanded.');
INSERT INTO artist (name, description) VALUES ('Massive Attack', 'Collaborative British music production group from Bristol, England.

The band currently consists of Robert Del Naja, Tricky, and Daddy G. The original lineup also included Andrew Vowles. The group name is taken from a slogan sprayed by New York graffiti artist ''[url=https://www.discogs.com/artist/1894642-Brim-2]Brim[/url]'', who sprayed ''Massive Attack'' underneath a ''piece'' in Bristol, UK in 1985. ''[url=https://www.discogs.com/artist/1894642-Brim-2]Brim[/url]'', along with ''Balogun'' and ''[url=https://www.discogs.com/artist/5007984-Bio-14]Bio[/url]'' were part of the TATS CRU from NYC who sprayed a ''piece'' each together at the Malcolm X Centre, St. Paul''s in Bristol.  [a151718], who was an upcoming graffiti artist at the time, with the tag 3-D, has stated that he/they had adopted the slogan initially as a name for a record label, and then later took it on as a band name. During the 1991 Gulf War the group name was shown on some releases as ''Massive'' in order to maintain airplay after pressure from the British Government on radio programmers. ');
INSERT INTO artist (name, description) VALUES ('Franz Ferdinand', 'Franz Ferdinand are a band formed in Glasgow in 2002. The name of the band was originally inspired by a racehorse called Archduke Ferdinand. After seeing the horse win the Northumberland Plate in 2001, the band began to discuss Archduke Franz Ferdinand and thought it would be a good band name because of the alliteration of the name and the implications of the Archduke''s death (his assassination was a significant factor in the lead up to World War I).');
INSERT INTO artist (name, description) VALUES ('Korn', 'Nu-Metal (Modern Rock) band from Bakersfield, California (USA).

Korn [stylized as "KoЯn"] is a Grammy Award winning Metal band that are often credited with creating and popularizing the nu metal genre.
The band formed after the group [a=L.A.P.D. (4)] folded. L.A.P.D. constisted of [a=Reginald Arvizu], [a=James Shaffer], and [a=David Silveria] and singer [a=Richard Morill]. Morill left because of drug addictions and the remaining 3 members along with [a=Brian Welch], who was a close friend of the band began searching for a new singer. They found that singer in 1993 when seeing the frontman of the band “[a=Sex Art]”, [a=Jonathan Davis], perform. Davis joined the band and the band was renamed Creep and shortly after “Korn”.

In 1993 they released their first demo “Neidermeyer''s Mind” with producer [a=Ross Robinson], who would eventually also produce the first 2 albums. The song “[Blind]” had become a trademark in the Korn performances. The song (which was released on their first demo and first album) was originally written by [a=Dennis Shinn] with [a=Sex Art], but was re-produced by Korn. Whereas Korn kept the original music and vocals / lyrics as written by Shinn. Korn''s reproduction acted as a final polish of the song. "[Daddy]" was also a song from Sex Art, titled "Follow Me". Korn had remade that song, by replacing the music entirely, but keeping the vocal melodies & original lyrics. The lyrics were also written by Dennis Shinn, but Jonathan Davis added in a new chorus once the song was revised by Korn. 

Musically, Korn tracks mix both heavy metal and hip-hop. Korn toured incessantly to promote their first album. With no radio play or MTV, they relied solely on their intensive live shows which created a large cult following of dedicated fans.

Three of the band members are often credited by their nicknames. "Head" (Welch), "Fieldy" (Arvizu) and "Munky" (Shaffer).

Korn had a constant formation for 12 years until 2005, when guitarist Welch left Korn after his decision to rededicate his life to Jesus Christ and his daughter. In 2006 drummer Silveria would follow, stating he stept out of the band to further pursue his entrepreneurial ventures and to be with his family. Korn went on as a 3-piece and had a back-up band for touring until 2009. In 2009 drummer [a=Ray Luzier] became the first new member of Korn since it’s formation in 1993, after being in the back-up band for a while. In may 2013 Welch rejoined Korn. 

In 2011 Korn released an experimental album “The Path Of Totality” mixing metal with dubstep. This album has won them the “Revolver Golden Gods Awards” award for best album of the year. 

[b]Members:[/b]
[a=Jonathan Davis] (1993-present)
[a=James Shaffer] (1993-present)
[a=Reginald Arvizu] (1993-present)
[a=David Silveria] (1993-2006)
[a=Brian Welch] (1993-2005, 2012-present)
[a=Ray Luzier] (2009-present)

[b]Fanclub:[/b] [a7428401]');
INSERT INTO artist (name, description) VALUES ('Nick Cave & The Bad Seeds', 'An alternative/art rock band formed in 1983 in Melbourne, Australia. The group has had an international line-up throughout their career.

Current line-up:
Nick Cave: vocals, piano, organ (1983–present)
Thomas Wydler: drums, percussion (1985–present)
Martyn P. Casey: bass (1990–present)
Jim Sclavunos: percussion, drums (1994–present)
Warren Ellis: violin, accordion, mandolin (1997–present)
George Vjestica: guitar (2013–present)');
INSERT INTO artist (name, description) VALUES ('Kanye West', 'Ye (born Kanye Omari West on June 8, 1977) is an American rapper, singer, songwriter, record producer, and fashion designer. His musical career has been marked by dramatic change, spanning an eclectic range of influences. Outside of his music career, West has also had success in the fashion industry.');
INSERT INTO artist (name, description) VALUES ('Sigur Rós', 'Icelandic post-rock band from Reykjavík. Known for their ethereal sound, frontman Jónsi''s falsetto vocals, and the use of bowed guitar, the band''s music is also noticeable for its incorporation of classical and minimalist aesthetic elements. The name "Sigur Rós" is Icelandic for "Victory Rose". The band is named after Jónsi''s newborn sister Sigurrós Elín. 
Jón Þór "Jónsi" Birgisson (guitar and vocals), Georg Holm (bass) and Ágúst Ævar Gunnarsson (drums) formed the group in Reykjavík in January 1994. Ágúst Ævar Gunnarsson retired after the release of the second album to be replaced by Orri Páll Dýrason. The band was joined by Kjartan Sveinsson on keyboards in 1998. Kjartan Sveinsson left the band in 2013. Orri Páll Dýrason left the band in 2018 facing allegations of sexual assult writing “I cannot have these serious allegations influence the band and the important and beautiful work that has been done there for the last years.”
Line-up (As of Oct. 2018): Jón Þór Birgisson (guitar, vocals), Georg Holm (bass guitar), Kjartan Sveinsson (keyboards, rejoined Feb 2022)

');
INSERT INTO artist (name, description) VALUES ('Bring Me The Horizon', 'Metalcore band from Sheffield, Yorkshire, UK, formed in 2004.
The style of their early work, including their debut album "[m=345402]", has been described as deathcore, but the band started to adopt a more eclectic style of metalcore on subsequent albums. Their 2015 album "[m=883261]" marked a shift in their sound to less aggressive rock music styles, including electronic rock and nu metal. This was a conscious decision made by the band in a boost change their direction and appeal.

Lineup:
Oliver "Oli" Sykes - vocals (2004-present)
Matt "Vegan" Keen - bass (2004-present)
Matt Nicholls - drums (2004-present)
Lee Mahlia - guitar (2004 -present)
Jordan Fish - keyboards, drum pad, percussion, backing vocals (2012-present)

Former members:
Curtis Ward - rhythm guitar (2004-2009)
Jona Weinhofen - rhythm guitar, backing vocals (2009-2013)');
INSERT INTO artist (name, description) VALUES ('Iron Maiden', 'Iron Maiden are an English heavy metal band formed in Leyton, East London, in 1975 by bassist and primary songwriter [a=Steve Harris]. Pioneers of the New Wave of British Heavy Metal movement, Iron Maiden achieved initial success during the early 1980s. After several line-up changes, the band went on to release a series of UK and US platinum and gold albums, including 1982''s The Number of the Beast, 1983''s Piece of Mind, 1984''s Powerslave, 1985''s live release Live After Death, 1986''s Somewhere in Time and 1988''s Seventh Son of a Seventh Son. Since the return of lead vocalist [a=Bruce Dickinson] and guitarist Adrian Smith in 1999, the band has undergone a massive resurgence in popularity, with their 2010 studio offering, The Final Frontier, peaking at No. 1 in 28 countries and receiving widespread critical acclaim. Their sixteenth studio album, The Book of Souls, was released on 4 September 2015 and has been peaking at No. 1 in 45 countries including digital charts.

Despite little radio or television support, Iron Maiden are considered one of the most influential and successful heavy metal bands in history, with The Sunday Times reporting in 2017 that the band have sold over 100 million copies of their albums worldwide. Their releases were nearby 600 times certified silver, gold, platinum worldwide. The band won multiple music awards including (among many others) Brit Awards, Grammy Awards, Emma-Gaala Awards, BPI Awards, Echo Awards, Juno Awards, Silver Cleaf, the Ivor Novello Award for international achievement in 2002. As of October 2013, the band have played over 2000 live shows throughout their career. For 40 years the band have been supported by their famous mascot, "Eddie", who has appeared on almost all of their album and single covers, as well as in their live shows.
Band Members:

[b]Vocals[/b]
[a=Paul Mario Day] (1975-1976)
[a=Dennis Willcock] (1976-1977)
[a=Paul Di''Anno] (1978-1981)
[a=Bruce Dickinson] (1981-1993 and 1999-present)
[a=Blaze Bayley] (1994-1998)

[b]Guitar[/b]
[a=Terry Rance] (1975-1976)
Dave Sullivan (1975-1976)
[a=Dave Murray ] (1976-1977 and 1978-present)
[a=Bob Sawyer (3)] (1977)
[a=Terry Wapram] (1977-1978)
[a=Paul Cairns ] (1978-1979)
[a=Paul Todd] (1979)
[a=Tony Parsons (3)] (1979)
[a=Dennis Stratton] (1979-1980)
[a=Adrian Smith ] (1980-1990 and 1999-present)
[a=Janick Gers] (1990-present)

[b]Bass[/b]
[a=Steve Harris] (1975-present)

[b]Drums[/b]
[a=Ron "Rebel" Matthews] (1975-1977)
Barry "[a=Thunderstick]" Purkis (1977)
[a=Doug Sampson] (1977-1979)
[a=Clive Burr] (1980-1982)
[a=Nicko McBrain] (1982-present)

[b]Keyboards[/b] 
[a=Tony Hustings-Moore] (1977)
[a=Michael Kenney] (1986-present) (Live performances only, not a full member)');
INSERT INTO artist (name, description) VALUES ('AIR', 'Air is a French electronic / rock duo composed by Jean-Benoît Dunckel and Nicolas Godin, active since 1995. 

"AIR" is an acronym for Amour, Imagination, Rêve (Love, Imagination, Dream).');
INSERT INTO artist (name, description) VALUES ('Arctic Monkeys', 'Indie/Rock band formed in 2002 in High Green, a suburb of Sheffield, South Yorkshire, UK.

Members: Alex Turner (guitar, vocals) Jamie Cook (guitar), Nick O''Malley (bass), Matt Helders (drums)

Former Member: Andy Nicholson (bass)
');
INSERT INTO artist (name, description) VALUES ('Sturgill Simpson', 'Formerly the leader of Sunday Valley, an energetic roots outfit that made some waves in the early years of the new millennium, Sturgill Simpson gained greater renown as a solo artist, thanks in large part to his muscular 2013 solo debut High Top Mountain. An outlaw country record in form and feel -- its debt to Waylon Jennings clear and unashamed -- High Top Mountain became a word-of-mouth hit in 2013, thereby establishing Simpson''s country credentials and opening the door to a wider future.

A native of Jackson, Kentucky and raised near Lexington, Simpson has deep southern roots, but he moved out west once he reached his late teens. In 2004, he formed Sunday Valley, receiving a big break when they played Portland, Oregon''s Pickathon Festival in 2011. Sturgill went solo in 2012, beginning work on the album that became High Top Mountain, which appeared the following year.');
INSERT INTO artist (name, description) VALUES ('Jamiroquai', 'UK based pop-funk/acid jazz band formed in 1992: [a100145] (vocals), [a143547] (drums), [a495721] (percussion), [a450342] (guitar), [a946453] (keyboards), [a145090] (bass), Nate Williams (Keyboard, Guitar, Backing Vocals), [a5954] (Backing Vocals), Elle Cato (Backing Vocals), [a379830] (Backing Vocals), Howard Whiddett (Ableton Live).

Former "main" members: [a103646] (1992-2002), [a495722] (1992-2000), [a61169] (1992-1994), [a55734] (1993-1998), [a470636] (1995-2000), [a456973] (1998-2003).');
INSERT INTO artist (name, description) VALUES ('The Strokes', 'The Strokes are an American rock band from New York City. Formed in 1998, the band is composed of singer Julian Casablancas, guitarists Nick Valensi and Albert Hammond Jr., bassist Nikolai Fraiture, and drummer Fabrizio Moretti. Following the conclusion of five-album deals with RCA and Rough Trade, the band has continued to release new music through Casablancas'' Cult Records.

The band''s debut album, Is This It (2001), was met with widespread critical acclaim and helped usher in the garage rock revival movement of the early 21st century; it was ranked No. 8 on Rolling Stone''s 100 "Best Debut Albums of All Time", No. 2 on Rolling Stone''s "100 Best Albums of the ''00s", No. 199 on Rolling Stone''s "500 Greatest Albums of All Time", and No. 4 on NME''s "Top 500 Albums of All Time".');
INSERT INTO artist (name, description) VALUES ('New Order', 'Formed 1980 in Manchester, United Kingdom shortly after the suicide of [a=Ian Curtis] ([a=Joy Division], [url=http://www.discogs.com/artist/Warsaw+(3)]Warsaw[/url])
Members: [a=Bernard Sumner] (vocals, guitar, keyboards), [a=Peter Hook] (bass, keyboards, 1980–2010), [a=Stephen Morris] (drums, keyboards), [a=Gillian Gilbert] (keyboards, guitar, 1981–2001, 2011–present), [a=Phil Cunningham] (guitar, keyboards, 2001–present), [a=Tom Chapman ] (bass, 2011–present).');
INSERT INTO artist (name, description) VALUES ('Aphex Twin', 'UK electronic musician. 

Born: 18 August 1971 in Limerick, County Limerick, Ireland. 

Grammy Award winning composer, in 1991 he co-founded the [l=Rephlex] label with [a953996]. After having released a number of albums and EPs on Rephlex, [l=Warp Records], and other labels under many aliases, he gained more and more success from the mid-1990s with releases such as  "[m=27457]" (1997), #36 on UK charts, and "[m=532]" (1999), #16 on UK charts. 

The two classic Aphex Twin logos were designed in 1991-1992 by [a2252378]. 
');
INSERT INTO artist (name, description) VALUES ('Green Day', 'Green Day is a pop punk/alternative rock band from East Bay, California that formed in 1987. They were originally called Sweet Children, but changed their name before their first release.

Current lineup 
lead vocals, guitars : [a=Billie Joe Armstrong]
bass guitar, backing vocals : Mike Dirnt ([a=Michael Pritchard])
drums, percussion : Tré Cool ([a=Frank E. Wright] III)

Former member:
Drums: [a=John Kiffmeyer] alias [a=Al Sobrante] until 1990.');
INSERT INTO artist (name, description) VALUES ('The Prodigy', 'British electronic group, founded in 1990. Their first release was "What Evil Lurks" EP (1991). Their early music was mostly rave/breakbeat, but has become more mainstream mixing in rock guitars with the third album "The Fat Of The Land" (1997).

Band members:
[a=Liam Howlett] - head of the group, keyboards, synthesizers, programming, laptop, computer, samples, sequencers, turntables, drum machines (1990-present)
[a=Maxim] - MC, beatboxing, vocals (1991-present)

Former members:
[a=Keith Flint] - dancing (1990-2019); lead vocals (1995-2019)
[a=Leeroy Thornhill] - dancing (1990-2000); occasional live keyboards, synthesizers (1994-2000)
Sharky - dancing (1990-1991)

The original Prodigy line-up was Liam on keyboards and Leeroy, Keith and Sharky as dancers, formed in late 1990 (The Prodigy officially name the date October 5, 1990). Maxim was recruited at short notice to MC at their debut gig at Labrynth in Dalston, London in February 1991. Sharky left the group at Christmas 1990 after they got their record deal with XL as she didn''t want to devote more time to the band. Their initial deal with XL was for 4 singles, with XL paying a £1500 advance prior to the first single.
Liam Howlett briefly used the pseudonym [a=Earthbound (6)] (named after Liam''s studio) for the original white-label summer releases of "One Love" (1993).
[a=Leeroy Thornhill] left the band in 2000. 
Keith Flint died by suicide on 4 March 2019.');
INSERT INTO artist (name, description) VALUES ('Shellac', 'Shellac are an indie rock band from Chicago, IL, USA.  The group was formed in 1992 by vocalist/guitarist Steve Albini and drummer Todd Trainer.  Former [a=Naked Raygun] bassist Camilo Gonzalez sat in on the band''s first few rehearsals and recorded one song ("Rambler Song") with them before Bob Weston joined to permanently fill the bass position.  

Shellac records and performs infrequently due to their geographic separation (both Albini and Weston live in Chicago while Trainer lives in Minnesota) and the fact that all the members have day jobs (both Albini and Weston are recording engineers while Trainer has managed a warehouse and tended bar).  Trainer has also released solo albums under the name [a=Brick Layer Cake] and Weston works with [a=Mission Of Burma].
');
INSERT INTO artist (name, description) VALUES ('Neil Young', 'Neil Young is a Canadian-American singer-songwriter and a musician who plays guitar, keyboards and harmonica. He also runs [l=Vapor Records] and is active on environmental and political issues. Young is famous for his solo releases, his releases with [a268789] and for being a member of [a285408] (aka CSNY). Born November 12, 1945 in Toronto, Ontario, Canada, he currently holds dual citizenship for Canada and the United States and has been living in California since the sixties. He was inducted into the Rock And Roll Hall of Fame in 1995 (Performer category). Young had announced in 2019 that his application for United States citizenship had been held up because of his use of marijuana, but the issue was resolved and he did become a United States citizen.');
INSERT INTO artist (name, description) VALUES ('Jamie XX', 'English producer and remix artist. Member of [a1416238].');
INSERT INTO artist (name, description) VALUES ('Dan Auerbach', 'American musician and record producer, born 14 May 1979 in Akron, Ohio, USA. Son of [a=Chuck Auerbach]. Best known as guitarist and vocalist with [a=The Black Keys].');
INSERT INTO artist (name, description) VALUES ('Pantera', 'Groove metal (originally glam metal) band from Arlington, Texas, USA.

Pantera was formed in 1981 by brothers - Vincent Paul Abbott (Vinnie Paul, drums) and Darrell Lance Abbott (Diamond "Dimebag" Darrell, guitar) with Terry Glaze (rhythm guitar), Donny Hart (vocals) and Tommy D. Bradford (bass).

Donny Hart left in 1982 (for the first time), and Terry Glaze abandoned his guitar and became a full-time singer. Later in 1982 Tommy D. Bradford left as well, being replaced by Rex Brown.

In early 1986 Terry Glaze left, and first was replaced by Matt L''Amour on vocals in winter 1986, later by Rick Mythiasin, and later by David Peacock who was the band''s vocalist from late spring 1986 to October 1986.

Later David Peacock left and was replaced again by the band''s original vocalist Donny Hart, who left in late 1986 and was replaced by Phil Anselmo.

Pantera released 4 albums in the 80''s (the last one, "Power Metal" from 1988 features new vocalist, Phil Anselmo). Their early work did not achieve commercial success. In 1990 Pantera released their commercial debut album "Cowboys from Hell". Pantera would go on to release two extremely successful albums; "Vulgar Display of Power" and "Far Beyond Driven". In 2003, three years after Pantera''s last studio album, "Reinventing the Steel", the band split up after troubles with vocalist Phil Anselmo committing to the band - officially split on November 24, 2003.

On December 8th 2004, Dimebag Darrell was shot and killed onstage while performing with [a=Damageplan] at the Alrosa Villa in Columbus, Ohio by Nathan Gale, a schizophrenic former US Marine.

Vinnie Paul Abbott passed away on June 22th 2018.

In July 2022 Pantera''s surviving members Rex Brown and Phil Anselmo (while not being founding members) announced a reunion tour in 2023 - with session/touring musicians being Zakk Wylde (guitars) and Charlie Benante (drums).

Current members:
Rex Brown - bass, backing vocals (1982-2003, 2022-present)
Phil Anselmo - lead vocals (1986-2003, 2022-present)

Former members:
Dimebag Darrell - lead guitar, backing vocals (1981-2003), rhythm guitar (1982-2003) (died 2004)
Vinnie Paul - drums (1981-2003) (died 2018)
Terry Glaze - rhythm guitar (1981-1982), lead vocals (1982-1986)
Donny Hart - lead vocals (1981-1982, 1986)
Tommy Bradford - bass, backing vocals (1981-1982)
Matt L''Amour - lead vocals (1986)
Rick Mythiasin - lead vocals (1986)
David Peacock - lead vocals (1986)

Session / touring members:
Zakk Wylde - guitar (2022-present)
Charlie Benante - drums (2022-present)');
INSERT INTO artist (name, description) VALUES ('Nine Inch Nails', 'Industrial rock band Nine Inch Nails (abbreviated as NIN and stylized as NIИ) was formed in 1988 by [a27457] in Cleveland, Ohio. Reznor has served as the main producer, singer, songwriter, instrumentalist, and sole member of Nine Inch Nails for 28 years. This changed in December 2016 when [a259284] officially became the second member of the band. Nine Inch Nails straddles a wide range of many styles of rock music and other genres that require an electronic sound, which can often cause drastic changes in sound from album to album. However NIN albums in general have many identifiable characteristics in common, such as recurring leitmotifs, chromatic melodies, dissonance, terraced dynamics and common lyrical themes. Nine Inch Nails is most famously known for the melding of industrial elements with pop sensibilities in their first albums. This move was considered instrumental in bringing the industrial genre as a whole into the mainstream, although genre purists and Trent Reznor alike have refused to identify NIN as an industrial band.');
INSERT INTO artist (name, description) VALUES ('The Streets', 'Mike Skinner born 27 November 1978 was brought up in Birmingham and now lives in Brixton.
He started messing around with keyboards at the age of 5.
He took several jobs in fast food restaurants to finance a failed attempt to launch his own record label.
As a teenager he built a recording studio in a cupboard in his bedroom.
At 19 he went to Australia for a year, taking his sampler along for company.
The first two Streets albums were nominated for the Mercury Music Prize: Original Pirate Material in 2002 and A Grand Don''t Come For Free in 2004.
"Fit But You Know It" was a Top 5 hit in the summer of 2004.
Mike Skinner has performed live at Reading Festival in the dance tent as well as on the main stage.
');
INSERT INTO artist (name, description) VALUES ('Alice In Chains', 'Alternative Rock (Modern Rock)  band formed in Seattle, Washington (USA).
Vocalist Layne Staley was found dead in his apartment on April 5th, 2002. William DuVall replaced Staley on vocals when the remainder of the band reunited in 2005.

Current lineup:
William DuVall - vocals
Jerry Cantrell - guitars, vocals
Sean Kinney - drums, percussion
Mike Inez - bass, guitar');
INSERT INTO artist (name, description) VALUES ('The Flaming Lips', 'The Flaming Lips are an American psychedelic rock band formed in 1983 in Oklahoma City, OK, USA.
The band currently consists of Wayne Coyne (vocals, guitar, keyboards), Steven Drozd (guitars, keyboards, bass, vocals), Derek Brown (keyboards, guitars, percussion), Matt Duckworth Kirksey (drums, percussion, keyboards) and Nicholas Ley (percussion, drums).');
INSERT INTO artist (name, description) VALUES ('Pink Floyd', 'Pink Floyd was an English rock band from London. Founded in 1965, the group achieved worldwide acclaim, initially with innovative psychedelic music, and later in a genre that came to be termed progressive rock.

Distinguished by philosophical lyrics, musical experimentation, frequent use of sound effects and elaborate live shows, Pink Floyd remains one of the most commercially successful and influential groups in the history of popular music.

[a=David Gilmour] – guitar, slide guitar, vocals (1968-2014)
[a=Richard Wright] – keyboards, vocals (1965-1980, 1987-2008)
[a=Nick Mason] – drums, percussion, sound effects (1965-2014)
[a=Roger Waters] – bass guitar, vocals, sound effects (1965-1985)
[a=Syd Barrett] – guitar, vocals (1965-1968)

[b]Other players:[/b]
[a=Rado Klose] – guitar (1965)
[a=Jon Carin] – backing vocals, keyboards, slide guitar, sound effects (1985-1995)
[a=Guy Pratt] – bass guitar, backing vocals (1987-1995)

Inducted into Rock And Roll Hall of Fame in 1996 (Performer).
Group name was taken from both [a=Pink Anderson] and [a=Floyd "Dipper Boy" Council] as a tribute to the American blues music they loved.');
INSERT INTO artist (name, description) VALUES ('Kendrick Lamar', 'American rapper born June 17, 1987 in Compton, California, USA.

Cousin of [a=Baby Keem].');
INSERT INTO artist (name, description) VALUES ('Michael Jackson', 'American singer, dancer, entertainer, songwriter, producer and recording artist.

Born: 29 August 1958 in Gary, Indiana, USA.
Died: 25 June 2009 in Los Angeles, California, USA (aged 50).

Known affectionately as the "King Of Pop", Jackson was a singer, dancer, musician, music producer, writer, entertainer, singer-songwriter, choreographer, record producer, recording artist, poet, arranger, businessman, philanthropist, actor and voice artist. He is one of the most celebrated and influential music artists of all time.
 
Jackson began his career as the youngest member of [a=The Jackson 5] and started his solo recording career in 1971. Brother of recording artists [a=Jackie Jackson], [a=Janet Jackson], [a=Jermaine Jackson], [a=La Toya Jackson], [a=Marlon Jackson], [a=Randy Jackson], [a=Rebbie Jackson] & [a=Tito Jackson], as well as uncle of [a=3T].

Inducted into Rock And Roll Hall of Fame in 2001 (as performer).

On June 25, 2009, Michael Jackson died of acute propofol and benzodiazepine intoxication at his home on North Carolwood Drive in the Holmby Hills neighborhood of Los Angeles, CA. His personal physician, Conrad Murray, said he had found Jackson in his room, not breathing and with a barely detectable pulse, and that he administered CPR on Jackson to no avail. After a call was placed to 9-1-1 at 12:21 p.m., Jackson was treated by paramedics at the scene and was later pronounced dead at the Ronald Reagan UCLA Medical Center.');
INSERT INTO artist (name, description) VALUES ('Fleetwood Mac', 'Founded in London in July 1967 (by ex-[url=http://www.discogs.com/artist/John+Mayall+%26+The+Bluesbreakers]Bluesbreakers[/url] members, Peter Green and Mick Fleetwood), "Peter Green''s Fleetwood Mac" instantly became a major force in the UK blues scene, along with their eponymous first album. Following "Mr. Wonderful" & "Then Play On" the driving force of Peter Green had deteriorated as he lapsed into a personal crisis by 1970. The group reorganized, under the leadership of Fleetwood, and slowly took on a new direction - away from the blues and into the mainstream of international popularity, known simply as [b]Fleetwood Mac[/b].

Member/Dates:
Peter Green (guitar, vocals, 1967-70)
Mick Fleetwood (drums, 1967-1995, 1997-present)
John McVie (bass, 1967-1995, 1997-present)
Jeremy Spencer (guitar, vocals, 1967-71)
Bob Brunning (bass, 1967)
Danny Kirwan (guitar, 1968-72)
Christine McVie (vocals, piano, accordion, 1970-1995, 1997-1998, 2014-2022)
Bob Welch (guitar, vocals, 1971-74)
Bob Weston (guitar, 1973-74)
Dave Walker (guitar, vocals, 1973)
Doug Graves (keyboards, 1974)
Lindsey Buckingham (guitar, vocals, piano, 1975-87, 1993, 1997-2018)
Stevie Nicks (vocals, 1974–1991, 1993, 1997-present)
Billy Burnette (guitar, vocals, 1990-94)
Rick Vito (guitar, 1990-91)
Dave Mason, (guitar, vocals, 1993-94)
Bekka Bramlett (vocals, 1993-94)
Mike Campbell (lead guitar, vocals, 2018–present)
Neil Finn, (vocals, rhythm guitar, 2018–present)

Inducted into Rock And Roll Hall of Fame in 1998 (Performer)');
INSERT INTO artist (name, description) VALUES ('Prince And The Revolution', '[b]NOTE: If The Revolution are credited without Prince, please use [a571633].[/b]
Without The Revolution see here: [a=Prince].');
INSERT INTO artist (name, description) VALUES ('Jack White', 'German songwriter, producer and former soccer player, born 2 September 1940 in Cologne.
For the American singer-songwriter from [a=The White Stripes] fame, see [a=Jack White ].');
INSERT INTO artist (name, description) VALUES ('Eagles', 'American rock band founded in 1971 by [a=Glenn Frey] (guitar), [a=Bernie Leadon] (banjo, mandolin, electric guitar, acoustic guitar), [a=Randy Meisner] (bass) and [a=Don Henley] (drums).

[a=Don Henley]: drums, percussion, vocals
[a=Timothy B. Schmit]: bass, vocals
[a=Joe Walsh]: guitars, organ, vocals

Former members: [a=Bernie Leadon], [a=Randy Meisner], [a=Don Felder], [a=Glenn Frey]

Inducted into the Rock And Roll Hall of Fame in 1998 (Performer).');
INSERT INTO artist (name, description) VALUES ('Bruce Springsteen', 'Born: September 23, 1949, Long Branch, New Jersey, USA.

Nicknamed "The Boss", Springsteen is an American singer-songwriter and rock musician, widely known for his brand of poetic lyrics, his Jersey Shore roots, his distinctive voice, and his lengthy and energetic stage performances. He released his first album in 1973. The backing group that played for him is called [a=The E-Street Band].
Inducted into Rock And Roll Hall of Fame (Performer) and Songwriters Hall of Fame in 1999.
Married [a=Patti Scialfa] on June 8, 1991. On July 25, 1990, Scialfa gave birth to the couple''s first child, [a=Evan James Springsteen].
Oldest brother of [a=Pamela Springsteen].');
INSERT INTO artist (name, description) VALUES ('Dire Straits', 'British rock band formed in 1977 by Mark Knopfler, David Knopfler, John Illsley and Pick Withers. The group first split up in 1988 but reformed in 1991 and then disbanded again in 1995.

Full-time band members:
[a=Mark Knopfler] – lead guitar, lead vocals (1977–1995)
[a=John Illsley] – bass guitar, backing vocals (1977–1995)
[a=Alan Clark] – keyboards (1980–1995)
[a=Guy Fletcher] – synthesizer, backing vocals (1984–1995)
[a=David Knopfler] – rhythm guitar, keyboards, backing vocals (1977–1980)
[a=Pick Withers] – drums, percussion (1977–1982)
[a=Terry Williams (3)] – drums (1982–1989)
[a=Jack Sonni] – rhythm guitar (1985–1988)
[a=Hal Lindes] – rhythm guitar, backing vocals (1980–1985)

Touring/session members:
[a=Joop de Korte] – percussion
[a=Mel Collins] – saxophone
[a=Tommy Mandel] – keyboards
[a=Chris White] – saxophone
[a=Chris Whitten] – drums, percussion
[a=Phil Palmer] – guitar
[a=Paul Franklin] – pedal steel guitar
[a=Danny Cummings] – percussion');
INSERT INTO artist (name, description) VALUES ('Crosby, Stills, Nash & Young', 'Crosby, Stills, Nash & Young (CSNY) was the name given to vocal folk rock supergroup [b][a254201][/b] when joined by Canadian singer-songwriter [a138556], who was an occasional fourth member.');
INSERT INTO artist (name, description) VALUES ('The Cars', 'American New Wave rock group from Boston, Massachusetts. Formed in 1976. 

Released their first single and LP two years later. Initially a guitar-driven rock act with some progressive keyboard accompaniment, after their first album they rapidly moved toward a heavily synth-based, pop-rock sound, then disbanded in 1988. Line-up: [a=Ric Ocasek] (vocals, guitar), [url=https://www.discogs.com/artist/365116-Benjamin-Orr?noanv=1]Benjamin Orr[/url] (vocals, bass), [a=Elliot Easton] (guitar), [a=Greg Hawkes] (keyboards, sax, guitar) and [url=http://www.discogs.com/artist/David+Robinson+(3)]David Robinson[/url] (drums).

The Cars were one of the most successful American New Wave bands to emerge in the late 1970s, and in the ensuing decade the band racked up a string of platinum albums and Top 40 singles.

In 2006, Greg Hawkes and Elliot Easton, together with [a=Todd Rundgren] and [a=Kasim Sulton] (both of [url=http://www.discogs.com/artist/Utopia+(5)]Utopia[/url]) and [a=Prairie Prince] (formerly of [url=http://www.discogs.com/artist/Tubes,+The]The Tubes[/url]) formed [url=http://www.discogs.com/artist/697629-The-New-Cars]The New Cars[/url] and played mainly original Cars material live.

In 2011 The Cars (without Benjamin Orr who had passed away on October 4, 2000) released a new album and went on tour again with Greg Hawkes taking over on bass and Ric Ocasek as sole lead singer.

Inducted into the Rock and Roll Hall of Fame in 2018, and reunited once more to perform at the induction ceremony. Ric Ocasek passed away on September 15, 2019.');
INSERT INTO artist (name, description) VALUES ('Supertramp', 'British/American rock band formed in London, England in 1969 - Disbanded in 1988 - Reunited intermittently from 1996 to 2002 - Reformed in 2010/11 for European tour.

[b]Lineup on LP 1 in 1970:[/b]
● [a=Roger Hodgson] – vocals, acoustic guitar, cello, flageolet, bass (1970–1983)
● [a395811] – vocals, piano, electric piano, organ, harmonica (1970–1988, 1996–2002, 2010–2011, 2015) 
● [a=Richard Palmer-James] – acoustic & electric guitar, balalaika, vocals (1970–1971) 
● [a=Robert Millar] – drums, harmonica, percussion (1970–1971) 

[b]Lineup on LP 2 [i]Indelibly Stamped[/i] in 1971:[/b]
● [a=Roger Hodgson] – vocals, acoustic & electric guitar, bass (1970–1983)
● [a=Rick Davies] – vocals, keyboards, harmonica (1970–1988, 1996–2002, 2010–2011, 2015) 
● [a=Dave Winthrop] – flutes, saxophones, vocals (1970–1973) 
● [a=Frank Farrell ] – bass, piano, accordion, background vocals (1971–1972) 
● [a=Kevin Currie] – drums, percussion (1971–1973)

[b]Classic lineup 1973–1983–1988:[/b]
● [a=Roger Hodgson] – lead vocals, keyboards, guitars (1970–1983)
● [a=Rick Davies] – vocals, keyboards (1970–1988, 1996–2002, 2010–2011, 2015) 
● [a=John Helliwell] – woodwinds, keyboards, backing vocals (1973–1988, 1996–2002, 2010–2011, 2015) 
● [a=Dougie Thomson] – bass (1972–1988)
● [a=Bob Siebenberg] – drums (1973–1988, 1996–2002, 2010–2011, 2015) 

[b]Current lineup:[/b]
● [a=Rick Davies] – lead vocals, keyboards, harmonica (1970–1988, 1996–2002, 2010–2011, 2015)
● [a=Mark Hart] – vocals, keyboards, guitar (1996–2002, 2015; touring musician: 1985–1988)
● [a=John Helliwell] – woodwinds, keyboards, backing vocals (1973–1988, 1996–2002, 2010–2011, 2015)
● [a=Carl Verheyen] – guitars, percussion, backing vocals (1996–2002, 2010–2011, 2015; touring musician: 1985–1986) 
● [a=Gabe Dixon] – keyboards, tambourine, vocals (2010–2011, 2015)
● [a=Lee Thornburg] – trumpet, trombone, keyboards, backing vocals (1996–2002, 2010–2011, 2015) 
● [a=Jesse Siebenberg] – vocals, guitars, percussion (1997–2002, 2010–2011, 2015), keyboards (2010–present) 
● [a=Cliff Hugo] – bass (1996–2002, 2010–2011, 2015) 
● [a=Bob Siebenberg] – drums, percussion (1973–1988, 1996–2002, 2010–2011, 2015)
● [a=Cassie Miller] – backing vocals (2010–2011, 2015)

[a=Rick Davies], [a=John Helliwell] and [a=Bob Siebenberg] are the only members of the "classic" lineup remaining in the band to this day.
[a=Roger Hodgson] left the band in 1983. ');
INSERT INTO artist (name, description) VALUES ('Sufjan Stevens', 'American singer-songwriter born July 1, 1975 in Detroit, Michigan. ');
INSERT INTO artist (name, description) VALUES ('Oasis ', 'Rock band from Burnage, Manchester, formed in 1991.
Formed out of the ashes of a band called The Rain (consisting of [a605785], [a605786], [a429260] and Chris Hutton on vocals) who started in 1990. Chris was sacked and [a53887] took over on vocals. His brother [a5452] (former guitar roadie for [a=Inspiral Carpets]'' [a=Clint Boon]) then joined as songwriter and additional guitarist.
In 1999, two of the founding members (Guigsy and Bonehead) left the group and Noel played their parts on the fourth album. Two new musicians were recruited - [a447669] and [a80566] - initially for touring duties, but became full-time and were part of the songwriting process on the following albums.  
On August 28, 2009, Noel announced that he was leaving the band after an altercation with Liam. The remaining members continue performing as [a=Beady Eye], while Noel formed [a2384642].

Members:
[a=Paul McGuigan] (1991-1999)
[a=Paul Arthurs] (1991-1999)
[a=Liam Gallagher] (1991-2009)
[a=Tony McCarroll] (1991-1995)
[a=Noel Gallagher] (1991-2009)
[a=Alan White ] (1995-2004)
[a=Gem Archer] (1999-2009) ex-[a=Heavy Stereo]
[a=Andy Bell ] (1999-2009) ex-[a=Ride] & [a=Hurricane #1]
[a=Zak Starkey]: Drums (2004-2008) son of [a=Ringo Starr]
[a=Chris Sharrock] (2008-2009) ex-[a=The La''s]

Notable session & live members:
Scott McLeod (1995 Briefly replaced Guigsy; appears in Wonderwall video) ex-The Ya Ya''s
[a=Matt Deighton]: Lead Guitar & Backing Vocals (stood-in for Noel during non-UK dates) (2000) 
[a=Steve White (3)]: Drummer (stood-in for brother Alan when he was ill) (2001)
[a=Mike Rowe]: Keyboards (1997-2002, also plays on Noel''s solo work)
[a=Jay Darlington] (ex-[a=Kula Shaker]): Keyboards (2002-2009)
[a=Terry Kirkbride] (ex-[a=Proud Mary] & [a=Ambershades]): Drums (2004, 2006-2007)
[a=Johnny Depp] Guitar (1997)');
INSERT INTO artist (name, description) VALUES ('Simon & Garfunkel', 'Simon & Garfunkel were an American folk rock duo consisting of singer-songwriter [a106474] and singer [a253432]. They were one of the most popular recording artists of the 1960s and became counterculture icons of the decade''s social revolution.

Inducted into Rock And Roll Hall of Fame in 1990 (Performer).');
INSERT INTO artist (name, description) VALUES ('The War On Drugs', 'American rock band from Philadelphia, Pennsylvania, formed in 2005. The band consists of Adam Granduciel (vocals, guitar), David Hartley (bass guitar), Robbie Bennett (keyboards), Charlie Hall (drums), Jon Natchez (saxophone, keyboards) and Anthony LaMarca (guitar). Founded by close collaborators Adam Granduciel and Kurt Vile, The War on Drugs released their debut studio album, Wagonwheel Blues, in 2008. Vile departed shortly after its release to focus on his solo career. ');
INSERT INTO artist (name, description) VALUES ('Fleet Foxes', 'Indie folk band from Seattle, Washington, U.S., founded in 2005. Later relocated to New York.');
INSERT INTO artist (name, description) VALUES ('Dr. Dre', 'Dr. Dre is the stage name of [a251429] (born February 18, 1965, Compton, California, USA), an American record producer, rapper and entrepreneur. He is credited as a key figure in the popularization of West Coast G-funk, a style of rap music characterized as synthesizer-based with slow, heavy beats.

From the 1980s to the 1990s, he was formerly a respective member of the [a1458] and [a13726] In 1991, following his departure from N.W.A. and [l7801], Dre co-founded [l19737] with the controversial [a185511] and [a39155]

In 1996, after releasing 1992''s [url=https://www.discogs.com/Dr-Dre-The-Chronic/master/33951][i]The Chronic[/i][/url], he left Death Row and founded his own label, [l2310]. He has since produced albums for and/or overseen the careers of many rappers, including [a132084], [a38661], [a14753], [a79578], [a209748], [a37906], and [a1778977].

In 2006, he and [l2311] co-founder [a170807] co-founded Beats Electronics. In 2014, Beats was acquired by computer giant Apple for $3.2 billion, making Dr. Dre the second richest figure in the American hip hop scene by Forbes Magazine with a net worth of $550 million.');
INSERT INTO artist (name, description) VALUES ('Bon Iver', 'American indie folk band started 2007 as a solo project of Justin Vernon, but has now evolved into a larger band.');
INSERT INTO artist (name, description) VALUES ('Billy Joel', 'Billy Joel was born on May 9, 1949 in the Bronx and shortly after moved to the Levittown section of Hicksville, Long Island, New York where he started playing piano at the age of 4. In 1964, inspired by the Beatles, he formed his first band "The Echoes", which became "The Lost Souls" in 1965 and then "The Emerald Lords" in 1966. In 1967 he joined "The Hassles" and recorded two albums, which were not successful. Billy Joel and Jon Small, the drummer of The Hassles then formed the psychedelic duo "Attila" and released one album without success. In 1971 Billy Joel started his solo career with the album "Cold Spring Harbour" and finally achieved fame in 1973 with his song "Piano Man".

Inducted into Songwriters Hall of Fame in 1992.
Inducted into Rock And Roll Hall of Fame in 1999 (Performer)');
INSERT INTO artist (name, description) VALUES ('Carole King', 'American singer and songwriter, born February 9 1942, Brooklyn, New York City.

Formed vocal group Co-Sines in 1957 whilst at High School and adopted the stage name Carole King. Dated [a=Neil Sedaka] at this time. Met [a=Gerry Goffin] at Queens College with whom she formed a songwriting partnership and married in 1960. Their first big hit was "Will You Love Me Tomorrow" by The Shirelles in 1961. Goffin and King split personally and professionally in 1968 (children: [a=Louise Goffin], Sherry Goffin Kondor), although they did work together later on. Carole King was inducted into the Songwriters Hall of Fame in 1987 and in 2002 became a recipient of the Songwriters Hall of Fame "Johnny Mercer Award".

She formed The City with [a252395] and [a318609]. She married Larkey in 1968, but The City was short-lived and disbanded after one album. In 1970 she toured with James Taylor and launched her solo career with "Writer" and then the classic "Tapestry". The hit albums continued and in 1976 she divorced from Charles Larkey (children: Molly & Levi).

In 1977 she married songwriting partner Rick Evers. Evers died a year later from a heroin overdose.

She is active in environmental issues and more recently campaigned on behalf of the US Democratic Party, whilst continuing to write songs and perform.');
INSERT INTO artist (name, description) VALUES ('The Beatles', 'British rock/pop group, formed in Liverpool, England during the late 1950s. Signed a recording contract with EMI in 1962.

The lineup (1962-70) comprised John Lennon (vocals, guitar, harmonica, keyboards), Paul McCartney (vocals, bass, guitar, keyboards, percussion), George Harrison (guitar, vocals, sitar), and Ringo Starr (drums, vocals, percussion). In 1961, Stuart Sutcliffe (bass) and Pete Best (drums) were also members.

Following an initial period as a straightforward Mersey-beat group, later recordings saw them experiment with psychedelia, incorporating innovative production techniques involving tape loops and other effects. Despite the group splitting in 1970, their record company has continued to release special products.

Inducted into the Rock And Roll Hall of Fame in 1988 (Group). By 2015, all four members were inducted also as individual solo artists.');
INSERT INTO artist (name, description) VALUES ('Amy Winehouse', 'British R&B/Soul and jazz singer/songwriter, and artist. 

Born: 14 September 1983 in London, England, UK. 
Died: 23 July 2011 in London, England, UK (aged 27). 

Her debut album, "[m=51290]" (2003) was nominated for the Mercury Music Prize, and she won an Ivor Novello award in 2004 for her debut single "[m=51301]" (2003). Her second album "[m=51256]" (2006) was one the highest selling for that year. 

Sadly died at a young age of accidental alcohol poisoning at her home in Camden, London, UK. 

Founder of [l=Lioness Records]. 
');
INSERT INTO artist (name, description) VALUES ('Johnny Cash', 'Johnny Cash was an American singer-songwriter, actor, musician and author, born February 26, 1932 in Kingsland, Arkansas, USA as J.R. Cash; he died September 12, 2003 in Baptist Hospital, Nashville, Tennessee, USA. 

He was married to country singer [a=June Carter]. [a=Tommy Cash] is his younger brother. [a=Joanne Cash] is his younger sister. [a=Roy Cash Sr.] is his older brother. [a=Roy Cash Jr.] is his nephew. Singer-songwriter [a=Rosanne Cash] is his daughter, from his first marriage with Vivian Liberto. Stepfather of singer-songwriter [a=Carlene Carter] (daughter of [a=June Carter] and her first husband [a=Carl Smith (3)]).

Johnny Cash was inducted into the Nashville Songwriters Hall of Fame in 1977, the Country Music Hall of Fame in 1980, the Rock And Roll Hall of Fame in 1992 (performer), and the Gospel Music Hall of Fame in 2010.

Previously worked in the army as a code breaker.');
INSERT INTO artist (name, description) VALUES ('Tyler, The Creator', 'Tyler Gregory Okonma (born March 6, 1991), better known as Tyler, the Creator, is an American rapper, record producer, and music video director. He rose to prominence as the leader and co-founder of the alternative hip hop collective Odd Future and has rapped on and produced songs for nearly every Odd Future release. Okonma creates all the artwork for the group''s releases and also designs the group''s clothing and other merchandise.

After releasing his debut album Goblin under XL Recordings in April 2011, Okonma signed a joint venture deal for him and his label Odd Future Records, with RED Distribution and Sony Music Entertainment. Following that he released his second studio album Wolf, which was met with generally positive reviews and debuted at number three on the US Billboard 200 selling 90,000 copies in its first week.

In 2011, Okonma started the clothing company Golf Wang, and in 2012, he began hosting an annual music festival named the Camp Flog Gnaw Carnival. He runs his own streaming service named Golf Media; it contains original scripted series from Okonma himself and the Camp Flog Gnaw Carnival is annually streamed there.

Previously worked at Fed Ex & at Starbucks for two & a half years.');
INSERT INTO artist (name, description) VALUES ('Peter Frampton', 'British vocalist, guitarist and composer, born April 22, 1950 in Beckenham, Kent, United Kingdom.');
INSERT INTO artist (name, description) VALUES ('Foreigner', 'British–American rock band, originally formed in New York City and London in 1976 by the English musicians Mick Jones and Ian McDonald along with American vocalist Lou Gramm.');
INSERT INTO artist (name, description) VALUES ('MF Doom', 'Daniel Dumile (/ˈduːmɪleɪ/ DOO-mil-ay;) Thompson (July 13, 1971 - October 31, 2020) was a hip hop recording artist best known for his "super villain" stage persona and unique lyrics. Dumile took on several stage names in his career, most notably MF DOOM.

[a701676] aka [a1500203] was born in London, England, as the son of a Trinidadian mother and a Zimbabwean father. His family moved to Long Island, New York when he was a child; Dumile remained a British citizen and never gained American citizenship.

');
INSERT INTO artist (name, description) VALUES ('Wu-Tang Clan', 'Wu-Tang Clan - Rap group formed in Staten Island, New York in 1992.  [a=RZA], [a=GZA], [a=Ol'' Dirty Bastard], [a=Inspectah Deck], [a=U-God], [a=Raekwon], [a=Ghostface Killah], [a=Method Man], [a=Masta Killa]  &  [a=Cappadonna] as the 10th member after Ol'' Dirty Bastard died. There''s many more Wu-Tang Affiliates.');
INSERT INTO artist (name, description) VALUES ('Neutral Milk Hotel', 'American indie rock band formed in 1989 in Ruston, Louisiana.

');
INSERT INTO artist (name, description) VALUES ('Queen', 'Queen is a British rock band formed in London in 1970 from the previously disbanded [a667383] Rock band. Originally called Smile, later in 1970 singer [a79949] came up with the new name for the band. [a268365] joined in March 1971 giving them their fourth and final bass player.

The band has released a total of 18 number-one albums, 18 number-one singles and 10 number-one DVDs, and have sold over 300 million albums worldwide, making them one of the world''s best-selling music artists. They have been honoured with seven Ivor Novello awards and were inducted into the Rock and Roll Hall of Fame in 2001.

Lead singer Freddie Mercury died in November 1991 of AIDS-related complications. A year after his death, in April 20 1992 held a tribute concert for the lead singer to commemorate his life featuring all three remaining members and along with many great guest singers and guitarists.

Since the death of Freddie Mercury in 1991, [a253217] and [a208268] continued as various "Queen+" incarnations. John Deacon has retired from the music business, and opted out of almost all post-Mercury Queen activities, saying "As far as we are concerned, this is it. There is no point carrying on. It is impossible to replace Freddie".');
INSERT INTO artist (name, description) VALUES ('The Smiths', 'The Smiths were an English rock band formed in Manchester in 1982. The group consisted of vocalist Morrissey, guitarist Johnny Marr, bassist Andy Rourke, and drummer Mike Joyce. Critics have called them one of the most important bands to emerge from the British independent music scene of the 1980s. In 2002, the NME named the Smiths "the artist to have had the most influence on the NME". In 2003, all four of their albums appeared on Rolling Stone''s list of the "500 Greatest Albums of All Time".  The band broke up in 1987 due to internal tensions and have turned down several offers to reunite.');
INSERT INTO artist (name, description) VALUES ('John Williams (4)', 'American film composer, conductor, and pianist, born February 8, 1932, Floral Park, Long Island, NY, USA.
For the pianist with Stan Getz  Quartet, Quintet  a.o. select [a320757].
For the classical guitarist select [a337094]

In a career spanning six decades, he has composed some of the most recognizable film scores in the history of motion pictures. Williams (often credited as "Johnny Williams") also composed the theme music for various TV programs in the 1960s. Williams was known as "Little Johnny Love" Williams during the early 1960s, and he served as music arranger and bandleader for a series of popular music albums with the singer [a=Frankie Laine]. His most typical style may be considered Neo-romanticism, with a notorious use of letmotifs and orchestral grandeur (most iconically in the [i]Star Wars[/i] saga), but he has made also incursions in Impressionist, Expressionist or Experimental music, and also in progressive Jazz (his father was a jazz drummer and he began his career as a jazz pianist, often working with [a10529]).

Williams has won five Academy Awards, four Golden Globe Awards, seven BAFTA Awards, and 21 Grammy Awards. As of 2006, he has received 45 Academy Award nominations, an accomplishment surpassed only by [a=Walt Disney]. His longtime collaboration with producers [a=Steven Spielberg] and [a=George Lucas] has been very fruitful and contributed to the growing popularity of score music. John Williams was honored with the prestigious Richard Kirk award at the 1999 BMI Film and TV Awards. 

Williams was inducted into the Hollywood Bowl Hall of Fame in 2000, and was a recipient of the Kennedy Center Honors in 2004.');
INSERT INTO artist (name, description) VALUES ('Huey Lewis & The News', 'Formed: 1978 // Corte Madera, CA, United States 
Members:
Huey Lewis (lead vocals, harmonica)
Johnny Colla (saxophone, guitar, vocals)
Bill Gibson (percussion, vocals)
John Pierce (bass) 1995 - 
Sean Hopper (keyboards, vocals)
Stef Burns (lead guitar, vocals) 2000 - 
"The News Brothers" 1994 - 
Marvin McFadden (trumpet)
Rob Sudduth (tenor & baritone saxophone) 

Former members:
Mario Cipollina (bass, vocals) 1979 - 1995
Chris Hayes (lead guitar, vocals) 1979 - 2000
Ron Stallings (tenor saxophone) 1994 - 2009');
INSERT INTO artist (name, description) VALUES ('King Crimson', 'One of the pioneers of the progressive rock genre. The first official rehearsal of the band was on January 13, 1969. The first line-up comprised guitarist [a=Robert Fripp], lyricist and lighting man [a=Peter Sinfield] (who “invented” the name of the band), composer and multi-instrumentalist [a=Ian McDonald], bassist and vocalist [a=Greg Lake], and drummer [a=Michael Giles]. They toured extensively and released the album [m=406634], a seminal piece of late ’60s music. Shortly afterwards, the band split to reform again suffering continuous personnel changes for a period of two and a half years (early 1970-mid 1972), releasing three more studio albums and one recorded live, with Robert Fripp as the only remaining member.

The new King Crimson that evolved in July 1972 (featuring ex-[a=Yes] drummer [a=Bill Bruford], ex-[a=Family (6)] and later [a=Asia ] bassist/vocalist [a=John Wetton] and other more transitory members) marked a turn toward a heavier progressive sound, with experimental and fusion overtones, climaxing in unique semi-improvisatory live performances. This core line-up carried on until mid-1974, when Fripp broke up the band (as he thought) for good.

In mid-1981, after a full 7 years, a newly-formed band including Robert Fripp, with [a=Adrian Belew] on vocals and guitar, [a=Tony Levin] on bass and Chapman Stick, and Bill Bruford on acoustic and electronic drums, changed its name from [url=http://www.discogs.com/artist/Discipline+(6)]Discipline[/url] to King Crimson. This line-up remained intact until summer 1984, releasing three studio albums.

Ten years later (May 1994), King Crimson started rehearsing again, this time as a "double trio" including [a=Pat Mastelotto] on drums and percussion and [a=Trey Gunn] on Stick in addition to the 1980s line-up; it released two full albums and a handful of EPs through Fripp''s own [l=Discipline Global Mobile] label. A process of “fractalization” led to the creation of multiple spin-off groups containing three or four King Crimson members, dubbed "ProjeKcts" [url=http://www.discogs.com/artist/ProjeKct+One]One[/url], [url=http://www.discogs.com/artist/Projekct+Two]Two[/url], [url=http://www.discogs.com/artist/ProjeKct+Three]Three[/url], [url=http://www.discogs.com/artist/Projekct+Four]Four[/url], and [url=http://www.discogs.com/artist/Projekct+X]X[/url], which released live and studio sessions through DGM. Having regained the rights to the full King Crimson catalogue, DGM put out numerous other recordings from all periods of the band''s existence, including "King Crimson Collectors'' Club" bi-monthly releases available only to members of the label''s website. In the hands of DGM, the King Crimson back catalogue (with most late additions available only on FLAC/MP3 format rather than on CD) grew enormously, making it one of the biggest for any rock group ever.

The next reincarnation of the band, jokingly dubbed the "double duo", omitted Bill Bruford and Tony Levin. Its first complete studio album was “The ConstruKction of Light” (May 2000), and the line-up carried on until the end of 2003. Since then, Tony Levin rejoined the group and Trey Gunn departed. In 2008, with the addition of [a=Gavin Harrison] the new King Crimson began and performed a 40th Anniversary Tour.

Robert Fripp stated in an August 2012 interview that he had retired from the music business, but 2014 found a new King Crimson line-up touring, including Fripp (guitar), Mel Collins (saxophones, flute), Tony Levin (basses, stick), Pat Mastelotto (drums, percussion), Gavin Harrison (drums, percussion), [a=Jakko M. Jakszyk] (vocals, guitar, flute), and [a=William Rieflin] (drums, percussion, synthesizer). In 2016 [a=Jeremy Stacey] (drums, keyboards) joined as an eighth member making the group a "double quartet".

The band toured North America and then Japan in 2021. Levin and Jakszyk had earlier said that the North America tour was probably the band''s last there.');
INSERT INTO artist (name, description) VALUES ('Janis Joplin', 'Born: 19 January 1943, Port Arthur, Texas, USA.
Died: 04 October 1970, Los Angeles, California, USA.

[b]Joplin[/b] was the eldest of her siblings Michael and Laura, and attended Thomas Jefferson High School, where she began painting and listening to blues artists [a=Bessie Smith], [a=Leadbelly], [a=Big Mama Thornton] and [a=Odetta] with the other rebellious kids in her neighborhood. She graduated high school in 1960, and in 1962, she quit university in the middle of her studies. The university then ran the headline, "She Dares To Be Different" in the student newspaper.

She went to San Francisco in 1963, first living in North Beach and later, Haight-Ashbury, where she begun the drug and alcohol habits that would tragically end her life. During this period, she recorded a session with [a=Jorma Kaukonen] that later appeared as the bootleg "The Typewriter Tape". Noticeably suffering from her addictions, she returned to Port Arthur in May 1965 and ''straightened up'' for a year, enrolling as a sociology major at Lamar University.

In 1966, at the invitation of [a=Chet Helms] whom she''d known as a teenager, she returned to California and was recruited as the singer for [a=Big Brother & The Holding Company] in June, appearing at the [l=Avalon Ballroom] in San Francisco during her first public performance with them. In August 1966, the group signed with [l=Mainstream Records] and recorded an album. However, it was not released until a year later and in the meantime, with very little reward, they moved with the [a=Grateful Dead] to a house in Lagunitas, California. It was there that Joplin relapsed into hard drug use.

Joplin and the band signed with [a=Albert Grossman] in November 1967 and released [r559560] in 1968. This release was the culmination of a year in which Joplin had wowed audiences at the Monterey Pop Festival, the Anderson Theater in New York, the Wake For Martin Luther King Jr concert with [a=Jimi Hendrix] in New York and on TV''s prime-time Dick Cavett Show. Joplin then left the band after a Family Dog benefit gig in December 1968 and formed a back-up group, the [a=Kozmic Blues Band], releasing an album in September 1969. The group disbanded three months later, with Joplin again suffering from her addictions.

After taking time out in Brazil with close friend Linda Gravenites (wife of Bay Area musician [a=Nick Gravenites] from 1962-1970), who was her costume designer and praised by Joplin in the May 1968 issue of Vogue, Joplin returned to America and formed the [a=Full Tilt Boogie Band], which began touring in May 1970. She also appeared in reunion concerts with [a=Big Brother & The Holding Company] at this time. She then began recording a new album in September 1970 with producer [a=Paul A. Rothchild].

By Saturday, October 3rd Joplin had already laid down a number of takes at [l=Sunset Recording Studios] in LA, including "Mercedes Benz". On the following day she failed to appear and John Cooke, the road manager of Full Tilt Boogie Band, drove to the Landmark Motor Hotel where Joplin was staying. There he found her dead on the floor of her room, the result of a seizure caused by a heroin overdose.

Joplin was cremated and her ashes scattered from a plane into the Pacific Ocean. Her unfinished recordings were assembled and the result was the posthumously released [r755239] in 1971. It became the biggest selling album of her career.

Inducted into Rock And Roll Hall of Fame in 1995 (Performer).');
INSERT INTO artist (name, description) VALUES ('Harry Styles', 'British singer, songwriter, and artist. 

Born: 1 February 1994 in Redditch, Worcestershire, England, UK. 

Pop singer-songwriter, known as a member of the boy band [a=One Direction]. He made his debut, however, as a singer with his band [a=White Eskimo] that performed locally in Holmes Chapel, Cheshire, UK. 

In 2010, Styles auditioned as a solo artist for the British television series [l=The X Factor]. After being eliminated as a solo performer, Styles was brought back into the competition, along with four other contestants, to form the group that would later become known as One Direction. 

He is the founder of [l=Erskine Records], the label he records under as a solo artist. His third album, "[m=2640143]" (2022), was shortlisted for the [url=https://www.discogs.com/lists/Mercury-Prize-shortlist-2022-31st-year/1059083]2022 Mercury Prize[/url]. 
');
INSERT INTO artist (name, description) VALUES ('The Doors', 'American psychedelic rock/blues rock band formed from "[a759311]" in July, 1965 in Los Angeles, CA, United States by [a260501] and [a242088]. After the death of Jim Morrison on July 3, 1971 in Paris, the other band members released two more albums, but they were not very successful. In April 1973 the band broke up.

Inducted into Rock And Roll Hall of Fame in 1993 (Performer).');
INSERT INTO artist (name, description) VALUES ('Journey', 'Journey is an American rock band that formed in San Francisco in 1973, composed of former members of Santana and Frumious Bandersnatch. The band has gone through several phases; its strongest commercial success occurred between 1978 and 1987. ');
INSERT INTO artist (name, description) VALUES ('Men At Work', 'Men at Work are an Australian pop rock band founded in 1978 which achieved international success in the 1980s. They are the only Australian artists to reach the Number 1 position in album and singles charts in both the United States and the United Kingdom with Business as Usual and "Down Under". The group won the 1983 Grammy Award for Best New artist and sold over 30 million albums worldwide. In 2019, [a285083] reformed Men at Work, being the bands first tour since 2002, with brief reunions in 2009.

Members have included: [a=Colin Hay] (vocals, rhythm guitar), [a=Ron Strykert] (guitar, vocals, 1978–1985), [a=John Rees ] (bass, 1979-1984), [a=Greg Ham] (saxophone, flute, keyboards, 1979–1985, 1996–2002; occasional performances until 2012; died 2012), [a=Jerry Speiser] (drums, 1979-1984)');
INSERT INTO artist (name, description) VALUES ('Taylor Swift', 'American singer-songwriter, born December 13, 1989 in Reading, Pennsylvania, USA. She signed her record deal with Big Machine Records at the age of 15 and released her debut album in October of 2006. 

Swift has written or co-written every song on her albums, with the exception of [i]Speak Now[/i] in which she is the sole writer of every song on the album. She has also released several of her songs with pop remixes and released them to pop radio, much like country-pop artist Shania Twain with whom Swift has often been compared to in both music style and fashion.

Swift has collaborated with artists like Boys Like Girls, John Mayer, The Civil Wars, B.o.B., Ed Sheeran, Gary Lightbody from Snow Patrol and Tim McGraw, whom her debut single is named after.

After some controversy over the masters sold by her label, Swift began re-recording her first 6 studio albums. Currently, she has released Fearless and Red. The following albums are labeled (Taylor''s Version) to indicate ownership of the masters.');
INSERT INTO artist (name, description) VALUES ('Weezer', 'Rock band from Los Angeles, California, US.
Formed in 1992.

Current members:
Rivers Cuomo - Lead vocals/Lead guitar/Keys (1992-)
Patrick Wilson - Drums/Percussion/Backing vocals (1992-)
Brian Bell - Rhythm/Lead guitar/Backing vocals/Keys (1993-)
Scott Shriner - Bass/Backing vocals/Keys (2001-)

Former members:
Jason Cropper - Rhythm guitar (1992-1993)
Matt Sharp - Bass (1992-1998)
Mikey Welsh - Bass (1998-2001)');
INSERT INTO artist (name, description) VALUES ('Miles Davis', 'Trumpeter, bandleader, composer, and one of the most important figures in jazz music history, and music history in general. Davis adopted a variety of musical directions in a five-decade career that kept him at the forefront of many major stylistic developments in jazz. Winner of eight Grammy awards.

Born: 26 May 1926 in Alton, Illinois, USA.
Died: 28 September 1991 in Santa Monica, California, USA (aged 65).

Best known for his seminal modern jazz album "[m=5460]" (1959), the highest selling jazz album of all time with six million copies sold.

Miles went to NYC to study at the academic school for musicians, where he met [a=Charlie Parker]. They started playing together from 1945. In 1948 Miles Davis started to make his own ensembles, at that time he met [a=Gil Evans], The Miles Davis Nonet was born. From the few recordings they made in 1949 to 1950 came the album "[m=62308]" (1957), with Davis and Evans going on to work more together in the future.

Miles Davis was one of the musicians who introduced the ''Hard Bop'' in the mid 1950s. In the late 1960s he started to experiment with electronic instruments and rock and funk rhythms. In the mid 1970s he stopped playing because of health problems, though in 1980 he made an ''electronical'' comeback.

Inducted into Rock And Roll Hall of Fame in 2006 (Performer). Winner of Eight Grammy Awards.

He married dancer/actress [a=Frances Taylor Davis] on December 12, 1959; they divorced in 1968. He then married singer [a=Betty Mabry] in September 1968; they divorced in 1970. He then married actress [a=Cicely Tyson] on November 26, 1981; they divorced in 1989. Father of [a=Cheryl Davis] & [a=Erin Davis]. Uncle of [a=Vince Wilburn, Jr.]');
INSERT INTO artist (name, description) VALUES ('The Smashing Pumpkins', 'Alternative Rock (Modern Rock) band from Chicago, Illinois (USA).

Smashing Pumpkins formed in 1988 by Billy Corgan and James Iha. The band split in 2000, but was reformed by Corgan in 2006.
');
INSERT INTO artist (name, description) VALUES ('Tame Impala', 'Tame Impala is the psychedelic rock project of [a1245512] in the studio, but as a touring act from 2007, Parker plays alongside [a1007517], [a1245514], [a819641] and [a3413307]. The band released their critically acclaimed debut album [m268496], which achieved certified Gold in Australia. The follow up was 2012''s [m477610] receiving a Grammy nomination for Best Alternative Music Album. A third album released in 2015, [m861083], won ARIA Awards for ''Best Rock Album'' and ''Album of the Year''.');
INSERT INTO artist (name, description) VALUES ('Boston', 'Hard / arena rock band from Boston, Massachusetts, USA, formed in 1976. The band gained commercial success during the mid & late 1970''s.

[b]Current members:[/b]
● [a=Tom Scholz] – lead and rhythm guitar, bass, keyboards, percussion, backing vocals (1976–present)
● [a=Gary Pihl] – rhythm and lead guitar, keyboards, backing vocals (1985–present)
● [a=Curly Smith] – drums, percussion, harmonica, backing vocals (1994–1997, 2012–present)
● [a=Jeff Neal] – drums, percussion, backing vocals (2002–present)
● [a=Tommy DeCarlo] – lead vocals, keyboards, percussion (2008–present)
● [a=Tracy Ferrie] – bass guitar, backing vocals (2012–present)
● [a=Beth Cohen] – keyboards, guitar and vocals (2002, 2012, 2015–present)

[b]Former members:[/b]
● [a=Brad Delp] – lead vocals, rhythm guitar, keyboards, percussion (1976–1989, 1994–2007; his death)
● [a=Jim Masdea] – drums, percussion, keyboards (1976, 1983–1988)
● [a=Fran Sheehan] – bass (1976–1983)
● [a=Sib Hashian] – drums, percussion, backing vocals (1976–1983; died 2017)
● [a=Barry Goudreau] – guitars, backing vocals (1976–1981)
● [a=David Sikes] – vocals, bass, keyboards (1987–1999)
● [a=Doug Huffman] – drums, percussion, keyboards, backing vocals (1987–1994)
● [a=Fran Cosmo] – lead vocals, guitar (1993–2006)
● [a=Anthony Cosmo] (also known as Anton Cosmo) – guitar, backing vocals, songwriter (1997–2006)
● [a=Anthony Citrinite] – drums (2001–2002)
● [a=Tom Hambridge] – drums (2002)
● [a=Michael Sweet] – lead vocals, rhythm guitar (2008–2011)
● [a=David Victor] – guitar, vocals (2012–2014)
● [a=Kimberley Dahme] – bass, guitar, vocals (2001–2014)');
INSERT INTO artist (name, description) VALUES ('Godspeed You Black Emperor!', 'Canadian post-rock band. Formed in 1994 in Montreal, Quebec, Canada. Hiatus between 2004-2009. Originally called Godspeed You Black Emperor!, before later using Godspeed You! Black Emperor. 

As an experimental nine-piece from Montreal, they specialise in instrumental music. Members consist of [a=Mike Moya] (guitar),  [a=Efrim Menuck] (guitar), [a=Mauro Pezzente] (bass), [a=David Bryant] (guitar), [a=Thierry Amar] (bass), [a=Sophie Trudeau] (violin), [a=Aidan Girt] (percussion), and [a=Tim Herzog] (percussion). 

Please use artist page [a=God Speed You Black Emperor!] for anything relating to the [m=2509531] cassette release from 1994 as this is now definitively a solo [a=Efrim Menuck] project.
');
INSERT INTO artist (name, description) VALUES ('Aerosmith', 'Aerosmith is an American rock band, sometimes referred to as "the Bad Boys from Boston" and "America''s Greatest Rock and Roll Band". Their style, which is rooted in blues-based hard rock, has come to also incorporate elements of pop rock, heavy metal, and rhythm and blues, and has inspired many subsequent rock artists. They were formed in Boston, Massachusetts in 1970. Guitarist Joe Perry and bassist Tom Hamilton, originally in a band together called the Jam Band, met up with vocalist Steven Tyler, drummer Joey Kramer, and guitarist Ray Tabano, and formed Aerosmith. In 1971, Tabano was replaced by Brad Whitford, and the band began developing a following in Boston.');
INSERT INTO artist (name, description) VALUES ('Portishead', 'Portishead are an English band formed in 1991 in Bristol. They are often considered one of the pioneers of trip hop music. The band are named after the nearby town of the same name, eight miles west of Bristol, along the coast. Portishead consists of Geoff Barrow, Beth Gibbons and Adrian Utley, while sometimes citing a fourth member, Dave McDonald, an engineer on their first records. Live shows also featured [a=DJ Andy Smith]. Their debut album, Dummy, was met with critical acclaim in 1994. Two other studio albums were issued: Portishead in 1997 and Third in 2008.');
INSERT INTO artist (name, description) VALUES ('Billie Eilish', 'Singer-songwriter born on December 18, 2001 in Los Angeles, California, USA. Sister of [a6016928].
First hit single "Ocean Eyes" released at 14 years old, and first album at 17.
');

INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Hellfire', 'Hellfire
Sugar / Tzu
Eat Men Eat
Welcome To Hell
Still
Half Time
The Race Is About To Begin
Dangerous Liaisons
The Defence
27 Questions', 3, 573, 'CD', 2022, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Hellfire', 'Hellfire
Sugar/Tzu
Eat Men, Eat
Welcome To Hell
Still
Half Time
The Race Is About To Begin
Dangerous Liaisons
The Defence
27 Questions', 7, 1979, 'Vinyl', 2022, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Schlagenheim', '953
Speedway
Reggae
Near DT, MI
Western
Of Schlagenheim
BMBMBM
Years Ago
Ducter', 3, 800, 'CD', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (1, 'Schlagenheim', '953
Speedway
Reggae
Near DT,MI
Western
Of Schlagenheim
bmbmbm
Years Ago
Ducter', 1, 1490, 'Vinyl', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (2, 'For The First Time', 'Instrumental
Athens, France
Science Fair
Sunglasses
Track X
Opus', 3, 797, 'CD', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (2, 'For The First Time', 'Instrumental
Athens, France
Science Fair
Sunglasses
Track X
Opus', 3, 1700, 'Vinyl', 2021, NULL);
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
Sad Boys', 5, 1687, 'Vinyl', 2022, NULL);
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
Auto-Mobile', 7, 11000, 'Vinyl', 2000, NULL);
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
Sideria', 1, 22812, 'Vinyl', 1998, NULL);
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
Sideria', 3, 6800, 'CD', 1998, NULL);
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
Yoshimi, Forest, Magdalene ', 4, 1834, 'Vinyl', 2020, NULL);
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
Management', 7, 1175, 'Vinyl', 2021, NULL);
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
Shogun', 5, 217, 'CD', 2008, NULL);
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
Zoom Into Me', 6, 114, 'CD', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (8, 'Jubilee ', 'Paprika 
Be Sweet 
Kokomo, IN
Slide Tackle 
Posing In Bondage
Sit
Savage Good Boy
In Hell
Tactics 
Posing For Cars', 9, 5639, 'Vinyl', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (9, 'Spiderland', 'Breadcrumb Trail
Nosferatu Man
Don, Aman
Washer
For Dinner...
Good Morning, Captain', 9, 917, 'CD', 0, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (9, 'Spiderland', 'Breadcrumb Trail
Nosferatu Man
Don, Aman
Washer
For Dinner...
Good Morning, Captain', 3, 1880, 'Vinyl', 0, NULL);
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
Life After Life', 9, 10152, 'CD', 2020, NULL);
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
Soon', 1, 2299, 'CD', 2021, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (12, 'Ænima', 'Stinkfist
Eulogy
H.
Useful Idiot
Forty Six & 2
Message To Harry Manback
Hooker With A Penis
Intermission
Jimmy
Die Eier Von Satan
Pushit
Cesaro Summability
Ænima
(-) Ions
Third Eye', 8, 120000, 'Vinyl', 1997, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (11, 'm b v', 'She Found Now
Only Tomorrow
Who Sees You
Is This And Yes
If I Am
New You
In Another Way
Nothing Is
Wonder 2
She Found Now
Only Tomorrow
Who Sees You
Is This And Yes
If I Am
New You
In Another Way
Nothing Is
Wonder 2', 8, 300, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (13, 'Brothers', 'Everlasting Light
Next Girl
Tighten Up
Howlin'' For You
She''s Long Gone
Black Mud
The Only One
Too Afraid To Love You
Ten Cent Pistol
Sinister Kid
The Go Getter
I''m Not The One
Unknown Brother
Never Gonna Give You Up
These Days
Everlasting Light
Next Girl
Tighten Up
Howlin'' For You
She''s Long Gone
Black Mud
The Only One
Too Afraid To Love You
Ten Cent Pistol
Sinister Kid
The Go Getter
I''m Not The One
Unknown Brother
Never Gonna Give You Up
These Days', 5, 3384, 'Vinyl', 2010, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (13, 'Turn Blue', 'Weight Of Love
In Time
Turn Blue
Fever
Year In Review
Bullet In The Brain
It''s Up To You Now
Waiting On Words
10 Lovers
In Our Prime
Gotta Get Away
Weight Of Love
In Time
Turn Blue
Fever
Year In Review
Bullet In The Brain
It''s Up To You Now
Waiting On Words
10 Lovers
In Our Prime
Gotta Get Away', 1, 940, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (14, 'Blood Sugar Sex Magik', 'The Power Of Equality
If You Have To Ask
Breaking The Girl
Funky Monks
Suck My Kiss
I Could Have Lied
Mellowship Slinky In B Major
The Righteous & The Wicked
Give It Away
Blood Sugar Sex Magik
Under The Bridge
Naked In The Rain
Apache Rose Peacock
The Greeting Song
My Lovely Man
Sir Psycho Sexy
They''re Red Hot', 3, 47, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (15, 'Yankee Hotel Foxtrot', 'I Am Trying To Break Your Heart
Kamera
Radio Cure
War On War
Jesus, Etc.
Ashes Of American Flags
Heavy Metal Drummer
I''m The Man Who Loves You
Pot Kettle Black
Poor Places
Reservations
I Am Trying To Break Your Heart
Kamera
Radio Cure
War On War
Jesus, Etc.
Ashes Of American Flags
Heavy Metal Drummer
I''m The Man Who Loves You
Pot Kettle Black
Poor Places
Reservations', 6, 3572, 'Vinyl', 2011, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (16, 'Metallica', 'Enter Sandman
Sad But True
Holier Than Thou
The Unforgiven
Wherever I May Roam
Don''t Tread On Me
Through The Never
Nothing Else Matters
Of Wolf And Man
The God That Failed
My Friend Of Misery
The Struggle Within', 3, 171, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'The King Of Limbs', 'Bloom
Morning Mr Magpie
Little By Little
Feral
Lotus Flower
Codex
Give Up The Ghost
Separator
Bloom
Morning Mr Magpie
Little By Little
Feral
Lotus Flower
Codex
Give Up The Ghost
Separator', 6, 685, 'Vinyl', 2011, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'A Moon Shaped Pool', 'Burn The Witch
Daydreaming
Decks Dark
Desert Island Disk
Ful Stop
Glass Eyes
Identikit
 The Numbers
Present Tense
Tinker Tailor Soldier Sailor Rich Man Poor Man Beggar Man Thief
True Love Waits
Burn The Witch
Daydreaming
Decks Dark
Desert Island Disk
Ful Stop
Glass Eyes
Identikit
The Numbers
Present Tense
Tinker Tailor Soldier Sailor Rich Man Poor Man Beggar Man Thief
True Love Waits
Ill Wind
Spectre', 2, 1879, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (18, 'Toxicity', 'Prison Song
Needles
Deer Dance
Jet Pilot
X
Chop Suey!
Bounce
Forest
ATWA
Science
Shimmy
Toxicity
Psycho
Aerials
(silence)
Arto', 2, 100, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'In Rainbows', '15 Step
Bodysnatchers
Nude
Weird Fishes/Arpeggi
All I Need
Faust Arp
Reckoner
House Of Cards
Jigsaw Falling Into Place
Videotape
15 Step
Bodysnatchers
Nude
Weird Fishes/Arpeggi
All I Need
Faust Arp
Reckoner
House Of Cards
Jigsaw Falling Into Place
Videotape
Mk 1
Down Is The New Up
Go Slowly
Mk 2
Last Flowers
Up On The Ladder
Bangers + Mash
4 Minute Warning', 8, 9900, 'Vinyl', 2007, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (19, 'Rock Or Bust', 'Rock Or Bust
Play Ball
Rock The Blues Away
Miss Adventure
Dogs Of War
Got Some Rock & Roll Thunder
Hard Times
Baptism By Fire
Rock The House
Sweet Candy
Emission Control
Rock Or Bust
Play Ball
Rock The Blues Away
Miss Adventure
Dogs Of War
Got Some Rock & Roll Thunder
Hard Times
Baptism By Fire
Rock The House
Sweet Candy
Emission Control', 4, 401, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (14, 'Californication', 'Around The World
Parallel Universe
Scar Tissue
Otherside
Get On Top
Californication
Easily
Porcelain
Emit Remmus
I Like Dirt
This Velvet Glove
Savior
Purple Stain
Right On Time
Road Trippin''', 3, 50, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (14, 'By The Way', 'By The Way
Universally Speaking
This Is The Place
Dosed
Don''t Forget Me
The Zephyr Song
Can''t Stop
I Could Die For You
Midnight
Throw Away Your Television
Cabron
Tear
On Mercury
Minor Thing
Warm Tape
Venice Queen', 3, 20, 'CD', 2002, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (20, 'Hybrid Theory', 'Papercut
One Step Closer
With You
Points Of Authority
Crawling
Runaway
By Myself
In The End
A Place For My Head
Forgotten
Cure For The Itch
Pushing Me Away', 2, 50, 'CD', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, '★ (Blackstar)', '★ (Blackstar)
''Tis A Pity She Was A Whore
Lazarus
Sue (Or In A Season Of Crime)
Girl Loves Me
Dollar Days
I Can''t Give Everything Away', 7, 343, 'CD', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (22, 'Audioslave', 'Cochise
Show Me How To Live
Gasoline
What You Are
Like A Stone
Set It Off
Shadow On The Sun
I Am The Highway
Exploder
Hypnotize
Bring Em Back Alive
Light My Way
Getaway Car
The Last Remaining Light', 4, 89, 'CD', 2002, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (23, 'A Rush Of Blood To The Head', 'Politik
In My Place
God Put A Smile Upon Your Face
The Scientist
Clocks
Daylight
Green Eyes
Warning Sign
A Whisper
A Rush Of Blood To The Head
Amsterdam', 8, 27, 'CD', 2002, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (24, 'Americana', 'Welcome
Have You Ever
Staring At The Sun
Pretty Fly (For A White Guy)
The Kids Aren''t Alright
Feelings
She''s Got Issues
Walla Walla
The End Of The Line
No Brakes
Why Don''t You Get A Job?
Americana
Pay The Man
(silence)
Pretty Fly (Reprise)', 9, 25, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'In Utero', 'Serve The Servants
Scentless Apprentice
Heart-Shaped Box
Rape Me
Frances Farmer Will Have Her Revenge On Seattle
Dumb
Very Ape
Milk It
Pennyroyal Tea
Radio Friendly Unit Shifter
Tourette''s
All Apologies
Silence
Gallons Of Rubbing Alcohol Flow Through The Strip', 4, 50, 'CD', 1993, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (12, '10,000 Days', 'Vicarious
Jambi
Wings For Marie (Pt 1)
10,000 Days (Wings Pt 2)
The Pot
Lipan Conjuring
Lost Keys (Blame Hofmann)
Rosetta Stoned
Intension
Right In Two
Viginti Tres', 2, 499, 'CD', 2006, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'Nevermind', 'Smells Like Teen Spirit
In Bloom
Come As You Are
Breed
Lithium
Polly
Territorial Pissings
Drain You
Lounge Act
Stay Away
On A Plain
Something In The Way
Endless Nameless', 5, 100, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (26, 'Vitalogy', 'Division One
Last Exit
Spin The Black Circle
Not For You
Tremor Christ
Nothingman
Whipping
Division Two
Pry, To
Corduroy
Bugs
Satan''s Bed
Better Man
Aye Davanita
Immortality
Hey Foxymophandlemama, That''s Me', 4, 86, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (14, 'One Hot Minute', 'Warped
Aeroplane
Deep Kick
My Friends
Coffee Shop
Pea
One Big Mob
Walkabout
Tearjerker
One Hot Minute
Falling Into Grace
Shallow Be Thy Game
Transcending', 0, 50, 'CD', 1995, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (23, 'Parachutes', 'Don''t Panic
Shiver
Spies
Sparks
Yellow
Trouble
Parachutes
High Speed
We Never Change
Everything''s Not Lost
(silence)
Life Is For Living', 3, 37, 'CD', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (27, 'Coexist', 'Angels
Chained
Fiction
Try
Reunion
Sunset
Missing
Tides
Unfold
Swept Away
Our Song
Angels
Chained
Fiction
Try
Reunion
Sunset
Missing
Tides
Unfold
Swept Away
Our Song', 6, 1000, 'Vinyl', 2012, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (28, 'Singles - Original Motion Picture Soundtrack', 'Would?
Breath
Seasons
Dyslexic Heart
The Battle Of Evermore
Chloe Dancer / Crown Of Thorns
Birth Ritual
State Of Love And Trust
Overblown
Waiting For Somebody
May This Be Love
Nearly Lost You
Drown
Touch Me, I''m Dick
Nowhere But You
Spoon Man
Flutter Girl
Missing
Would? (Live)
It Ain''t Like That (Live)
Birth Ritual (Live)
Dyslexic Heart (Acoustic)
Waiting For Somebody (Score Acoustic)
Overblown (Demo)
Heart And Lungs
Six Foot Under
Singles Blues 1
Blue Heart
Lost In Emily''s Woods
Ferry Boat #3
Score Piece #4', 5, 2100, 'Vinyl', 2017, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (29, 'Jagged Little Pill', 'All I Really Want
You Oughta Know
Perfect
Hand In My Pocket
Right Through You
Forgiven
You Learn
Head Over Feet
Mary Jane
Ironic
Not The Doctor
Wake Up
You Oughta Know (The Jimmy The Saint Blend)
(silence)
Your House (Acappella)', 3, 25, 'CD', 1995, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (18, 'System Of A Down', 'Suite-Pee
Know
Sugar
Suggestions
Spiders
Ddevil
Soil
War?
Mind
Peephole
CUBErt
Darts
P.L.U.C.K. (Politically Lying, Unholy, Cowardly Killers.)', 0, 79, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'Reveal', 'The Lifting
I''ve Been High
All The Way To Reno (You''re Gonna Be A Star)
She Just Wants To Be
Disappear
Saturn Return
Beat A Drum
Imitation Of Life
Summer Turns To High
Chorus And The Ring
I''ll Take The Rain
Beachball', 0, 49, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (23, 'X&Y', 'Square One
What If
White Shadows
Fix You
Talk
X&Y
Speed Of Sound
A Message
Low
The Hardest Part
Swallowed In The Sea
Twisted Logic
Til Kingdom Come', 9, 37, 'CD', 2005, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (31, 'Homework', 'Daftendirekt
Wdpk 83.7 FM
Revolution 909
Da Funk
Phœnix
Fresh
Around The World
Rollin'' & Scratchin''
Teachers
High Fidelity
Rock''n Roll
Oh Yeah
Burnin''
Indo Silver Club
Alive
Funk Ad', 8, 150, 'CD', 1997, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (32, 'Music', 'Music
Impressive Instant
Runaway Lover
I Deserve It
Amazing
Nobody''s Perfect
Don''t Tell Me
What It Feels Like For A Girl
Paradise (Not For Me)
Gone
American Pie', 4, 9, 'CD', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'Nevermind', 'Smells Like Teen Spirit
In Bloom
Come As You Are
Breed
Lithium
Polly
Territorial Pissings
Drain You
Lounge Act
Stay Away
On A Plain
Something In The Way
Endless Nameless', 7, 100, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'OK Computer', 'Airbag
Paranoid Android
Subterranean Homesick Alien
Exit Music (For A Film)
Let Down
Karma Police
Fitter Happier
Electioneering
Climbing Up The Walls
No Surprises
Lucky
The Tourist', 9, 135, 'CD', 1997, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (32, 'Ray Of Light', 'Drowned World/Substitute For Love
Swim
Ray Of Light
Candy Perfume Girl
Skin
Nothing Really Matters
Sky Fits Heaven
Shanti/Ashtangi
Frozen
The Power Of Good-Bye
To Have And Not To Hold
Little Star
Mer Girl', 4, 37, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (33, 'Led Zeppelin', 'Good Times Bad Times
Babe I''m Gonna Leave You
You Shook Me
Dazed And Confused
Your Time Is Gonna Come
Black Mountain Side
Communication Breakdown
I Can''t Quit You Baby
How Many More Times', 0, 281, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'Monster', 'What''s The Frequency, Kenneth?
Crush With Eyeliner
King Of Comedy
I Don''t Sleep, I Dream
Star 69
Strange Currencies
Tongue
Bang And Blame
I Took Your Name
Let Me In
Circus Envy
You', 9, 27, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (32, 'The Immaculate Collection', 'Holiday
Lucky Star
Borderline
Like A Virgin
Material Girl
Crazy For You
Into The Groove
Live To Tell
Papa Don''t Preach
Open Your Heart
La Isla Bonita
Like A Prayer
Express Yourself
Cherish
Vogue
Justify My Love
Rescue Me', 0, 37, 'CD', 1990, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'OK Computer', 'Airbag
Paranoid Android
Subterranean Homesick Alien
Exit Music (For A Film)
Let Down
Karma Police
Fitter Happier
Electioneering
Climbing Up The Walls
No Surprises
Lucky
The Tourist', 4, 250, 'CD', 1997, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (34, 'Images And Words', 'Pull Me Under
Another Day
Take The Time
Surrounded
Metropolis - Part I (The Miracle And The Sleeper)
Under A Glass Moon
Wait For Sleep
Learning To Live', 4, 168, 'CD', 1992, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (35, 'Elephant', 'Seven Nation Army
Black Math
There''s No Home For You Here
I Just Don''t Know What To Do With Myself
In The Cold, Cold Night
I Want To Be The Boy To Warm Your Mother''s Heart
You''ve Got Her In Your Pocket
Ball And Biscuit
The Hardest Button To Button
Little Acorns
Hypnotize
The Air Near My Fingers
Girl, You Have No Faith In Medicine
Well It''s True That We Love One Another', 8, 150, 'CD', 2003, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (36, 'Surrender', 'Music: Response
Under The Influence
Out Of Control
Orange Wedge
Let Forever Be
The Sunshine Underground
Asleep From Day
Got Glint?
Hey Boy Hey Girl
Surrender
Dream On', 7, 10, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'Nevermind', 'Smells Like Teen Spirit
In Bloom
Come As You Are
Breed
Lithium
Polly
Territorial Pissings
Drain You
Lounge Act
Stay Away
On A Plain
Something In The Way
(silence)
Endless, Nameless', 7, 120, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (37, 'Evil Empire', 'People Of The Sun
Bulls On Parade
Vietnow
Revolver
Snakecharmer
Tire Me
Down Rodeo
Without A Face
Wind Below
Roll Right
Year Of Tha Boomerang', 0, 45, 'CD', 1996, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (38, 'Mezzanine', 'Angel
Risingson
Teardrop
Inertia Creeps
Exchange
Dissolved Girl
Man Next Door
Black Milk
Mezzanine
Group Four
(Exchange)', 3, 86, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (39, 'Franz Ferdinand', 'Jacqueline
Tell Her Tonight
Take Me Out
The Dark Of The Matinée
Auf Achse
Cheating On You
This Fire
Darts Of Pleasure
Michael
Come On Home
40''', 6, 44, 'CD', 2004, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'MTV Unplugged In New York', 'About A Girl
Come As You Are
Jesus Doesn''t Want Me For A Sunbeam
The Man Who Sold The World
Pennyroyal Tea
Dumb
Polly
On A Plain
Something In The Way
Plateau
Oh Me
Lake Of Fire
All Apologies
Where Did You Sleep Last Night', 5, 11, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (40, 'Follow The Leader', '(no audio)
It''s On!
Freak On A Leash
Got The Life
Dead Bodies Everywhere
Children Of The Korn
B.B.K.
Pretty
All In The Family
Reclaim My Place
Justin
Seed
Cameltosis
My Gift To You
(no audio)
[Conversation]
Earache My Eye', 2, 30, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (41, 'Abattoir Blues / The Lyre Of Orpheus', 'Abattoir Blues
Get Ready For Love
Cannibal''s Hymn
Hiding All Away
Messiah Ward
There She Goes, My Beautiful World
Nature Boy
Abattoir Blues
Let The Bells Ring
Fable Of The Brown Ape
The Lyre Of Orpheus
The Lyre Of Orpheus
Breathless
Babe, You Turn Me On
Easy Money
Supernaturally
Spell
Carry Me
O Children', 4, 202, 'CD', 2004, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (42, '808s & Heartbreak', 'Say You Will
Welcome To Heartbreak
Heartless
Amazing
Love Lockdown
Paranoid
RoboCop
Street Lights
Bad News
See You In My Nightmares
Coldest Winter
Pinocchio Story (Live From Singapore)
Say You Will
Welcome To Heartbreak
Heartless
Amazing
Love Lockdown
Paranoid
RoboCop
Street Lights
Bad News
See You In My Nightmares
Coldest Winter
Pinocchio Story (Live From Singapore)', 7, 4116, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'Up', 'Airportman
Lotus
Suspicion
Hope
At My Most Beautiful
The Apologist
Sad Professor
You''re In The Air
Walk Unafraid
Why Not Smile
Daysleeper
Diminished
Parakeet
Falls To Climb', 5, 49, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (43, 'Ágætis Byrjun', 'Svefn-g-englar
Starálfur
Flugufrelsarinn
Ný Batterí
Hjartað Hamast (Bamm Bamm Bamm)
Viðrar Vel Til Loftárása
Olsen Olsen
Ágætis Byrjun
Avalon
Intro
Svefn-g-englar
Starálfur
Flugufrelsarinn
Ný Batterí
Hjartað Hamast (Bamm Bamm Bamm)
Viðrar Vel Til Loftárása
Olsen Olsen
Ágætis Byrjun
Avalon', 7, 2450, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (37, 'The Battle Of Los Angeles', 'Testify
Guerrilla Radio
Calm Like A Bomb
Mic Check
Sleep Now In The Fire
Born Of A Broken Man
Born As Ghosts
Maria
Voice Of The Voiceless
New Millennium Homes
Ashes In The Fall
War Within A Breath', 6, 50, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (44, 'That''s The Spirit', 'Doomed
Happy Song
Throne
True Friends
Follow You
What You Need
Avalanche
Run
Drown
Blasphemy
Oh No
Doomed
Happy Song
Throne
True Friends
Follow You
What You Need
Avalanche
Run
Drown
Blasphemy
Oh No', 4, 1255, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (45, 'The Book Of Souls', 'If Eternity Should Fail
Speed Of Light
The Great Unknown
The Red And The Black
When The River Runs Deep
The Book Of Souls
Death Or Glory
Shadows Of The Valley
Tears Of A Clown
The Man Of Sorrows
Empire Of The Clouds', 4, 686, 'CD', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (26, 'Yield', 'Brain Of J.
Faithfull
No Way
Given To Fly
Wishlist
Pilate
Do The Evolution
•
MFC
Low Light
In Hiding
Push Me, Pull Me
All Those Yesterdays
(silence)
Hummus', 5, 100, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (46, 'Moon Safari', 'La Femme D''Argent
Sexy Boy
All I Need
Kelly , Watch The Stars !
Talisman
Remember
You Make It Easy
Ce Matin Là
New Star In The Sky (Chanson Pour Solal)
Le Voyage De Pénélope', 3, 54, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (47, 'Favourite Worst Nightmare', 'Brianstorm
Teddy Picker
D Is For Dangerous
Balaclava
Fluorescent Adolescent
Only Ones Who Know
Do Me A Favour
This House Is A Circus
If You Were There, Beware
The Bad Thing
Old Yellow Bricks
505', 5, 99, 'CD', 2007, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, 'The Next Day', 'The Next Day
Dirty Boys
The Stars (Are Out Tonight)
Love Is Lost
Where Are We Now?
Valentine’s Day
If You Can See Me
I’d Rather Be High
Boss Of Me
Dancing Out In Space
How Does The Grass Grow?
(You Will) Set The World On Fire
You Feel So Lonely You Could Die
Heat
So She
Plan
I''ll Take You There
The Next Day
Dirty Boys
The Stars (Are Out Tonight)
Love Is Lost
Where Are We Now?
Valentine’s Day
If You Can See Me
I’d Rather Be High
Boss Of Me
Dancing Out In Space
How Does The Grass Grow?
(You Will) Set The World On Fire
You Feel So Lonely You Could Die
Heat
So She
Plan
I''ll Take You There', 2, 2293, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (48, 'A Sailor''s Guide To Earth', 'Welcome To Earth (Pollywog)
Breakers Roar
Keep It Between The Lines
Sea Stories
In Bloom
Brace For Impact (Live A Little)
All Around You
Oh Sarah
Call To Arms
CD
Welcome To Earth (Pollywog)
Breakers Roar
Keep It Between The Lines
Sea Stories
In Bloom
Brace For Impact (Live A Little)
All Around You
Oh Sarah
Call To Arms', 7, 1786, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (14, 'Californication', 'Around The World
Parallel Universe
Scar Tissue
Otherside
Get On Top
Californication
Easily
Porcelain
Emit Remmus
I Like Dirt
This Velvet Glove
Savior
Purple Stain
Right On Time
Road Trippin''', 2, 165, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (49, 'Travelling Without Moving', 'Virtual Insanity
Cosmic Girl
Use The Force
Everyday
Alright
High Times
Drifting Along
Didjerama
Didjital Vibrations
Travelling Without Moving
You Are My Love
Spend A Lifetime
Funktion', 7, 49, 'CD', 1996, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'In Utero', 'Serve The Servants
Scentless Apprentice
Heart-Shaped Box
Rape Me
Frances Farmer Will Have Her Revenge On Seattle
Dumb
Very Ape
Milk It
Pennyroyal Tea
Radio Friendly Unit Shifter
Tourette''s
All Apologies', 1, 313, 'CD', 1993, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (16, 'Garage Inc.', 'New Recordings ''98
Free Speech For The Dumb
It''s Electric
Sabbra Cadabra
Turn The Page
Die, Die My Darling
Loverman
Mercyful Fate
Astronomy
Whiskey In The Jar
Tuesday''s Gone
The More I See
Garage Days Re-Revisited ''87
Helpless
The Small Hours
The Wait
Crash Course In Brain Surgery
Last Caress / Green Hell
Garage Days Revisited ''84
Am I Evil?
Blitzkrieg
B-sides & One-offs ''88-''91
Breadfan
The Prince
Stone Cold Crazy
So What
Killing Time
Motorheadache ''95
Overkill
Damage Case
Stone Dead Forever
Too Late Too Late', 3, 206, 'CD', 1998, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (16, '...And Justice For All', 'Blackened
...And Justice For All
Eye Of The Beholder
One
The Shortest Straw
Harvester Of Sorrow
The Frayed Ends Of Sanity
To Live Is To Die
Dyers Eve', 1, 227, 'CD', 1988, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'Out Of Time', 'Radio Song
Losing My Religion
Low
Near Wild Heaven
Endgame
Shiny Happy People
Belong
Half A World Away
Texarkana
Country Feedback
Me In Honey', 0, 20, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (50, 'Is This It', 'Is This It
The Modern Age
Soma
Barely Legal
Someday
Alone, Together
Last Nite
Hard To Explain
New York City Cops
Trying Your Luck
Take It Or Leave It', 4, 94, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'In Time (The Best Of R.E.M. 1988-2003)', 'Man On The Moon
The Great Beyond
Bad Day
What''s The Frequency, Kenneth?
All The Way To Reno (You''re Gonna Be A Star)
Losing My Religion
E-Bow The Letter
Orange Crush
Imitation Of Life
Daysleeper
Animal
The Sidewinder Sleeps Tonite
Stand
Electrolite
All The Right Friends
Everybody Hurts
At My Most Beautiful
Nightswimming', 9, 50, 'CD', 2003, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (15, 'Sky Blue Sky', 'Either Way
You Are My Face
Impossible Germany
Sky Blue Sky
Side With The Seeds
Shake It Off
Please Be Patient With Me
Hate It Here
Leave Me (Like You Found Me)
Walken
What Light
On And On And On
Either Way
You Are My Face
Impossible Germany
Sky Blue Sky
Side With The Seeds
Shake It Off
Please Be Patient With Me
Hate It Here
Leave Me (Like You Found Me)
Walken
What Light
On And On And On', 8, 5170, 'Vinyl', 2007, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (51, 'Get Ready', 'Crystal
60 Miles An Hour
Turn My Way
Vicious Streak
Primitive Notion
Slow Jam
Rock The Shack
Someone Like You
Close Range
Run Wild', 5, 75, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, 'The Next Day', 'The Next Day
Dirty Boys
The Stars (Are Out Tonight)
Love Is Lost
Where Are We Now?
Valentine’s Day
If You Can See Me
I’d Rather Be High
Boss Of Me
Dancing Out In Space
How Does The Grass Grow?
(You Will) Set The World On Fire
You Feel So Lonely You Could Die
Heat
So She
Plan
I''ll Take You There
The Next Day
Dirty Boys
The Stars (Are Out Tonight)
Love Is Lost
Where Are We Now?
Valentine''s Day
If You Can See Me
I''d Rather Be High
Boss Of Me
Dancing Out In Space
How Does The Grass Grow?
(You Will) Set The World On Fire
You Feel So Lonely You Could Die
Heat
So She
Plan
I''ll Take You There', 8, 2000, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (52, 'Drukqs', 'Jynweythek
Vordhosbn
Kladfvgbung Micshk
Omgyjya-Switch7
Strotha Tynhe
Gwely Mernans
Bbydhyonchord
Cock/Ver10
Avril 14th
Mt Saint Michel + Saint Michaels Mount
Gwarek2
Orban Eq Trx4
Aussois
Hy A Scullyas Lyf A Dhagrow
Kesson Dalef
54 Cymru Beats
Btoum-Roumada
Lornaderek
QKThr
Meltphace 6
Bit 4
Prep Gwarlek 3b
Father
Taking Control
Petiatil Cx Htdui
Ruglen Holon
Afx237 V.7
Ziggomatic 17
Beskhu3epnm
Nanou 2', 1, 459, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (53, 'Dookie', 'Burnout
Having A Blast
Chump
Longview
Welcome To Paradise
Pulling Teeth
Basket Case
She
Sassafras Roots
When I Come Around
Coming Clean
Emenius Sleepus
In The End
F.O.D.
All By Myself', 6, 19, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (54, 'Music For The Jilted Generation', 'Intro
Break & Enter
Their Law
Full Throttle
Voodoo People
Speedway (Theme From Fastlane)
The Heat (The Energy)
Poison
No Good (Start The Dance)
One Love (Edit)
The Narcotic Suite', 9, 1, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (15, 'Summerteeth', 'Can''t Stand It
She''s A Jar
A Shot In The Arm
We''re Just Friends
I''m Always In Love
Nothing''severgonnastandinmyway (Again)
Pieholden Suite
How To Fight Loneliness
Via Chicago
ELT
My Darling
When You Wake Up Feeling Old
Summer Teeth
In A Future Age
Candy Floss
A Shot In The Arm (Remix)
Can''t Stand It
She''s A Jar
A Shot In The Arm
We''re Just Friends
I''m Always In Love
Nothing''severgonnastandinmyway (Again)
Pieholden Suite
How To Fight Loneliness
Via Chicago
ELT
My Darling
When You Wake Up Feeling Old
Summer Teeth
In A Future Age
Candyfloss', 6, 5800, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (55, '1000 Hurts', 'Prayer To God
Squirrel Song
Mama Gina
QRJ
Ghosts
Song Against Itself
Canaveral
New Number Order
Shoe Song
Watch Song
Prayer To God
Squirrel Song
Mama Gina
QRJ
Ghosts
Song Against Itself
Canaveral
New Number Order
Shoe Song
Watch Song', 5, 1410, 'Vinyl', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (16, 'S&M', 'The Ecstasy Of Gold
The Call Of Ktulu
Master Of Puppets
Of Wolf And Man
The Thing That Should Not Be
Fuel
The Memory Remains
No Leaf Clover
Hero Of The Day
Devil''s Dance
Bleeding Me
Nothing Else Matters
Until It Sleeps
For Whom The Bell Tolls
- Human
Wherever I May Roam
Outlaw Torn
Sad But True
One
Enter Sandman
Battery', 9, 99, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (26, 'Ten', 'Once
Even Flow
Alive
Why Go
Black
Jeremy
Oceans
Porch
Garden
Deep
Release
(silence)
Untitled', 0, 9, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (15, 'Wilco (The Album)', 'Wilco (The Song)
Deeper Down
One Wing
Bull Black Nova
You And I
You  Never Know
Country Disappeared
Solitaire
I''ll Fight
Sonny Feeling
Everlasting Everything
Wilco (The Song)
Deeper Down
One Wing
Bull Black Nova
You And I
You Never Know
Country Disappeared
Solitaire
I''ll Fight
Sonny Feeling
Everlasting Everything', 7, 1692, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (56, 'Harvest Moon', 'Unknown Legend
From Hank To Hendrix
You And Me
Harvest Moon
War Of Man
One Of These Days
Such A Woman
Old King
Dreamin'' Man
Natural Beauty', 9, 56, 'CD', 1992, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (57, 'In Colour', 'Gosh
Sleep Sound
SeeSaw
Obvs
Just Saying
Stranger In A Room
Hold Tight
Loud Places
I Know There''s Gonna Be (Good Times)
The Rest Is Noise
Girl
Stranger In A Room (Instrumental)
Loud Places (Instrumental)
Gosh
Sleep Sound
SeeSaw
Obvs
Just Saying
Stranger In A Room
Hold Tight
Loud Places
I Know There''s Gonna Be (Good Times)
The Rest Is Noise
Girl', 5, 1164, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (58, 'Keep It Hid', 'Trouble Weighs A Ton
I Want Some More
Heartbroken, In Disrepair
Because I Should
Whispered Words (Pretty Lies)
Real Desire
When The Night Comes
Mean Monsoon
The Prowl
Keep It Hid
My Last Mistake
When I Left The Room
Street Walkin''
Goin'' Home
Trouble Weighs A Ton
I Want Some More
Heartbroken, In Disrepair
Because I Should
Whispered Words (Pretty Lies)
Real Desire
When The Night Comes
Mean Monsoon
The Prowl
Keep It Hid
My Last Mistake
When I Left The Room
Street Walkin''
Goin'' Home', 3, 5639, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (59, 'Vulgar Display Of Power', 'Mouth For War
A New Level
Walk
Fucking Hostile
This Love
Rise
No Good (Attack The Radical)
Live In A Hole
Regular People (Conceit)
By Demons Be Driven
Hollow', 5, 100, 'CD', 1992, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (26, 'Ten', 'Once
Even Flow
Alive
Why Go
Black
Jeremy
Oceans
Porch
Garden
Deep
Release
(silence)
Master / Slave
Alive (Live)
Wash
Dirty Frank', 3, 75, 'CD', 1992, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (60, 'Hesitation Marks', 'The Eater Of Dreams
Copy Of A
Came Back Haunted
Find My Way
All Time Low
Disappointed
Everything
Satellite
Various Methods Of Escape
Running
I Would For You
In Two
While I''m Still Here
Black Noise
The Eater Of Dreams
Copy Of A
Came Back Haunted
Find My Way
All Time Low
Disappointed
Everything
Satellite
Various Methods Of Escape
Running
I Would For You
In Two
While I''m Still Here
Black Noise', 4, 1692, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'Amnesiac', 'Packt Like Sardines In A Crushd Tin Box
Pyramid Song
Pulk/Pull Revolving Doors
You And Whose Army?
I Might Be Wrong
Knives Out
Morning Bell/Amnesiac
Dollars And Cents
Hunting Bears
Like Spinning Plates
Life In A Glasshouse', 7, 100, 'CD', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (47, 'AM', 'Do I Wanna Know?
R U Mine?
One For The Road
Arabella
I Want It All
No.1 Party Anthem
Mad Sounds
Fireside
Why''d You Only Call Me When You''re High?
Snap Out Of It 
Knee Socks
I Wanna Be Yours', 8, 484, 'CD', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (61, 'Original Pirate Material', 'Turn The Page
Has It Come To This?
Let''s Push Things Forward
Sharp Darts
Same Old Thing
Geezers Need Excitement
It''s Too Late
Too Much Brandy
Don''t Mug Yourself
Who Got The Funk?
The Irony Of It All
Weak Become Heroes
Who Dares Wins
Stay Positive', 1, 67, 'CD', 2002, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (12, 'Ænima', 'Stinkfist
Eulogy
H.
Useful Idiot
Forty Six & 2
Message To Harry Manback
Hooker With A Penis
Intermission
Jimmy
Die Eier Von Satan
Pushit
Cesaro Summability
Ænema
(-) Ions
Third Eye', 2, 114, 'CD', 1996, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'Kid A', 'Everything In Its Right Place
Kid A
The National Anthem
How To Disappear Completely
Treefingers
Optimistic
In Limbo
Idioteque
Morning Bell
Motion Picture Soundtrack', 7, 234, 'CD', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (62, 'Jar Of Flies', 'Rotten Apple
Nutshell
I Stay Away
No Excuses
Whale & Wasp
Don''t Follow
Swing On This', 8, 165, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (63, 'The Soft Bulletin', 'Race For The Prize
A Spoonful Weighs A Ton
The Spark That Bled
Slow Motion
What Is The Light?
The Observer
Waitin'' For A Superman
Suddenly Everything Has Changed
The Gash
Feeling Yourself Disintegrate
Sleeping On The Roof
Race For The Prize
Waitin'' For A Superman
Buggin''', 7, 50, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (40, 'Korn', 'Blind
Ball Tongue
Need To
Clown
Divine
Faget
Shoots And Ladders
Predictable
Fake
Lies
Helmet In The Bush
Daddy
Michael And Geri', 2, 112, 'CD', 1994, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (49, 'Synkronized', 'Canned Heat (Album Version)
Planet Home
Black Capricorn Day
Soul Education
Falling
Destitute Illusions
Supersonic
Butterfly
Where Do We Go From Here?
King For A Day
Deeper Underground', 3, 42, 'CD', 1999, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (30, 'Out Of Time', 'Radio Song
Losing My Religion
Low
Near Wild Heaven
Endgame
Shiny Happy People
Belong
Half A World Away
Texarkana
Country Feedback
Me In Honey', 2, 23, 'CD', 1991, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'Is There Anybody Out There? (The Wall Live 1980-81)', 'MC: Atmos
In The Flesh?
The Thin Ice
Another Brick In The Wall - Part 1
The Happiest Days Of Our Lives
Another Brick In The Wall - Part 2
Mother
Goodbye Blue Sky
Empty Spaces
What Shall We Do Now?
Young Lust
One Of My Turns
Don''t Leave Me Now
Another Brick In The Wall Part 3
The Last Few Bricks
Goodbye Cruel World
Hey You
Is There Anybody Out There?
Nobody Home
Vera
Bring The Boys Back Home
Comfortably Numb
The Show Must Go On
MC: Atmos
In The Flesh
Run Like Hell
Waiting For The Worms
Stop
The Trial
Outside The Wall', 1, 300, 'CD', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (31, 'Random Access Memories', 'Give Life Back To Music
The Game Of Love
Giorgio By Moroder
Within
Instant Crush
Lose Yourself To Dance
Touch
Get Lucky
Beyond
Motherboard
Fragments Of Time
Doin'' It Right
Contact', 4, 2333, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (65, 'Good Kid, M.A.A.d City', 'Sherane A.K.A Master Splinter''s Daughter
Bitch, Don''t Kill My Vibe
Backseat Freestyle
The Art Of Peer Pressure
Money Trees
Poetic Justice
Good Kid
M.A.A.d City
Swimming Pools (Drank) (Extended Version)
Sing About Me, I''m Dying Of Thirst
Real
Compton
The Recipe
Black Boy Fly
Now Or Never', 4, 1852, 'Vinyl', 2012, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'The Dark Side Of The Moon', 'Speak To Me
Breathe (In The Air)
On The Run
Time
The Great Gig In The Sky
Money
Us And Them
Any Colour You Like
Brain Damage
Eclipse', 2, 1880, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (66, 'Thriller', 'Wanna Be Startin'' Somethin''
Baby Be Mine
The Girl Is Mine
Thriller
Beat It
Billie Jean
Human Nature
P.Y.T. (Pretty Young Thing)
The Lady In My Life', 0, 470, 'Vinyl', 1982, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (67, 'Rumours', 'Second Hand News
Dreams
Never Going Back Again
Don''t Stop
Go Your Own Way
Songbird
The Chain
You Make Loving Fun
I Don''t Want To Know
Oh Daddy
Gold Dust Woman', 7, 508, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'The Dark Side Of The Moon', 'Speak To Me
Breathe
On The Run
Time
The Great Gig In The Sky
Money
Us And Them
Any Colour You Like
Brain Damage
Eclipse', 1, 1410, 'Vinyl', 1973, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'Nevermind', 'Smells Like Teen Spirit
In Bloom
Come As You Are
Breed
Lithium
Polly
Territorial Pissings
Drain You
Lounge Act
Stay Away
On A Plain
Something In The Way', 7, 2068, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (68, 'Purple Rain', 'Let''s Go Crazy
Take Me With U
The Beautiful Ones
Computer Blue
Darling Nikki
When Doves Cry
I Would Die 4 U
Baby I''m A Star
Purple Rain', 4, 657, 'Vinyl', 1984, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (69, 'Lazaretto', 'Three Women
Lazaretto
Temporary Ground
Would You Fight For My Love?
High Ball Stepper
Untitled
Untitled
Just One Drink
Just One Drink
Alone In My Home
That Black Bat Licorice
Entitlement
I Think I Found The Culprit
Want And Able
Untitled
Untitled', 5, 2000, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, 'The Rise And Fall Of Ziggy Stardust And The Spiders From Mars', 'Five Years
Soul Love
Moonage Daydream
Starman
It Ain''t Easy
Lady Stardust
Star
Hang On To Yourself
Ziggy Stardust
Suffragette City
Rock ''N'' Roll Suicide', 7, 1200, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (47, 'AM', 'Do I Wanna Know?
R U Mine?
One For The Road
Arabella
I Want It All
No.1 Party Anthem
Mad Sounds
Fireside
Why''d You Only Call Me When You''re High?
Snap Out Of It 
Knee Socks
I Wanna Be Yours', 0, 1372, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (56, 'Harvest', 'Out On The Weekend
Harvest
A Man Needs A Maid
Heart Of Gold
Are You Ready For The Country
Old Man
There''s A World
Alabama
The Needle And The Damage Done
Words (Between The Lines Of Age)', 9, 751, 'Vinyl', 1972, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (70, 'Hotel California', 'Hotel California
New Kid In Town
Life In The Fast Lane
Wasted Time
Wasted Time (Reprise)
Victim Of Love
Pretty Maids All In A Row
Try And Love Again
The Last Resort', 9, 844, 'Vinyl', 1976, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (66, 'Thriller', 'Wanna Be Startin'' Somethin''
Baby Be Mine
The Girl Is Mine
Thriller
Beat It
Billie Jean
Human Nature
P.Y.T. (Pretty Young Thing)
The Lady In My Life', 5, 90, 'Vinyl', 1982, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (71, 'Born In The U.S.A.', 'Born In The U.S.A.
Cover Me
Darlington County
Working On The Highway
Downbound Train
I''m On Fire
No Surrender
Bobby Jean
I''m Goin'' Down
Glory Days
Dancing In The Dark
My Hometown', 8, 376, 'Vinyl', 1984, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (72, 'Brothers In Arms', 'So Far Away
Money For Nothing
Walk Of Life
Your Latest Trick
Why Worry
Ride Across The River
The Man''s Too Strong
One World
Brothers In Arms', 7, 187, 'Vinyl', 1985, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (73, 'Déjà Vu', 'Carry On
Teach Your Children
Almost Cut My Hair
Helpless
Woodstock
Deja Vu
Our House
4 + 20
Country Girl
Everybody I Love You', 0, 282, 'Vinyl', 1970, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (74, 'The Cars', 'Good Times Roll
My Best Friend''s Girl
Just What I Needed
I''m In Touch With Your World
Don''t Cha Stop
You''re All I''ve Got Tonight
Bye Bye Love
Moving In Stereo
All Mixed Up', 0, 281, 'Vinyl', 1978, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (42, 'My Beautiful Dark Twisted Fantasy', 'Dark Fantasy
Gorgeous
Power
All Of The Lights (Interlude)
All Of The Lights
Monster
So Appalled
Devil In A New Dress
Runaway
Hell Of A Life
Blame Game
Lost In The World
Who Will Survive In America', 9, 4700, 'Vinyl', 2010, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (75, 'Breakfast In America', 'Gone Hollywood
The Logical Song
Goodbye Stranger
Breakfast In America
Oh Darling
Take The Long Way Home
Lord Is It Mine
Just Another Nervous Wreck
Casual Conversations
Child Of Vision', 4, 939, 'Vinyl', 1979, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (76, 'Carrie & Lowell', 'Death With Dignity
Should Have Known Better
All Of Me Wants All Of You
Drawn To The Blood
Fourth of July
The Only Thing
Carrie & Lowell
Eugene
John My Beloved
No Shade In The Shadow Of The Cross
Blue Bucket Of Gold', 9, 1504, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (77, '(What''s The Story) Morning Glory?', 'Hello
Roll With It
Wonderwall
Don''t Look Back In Anger
Hey Now!
Untitled
Bonehead''s Bank Holiday
Some Might Say
Cast No Shadow
She''s Electric
Morning Glory
Untitled
Champagne Supernova', 4, 2287, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'Wish You Were Here', 'Shine On You Crazy Diamond (1-5)
Welcome To The Machine
Have A Cigar
Wish You Were Here
Shine On You Crazy Diamond (6-9)', 8, 940, 'Vinyl', 1975, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (78, 'Bridge Over Troubled Water', 'Bridge Over Troubled Water
El Condor Pasa
Cecilia
Keep The Customer Satisfied
So Long, Frank Lloyd Wright
The Boxer
Baby Driver
The Only Living Boy In New York
Why Don''t You Write Me
Bye Bye Love
Song For The Asking', 0, 188, 'Vinyl', 1970, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (79, 'Lost In The Dream', 'Under The Pressure
Red Eyes
Suffering
An Ocean In Between The Waves
Disappearing
Eyes To The Wind
The Haunting Idle
Burning
Lost In The Dream
In Reverse', 9, 1410, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'The Dark Side Of The Moon', 'Speak To Me
Breathe (In The Air)
On The Run
Time
The Great Gig In The Sky
Money
Us And Them
Any Colour You Like
Brain Damage
Eclipse', 3, 1490, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (80, 'Fleet Foxes', 'Fleet Foxes
Sun It Rises
White Winter Hymnal
Ragged Wood
Tiger Mountain Peasant Song
Quiet Houses
He Doesn''t Know Why
Heard Them Stirring
Your Protector
Meadowlarks
Blue Ridge Mountains
Oliver James
Sun Giant EP
Sun Giant
Drops In The River
English House
Mykonos
Innocent Son', 8, 1880, 'Vinyl', 2008, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (81, 'The Chronic', 'The Chronic (Intro)
F_ _ _ Wit Dre Day (And Everybody''s Celebratin'')
Let Me Ride
The Day The Niggaz Took Over
Nuthin'' But A "G" Thang
Deeez Nuuuts
Lil'' Ghetto Boy
A Nigga Witta Gun
Rat-Tat-Tat-Tat
The $20 Sack Pyramid
Lyrical Gangbang
High Powered
The Doctor''s Office
Stranded On Death Row
The Roach (The Chronic Outro)
Bitches Ain''t S _ _ _', 9, 1316, 'Vinyl', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'Wish You Were Here', 'Shine On You Crazy Diamond (1 - 5)
Welcome To The Machine
Have A Cigar
Wish You Were Here
Shine On You Crazy Diamond (6 - 9)', 6, 1948, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (82, 'For Emma, Forever Ago', 'Flume
Lump Sum
Skinny Love
The Wolves (Act I And II)
Blindsided
Creature Fear
Team
For Emma
Re: Stacks', 3, 1029, 'Vinyl', 2008, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (83, 'The Stranger', 'Movin'' Out (Anthony''s Song)
The Stranger
Just The Way You Are
Scenes From An Italian Restaurant
Vienna
Only The Good Die Young
She''s Always A Woman
Get It Right The First Time
Everybody Has A Dream
Untitled', 4, 94, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (84, 'Tapestry', 'I Feel The Earth Move
So Far Away
It''s Too Late
Home Again
Beautiful
Way Over Yonder
You''ve Got A Friend
Where You Lead
Will You Love Me Tomorrow?
Smackwater Jack
Tapestry
(You Make Me Feel Like) A Natural Woman', 5, 282, 'Vinyl', 1971, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (28, 'Grease (The Original Soundtrack From The Motion Picture)', 'Grease
Summer Nights
Hopelessly Devoted To You
You''re The One That I Want
Sandy
Beauty School Drop-Out
Look At Me, I''m Sandra Dee
Greased Lightnin''
It''s Raining On Prom Night
Alone At A Drive-In Movie (Instrumental)
Blue Moon
Rock ''N'' Roll Is Here To Stay
Those Magic Changes
Hound Dog
Born To Hand-Jive
Tears On My Pillow
Mooning
Freddy, My Love
Rock ''N'' Roll Party Queen
There Are Worse Things I Could Do
Look At Me, I''m Sandra Dee (Reprise)
We Go Together
Love Is A Many Splendored Thing (Instrumental)
Grease (Reprise)', 6, 300, 'Vinyl', 1978, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (66, 'Bad', 'Bad
The Way You Make Me Feel
Speed Demon
Liberian Girl
Just Good Friends
Another Part Of Me
Man In The Mirror
I Just Can''t Stop Loving You
Dirty Diana
Smooth Criminal', 4, 300, 'Vinyl', 1987, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (85, 'Let It Be', 'Two Of Us
I Dig A Pony
Across The Universe
I Me Mine
Dig It
Let It Be
Maggie Mae
I''ve Got A Feeling
One After 909
The Long And Winding Road
For You Blue
Get Back', 1, 159, 'Vinyl', 1970, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (12, 'Lateralus', 'The Grudge
Eon Blue Apocalypse
The Patient
Mantra
Schism
Parabol
Parabola
Disposition
Ticks & Leeches
Lateralus
Reflection
Triad
Faaip De Oiad', 0, 3195, 'Vinyl', 2005, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (17, 'In Rainbows', '15 Step
Bodysnatchers
Nude
Weird Fishes/Arpeggi
All I Need
Faust Arp
Reckoner
House Of Cards
Jigsaw Falling Into Place
Videotape', 3, 5500, 'Vinyl', 2007, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (86, 'Back To Black', 'Rehab
You Know I''m No Good
Me & Mr Jones
Just Friends
Back To Black
Love Is A Losing Game
Tears Dry On Their Own
Wake Up Alone
Some Unholy War
He Can Only Hold Her
You Know I''m No Good', 7, 1714, 'Vinyl', 2006, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (87, 'At San Quentin', 'Wanted Man
Wreck Of The Old 97
I Walk The Line
Darling Companion
Starkville City Jail
San Quentin
San Quentin
A Boy Named Sue
(There''ll Be) Peace In The Valley
Folsom Prison Blues', 6, 470, 'Vinyl', 1969, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (88, 'Igor', 'Igor''s Theme
Earfquake 
I Think
Boyfriend
Running Out Of Time
New Magic Wand
A Boy Is A Gun
Puppet
What''s Good
Gone, Gone / Thank You
I Don''t Love You Anymore
Are We Still Friends?', 7, 1880, 'Vinyl', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (33, 'Untitled', 'Black Dog
Rock And Roll
The Battle Of Evermore
Stairway To Heaven
Misty Mountain Hop
Four Sticks
Going To California
When The Levee Breaks', 3, 1034, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (31, 'Discovery', 'One More Time
Aerodynamic
Digital Love
Harder, Better, Faster, Stronger
Crescendolls
Nightvision
Superheroes
High Life
Something About Us
Voyager
Veridis Quo
Short Circuit
Face To Face
Too Long', 6, 8920, 'Vinyl', 2001, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (38, 'Mezzanine', 'Angel
Risingson 
Teardrop 
Inertia Creeps
Exchange 
Dissolved Girl 
Man Next Door
Black Milk 
Mezzanine
Group Four
(Exchange)', 2, 2500, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, 'Hunky Dory', 'Changes
Oh! You Pretty Things/Eight Line Poem
Life On Mars?
Kooks
Quicksand
Fill Your Heart/Andy Warhol
Song For Bob Dylan
Queen Bitch
The Bewlay Brothers', 3, 1146, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (33, 'Led Zeppelin III', 'Immigrant Song
Friends
Celebration Day
Since I''ve Been Loving You
Out On The Tiles
Gallows Pole
Tangerine
That''s The Way
Bron-Y-Aur Stomp
Hats Off To (Roy) Harper', 0, 1698, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (89, 'Frampton Comes Alive!', 'Something''s Happening
Doobie Wah
Show Me The Way
It''s A Plain Shame
All I Want To Be (Is By Your Side)
Wind Of Change
Baby, I Love Your Way
I Wanna Go To The Sun
Penny For Your Thoughts
(I''ll Give You) Money
Shine On
Jumping Jack Flash
Lines On My Face
Do You Feel Like We Do', 3, 282, 'Vinyl', 1976, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (85, 'Magical Mystery Tour', 'Magical Mystery Tour
The Fool On The Hill
Flying
Blue Jay Way
Your Mother Should Know
I Am The Walrus
Hello Goodbye
Strawberry Fields Forever
Penny Lane
Baby You''re A Rich Man
All You Need Is Love', 4, 940, 'Vinyl', 1967, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (88, 'Scum Fuck Flower Boy', 'Foreword
Where This Flower Blooms
Sometimes...
See You Again
Who Dat Boy
Pothole
Garden Shed
Boredom
I Ain''t Got Time!
911 / Mr. Lonely
Droppin'' Seeds
November
Glitter
Enjoy Right Now, Today', 3, 2058, 'Vinyl', 2017, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (90, '4', 'Night Life
Juke Box Hero
Break It Up
Waiting For A Girl Like You
Luanne
Urgent
I''m Gonna Win
Woman In Black
Girl On The Moon
Don''t Let Go', 4, 188, 'Vinyl', 1981, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (91, 'Madvillainy', 'The Illest Villains
Accordion
Meat Grinder
Bistro
Raid
America''s Most Blunted
Sickfit (Inst.)
Rainbows
Curls
Do Not Fire! (Inst.)
Money Folder
Scene Two (Voice Skit)
Shadows Of Tomorrow
Operation Lifesaver AKA Mint Test
Figaro
Hardcore Hustle
Strange Ways
(Intro)
Fancy Clown
Eye
Supervillain Theme (Inst.)
All Caps
Great Day
Rhinestone Cowboy', 3, 7500, 'Vinyl', 2004, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (92, 'Enter The Wu-Tang (36 Chambers)', 'Shaolin Sword
Bring Da Ruckus
Shame On A Nigga
Clan In Da Front
Wu-Tang: 7th Chamber
Can It Be All So Simple
Protect Ya Neck (Intermission)
Wu-Tang Sword
Da Mystery Of Chessboxin''
Wu-Tang Clan Ain''t Nuthing Ta F'' Wit
C.R.E.A.M.
Method Man
Tearz
Wu-Tang: 7th Chamber - Part II
Conclusion', 2, 350, 'Vinyl', 1993, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (93, 'In The Aeroplane Over The Sea', 'The King Of Carrot Flowers, Pt. One
The King Of Carrot Flowers, Pts. Two & Three
In The Aeroplane Over The Sea
Two-Headed Boy
The Fool
Holland, 1945
Communist Daughter
Oh Comely
Ghost
Untitled
Two-Headed Boy, Pt. Two', 7, 1216, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (94, 'Greatest Hits', 'Bohemian Rhapsody
Another One Bites The Dust
Killer Queen
Fat Bottomed Girls
Bicycle Race
You''re My Best Friend
Don''t Stop Me Now
Save Me
Crazy Little Thing Called Love
Somebody To Love
Now I''m Here
Good Old-Fashioned Lover Boy
Play The Game
Flash
Seven Seas Of Rhye
We Will Rock You
We Are The Champions', 5, 1893, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (47, 'AM', 'Do I Wanna Know?
R U Mine?
One For The Road
Arabella
I Want It All
No.1 Party Anthem
Mad Sounds
Fireside
Why''d You Only Call Me When You''re High?
Snap Out Of It 
Knee Socks
I Wanna Be Yours', 8, 573, 'Vinyl', 2013, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (78, 'Simon And Garfunkel''s Greatest Hits', 'Mrs. Robinson
For Emily, Whenever I May Find Her
The Boxer
The 59th Street Bridge Song (Feelin'' Groovy)
The Sound Of Silence
I Am A Rock
Scarborough Fair / Canticle
Homeward Bound
Bridge Over Troubled Water
America
Kathy''s Song
El Condor Pasa (If I Could)
Bookends
Cecilia', 3, 187, 'Vinyl', 1972, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'MTV Unplugged In New York', 'About A Girl
Come As You Are
Jesus Doesn''t Want Me For A Sunbeam
The Man Who Sold The World
Pennyroyal Tea
Dumb
Polly
On A Plain
Something In The Way
Plateau
Oh Me
Lake Of Fire
All Apologies
Where Did You Sleep Last Night', 6, 1900, 'Vinyl', 2017, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'The Wall', 'In The Flesh?
The Thin Ice
Another Brick In The Wall Part 1
The Happiest Days Of Our Lives
Another Brick In The Wall Part 2
Mother
Goodbye Blue Sky
Empty Spaces
Young Lust
One Of My Turns
Don''t Leave Me Now
Another Brick In The Wall Part 3
Goodbye Cruel World
Hey You
Is There Anybody Out There?
Nobody Home
Vera
Bring The Boys Back Home
Comfortably Numb
The Show Must Go On
In The Flesh
Run Like Hell
Waiting For The Worms
Stop
The Trial
Outside The Wall', 7, 2500, 'Vinyl', 1979, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (83, 'Glass Houses', 'You May Be Right
Sometimes A Fantasy
Don''t Ask Me Why
It''s Still Rock And Roll To Me
All For Leyna
I Don''t Want To Be Alone
Sleeping With The Television On
C''Etait Toi (You Were The One)
Close To The Borderline
Through The Long Night', 4, 200, 'Vinyl', 1980, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (16, 'Ride The Lightning', 'Fight Fire With Fire
Ride The Lightning
For Whom The Bell Tolls
Fade To Black
Trapped Under Ice
Escape
Creeping Death
The Call Of Ktulu', 8, 1691, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (64, 'The Wall', 'In The Flesh?
The Thin Ice
Another Brick In The Wall Part 1
The Happiest Days Of Our Lives
Another Brick In The Wall Part 2
Mother
Goodbye Blue Sky
Empty Spaces
Young Lust
One Of My Turns
Don''t Leave Me Now
Another Brick In The Wall Part 3
Goodbye Cruel World
Hey You
Is There Anybody Out There?
Nobody Home
Vera
Bring The Boys Back Home
Comfortably Numb
The Show Must Go On
In The Flesh
Run Like Hell
Waiting For The Worms
Stop
The Trial
Outside The Wall', 0, 1199, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (95, 'The Queen Is Dead', 'The Queen Is Dead (Take Me Back To Dear Old Blighty) (Medley)
Frankly, Mr. Shankly
I Know It''s Over
Never Had No One Ever
Cemetry Gates
Bigmouth Strikes Again
The Boy With The Thorn In His Side
Vicar In A Tutu
There Is A Light That Never Goes Out
Some Girls Are Bigger Than Others', 9, 1590, 'Vinyl', 2012, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (96, 'Star Wars', 'Main Title
Imperial Attack
Princess Leia''s Theme
The Desert And The Robot Auction
Ben''s Death And TIE Fighter Attack
The Little People Work
Rescue Of The Princess
Inner City
Cantina Band
The Land Of The Sand People
Mouse Robot And Blasting Off
The Return Home
The Walls Converge
The Princess Appears
The Last Battle
The Throne Room And End Title', 0, 611, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (97, 'Sports', 'The Heart Of Rock & Roll
Heart And Soul
Bad Is Bad
I Want A New Drug
Walking On A Thin Line
Finally Found A Home
If This Is It
You Crack Me Up
Honky Tonk Blues', 1, 188, 'Vinyl', 1983, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (98, 'In The Court Of The Crimson King', '21st Century Schizoid Man (Including Mirrors)
I Talk To The Wind
Epitaph (Including (A) March For No Reason (B) Tomorrow And Tomorrow)
Moonchild (Including (A) The Dream (B) The Illusion)
The Court Of The Crimson King (Including (A) The Return Of The Fire Witch (B) The Dance Of The Puppets)', 9, 1720, 'Vinyl', 2010, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (66, 'Off The Wall', 'Don''t Stop ''Til You Get Enough
Rock With You
Working Day And Night
Get On The Floor
Off The Wall
Girlfriend
She''s Out Of My Life
I Can''t Help It
It''s The Falling In Love
Burn This Disco Out', 3, 467, 'Vinyl', 1979, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (99, 'Pearl', 'Move Over
Cry Baby
A Woman Left Lonely
Half Moon
Buried Alive In The Blues
My Baby
Me & Bobby McGee
Mercedes Benz
Trust Me
Get It While You Can', 8, 187, 'Vinyl', 1971, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (100, 'Harry Styles', 'Meet Me In The Hallway
Sign Of The Times
Carolina
Two Ghosts
Sweet Creature
Only Angel
Kiwi
Ever Since New York
Woman
From The Dining Table', 4, 1645, 'Vinyl', 2017, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (101, 'The Doors', 'Break On Through (To The Other Side)
Soul Kitchen
The Crystal Ship
Twentieth Century Fox
Alabama Song (Whisky Bar)
Light My Fire
Back Door Man
I Looked At You
End Of The Night
Take It As It Comes
The End', 5, 470, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (62, 'Dirt', 'Them Bones
Dam That River
Rain When I Die
Down In A Hole
Sickman
Rooster
Junkhead
Dirt
God Smack
Iron Gland
Hate To Feel
Angry Chair
Would?', 2, 3290, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (94, 'A Night At The Opera', 'Death On Two Legs (Dedicated To ...)
Lazing On A Sunday Afternoon
I''m In Love With My Car
You''re My Best Friend
''39
Sweet Lady
Seaside Rendezvous
The Prophet''s Song
Love Of My Life
Good Company
Bohemian Rhapsody
God Save The Queen', 3, 917, 'Vinyl', 1975, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (42, 'The College Dropout', 'We Don''t Care
Graduation Day
All Falls Down
Spaceship
Jesus Walks
Never Let Me Down
Get Em High
The New Workout Plan
Through The Wire
Slow Jamz
Breathe In Breathe Out
School Spirit
Two Words
Family Business
Last Call', 1, 2027, 'Vinyl', 2004, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (82, 'Bon Iver, Bon Iver', 'Perth
Minnesota, WI
Holocene
Towers
Michicant
Hinnom, TX
Wash.
Calgary
Lisbon, OH
Beth/Rest', 6, 752, 'Vinyl', 2011, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (65, 'Good Kid, m.A.A.d City', 'Sherane a.k.a Master Splinter''s Daughter
Bitch, Don''t Kill My Vibe
Backseat Freestyle
The Art Of Peer Pressure
Money Trees
Poetic Justice
Good Kid
m.A.A.d City
Swimming Pools (Drank) (Extended Version)
Sing About Me, I''m Dying Of Thirst
Real
Compton
The Recipe
Black Boy Fly
Now Or Never', 6, 1880, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (87, 'At Folsom Prison', 'Folsom Prison Blues
Dark As The Dungeon
I Still Miss Someone
Cocaine Blues
25 Minutes To Go
Orange Blossom Special
The Long Black Veil
Send A Picture Of Mother
The Wall
Dirty Old Egg-Sucking Dog
Flushed From The Bathroom Of Your Heart
Jackson
Give My Love To Rose
I Got Stripes
Green, Green Grass Of Home
Greystone Chapel', 9, 1316, 'Vinyl', 1968, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (37, 'Rage Against The Machine', 'Bombtrack
Killing In The Name
Take The Power Back
Settle For Nothing
Bullet In The Head
Know Your Enemy
Wake Up
Fistful Of Steel
Township Rebellion
Freedom', 5, 1880, 'Vinyl', 2012, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (33, 'Untitled', 'Black Dog
Rock And Roll
The Battle Of Evermore
Stairway To Heaven
Misty Mountain Hop
Four Sticks
Going To California
When The Levee Breaks', 5, 1410, 'Vinyl', 2014, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (102, 'Escape', 'Don''t Stop Believin''
Stone In Love
Who''s Crying Now
Keep On Runnin''
Still They Ride
Escape
Lay It Down
Dead Or Alive
Mother, Father
Open Arms', 1, 469, 'Vinyl', 1981, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (103, 'Business As Usual', 'Who Can It Be Now?
I Can See It In Your Eyes
Down Under
Underground
Helpless Automaton
People Just Love To Play With Words
Be Good Johnny
Touching The Untouchables
Catch A Star
Down By The Sea', 8, 188, 'Vinyl', 1982, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (104, 'Reputation', '...Ready For It?
End Game 
I Did Something Bad
Don''t Blame Me
Delicate
Look What You Made Me Do
So It Goes...
Gorgeous
Getaway Car 
King Of My Heart
Dancing With Our Hands Tied
Dress
This Is Why We Can''t Have Nice Things
Call It What You Want
New Year’s Day', 6, 2632, 'Vinyl', 2017, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (105, 'Weezer', 'My Name Is Jonas
No One Else
The World Has Turned And Left Me Here
Buddy Holly
Undone - The Sweater Song
Surf Wax America
Say It Ain''t So
In The Garage
Holiday
Only In Dreams', 9, 1871, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (106, 'Kind Of Blue', 'So What
Freddie Freeloader
Blue In Green
All Blues
Flamenco Sketches', 9, 2303, 'Vinyl', 2010, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (107, 'Siamese Dream', 'Cherub Rock
Quiet
Today
Hummer
Rocket
Disarm
Soma
Geek U.S.A.
Mayonaise
Spaceboy
Silverfuck
Sweet Sweet
Luna', 2, 8930, 'Vinyl', 2011, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (86, 'Back To Black', 'Rehab
You Know I''m No Good
Me & Mr Jones
Just Friends
Back To Black
Love Is A Losing Game
Tears Dry On Their Own
Wake Up Alone
Some Unholy War
He Can Only Hold Her
Addicted', 1, 1500, 'Vinyl', 2007, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (67, 'Rumours', 'Second Hand News
Dreams
Never Going Back Again
Don''t Stop
Go Your Own Way
Songbird
The Chain
You Make Loving Fun
I Don''t Want To Know
Oh Daddy
Gold Dust Woman', 4, 1410, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (19, 'Back In Black', 'Hells Bells
Shoot To Thrill
What Do You Do For Money Honey
Givin The Dog A Bone
Let Me Put My Love Into You
Back In Black
You Shook Me All Night Long
Have A Drink On Me
Shake A Leg
Rock And Roll Ain''t Noise Pollution', 4, 1000, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (53, 'Dookie', 'Burnout
Having A Blast
Chump
Longview
Welcome To Paradise
Pulling Teeth
Basket Case
She
Sassafras Roots
When I Come Around
Coming Clean
Emenius Sleepus
In The End
F.O.D.
All By Myself', 1, 1869, 'Vinyl', 2009, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (108, 'Lonerism', 'Be Above It
Endors Toi
Apocalypse Dreams
Mind Mischief
Music To Walk Home By
Why Won''t They Talk To Me?
Feels Like We Only Go Backwards
Keep On Lying
Elephant
She Just Won''t Believe Me
Nothing That Has Happened So Far Has Been Anything We Could Control
Sun''s Coming Up', 4, 688, 'Vinyl', 2012, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (13, 'El Camino', 'Lonely Boy
Dead And Gone
Gold On The Ceiling
Little Black Submarines
Money Maker
Run Right Back
Sister
Hell Of A Season
Stop Stop
Nova Baby
Mind Eraser
Lonely Boy
Dead And Gone
Gold On The Ceiling
Little Black Submarines
Money Maker
Run Right Back
Sister
Hell Of A Season
Stop Stop
Nova Baby
Mind Eraser', 3, 2744, 'Vinyl', 2011, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (65, 'To Pimp A Butterfly', 'Wesley''s Theory
For Free? (Interlude)
King Kunta
Institutionalized
These Walls
U
Alright
For Sale? (Interlude)
Momma
Hood Politics
How Much A Dollar Cost
Complexion (A Zulu Love)
The Blacker The Berry
You Ain''t Gotta Lie (Momma Said)
I
Mortal Man', 8, 2622, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (25, 'In Utero', 'Serve The Servants
Scentless Apprentice
Heart-Shaped Box
Rape Me
Frances Farmer Will Have Her Revenge On Seattle
Dumb
Very Ape
Milk It
Pennyroyal Tea
Radio Friendly Unit Shifter
Tourette''s
All Apologies', 3, 1720, 'Vinyl', 2015, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (109, 'Boston', 'More Than A Feeling
Peace Of Mind
Foreplay/Long Time
Rock & Roll Band
Smokin''
Hitch A Ride
Something About You
Let Me Take You Home Tonight', 0, 658, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (110, 'Lift Your Skinny Fists Like Antennas To Heaven', 'Storm
Static
Sleep
Antennas To Heaven...', 6, 1714, 'Vinyl', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (21, '★ (Blackstar)', '★ (Blackstar)
''Tis A Pity She Was A Whore
Lazarus
Sue (Or In A Season Of Crime)
Girl Loves Me
Dollar Days
I Can''t Give Everything Away', 5, 2600, 'Vinyl', 2016, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (111, 'Toys In The Attic', 'Toys In The Attic
Uncle Salty
Adam''s Apple
Walk This Way
Big Ten Inch Record
Sweet Emotion
No More No More
Round And Round
You See Me Crying', 0, 94, 'Vinyl', 1975, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (112, 'Dummy', 'Mysterons
Sour Times
Strangers
It Could Be Sweet
Wandering Star
Numb
Roads
Pedestal
Biscuit
Glory Box', 6, 1989, 'Vinyl', 2000, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (28, 'Saturday Night Fever (The Original Movie Sound Track)', 'Stayin'' Alive
How Deep Is Your Love
Night Fever
More Than A Woman
If I Can''t Have You
A Fifth Of Beethoven
More Than A Woman
Manhattan Skyline
Calypso Breakdown
Night On Disco Mountain
Open Sesame
Jive Talkin''
You Should Be Dancing
Boogie Shoes
Salsation
K-Jee
Disco Inferno', 9, 281, 'Vinyl', 1977, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (113, 'When We All Fall Asleep, Where Do We Go?', '!!!!!!!
Bad Guy
Xanny
You Should See Me In A Crown
All The Good Girls Go To Hell
Wish You Were Gay
When The Party''s Over
8
My Strange Addiction
Bury A Friend
Ilomilo
Listen Before I Go
I Love You
Goodbye', 6, 573, 'Vinyl', 2019, NULL);
INSERT INTO product (artist_id, name, description, stock, price, format, year, rating) VALUES (33, 'Led Zeppelin', 'Good Times Bad Times
Babe I''m Gonna Leave You
You Shook Me
Dazed And Confused
Your Time Is Gonna Come
Black Mountain Side
Communication Breakdown
I Can''t Quit You Baby
How Many More Times', 4, 1376, 'Vinyl', 2014, NULL);

INSERT INTO product_genre (product_id, genre_id) VALUES (1, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 3);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (1, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (2, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (3, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (4, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 8);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (5, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 8);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (6, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 11);
INSERT INTO product_genre (product_id, genre_id) VALUES (7, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 12);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (8, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (9, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (10, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (10, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (11, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 16);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 17);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (12, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (13, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (13, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (14, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (14, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (15, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (16, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (17, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 21);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (18, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (19, 11);
INSERT INTO product_genre (product_id, genre_id) VALUES (19, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (20, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (20, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (20, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (21, 11);
INSERT INTO product_genre (product_id, genre_id) VALUES (21, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (22, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (22, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (22, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (22, 27);
INSERT INTO product_genre (product_id, genre_id) VALUES (22, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (23, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (23, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (23, 27);
INSERT INTO product_genre (product_id, genre_id) VALUES (24, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (24, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (24, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (25, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (25, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (25, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (25, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (26, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (26, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (27, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (27, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (27, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (27, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (28, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (28, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (28, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (28, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (29, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (29, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (29, 30);
INSERT INTO product_genre (product_id, genre_id) VALUES (29, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (30, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (30, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (31, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (31, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (31, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (32, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (32, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (33, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (33, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (33, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (33, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (34, 30);
INSERT INTO product_genre (product_id, genre_id) VALUES (34, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 3);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (35, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (36, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (36, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (36, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (37, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (37, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (37, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (38, 32);
INSERT INTO product_genre (product_id, genre_id) VALUES (38, 33);
INSERT INTO product_genre (product_id, genre_id) VALUES (38, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (39, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (39, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (40, 35);
INSERT INTO product_genre (product_id, genre_id) VALUES (40, 36);
INSERT INTO product_genre (product_id, genre_id) VALUES (40, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (41, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (41, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (41, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (42, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (42, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (42, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (42, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (43, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (43, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (43, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (44, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (44, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (45, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (45, 37);
INSERT INTO product_genre (product_id, genre_id) VALUES (45, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (45, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (45, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 39);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (46, 40);
INSERT INTO product_genre (product_id, genre_id) VALUES (47, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (47, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (47, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (47, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (48, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (48, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (48, 30);
INSERT INTO product_genre (product_id, genre_id) VALUES (48, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (48, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (49, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (49, 42);
INSERT INTO product_genre (product_id, genre_id) VALUES (49, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (50, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (50, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (50, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (51, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (51, 44);
INSERT INTO product_genre (product_id, genre_id) VALUES (51, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (51, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 46);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 47);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 48);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (52, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (53, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (53, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (53, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (54, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (54, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 44);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 50);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 46);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (55, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (56, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (56, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (56, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (57, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (57, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (58, 46);
INSERT INTO product_genre (product_id, genre_id) VALUES (58, 52);
INSERT INTO product_genre (product_id, genre_id) VALUES (58, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (58, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (59, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (59, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (59, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (59, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (59, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (60, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (60, 35);
INSERT INTO product_genre (product_id, genre_id) VALUES (60, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (61, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (61, 53);
INSERT INTO product_genre (product_id, genre_id) VALUES (61, 54);
INSERT INTO product_genre (product_id, genre_id) VALUES (61, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (62, 55);
INSERT INTO product_genre (product_id, genre_id) VALUES (62, 56);
INSERT INTO product_genre (product_id, genre_id) VALUES (62, 44);
INSERT INTO product_genre (product_id, genre_id) VALUES (62, 57);
INSERT INTO product_genre (product_id, genre_id) VALUES (62, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (63, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (63, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (63, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (64, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (64, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (64, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (64, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (64, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (65, 59);
INSERT INTO product_genre (product_id, genre_id) VALUES (65, 60);
INSERT INTO product_genre (product_id, genre_id) VALUES (65, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (65, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (66, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (66, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (66, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (67, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (67, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (67, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (67, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (68, 30);
INSERT INTO product_genre (product_id, genre_id) VALUES (68, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (68, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (69, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (69, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (69, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (70, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (70, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (70, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (70, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (71, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (71, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (71, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (71, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (72, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (72, 50);
INSERT INTO product_genre (product_id, genre_id) VALUES (72, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (72, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (73, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (74, 61);
INSERT INTO product_genre (product_id, genre_id) VALUES (74, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (74, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (74, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (75, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (75, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (76, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (76, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (76, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (77, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (77, 50);
INSERT INTO product_genre (product_id, genre_id) VALUES (77, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (77, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (78, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (78, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (78, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (79, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (79, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (79, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (80, 62);
INSERT INTO product_genre (product_id, genre_id) VALUES (80, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (81, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (81, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 63);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 64);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 65);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 66);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 67);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (82, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (83, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (83, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (83, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (84, 68);
INSERT INTO product_genre (product_id, genre_id) VALUES (84, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (84, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (84, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (85, 68);
INSERT INTO product_genre (product_id, genre_id) VALUES (85, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (86, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (86, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (87, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (87, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (87, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (88, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (88, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (88, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (89, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (89, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (89, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (90, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (90, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (90, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (90, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (91, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (91, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (91, 69);
INSERT INTO product_genre (product_id, genre_id) VALUES (91, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (91, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 50);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 70);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 71);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 72);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 73);
INSERT INTO product_genre (product_id, genre_id) VALUES (92, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (93, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (93, 33);
INSERT INTO product_genre (product_id, genre_id) VALUES (93, 32);
INSERT INTO product_genre (product_id, genre_id) VALUES (93, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (94, 74);
INSERT INTO product_genre (product_id, genre_id) VALUES (94, 44);
INSERT INTO product_genre (product_id, genre_id) VALUES (94, 57);
INSERT INTO product_genre (product_id, genre_id) VALUES (94, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (95, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (95, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (95, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (96, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (96, 8);
INSERT INTO product_genre (product_id, genre_id) VALUES (96, 1);
INSERT INTO product_genre (product_id, genre_id) VALUES (96, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (97, 68);
INSERT INTO product_genre (product_id, genre_id) VALUES (97, 75);
INSERT INTO product_genre (product_id, genre_id) VALUES (97, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (98, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (98, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (99, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (99, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (99, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (99, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (99, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (100, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (100, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 76);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 77);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (101, 66);
INSERT INTO product_genre (product_id, genre_id) VALUES (102, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (102, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (102, 53);
INSERT INTO product_genre (product_id, genre_id) VALUES (102, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (102, 27);
INSERT INTO product_genre (product_id, genre_id) VALUES (103, 68);
INSERT INTO product_genre (product_id, genre_id) VALUES (103, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (103, 78);
INSERT INTO product_genre (product_id, genre_id) VALUES (103, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (104, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (104, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (105, 79);
INSERT INTO product_genre (product_id, genre_id) VALUES (105, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (105, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (105, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (106, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (106, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (106, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (106, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (107, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (107, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (107, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (108, 76);
INSERT INTO product_genre (product_id, genre_id) VALUES (108, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (108, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (109, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (109, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (109, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 59);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 50);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 72);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (110, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (111, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (111, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (111, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (112, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (112, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (112, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (112, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (112, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (113, 30);
INSERT INTO product_genre (product_id, genre_id) VALUES (113, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 67);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (114, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (115, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (115, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (116, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (116, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (116, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 64);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 48);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (117, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (118, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (118, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (119, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (119, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (119, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (119, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (120, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (120, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (120, 65);
INSERT INTO product_genre (product_id, genre_id) VALUES (120, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (120, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (121, 42);
INSERT INTO product_genre (product_id, genre_id) VALUES (121, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (121, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (122, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (122, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (123, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (123, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (123, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 64);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 81);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 39);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (124, 40);
INSERT INTO product_genre (product_id, genre_id) VALUES (125, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (125, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (125, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (125, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (126, 82);
INSERT INTO product_genre (product_id, genre_id) VALUES (126, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (126, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (126, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (127, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (127, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (127, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (128, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (128, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (128, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (128, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (129, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (129, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (129, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 64);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (130, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (131, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (131, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (132, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (132, 83);
INSERT INTO product_genre (product_id, genre_id) VALUES (132, 84);
INSERT INTO product_genre (product_id, genre_id) VALUES (132, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (132, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (133, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (133, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (133, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (134, 85);
INSERT INTO product_genre (product_id, genre_id) VALUES (134, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (134, 86);
INSERT INTO product_genre (product_id, genre_id) VALUES (134, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (135, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (135, 87);
INSERT INTO product_genre (product_id, genre_id) VALUES (135, 69);
INSERT INTO product_genre (product_id, genre_id) VALUES (135, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (136, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (136, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (136, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (137, 17);
INSERT INTO product_genre (product_id, genre_id) VALUES (137, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (137, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (137, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (138, 88);
INSERT INTO product_genre (product_id, genre_id) VALUES (138, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (139, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (139, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (140, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (140, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (140, 42);
INSERT INTO product_genre (product_id, genre_id) VALUES (140, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (141, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (141, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (142, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (142, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (142, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (143, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (143, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (143, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (144, 89);
INSERT INTO product_genre (product_id, genre_id) VALUES (144, 90);
INSERT INTO product_genre (product_id, genre_id) VALUES (144, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (145, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (145, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (145, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 17);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (146, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (147, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (147, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (148, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (148, 91);
INSERT INTO product_genre (product_id, genre_id) VALUES (148, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (148, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (149, 39);
INSERT INTO product_genre (product_id, genre_id) VALUES (149, 84);
INSERT INTO product_genre (product_id, genre_id) VALUES (149, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (149, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (149, 40);
INSERT INTO product_genre (product_id, genre_id) VALUES (150, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (150, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (150, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (150, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (150, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (151, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (151, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (152, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (152, 20);
INSERT INTO product_genre (product_id, genre_id) VALUES (152, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (153, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (154, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (154, 65);
INSERT INTO product_genre (product_id, genre_id) VALUES (154, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (154, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (154, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (155, 29);
INSERT INTO product_genre (product_id, genre_id) VALUES (155, 62);
INSERT INTO product_genre (product_id, genre_id) VALUES (155, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (155, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (156, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (156, 92);
INSERT INTO product_genre (product_id, genre_id) VALUES (156, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (156, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (157, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (157, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (157, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (158, 43);
INSERT INTO product_genre (product_id, genre_id) VALUES (158, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (158, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (159, 60);
INSERT INTO product_genre (product_id, genre_id) VALUES (159, 49);
INSERT INTO product_genre (product_id, genre_id) VALUES (159, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (160, 82);
INSERT INTO product_genre (product_id, genre_id) VALUES (160, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (160, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (161, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (161, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (161, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (162, 84);
INSERT INTO product_genre (product_id, genre_id) VALUES (162, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (162, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (163, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (163, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (164, 93);
INSERT INTO product_genre (product_id, genre_id) VALUES (164, 87);
INSERT INTO product_genre (product_id, genre_id) VALUES (164, 92);
INSERT INTO product_genre (product_id, genre_id) VALUES (164, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (164, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (165, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (165, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (166, 93);
INSERT INTO product_genre (product_id, genre_id) VALUES (166, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (166, 59);
INSERT INTO product_genre (product_id, genre_id) VALUES (166, 70);
INSERT INTO product_genre (product_id, genre_id) VALUES (166, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (167, 94);
INSERT INTO product_genre (product_id, genre_id) VALUES (167, 95);
INSERT INTO product_genre (product_id, genre_id) VALUES (167, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (168, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (168, 10);
INSERT INTO product_genre (product_id, genre_id) VALUES (168, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (169, 96);
INSERT INTO product_genre (product_id, genre_id) VALUES (169, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (169, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (170, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (170, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (170, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (171, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (171, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (171, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (172, 41);
INSERT INTO product_genre (product_id, genre_id) VALUES (172, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (172, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (172, 27);
INSERT INTO product_genre (product_id, genre_id) VALUES (173, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (173, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (173, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 84);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 42);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (174, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (175, 68);
INSERT INTO product_genre (product_id, genre_id) VALUES (175, 97);
INSERT INTO product_genre (product_id, genre_id) VALUES (175, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (176, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (176, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (176, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 98);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 8);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (177, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (178, 39);
INSERT INTO product_genre (product_id, genre_id) VALUES (178, 99);
INSERT INTO product_genre (product_id, genre_id) VALUES (178, 100);
INSERT INTO product_genre (product_id, genre_id) VALUES (178, 101);
INSERT INTO product_genre (product_id, genre_id) VALUES (178, 40);
INSERT INTO product_genre (product_id, genre_id) VALUES (179, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (179, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (180, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (180, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (181, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (181, 65);
INSERT INTO product_genre (product_id, genre_id) VALUES (181, 52);
INSERT INTO product_genre (product_id, genre_id) VALUES (181, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (181, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (182, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (182, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (182, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 42);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 91);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 52);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (183, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (184, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (184, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (184, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (185, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (185, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (185, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (185, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 96);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 82);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (186, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (187, 87);
INSERT INTO product_genre (product_id, genre_id) VALUES (187, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (187, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (187, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (188, 38);
INSERT INTO product_genre (product_id, genre_id) VALUES (188, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (188, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (189, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (189, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (190, 62);
INSERT INTO product_genre (product_id, genre_id) VALUES (190, 19);
INSERT INTO product_genre (product_id, genre_id) VALUES (191, 28);
INSERT INTO product_genre (product_id, genre_id) VALUES (191, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (191, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (192, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (192, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (192, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (193, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (193, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (194, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (194, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (194, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (195, 102);
INSERT INTO product_genre (product_id, genre_id) VALUES (195, 46);
INSERT INTO product_genre (product_id, genre_id) VALUES (195, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (195, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (196, 86);
INSERT INTO product_genre (product_id, genre_id) VALUES (196, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (196, 13);
INSERT INTO product_genre (product_id, genre_id) VALUES (196, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (197, 103);
INSERT INTO product_genre (product_id, genre_id) VALUES (197, 104);
INSERT INTO product_genre (product_id, genre_id) VALUES (197, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (198, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (198, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (199, 22);
INSERT INTO product_genre (product_id, genre_id) VALUES (199, 65);
INSERT INTO product_genre (product_id, genre_id) VALUES (199, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (200, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (200, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (201, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (201, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (202, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (202, 86);
INSERT INTO product_genre (product_id, genre_id) VALUES (202, 32);
INSERT INTO product_genre (product_id, genre_id) VALUES (202, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (203, 80);
INSERT INTO product_genre (product_id, genre_id) VALUES (203, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (204, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (204, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (204, 53);
INSERT INTO product_genre (product_id, genre_id) VALUES (204, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (204, 27);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 58);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 93);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 90);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 87);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 24);
INSERT INTO product_genre (product_id, genre_id) VALUES (205, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (206, 34);
INSERT INTO product_genre (product_id, genre_id) VALUES (206, 14);
INSERT INTO product_genre (product_id, genre_id) VALUES (206, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (207, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (207, 15);
INSERT INTO product_genre (product_id, genre_id) VALUES (207, 96);
INSERT INTO product_genre (product_id, genre_id) VALUES (207, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (208, 9);
INSERT INTO product_genre (product_id, genre_id) VALUES (208, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (208, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 6);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 7);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 3);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 2);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 82);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 4);
INSERT INTO product_genre (product_id, genre_id) VALUES (209, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (210, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (210, 51);
INSERT INTO product_genre (product_id, genre_id) VALUES (210, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (210, 5);
INSERT INTO product_genre (product_id, genre_id) VALUES (211, 60);
INSERT INTO product_genre (product_id, genre_id) VALUES (211, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (212, 39);
INSERT INTO product_genre (product_id, genre_id) VALUES (212, 45);
INSERT INTO product_genre (product_id, genre_id) VALUES (212, 25);
INSERT INTO product_genre (product_id, genre_id) VALUES (212, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (212, 40);
INSERT INTO product_genre (product_id, genre_id) VALUES (213, 105);
INSERT INTO product_genre (product_id, genre_id) VALUES (213, 16);
INSERT INTO product_genre (product_id, genre_id) VALUES (213, 23);
INSERT INTO product_genre (product_id, genre_id) VALUES (213, 18);
INSERT INTO product_genre (product_id, genre_id) VALUES (214, 26);
INSERT INTO product_genre (product_id, genre_id) VALUES (214, 31);
INSERT INTO product_genre (product_id, genre_id) VALUES (214, 5);

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
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('admin@example.com', 'admin', '$2y$10$va6YsvW0j0xJGMkOWPSeve.xzjMKkdrf0whoz.eO2OulmPI/C3KiO', false, true);
INSERT INTO users (email, username, password, is_blocked, is_admin) VALUES ('user@example.com', 'user', '$2y$10$4EdDFNhRogk4GgH4oCdbaeG7WOBgqRDccQUiGTHQDi/niaKG8XKdq', false, false);

INSERT INTO fav_artist (user_id, artist_id) VALUES (13,1);
INSERT INTO fav_artist (user_id, artist_id) VALUES (3,4);
INSERT INTO fav_artist (user_id, artist_id) VALUES (12,5);
INSERT INTO fav_artist (user_id, artist_id) VALUES (4,7);
INSERT INTO fav_artist (user_id, artist_id) VALUES (5,10);
INSERT INTO fav_artist (user_id, artist_id) VALUES (6,6);
INSERT INTO fav_artist (user_id, artist_id) VALUES (7,3);
INSERT INTO fav_artist (user_id, artist_id) VALUES (10,11);
INSERT INTO fav_artist (user_id, artist_id) VALUES (12,2);

INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (15, 5, 2, '2022-08-21', 'Terrible');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (11, 11, 3, '2022-06-24', 'It''s okay ig');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (7, 12, 5, '2022-07-12', 'AOTY');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (8, 10, 2, '2022-08-01', 'Atrocious');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (5, 6, 3, '2022-09-20', 'Decent tbh');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (20, 15, 4, '2022-10-20', 'Pretty good');
INSERT INTO review (reviewer_id, product_id, score, created_at, message) VALUES (10, 12, 1, '2022-11-02', 'I''d rather die than listen to this again');

INSERT INTO report (reporter_id, reported_id) VALUES (18, 13);
INSERT INTO report (reporter_id, reported_id) VALUES (3, 11);
INSERT INTO report (reporter_id, reported_id) VALUES (4, 15);
INSERT INTO report (reporter_id, reported_id) VALUES (5, 10);
INSERT INTO report (reporter_id, reported_id) VALUES (11, 20);
INSERT INTO report (reporter_id, reported_id) VALUES (6, 7);
INSERT INTO report (reporter_id, reported_id) VALUES (20, 12);
INSERT INTO report (reporter_id, reported_id) VALUES (17, 12);

INSERT INTO ticket (ticketer_id, message) VALUES (20, 'Missing package');
INSERT INTO ticket (ticketer_id, message) VALUES (1, 'I''m testing too');
INSERT INTO ticket (ticketer_id, message) VALUES (2, 'Tickets please xD In all seriousness my package didn''t arrive :(');
INSERT INTO ticket (ticketer_id, message) VALUES (6, 'Scaaaarryyyyy');
INSERT INTO ticket (ticketer_id, message) VALUES (14, 'Boo');
INSERT INTO ticket (ticketer_id, message) VALUES (5, 'I''m also testing');
INSERT INTO ticket (ticketer_id, message) VALUES (7, 'I''m testing to see what happens');
INSERT INTO ticket (ticketer_id, message) VALUES (18, 'Wrong order');

INSERT INTO orders (user_id, address, payment_method, state) VALUES (3, 'Address 1', 'MBWay', 'Processing');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (11, 'Address 2', 'MBWay', 'Processing');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (12, 'Address 3', 'MBWay', 'Shipped');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (10, 'Address 4', 'MBWay', 'Delivered');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (4, 'Address 5', 'Billing', 'Processing');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (8, 'Address 6', 'Billing', 'Shipped');
INSERT INTO orders (user_id, address, payment_method, state) VALUES (20, 'Address 7', 'Billing', 'Delivered');

INSERT INTO notif (sent_at, description, type) VALUES ('2022-08-21', 'Order has been sent', 'Order');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-06-24', 'Order has been sent', 'Order');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-07-12', 'Order has been sent', 'Order');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-08-01', 'Order has been sent', 'Order');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-09-20', 'Item on sale', 'Wishlist');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-10-20', 'WOW new sale', 'Wishlist');
INSERT INTO notif (sent_at, description, type) VALUES ('2022-11-02', 'Test message', 'Misc');

INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (8, 13);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (20, 14);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (15, 10);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (18, 3);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (7, 5);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (5, 12);
INSERT INTO wishlist_product (wishlist_id, product_id) VALUES (6, 1);