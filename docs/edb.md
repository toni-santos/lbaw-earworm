# EBD: Database Specification Component

## A4: Conceptual Data Model (UML)

### 1. Class Diagram:

### Additional Business Rules:

<br>

# A5: Relational Schema:

|Relation Reference|Relation Compact Notation|
|---|---|
|R01|user(<ins>id</ins>, email **UK NN**, username **UK NN**, password **NN**)|
|R02|client(<ins>user_id</ins>->user, email->user **UK NN**, username->user **NN**, password->user **NN**, cart_id->cart **NN**, wishlist_id->wishlist **NN**, is_blocked **NN**)|
|R03|admin(<ins>user_id</ins>->user,email->user **UK NN**, username->user **NN**, password->user **NN**)|
|R04|artist(<ins>id</ins>, name **NN**, description)|
|R05|client_artist(<ins>client_id</ins>->client, <ins>artist_id</ins>->artist)|
|R06|product(<ins>id</ins>, name **NN**, artist_id->artist **NN**, genre, price **NN**, stock **NN**, format **NN CK** format **IN** Formats, year **NN**, description **DF** NULL, rating **DF** NULL)|
|R07|genre(<ins>id</ins>, name **NN**)|
|R08|genre_product(<ins>genre_id</ins>->genre, <ins>product_id</ins>->product)
|R09|review(<ins>id</ins>, client_id->client **NN**, product_id->product **NN**, score **NN CK** score > 0 AND score <= 5, date **NN**, description **DF** NULL)|
|R10|order(<ins>id</ins>, client_id->client **NN**, state **NN CK** state **IN** orderStates)|
|R11|order_product(<ins>order_id</ins>->order, <ins>product_id</ins>->product, quantity)
|R12|wishlist(<ins>id</ins>, client_id->client **NN**)|
|R13|wishlist_product(<ins>wishlist_id</ins>->wishlist, <ins>product_id</ins>->product)|
|R14|cart(<ins>id</ins>, client_id->client **NN**)
|R15|cart_product(<ins>cart_id</ins>->cart, <ins>product_id</ins>->product, quantity **NN**)
|R16|notification(<ins>id</ins>, date **NN**, description **DF** NULL)|
|R17|misc_notif(<ins>notification_id</ins>->notification)|
|R18|wishlist_notif(<ins>notification_id</ins>->notification)|
|R19|order_notif(<ins>notification_id</ins>->notification)|
|R20|ticket(<ins>id</ins>, user_id->user **NN**, message **NN**)|
|R21|report(<ins>id</ins>, reporter_id->client **NN**, reported_id->client **NN**, message **NN**)

### Legend:

    UK = UNIQUE KEY
    NN = NOT NULL
    DF = DEFAULT
    CK = CHECK

## Domains:
|Domain Name|Domain Specification|
|---|---|
|**Formats**|ENUM('CD', 'Vinyl', 'Cassette', 'DVD', 'Box Set')|
|**orderStates**|ENUM('Order Placed', 'Processing', 'Preparing to Ship', 'Shipped', 'Delivered', 'Ready for Pickup', 'Picked up')|

## Schema Validation

|**Table R01**|**User**|
|---|---|
|**Keys**|{id}, {username}, {email}|
|**Functional Dependencies**:||
|FD0101|id -> {email, username, password}|
|FD0102|email -> {id, username, password}|
|FD0103|username -> (id, email, password)|
|**Normal Form**|BCNF|

|**Table R02**|**Client**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0201|id -> {email, username, password, cart_id, wishlist_id, is_blocked}|
|FD0202|email -> {id, username, password, cart_id, wishlist_id, is_blocked}|
|**Normal Form**|BCNF|

|**Table R03**|**Admin**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0301|id -> {email, username, password}|
|FD0302|email -> {id, username, password}|
|**Normal Form**|BCNF|

|**Table R04**|**Artist**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0401|id -> {name, description}|
|**Normal Form**|BCNF|

|**Table R05**|**Client_Artist**|
|---|---|
|**Keys**|{client_id, artist_id}|
|**Functional Dependencies**:||
|**Normal Form**|BCNF|

|**Table R06**|**Product**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0601|id -> {name, artist_id, price, stock, genre, format, year, rating}|
|**Normal Form**|BCNF|

|**Table R07**|**Genre**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0701|id -> {name}|
|**Normal Form**|BCNF|

