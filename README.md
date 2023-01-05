# lbaw-earworm

> For music lovers who want a tailored retailer of their favorite artists' releases, EarWorm is a website that provides a trustworthy and all-inclusive selection of music.

![EarWorm](/docs/home.png)

[Small Demonstration Video](https://youtu.be/8hV3KfyZhCw)

The EarWorm website was developed by a small group of FEUP students, with a passion for both music and the preservation of its physical mediums, as a platform targeted at individual users that wish to buy physical musical products.

The main goal of the project is the development of a web-based and individually stylized music store for browsing and buying musical merchandise such as CDs, vinyls or other music affiliated products. After the initial deployment of the site, a team of administrators is required and will be responsible for managing the system and the stock, as well as ensuring any transaction runs smoothly.

This online platform grants users access to a vast library of purchaseable musical content, while also keeping track of their on-site transactions. Products are available for worldwide distribution, providing a myriad of payment options. Curated recommendations will be provided to each user based on their listening preferences.

Users are separated into groups with different permissions. These groups include the site administrators, with complete access and modification privileges, and the registered users, with privileges to enter information, buy and cancel ordered items, browse and inspect the site's products and rate previously obtained items.

The platform has a responsive design, allowing users to have a pleasant browsing experience not only visually but functionally as well, regardless of the device (desktop, tablet or smartphone).

The database information was obtained from the [Discogs](https://www.discogs.com/) website, through a combination of the [discogs API](https://www.discogs.com/developers) and scraping the website for extra resources. Some of the scripts used in these endeavours are available [here](https://github.com/toni-santos/lbaw-earworm/tree/main/scripts).

## 1. Installation

[Link to the final version of the source code](https://github.com/toni-santos/lbaw-earworm)

In order to install and run follow these steps:

> Start by cloning the repository & entering the directoty
> ```git clone https://git.fe.up.pt/lbaw/lbaw2223/lbaw22123.git & cd lbaw22123```

> Open a terminal window and link laravel's storage and serve a server
> ```php artisan storage:link```
> ```php artisan serve```

> On a separate window start the composer container for the database
> ```docker compose up```

> Be sure to check which ```.env``` file you are using during this process (prod or dev)

## 2. Usage

If you are locally deployed and running your own server, you may visit ```http://127.0.0.1:8000``` to start using the application.

If you have access to FEUP's VPN server you may also visit the deployed page at ```http://lbaw22123.lbaw.fe.up.pt``` 

### 2.1. Administration Credentials

Administration URL: ```http://127.0.0.1:8000/admin```  

| Username             | Password |
| -------------------- | -------- |
| admin@example.com    | password |

### 2.2. User Credentials

| Type          | Username           | Password     |
| ------------- | ------------------ | ------------ |
| basic account | user@example.com   | userpassword |
