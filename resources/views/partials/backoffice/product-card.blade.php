<div class="result-wrapper">
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
    <div class="result-bot-{{$product->id}}">
        <div>
            <form method="POST" class="form-bot" action="{{route('adminUpdateProduct', ['id' => $product->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <div class="input-container">
                        <input class="text-input" type="number" name="stock" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="stock">Stock</label>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="number" name="price" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="price">Price</label>
                    </div>
                    <fieldset id="sales-form-group">
                        <label class="static-label" for="10per">
                            <input type="radio" id="10per" name="sales-form-group">
                            10%</label>
                        <label class="static-label" for="20per">
                            <input type="radio" id="20per" name="sales-form-group">
                            20%</label>
                        <label class="static-label" for="30per">
                            <input type="radio" id="30per" name="sales-form-group">
                            30%</label>
                        <label class="static-label" name="50per" for="50per">
                            <input type="radio" id="50per" name="sales-form-group">
                            50%</label>
                        <label class="static-label" for="70per">
                            <input type="radio" id="70per" name="sales-form-group">
                            70%</label>
                    </fieldset>
                    <button class="confirm-button" type="submit">Change</button> 
                </section>
            </form>
            <form method="POST" class="form-bot" action="{{route('adminDeleteProduct', ['product' => $product])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>
        </div>
    </div>
    
</div>
