# EAP 

## A7: Web Resources Specification

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
|M07: Cart|Web resources associated with carts. Includes the following system features: add product to cart, decrease product amount in cart, remove product from cart.|
|M08: Reports and Tickets|Web resources associated with reports and tickets. Includes the following system features: add report, view report, delete report, add ticket, view ticket and delete ticket.|
|M09: User Administration and Static pages|Web resources associated with user management, specifically: view users, delete or block user accounts, view and change user information, view system access details for each user. Web resources with static content are associated with this module: dashboard, about, contact, services and faq.|

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

[Link to OpenAPI Specification file](https://git.fe.up.pt/lbaw/lbaw2223/lbaw22123/-/blob/main/docs/a7_openapi.yaml)

```yaml
openapi: 3.0.0

info:
 version: '1.0'
 title: 'LBAW EarWorm Web API'
 description: 'Web Resources Specification (A7) for MediaLibrary'

servers:
- url: http://lbaw.fe.up.pt
  description: Production server

externalDocs:

tags:
 - name: 'M01: Authentication and Individual Profile'
 - name: 'M02: Products'
 - name: 'M03: Artists'
 - name: 'M04: Reviews'
 - name: 'M05: Wishlist'
 - name: 'M06: Orders'
 - name: 'M07: Cart'
 - name: 'M08: Reports and Tickets'
 - name: 'M09: User Administration and Static pages'

paths:

  # -------------- #
  # M01 - Authentication and Individual Profile #

  /login:
   get:
     operationId: R101
     summary: 'R101: Login Form'
     description: 'Provide login form. Access: VIS'
     tags:
       - 'M01: Authentication and Individual Profile'
     responses:
       '200':
         description: 'Ok. Show Login UI'
   post:
     operationId: R102
     summary: 'R102: Login Action'
     description: 'Process the login form submission. Access: VIS'
     tags:
       - 'M01: Authentication and Individual Profile'

     requestBody:
       required: true
       content:
         application/x-www-form-urlencoded:
           schema:
             type: object
             properties:
               email:          # <!--- form field name
                 type: string
               password:    # <!--- form field name
                 type: string
             required:
                  - email
                  - password

     responses:
       '302':
         description: 'Redirect after processing the login credentials.'
         headers:
           Location:
             schema:
               type: string
             examples:
               302Success:
                 description: 'Successful authentication. Redirect to user profile.'
                 value: '/user/{id}'
               302Error:
                 description: 'Failed authentication. Redirect to login form.'
                 value: '/login'

  /logout:
    post:
      operationId: R103
      summary: 'R103: Logout Action'
      description: 'Logout the current authenticated user. Access: CLI, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '302':
          description: 'Redirect after processing logout.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful logout. Redirect to login form.'
                  value: '/login'

  /register:
    get:
      operationId: R104
      summary: 'R104: Register Form'
      description: 'Provide new user registration form. Access: VIS'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '200':
          description: 'Ok. Show Sign-Up UI'

    post:
      operationId: R105
      summary: 'R105: Register Action'
      description: 'Process the new user registration form submission. Access: VIS'
      tags:
        - 'M01: Authentication and Individual Profile'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                name:
                  type: string
                email:
                  type: string
                picture:
                  type: string
                  format: binary
                password:
                  type: string
              required:
                - email
                - password

      responses:
        '302':
          description: 'Redirect after processing the new user information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful authentication. Redirect to user profile.'
                  value: '/user/{id}'
                302Error:
                  description: 'Failed authentication. Redirect to login form.'
                  value: '/login'

  /user/{id}:
    parameters:
      - in: path
        name: id
        schema:
          type: integer
        required: true

    get:
      operationId: R106
      summary: 'R106: View User Profile'
      description: 'Show a user profile page. Access: VIS, OWN, ADM'
      tags:
        - 'M01: Authentication and Individual Profile'

      responses:
        '200':
          description: 'Ok. Show User Profile UI'

  /user/{id}/settings:
    parameters:
      - in: path
        name: id
        schema:
          type: integer
        required: true
    
    get:
      operationId: R107
      summary: 'R107: Edit Profile Form'
      description: 'Provide edit profile form. Access: OWN'
      tags:
        - 'M01: Authentication and Individual Profile'
      responses:
        '200':
          description: 'Ok. Show Edit Profile UI'
        '403':
          description: 'You do not have the required permissions to access this page.'

    post:
      operationId: R108
      summary: 'R108: Edit Profile Action'
      description: 'Process the edit profile form submission. Access: OWN'
      tags:
        - 'M01: Authentication and Individual Profile'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                email:
                  type: string

      responses:
        '302':
          description: 'Redirect after processing the new user information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful edit. Redirect to user profile.'
                  value: '/user/{id}'
                302Error:
                  description: 'Failed edit. Redirect to user profile.'
                  value: '/user/{id}'               

  /user:
    get:
      operationId: 'R109'
      summary: 'R109: View Own Profile'
      description: 'Show individual user profile page. Access: OWN'
      tags:
        - 'M01: Authentication and Individual Profile'

      responses:
        '200':
          description: 'Ok. Show User Profile UI'

  # -------------- #
  # M02 - Products #
 
  /api/products:
    get:
      operationId: R201
      summary: 'R201: Search Products API'
      description: 'Search for products and return the results as JSON. Access: VIS, CLI, ADM'

      tags:
        - 'M02: Products'

      parameters:
        - in: query
          name: query
          description: 'String to use for full-text search'
          schema:
            type: string
          required: false

        - in: query
          name: genre
          description: 'Genre of the product'
          schema:
            type: string
          required: false

        - in: query
          name: min_score
          description: 'Minimum score of the product'
          schema:
            type: float
          required: false
          
        - in: query
          name: max_score
          description: 'Maximum score of the product'
          schema:
            type: float
          required: false
        
        
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: array
                products:
                  type: object
                  properties:
                    id:
                      type: integer
                    name:
                      type: string
                    artist_id:
                      type: integer
                    price:
                      type: float
                    stock:
                      type: integer
                    format:
                      type: string
                    genre:
                      type: string
                    year:
                      type: integer
                    description:
                      type: string
                    score:
                      type: float
                example:
                - id: 1
                  name: "GOAA (Greatest Of All Albums)"
                  artist_id: 109
                  price: 12.00
                  stock: 300
                  format: "Vinyl"
                  genre: "Pop"
                  year: "2020"
                  description: "The greatest album ever made!!"
                  score: 1.25
                - id: 2
                  name: "Mixtape no.1"
                  artist_id: 127
                  price: 5.00
                  stock: 20
                  format: "Cassette"
                  genre: "Rap"
                  year: "2021"
                  description: "I was bored and made some music."
                  score: 4.99

  /product/{id}:
    parameters:
      - in: path
        name: id
        description: Product ID
        schema:
          type: integer
        required: true
        
    get:
      operationId: R202
      summary: 'R202: View Product Page'
      description: "Show a specific product page, where all of its information is displayed. Access: VIS, CLI, ADM"

      tags:
        - 'M02: Products'

      responses:
        '200':
          description: 'Ok. Show Product Page UI'
        '404':
          description: 'This product does not exist in our store.'
        

  /products:
    get:
      operationId: R203
      summary: 'R203: View Catalogue'
      description: "Show a page with all of the available products."

      tags:
        - 'M02: Products'

      responses:
        '200':
          description: 'Ok. Show Catalogue UI'

  # -------------- #
  # M03 - Artists  #

  /artist/{id}:
    parameters:
      - in: path
        name: id
        description: Artist ID
        schema:
          type: integer
        required: true

    get:
      operationId: R301
      summary: 'R301: View Artist Page'
      description: "Show a specific artist page, where all of its information is displayed. Access: VIS, CLI, ADM"

      tags:
        - 'M03: Artists'

      responses:
        '200':
          description: 'Ok. Show Artist Page UI'
        '404':
          description: 'This artist does not exist in our store.'

  # ------------ #
  # M06 - Orders #

  /checkout:
    get:
      operationId: R601
      summary: 'R601: Checkout Form'
      description: 'Provide checkout form. Access: VIS, OWN'
      tags:
        - 'M06: Order'
      responses:
        '200':
          description: 'Ok. Show Checkout UI'

    /checkout/order/:
      post:
        operationId: R602
        summary: 'R602: Checkout Action'
        description: 'Process the checkout form submission. Access: VIS, OWN'
        tags:
          - 'M06: Order'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                products:
                  type: array
                  product:
                    type: object
                    properties:
                      id:
                        type: integer
                      price:
                        type: float
                      quantity:
                        type: integer
              required:
                - products

      responses:
        '302':
          description: 'Redirect after processing checkout.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful checkout. Redirect to home.'
                  value: '/'
                302Error:
                  description: 'Failed checkout. Redirect to checkout.'
                  value: '/checkout'

  # ------------ #
  # M07 - Cart   #

  /cart/increase/{id}:
    parameters:
      - in: path
        name: id
        description: Product ID
        schema:
          type: integer
        required: true

    post:
      operationId: 'R701'
      summary: 'R701: Increase Product Amount on Cart'
      description: 'Increases the amount of a product on the cart by one, or adds it to the cart if it is not there already. Access: VIS, CLI'
      tags:
        - 'M07 - Cart'

      requestBody:
        required: true
        content:
          application/json: {}

      responses:
        '200':
          description: 'Ok. Product successfully added'

  /cart/decrease/{id}:
    parameters:
      - in: path
        name: id
        description: Product ID
        schema:
          type: integer
        required: true

    post:
      operationId: 'R702'
      summary: 'R702: Decrease Product Amount on Cart'
      description: 'Decreases the amount of a product on the cart by one. Access: VIS, CLI'
      tags:
        - 'M07 - Cart'

      requestBody:
        required: true
        content:
          application/json: {}

      responses:
        '200':
          description: 'Ok. Product amount successfully decreased'

  /cart/remove/{id}:
    parameters:
      - in: path
        name: id
        description: Product ID
        schema:
          type: integer
        required: true

    post:
      operationId: 'R703'
      summary: 'R703: Remove Product from Cart'
      description: 'Removes a product from the cart. Access: VIS, CLI'
      tags:
        - 'M07 - Cart'

      requestBody:
        required: true
        content:
          application/json: {}

      responses:
        '200':
          description: 'Ok. Product successfully removed from cart'

  # ----------------------------------------- #
  # M09: User Administration and Static pages #

  /admin:
    get:
      operationId: R901
      summary: 'R901: Admin Page'
      description: 'Show admin page. Access: ADM'
      tags:
        - 'M09: User Administration and Static pages'
      responses:
        '200':
          description: 'Ok. Show Admin Page UI'

  /admin/{id}:
    parameters:
      - in: path
        name: id
        schema:
          type: integer
        required: true

    post:
      operationId: R902
      summary: 'R902: Admin Edit User Action'
      description: 'Processes the changes made by an admin to a user. Access: ADM'
      tags:
        - 'M09: User Administration and Static pages'

      requestBody:
        required: true
        content:
          application/x-www-form-urlencoded:
            schema:
              type: object
              properties:
                username:
                  type: string
                email:
                  type: string
                is_blocked:
                  type: bool

      responses:
        '302':
          description: 'Redirect after processing the new user information.'
          headers:
            Location:
              schema:
                type: string
              examples:
                302Success:
                  description: 'Successful edit. Redirect to admin page.'
                  value: '/admin'
                302Error:
                  description: 'Failed edit. Redirect to admin page.'
                  value: '/admin'
```

## A8: Vertical Prototype

### 1. Implemented Features
As of this date (24/11/2022), the features present in this section limit themselves to basic functionalities pertaining to site visitors and logged-in clients, as they are the only users able to interact with the deployed vertical prototype. Products are present for basic interaction features, like adding products to the users cart, but medium priority user stories like wishlisting an item will only be added further down the development process. 

#### 1.1 Implemented User Stories

##### User:

|Identifier|Name|Priority|Description|
|---|---|---|---|
|US001|See Homepage|High|As a User, I want to access the home page, so that I can see a brief presentation of the website and instantly start browsing through products|
|US007|See Product Page|High|As a User, I want to access a products information (name, artists name, stock, price, etc.), so that I can be aware of what the product is|
|US008|View Product List|High|As a User, I want to be able to look at the full list of products available, so that I can quickly have a rough idea of which products interest me|
|US009|View Product Details|High|As a User, I want to check product details, so that I can be more informed about what I could be buying|
|US015|Browse Products through Multiple Attributes|High|As a User, I want to be able to search through the sites database by matching multiple attributes or categories, so that I can explicitly find the product(s) I am looking for|


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
|US205|Edit Profile|High|As a Client, I want to be able to edit my profile, so that I can change my accounts private and public information if I want to|
|US207|Checkout|High|As a Client, I want to be able to checkout, so that I can buy products|

##### Administrator:

|Identifier|Name|Priority|Description|
|---|---|---|---|
|US305|Block client accounts|High|As an Administrator, I want to be able to block certain accounts, so that I can keep the website free of users with malicious intent|
|US306|Unblock client accounts|High|As an Administrator, I want to be able to unblock certain accounts, so that I can allow previously blocked users back on the platform|


#### 1.2 Implemented Web Resources

**M01 - Authentication and Individual Profile**

|Web Resource Reference|URL|
|---|---|
|R101: Login Form|GET /login|
|R102: Login Action|POST /login|
|R103: Logout Action|POST /logout|
|R104: Register Form|GET /register|
|R105: Register Action|POST /register|
|R106: View User Profile|GET /user/{id}|
|R107: Edit Profile Form|GET /user/{id}/settings|
|R108: Edit Profile Action|POST /user/{id}/settings|
|R109: View Own Profile|GET /user|

**M02: Products**

|Web Resource Reference|URL|
|---|---|
|R201: Search Products API|GET /api/products|
|R202: View Product Page|GET /product/{id}|
|R203: View Catalogue|GET /products|

**M03: Artists**

|Web Resource Reference|URL|
|---|---|
|R301: View Artist Page|GET /artist/{id}|

**M06: Orders**

|Web Resource Reference|URL|
|---|---|
|R601: Checkout Form|GET /checkout|
|R602: Checkout Action|POST /checkout|

**M07: Cart**

|Web Resource Reference|URL|
|---|---|
|R701: Increase Product Amount on Cart|POST /cart/increase/{id}|
|R702: Decrease Product Amount on Cart|POST /cart/decrease/{id}|
|R703: Remove Product from Cart|POST /cart/remove/{id}|

**M09: User Administration and Static pages**

|Web Resource Reference|URL|
|---|---|
|R901: Admin Page|GET /admin|
|R902: Admin Edit User Action|POST /admin/{id}|

### 2. Prototype

The prototype is available at https://lbaw22123.lbaw.fe.up.pt

Credentials:

    email: insectlover@gmail.com
    password: iloveworms!123

The code is available at https://git.fe.up.pt/lbaw/lbaw2223/lbaw22123