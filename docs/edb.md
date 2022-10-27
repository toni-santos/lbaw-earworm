# EBD: Database Specification Component

## A4: Conceptual Data Model (UML)

### 1. Class Diagram:

### Additional Business Rules:

<br>

# A5: Relational Schema:

|Relation Reference|Relation Compact Notation|
|---|---|
|R01|user(<ins>id</ins>, email **UK NN**, username **NN**, password **NN**)|
|R02|client(<ins>user_id</ins>->user, email->user **UK NN**, username->user **NN**, password->User **NN**, is_blocked **NN**)|
|R03|admin(<ins>user_id</ins>->user,email->user **UK NN**, username->user **NN**, password->User **NN**)|
|R04|artist(<ins>id</ins>, name **NN**, description)|
|R05|client_artist(<ins>client_id</ins>->client, <ins>artist_id</ins>->artist)|
|R06|product(<ins>id</ins>, name **NN**, artist_id->artist **NN**, price **NN**, format **NN CK** format **IN** Formats, year **NN**, rating **DF** NULL)|
|R07|artist_product(<ins>artist_id</ins>->artist **NN**, <ins>product_id</ins>->product **NN**)|
|R08|review(<ins>id</ins>->user, <ins>product_id</ins>->product, score **NN CK** score > 0 AND score <= 5, date **NN**, description DF NULL)|
|R09|order(<ins>id</ins>, <ins>client_id</ins>->client, state **NN**)|
|R10|order_product(<ins>order_id</ins> -> order, <ins>product_id</ins> -> product, quantity)
|R11|wishlist(<ins>id</ins>, <ins>client_id</ins>->client)|
|R12|wishlist_product(<ins>wishlist_id</ins> -> wishlist, <ins>product_id</ins> -> product)|
|R13|cart(<ins>id</ins>, <ins>client_id</ins>->client)
|R14|cart_product(<ins>cart_id</ins>->cart, <ins>product_id</ins>->product, quantity **NN**)
|R15|notification(<ins>id</ins>, date, description DF NULL)|
|R16|misc_notif(<ins>notification_id</ins>->notification)|
|R17|wishlist_notif(<ins>notification_id</ins>->notification)|
|R18|order_notif(<ins>notification_id</ins>->notification)|
|R19|ticket(id, <ins>user_id</ins>->user, message **NN**)|
|R20|report(id,  <ins>reporter_id</ins>->client, <ins>reported_id</ins>->client, message **NN**)

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
|FD0201|id -> {email, username, password}|
|FD0202|email -> {id, username, password}|
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
|FD0401|id -> {name}|
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
|FD0601|id -> {name, price, format, year, rating}|
|**Normal Form**|BCNF|

|**Table R07**|**Review**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0801|id -> {product_id, product, score, date, description}|
|**Normal Form**|BCNF|

|**Table R08**|**Order**|
|---|---|
|**Keys**|{id}|
|**Functional Dependencies**:||
|FD0901|id -> {user, product_id}|
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

|---|---|
|**Index**|IDX01|
|**Index Relation**|Product|
|**Index Attribute**|artist_id|
|**Index Type**|IDX01|
|**Cardinality**|IDX01|
|**Clustering**|IDX01|
|**Justification**|IDX01|