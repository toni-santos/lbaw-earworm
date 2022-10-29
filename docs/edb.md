# EBD: Database Specification Component

## A4: Conceptual Data Model (UML)

### 1. Class Diagram:

### Additional Business Rules:

<br>

# A5: Relational Schema:

|Relation Reference|Relation Compact Notation|
|---|---|
|R01|user(<ins>id</ins>, email **UK NN**, username **NN**, password **NN**)|
|R02|client(<ins>user_id</ins>->user, email->user **UK NN**, username->user **NN**, password->user **NN**, cart_id->cart **NN**, wishlist_id->wishlist **NN**, is_blocked **NN**)|
|R03|admin(<ins>user_id</ins>->user,email->user **UK NN**, username->user **NN**, password->user **NN**)|
|R04|artist(<ins>id</ins>, name **NN**, description)|
|R05|client_artist(<ins>client_id</ins>->client, <ins>artist_id</ins>->artist)|
|R06|product(<ins>id</ins>, name **NN**, artist_id->artist **NN**, genre, price **NN**, format **NN CK** format **IN** Formats, year **NN**, rating **DF** NULL)|
|R07|review(<ins>id</ins>, client_id->client **NN**, product_id->product **NN**, score **NN CK** score > 0 AND score <= 5, date **NN**, description **DF** NULL)|
|R08|order(<ins>id</ins>, client_id->client **NN**, state **NN CK** state **IN** orderStates)|
|R09|order_product(<ins>order_id</ins>->order, <ins>product_id</ins>->product, quantity)
|R10|wishlist(<ins>id</ins>, client_id->client **NN**)|
|R11|wishlist_product(<ins>wishlist_id</ins>->wishlist, <ins>product_id</ins>->product)|
|R12|cart(<ins>id</ins>, client_id->client **NN**)
|R13|cart_product(<ins>cart_id</ins>->cart, <ins>product_id</ins>->product, quantity **NN**)
|R14|notification(<ins>id</ins>, date **NN**, description **DF** NULL)|
|R15|misc_notif(<ins>notification_id</ins>->notification)|
|R16|wishlist_notif(<ins>notification_id</ins>->notification)|
|R17|order_notif(<ins>notification_id</ins>->notification)|
|R18|ticket(<ins>id</ins>, user_id->user **NN**, message **NN**)|
|R19|report(<ins>id</ins>, reporter_id->client **NN**, reported_id->client **NN**, message **NN**)

### Legend:

    UK = UNIQUE KEY
    NN = NOT NULL
    DF = DEFAULT
    CK = CHECK

## Domains:
|Domain Name|Domain Specification|
|---|---|
|**Formats**|ENUM('CD', 'Vynil', 'Cassette', 'DVD' 'Box Set')|
|**orderStates**|ENUM('Order Placed', 'Processing', 'Preparing to Ship', 'Shipped', 'Delivered', 'Ready for Pickup', 'Picked up')|

## Schema Validation

|**Table R01**|**User**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0101|id -> {email, username, password}|
|FD0102|email -> {id, username, password}|
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
|FD0601|id -> {name, artist_id, price, genre, format, year, rating}|
|**Normal Form**|BCNF|

|**Table R07**|**Review**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0801|id -> {client_id, product_id, score, date, description}|
|**Normal Form**|BCNF|

|**Table R08**|**Order**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0901|id -> {user, product_id, state}|
|**Normal Form**|BCNF (?)|

|**Table R09**|**Order_Product**|
|---|---|
|**Keys**|{order_id, product_id}|
|**Functional Dependencies**:||
|FD1001|{order_id, product_id} -> {quantity}|
|**Normal Form**|BCNF|

|**Table R10**|**Wishlist**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1101|id -> {client_id}|
|**Normal Form**|BCNF|

