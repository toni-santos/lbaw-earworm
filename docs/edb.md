# EBD: Database Specification Component

## A4: Conceptual Data Model (UML)

### 1. Class Diagram:

### Additional Business Rules:

# Relational Schema:

|Relation Reference|Relation Compact Notation|
|---|---|
|R01|user(<ins>id</ins>, email **UK NN**, username **NN**, password **NN**)|
|R02|client(<ins>user_id</ins>->user, email->user **UK NN**, username->user **NN**, password->User **NN**, is_blocked **NN**)|
|R03|admin(<ins>user_id</ins>->user,email->user **UK NN**, username->user **NN**, password->User **NN**)|
|R04|artist(<ins>id</ins>, name **NN**)|
|R05|client_artist(<ins>client_id</ins>->client, <ins>artist_id</ins>->artist)
|R06|product(<ins>id</ins>, name **NN**, artist_id->artist **NN**, price **NN**, format **NN CK** format **IN** Formats, year **NN**, rating **DF** NULL)|
|R07|artist_product(<ins>artist_id</ins>->artist **NN**, <ins>product_id</ins>->product **NN**)|
|R08|review(<ins>id</ins>->user, <ins>product_id</ins>->product, score **NN CK** score > 0 AND score <= 5, date **NN**, description DF NULL)|
|R09|order(<ins>id</ins>, <ins>client_id</ins>->client, state **NN**)|
|R10|order_product(<ins>order_id</ins> -> order, <ins>product_id</ins> -> product)
|R11|wishlist(<ins>id</ins>, <ins>client_id</ins>->client)|
|R12|wishlist_product(<ins>wishlist_id</ins> -> wishlist, <ins>product_id</ins> -> product)|
|R13|cart(<ins>id</ins>, <ins>client_id</ins>->client)
|R14|cart_product(<ins>cart_id</ins>->cart, <ins>product_id</ins>->product, quantity **NN**)
|R15|notification(<ins>id</ins>, date, description DF NULL)|
|R16|misc_notif(<ins>notification_id</ins>->notification)|
|R17|wishlist_notif(<ins>notification_id</ins>->notification)|
|R18|order_notif(<ins>notification_id</ins>->notification)|
|R19|ticket(<ins>user_id</ins>->user, message **NN**)|
|R20|report(<ins>reporter_id</ins>->client, <ins>reported_id</ins>->client, message **NN**)

### Legend:

    UK = UNIQUE KEY
    NN = NOT NULL
    DF = DEFAULT
    CK = CHECK

## Domains:
|Domain Name|Domain Specification|
|---|---|
|**Formats**|ENUM('CD', 'Vynil', 'Cassette', 'DVD' 'Box Set')|
|**orderStates**|ENUM('Order Placed', 'Processing', 'Preparing to Ship', 'Shipped', 'Delivered', 'Shipping to Store', 'Ready for Pickup', 'Picked up')|

## Schema Validation

|**Table R01**|**User**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0101|id -> { email, username, password }|
|FD0102|email -> { id, username, password}|
|**Normal Form**|BCNF|

|**Table R02**|**Client**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0101|id -> { email, username, password }|
|FD0102|email -> { id, username, password}|
|**Normal Form**|BCNF|

|**Table R03**|**Admin**|
|---|---|
|**Keys**|{id}, {email}|
|**Functional Dependencies**:||
|FD0101|id -> { email, username, password }|
|FD0102|email -> { id, username, password}|
|**Normal Form**|BCNF|

|**Table R04**|**Artist**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0101|id -> { name }|
|**Normal Form**|BCNF|

|**Table R04**|**Artist**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0101|id -> { name }|
|**Normal Form**|BCNF|

|**Table R05**|**Client_Artist**|
|---|---|
|**Keys**|{client_id, artist_id}|
|**Functional Dependencies**:||
|**Normal Form**|BCNF (?)|


|**Table R06**|**Product**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0101|id -> { name, artist_id, price, format, year, rating }|
|**Normal Form**|BCNF (?)|