|**Table R08**|**Genre_Product**|
|---|---|
|**Keys**|{genre_id, product_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R09**|**Review**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0801|id -> {client_id, product_id, score, date, description}|
|**Normal Form**|BCNF|

|**Table R10**|**Order**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0901|id -> {user, product_id, state}|
|**Normal Form**|BCNF|

|**Table R11**|**Order_Product**|
|---|---|
|**Keys**|{order_id, product_id}|
|**Functional Dependencies**:||
|FD1001|{order_id, product_id} -> {quantity}|
|**Normal Form**|BCNF|

|**Table R12**|**Wishlist**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1101|id -> {client_id}|
|**Normal Form**|BCNF|

|**Table R13**|**Wishlist_Product**|
|---|---|
|**Keys**|{wishlist_id, product_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R14**|**Cart**|
|---|---|
|**Keys**|{id} |
|**Functional Dependencies**:||
|FD1301|id -> {client_id}|
|**Normal Form**|BCNF|

|**Table R15**|**Cart_Product**|
|---|---|
|**Keys**|{cart_id, product_id}|
|**Functional Dependencies**:||
|FD1401|{cart_id, product_id} -> {quantity}|
|**Normal Form**|BCNF|

|**Table R16**|**Notification**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1501|id -> {date, description}|
|**Normal Form**|BCNF|

|**Table R17**|**Misc_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R18**|**Wishlist_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R19**|**Order_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R20**|**Ticket**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1901|id -> {user_id, message}|
|**Normal Form**|BCNF|

|**Table R21**|**Report**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD2001|id -> {reporter_id, reported_id, message}|
|**Normal Form**|BCNF|

<br>

# A6

## Database Workload:

|**Relation**|**Relation name**|**Order of magnitude**|**Estimated growth**
|---|---|---|---|
|R01|user|1k|100/day|
|R02|client|100|10/day|
|R03|admin|10|1/day|
|R04|artist|1k|10/day|
|R05|client_artist|100|10/day|
|R06|product|1k|100/day|
|R07|genre|10|1/day|
|R08|genre_product|1k|100/day|
|R09|review|100|10/day|
|R10|order|100|10/day|
|R11|order_product|10|1/day|
|R12|wishlist|100|10/day|
|R13|wishlist_product|1k|10/day|
|R14|cart|100|10/day|
|R15|cart_product|100|10/day|
|R16|notification|100|10/day|
|R17|misc_notif|10|1/day|
|R18|wishlist_notif|10|1/day|
|R19|order_notif|10|1/day|
|R20|ticket|10|1/day|
|R21|report|10|1/day|

#

## Proposed Indexes
### Performance Indexes

|**Index**|IDX01|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|artist_id|
|**Index Type**|B-tree|
|**Cardinality**|High|
|**Clustering**|Yes|
|**Justification**|Table 'Product' is very large. Several queries need to frequently filter access to the works by artist or category. Filtering is done by exact match, thus an hash type index would be best suited. However, since we also want to apply clustering based on this index, and clustering is not possible on hash type indexes, we opted for a b-tree index. Update frequency is low and cardinality is medium so it's a good candidate for clustering.|
|**SQL CODE**|
    CREATE INDEX ProductArtist ON Product USING btree (id_artist);
    CLUSTER product USING ProductArtist;

|**Index**|IDX02|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|genre|
|**Index Type**|B-tree|
|**Cardinality**|Medium|
|**Clustering**|Yes|
|**Justification**|Table 'Product' is very large. Several queries need to frequently filter access to products by genre. Filtering is done by exact match, thus an hash type index would be best suited. However, since we also want to apply clustering based on this index, and clustering is not possible on hash type indexes, we opted for a b-tree index. Update frequency is low and cardinality is medium so it's a good candidate for clustering.|
|**SQL CODE**|
    CREATE INDEX ProductGenre ON Product USING btree (genre);
    CLUSTER product USING ProductGenre;

|**Index**|IDX03|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|rating|
|**Index Type**|B-tree|
|**Cardinality**|medium|
|**Clustering**|Yes|
|**Justification**|Table 'Product' is very large. Several queries need to frequently filter access to products by rating. Filtering is done by exact match, thus an hash type index would be best suited. However, since we also want to apply clustering based on this index, and clustering is not possible on hash type indexes, we opted for a b-tree index. Update frequency is low and cardinality is medium so it's a good candidate for clustering.|
|**SQL CODE**|
    CREATE INDEX ProductRating ON Product USING btree (rating); 
    CLUSTER product USING ProductRating;


|**Index**|IDX04|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|format|
|**Index Type**|B-tree|
|**Cardinality**|medium|
|**Clustering**|Yes|
|**Justification**|Table 'Product' is very large. Several queries need to frequently filter access to products by format. Filtering is done by exact match, thus an hash type index would be best suited. However, since we also want to apply clustering based on this index, and clustering is not possible on hash type indexes, we opted for a b-tree index. Update frequency is low and cardinality is medium so it's a good candidate for clustering.|
|**SQL CODE**|
    CREATE INDEX ProductFormat ON Product USING btree (format); 
    CLUSTER product USING ProductFormat;

--MAYBE?
|**Index**|IDX05|
|---|---|
|**Index Relation**|WishlistProduct|
|**Index Attribute**|client_id|
|**Index Type**|Hash|
|**Cardinality**|High|
|**Clustering**|No|
|**Justification**|Table 'WishlistProduct' is frequently accessed to obtain a user's wishlisted items. Filtering is done by exact match, thus an hash type index would be best suited. Update frequency is low and cardinality is high, so this is a good candidate for clustering: however, this is a hash-type index, so no clustering is performed. If clustering was proposed, 'client_id' would be the most suitable index for it.|
|**SQL CODE**|;| 

### Full-text Search Indexes

|**Index**|IDX11|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|name, genre|
|**Index Type**|Hash|
|**Cardinality**|GIN|
|**Clustering**|No|
|**Justification**|Full-text search features to browse for products based on matching product name or genre. Index type is GIN because these fields are not expected to change often, if at all.|
|**SQL CODE**|;| 

|**Index**|IDX12|
|---|---|
|**Index Relation**|Artist|
|**Index Attribute**|name|
|**Index Type**|Hash|
|**Cardinality**|GIN|
|**Clustering**|No|
|**Justification**|Full-text search features to browse for artists based on matching names. Index type is GIN because these fields are not expected to change often, if at all.|
|**SQL CODE**|;| 

## Triggers

|**Trigger**|TRIGGER01|
|---|---|
|**Description**|Every new review updates a product's rating.|
|**SQL CODE**|
    CREATE FUNCTION review_product()
    RETURNS TRIGGER AS 
    $BODY$
        BEGIN
            CASE  
                WHEN (COUNT(SELECT * FROM Product WHERE NEW.product_id = id)) = 0 THEN 
                    UPDATE Product
                    SET rating = (SUM(SELECT rating FROM Product WHERE NEW.product_id = id) + NEW.score)
                ELSE
                    UPDATE Product
                    SET rating = (SUM(SELECT rating FROM Product WHERE NEW.product_id = id) + NEW.score) / COUNT(SELECT * FROM Product WHERE NEW.product_id = id)
            END CASE;

        RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;

    CREATE TRIGGER review_product
        AFTER INSERT OR UPDATE OR DELETE ON Review
        FOR EACH ROW
        EXECUTE PROCEDURE review_product();

|**Trigger**|TRIGGER02|
|---|---|
|**Description**|Maximum number of stored notifications for a single user must not exceed 25.|
|**SQL CODE**|
    CREATE FUNCTION limit_notification()
    RETURNS TRIGGER AS 
    $BODY$
        BEGIN 
        IF (COUNT(SELECT * FROM Notification WHERE NEW.client_id = client_id)) > 25 THEN 
            DELETE FROM Notification
            WHERE notification_id = (SELECT MIN(notification_id) FROM Notification WHERE client_id = NEW.client_id)
        END IF;
        RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;

    CREATE TRIGGER limit_notification
        AFTER INSERT ON Notification
        FOR EACH ROW
        EXECUTE PROCEDURE limit_notification();

|**Trigger**|TRIGGER03|
|---|---|
|**Description**|Update stock when an item is purchased.|
|**SQL CODE**|
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


|**Trigger**|TRIGGER04|
|---|---|
|**Description**|Do not allow products to be bought with a stock number of 0.|
|**SQL CODE**|
    CREATE FUNCTION nostock_restriction()
    RETURNS TRIGGER AS 
    $BODY$
        BEGIN 
        IF (SELECT stock FROM Product WHERE product_id = NEW.product_id) < NEW.quantity THEN 
            RAISE EXCEPTION 'This product can't be bought due to lack of stock at the moment.';
        END IF;
        RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;

    CREATE TRIGGER nostock_restriction()
        BEFORE INSERT ON OrderProduct
        FOR EACH ROW
        EXECUTE PROCEDURE nostock_restriction()

## Transactions

|**Trigger**|TRAN01|
|---|---|
|**Description**||
|**SQL CODE**|
    CREATE FUNCTION review_product()
    RETURNS TRIGGER AS 
    $BODY$
        BEGIN
            CASE  
                WHEN (COUNT(SELECT * FROM Product WHERE NEW.product_id = id)) = 0 THEN 
                    UPDATE Product
                    SET rating = (SUM(SELECT rating FROM Product WHERE NEW.product_id = id) + NEW.score)
                ELSE
                    UPDATE Product
                    SET rating = (SUM(SELECT rating FROM Product WHERE NEW.product_id = id) + NEW.score) / COUNT(SELECT * FROM Product WHERE NEW.product_id = id)
            END CASE;

        RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;

    CREATE TRIGGER review_product
        AFTER INSERT OR UPDATE OR DELETE ON Review
        FOR EACH ROW
        EXECUTE PROCEDURE review_product();