|**Table R11**|**Wishlist_Product**|
|---|---|
|**Keys**|{wishlist_id, product_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R12**|**Cart**|
|---|---|
|**Keys**|{id} |
|**Functional Dependencies**:||
|FD1301|id -> {client_id}|
|**Normal Form**|BCNF|

|**Table R13**|**Cart_Product**|
|---|---|
|**Keys**|{cart_id, product_id}|
|**Functional Dependencies**:||
|FD1401|{cart_id, product_id} -> {quantity}|
|**Normal Form**|BCNF|

|**Table R14**|**Notification**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1501|id -> {date, description}|
|**Normal Form**|BCNF|

|**Table R15**|**Misc_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R16**|**Wishlist_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R17**|**Order_Notif**|
|---|---|
|**Keys**|{notification_id}|
|**Functional Dependencies**:||
|None||
|**Normal Form**|BCNF|

|**Table R18**|**Ticket**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD1901|id -> {user_id, message}|
|**Normal Form**|BCNF|

|**Table R19**|**Report**|
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
|R07|review|100|10/day||
|R08|order|100|10/day|
|R09|order_product|10|1/day|
|R10|wishlist|100|10/day|
|R11|wishlist_product|1k|10/day|
|R12|cart|100|10/day|
|R13|cart_product|100|10/day|
|R14|notification|100|10/day|
|R15|misc_notif|10|1/day|
|R16|wishlist_notif|10|1/day|
|R17|order_notif|10|1/day|
|R18|ticket|10|1/day|
|R19|report|10|1/day|

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
|**SQL CODE**|CREATE INDEX ArtistProduct<br> ON Product USING btree (id_artist);<br> CLUSTER product USING ArtistProduct;|

|**Index**|IDX02|
|---|---|
|**Index Relation**|Product|
|**Index Attribute**|genre|
|**Index Type**|B-tree|
|**Cardinality**|Medium|
|**Clustering**|Yes|
|**Justification**|Table 'Product' is very large. Several queries need to frequently filter access to the works by artist or category. Filtering is done by exact match, thus an hash type index would be best suited. However, since we also want to apply clustering based on this index, and clustering is not possible on hash type indexes, we opted for a b-tree index. Update frequency is low and cardinality is medium so it's a good candidate for clustering.|
|**SQL CODE**|CREATE INDEX ArtistGenre <br> ON Product USING btree (genre); <br> CLUSTER product USING ArtistGenre;|

|**Index**|IDX03|
|---|---|
|**Index Relation**|Order|
|**Index Attribute**|client_id|
|**Index Type**|Hash|
|**Cardinality**|High|
|**Clustering**|No|
|**Justification**|Table 'Order' is frequently accessed to obtain a user's orders. Filtering is done by exact match, thus an hash type index would be best suited. Update frequency is low and cardinality is high, so this is a good candidate for clustering: however, this is a hash-type index, so no clustering is performed. If clustering was proposed, 'client_id' would be the most suitable index for it.|
|**SQL CODE**|;| 

|**Index**|IDX04|
|---|---|
|**Index Relation**|CartProduct|
|**Index Attribute**|client_id|
|**Index Type**|Hash|
|**Cardinality**|High|
|**Clustering**|No|
|**Justification**|Table 'Order' is frequently accessed to obtain a user's orders. Filtering is done by exact match, thus an hash type index would be best suited. Update frequency is low and cardinality is high, so this is a good candidate for clustering: however, this is a hash-type index, so no clustering is performed. If clustering was proposed, 'client_id' would be the most suitable index for it.|
|**SQL CODE**|;| 

|**Index**|IDX05|
|---|---|
|**Index Relation**|WishlistProduct|
|**Index Attribute**|client_id|
|**Index Type**|Hash|
|**Cardinality**|High|
|**Clustering**|No|
|**Justification**|Table 'Order' is frequently accessed to obtain a user's orders. Filtering is done by exact match, thus an hash type index would be best suited. Update frequency is low and cardinality is high, so this is a good candidate for clustering: however, this is a hash-type index, so no clustering is performed. If clustering was proposed, 'client_id' would be the most suitable index for it.|
|**SQL CODE**|;| 

### Full-text Search Indexes


