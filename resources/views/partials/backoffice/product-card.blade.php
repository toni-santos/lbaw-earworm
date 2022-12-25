<div>
    <div class="result-top-{{$product->id}}" onclick="expandOptions(event, {{$product->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{url('/images/products/' . $product['id'] . '.jpg')}}>
            <div class="result-info">
                <p>ID: {{$product->id}}</p>
                <p>Name: {{$product->name}}</p>
                <p>Artist: {{$product->artist->name}}</p>
                <p>Genre: 
                    @foreach ($product->genres as $genre)
                        {{$genre['name']}},
                    @endforeach
                </p>
                <p>Price: {{$product->price / 100}}€</p>
                <p>Stock: {{$product->stock}}</p>
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$product->id}}" style="display:none;">
        <form method="POST" class="form-bot" action="{{route('adminUpdateProduct', ['id' => $product->id])}}">
            {{ csrf_field() }}
            <section class="inputs-box">
                <div class="input-container">
                    <label for="stock">Stock</label>
                    <input id="stock" name="stock" type="number" min="1" step="any" value={{request('max-price')}}>
                </div>
            </section>
            <button class="confirm-button" type="submit">Change</button>
        </form>
        <form method="POST" class="form-bot" action="{{route('adminDeleteProduct', ['user' => $product])}}">
            {{ csrf_field() }}
            <button class="confirm-button" type="submit">Delete</button>
        </form>
    </div>
    
</div>
