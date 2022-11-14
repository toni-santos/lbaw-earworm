# EAP 

# A7: Web Resources Specification

### 1. Overview:

|Module name|Description|
|---|---|
|M01: Authentication and Indiviual Profile|Web resources associated with user authentication and individual profile management. Includes the following system features: EarWorm login/logout, last.fm login/logout, EarWorm registration, credential recovery, view and edit personal profile information, payment option management.| 
|M02: Products|Web resources associated with products. Includes the following system features: product listing, product search and filter, view and edit product page/details, add product, delete product.| 
|M03: Artists|Web resources associated with artists. Includes the following system features: view and edit artist page/details.| 
|M04: Reviews|Web resources associated with reviews. Includes the following system features: add reviews, view reviews, edit reviews and delete reviews.|
|M05: Wishlist|Web resources associated with wishlists. Includes the following system features: add products to wishlist and remove products from wishlist.
|M06: Orders|Web resources associated with orders. Includes the following system features: add order, view orders, track order, delete order.|
|M07: Cart|Web resources associated with carts. Includes the following system features: Add product to cart and remove product from cart.
|M08: Reports and Tickets|Web resources associated with reports and tickets. Includes the following system features: add report, view report, delete report, add ticket, view ticket and delete ticket.|
|M09: User Administration and Static pages|Web resources associated with user management, specifically: view users, delete or block user accounts, view and change user information, view system access details for each user. Web resources with static content are associated with this module: dashboard, about, contact, services and faq.|

#

## 2. Permissions

|Tag|Name|Description|
|---|---|---|
|VIS|Visitor|Users without privileges|
|CLI|Client|Authenticated users|
|OWN|Owner| Clients that are owners of information, like personal profile or wishlisted products|
|ADM|Administrator|System administrators|

#

## 3. OpenAPI Specification



