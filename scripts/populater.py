import shutil
import discogs_client
import json
import time
import requests

d = discogs_client.Client('ExampleApplication/0.1', user_token="direMLOPEjcyVavKsrpQNKPuyWjfZwEuqarCklLq")
headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36'}

def get_release(id, releases, artists, genres):
    print("\n\nRELEASE", id, '\n\n')

    release_dict = {}

    release = d.release(id)

    print("name: " + str(release.title))
    release_dict['name'] = str(release.title)
    
    print("format: " + str(release.formats[0]['name']))
    release_dict['format'] = str(release.formats[0]['name'])
    
    artist = str([x.name for x in release.artists][0])
    print("artists: " + str([x.name for x in release.artists][0]))
    if artist not in artists:
        artists.append([x.name for x in release.artists][0])
    release_dict['artist'] = str(artists.index(artist))
    
    print("genres: " + str(release.styles + release.genres))
    genres_list = release.styles + release.genres
    release_dict['genres'] = []
    for i in genres_list:
        if i not in genres:
            genres.append(i)
        release_dict['genres'].append(str(genres.index(i)))        

    print("year: " + str(release.year))
    release_dict['year'] = str(release.year)

    print("photos: " + str(release.images[0]['uri']))
    release_dict['photo'] = str(release.images[0]['uri'])

    print("tracklist: " + str([x.title for x in release.tracklist]))
    release_dict['tracklist'] = str([str(x.title) for x in release.tracklist])

    print("price: " + str(release.marketplace_stats.lowest_price.value) + "€")
    release_dict['price'] = str(release.marketplace_stats.lowest_price.value)

    releases.append(release_dict)

    time.sleep(1)

def get_artist(artist, artists):
    print("\n\nARTIST ", artist, '\n\n')
    
    artist_dict = {}

    artist = d.search(artist, type='artist')[0]

    artist_dict['name'] = str(artist.name)

    print(artist.images[0]['uri'])
    artist_dict['pfp'] = str(artist.images[0]['uri'])

    print(artist.profile)
    artist_dict['description'] = str(artist.profile).replace('"', "'")

    artists.append(artist_dict)

    time.sleep(1)

def download_images(releases, artists):
    for c, i in enumerate(releases):
        req = requests.get(i['photo'], stream=True, headers=headers)
        if req.status_code == 200:
            req.raw.decode_content = True
            with open("./images/products/"+str(c + 1)+".jpg", 'wb') as f:
                shutil.copyfileobj(req.raw, f)
            f.close()
        else:
            print("failed to download")
    
    for c, i in enumerate(artists):
        req = requests.get(i['pfp'], stream=True, headers=headers)
        if req.status_code == 200:
            req.raw.decode_content = True
            with open("./images/artists/"+str(c + 1)+".jpg", 'wb') as f:
                shutil.copyfileobj(req.raw, f)
            f.close()
        else:
            print("failed to download")

def generate_populate(releases, artists, genres):
    f = open("database_populate.sql", "w")
    f.write("PRAGMA foreign_keys = ON;\n\n")
    
    product_table_name = "Product"
    product_table_struct = "(artist_id, name, price, format, year, rating)"
    artists_table_name = "Artist"
    artists_table_struct = "(name, description)"
    genres_table_name = "Genres"
    genres_table_struct = "(name)"
    genprod_table_name = "ProductGenre"
    genprod_table_struct = "(product_id, genre_id)"

    # Create genres table
    for i in genres:
        gen_line = "INSERT INTO " + genres_table_name + " " + genres_table_struct + " VALUES " + "(\"" + i + "\");\n"
        f.write(gen_line)
    f.write('\n');

    # Create artists table
    for i in artists:
        art_line = "INSERT INTO " + artists_table_name + " " + artists_table_struct + " VALUES " + "(\"" + i['name'] + "\", \"" + i['description'] + "\");\n"
        f.write(art_line)
    f.write('\n');

    # Create product table
    for i in releases:
        prod_line = "INSERT INTO " + product_table_name + " " + product_table_struct + " VALUES " + "(" + i['artist'] + ", \"" + i['name'] + "\", " + i['price'] + ", " + i['format'] + ", " + i['year'] + ", NULL);\n"
        f.write(prod_line)
    f.write('\n');

    for c, i in enumerate(releases):
        for j in i['genres']:
            genprod_line = "INSERT INTO " + genprod_table_name + " " + genprod_table_struct + " VALUES " + "(" + str(int(c) + 1) + ", " + str(int(j) + 1) + ");\n"
            f.write(genprod_line)
    f.write('\n');

    f.close()


def main():
    artists_names = []
    releases = []
    artists = []
    genres = []

    # Retrieve release and artist information alongside formats and genres
    with open('ids.json', "r") as ids:
        data = json.load(ids)
    for i in data['releases']:
        get_release(i, releases, artists_names, genres)
    for i in artists_names:
        get_artist(i, artists)
    ids.close()

    # Create and write the populate file
    generate_populate(releases, artists, genres)
    download_images(releases, artists)
    
if __name__ == "__main__":
    main()