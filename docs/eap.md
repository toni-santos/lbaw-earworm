# EAP 

# A7: Web Resources Specification

### 1. Overview:
These are the modules that will be part of the application. They were aggregated in accordance to the needs of the platform.

|Module name|Description|
|---|---|
|M01: Authentication and Indiviual Profile|Web resources associated with user authentication and individual profile management. Includes the following system features: EarWorm login/logout, last.fm login/logout, EarWorm registration, credential recovery, view and edit personal profile information, payment option management.| 
|M02: Products|Web resources associated with products. Includes the following system features: product listing, product search and filter, view and edit product page/details, add product, delete product.| 
|M03: Artists|Web resources associated with artists. Includes the following system features: view and edit artist page/details.| 
|M04: Reviews|Web resources associated with reviews. Includes the following system features: add reviews, view reviews, edit reviews and delete reviews.|
|M05: Wishlist|Web resources associated with wishlists. Includes the following system features: add products to wishlist and remove products from wishlist.
|M06: Orders|Web resources associated with orders. Includes the following system features: add order, view orders, track order, delete order.|
|M07: Reports and Tickets|Web resources associated with reports and tickets. Includes the following system features: add report, view report, delete report, add ticket, view ticket and delete ticket.|
|M08: User Administration and Static pages|Web resources associated with user management, specifically: view users, delete or block user accounts, view and change user information, view system access details for each user. Web resources with static content are associated with this module: dashboard, about, contact, services and faq.|

#

## 2. Permissions
Permissions are divided into 4 categories, as described below.

|Tag|Name|Description|
|---|---|---|
|VIS|Visitor|Users without privileges|
|CLI|Client|Authenticated users|
|OWN|Owner|Clients that are owners of information, like personal profile or wishlisted products|
|ADM|Administrator|System administrators|

#

## 3. OpenAPI Specification

#

## A8: Vertical Prototype

### 1. Implemented Features
As of this date (17/11/2022), the features present in this section limit themselves to basic functionalities pertaining to site visitors and logged in clients, as they are the only users able to interact with the soon-to-be deployed vertical prototype. Products and artists are present for basic interaction features, like adding products to the user's cart, but medium priority user stories like wishlisting an item will be added only further down the development process. 

#### 1.1 Implemented User Stories

##### User:

|Identifier|Name|Priority|Description|
|---|---|---|---|
|US001|See Homepage|High|As a User, I want to access the home page, so that I can see a brief presentation of the website and instantly start browsing through products|
|US006|See Artist Page|High|As a User, I want to access an artist's musical catalog, so that I can search through artist-specific related products in an organized way|
|US007|See Product Page|High|As a User, I want to access a product's information (name, artist's name, stock, price, etc.), so that I can be aware of what the product is|
|US008|View Product List|High|As a User, I want to be able to look at the full list of products available, so that I can quickly have a rough idea of which products interest me|
|US009|View Product Details|High|As a User, I want to check product details, so that I can be more informed about what I could be buying|
|US015|Browse Products through Multiple Attributes|High|As a User, I want to be able to search through the site's database by matching multiple attributes or categories, so that I can explicitly find the product(s) I am looking for|


##### Visitor:

|Identifier|Name|Priority|Description|
|---|---|---|---|
|US101|Sign-in|High|As a Visitor, I want to authenticate into the system, so that I can access privileged information|
|US102|Sign-up|High|As a Visitor, I want to register myself into the system, so that I can authenticate myself into the system|
|US103|Add Product to Cart|High|As a Visitor, I want to be able to add a product to my online shopping cart, so that I can track the products I am interested in buying|
|US104|Remove Product from Cart|High|As a Visitor, I want to be able to remove a product from my online shopping cart, so that I can discard the products I am no longer interested in buying|

##### Client:

|Identifier|Name|Priority|Description|
|---|---|---|---|
|US201|Sign-out|High|As a Client, I want to log out of my account, so that I am no longer signed in while using the website|
|US204|View Profile|High|As a Client, I want to be able to see my own profile, so that I can check information regarding my account|
|US207|Checkout|High|As a Client, I want to be able to checkout, so that I can buy products|

#### 1.2 Implemented Web Resources