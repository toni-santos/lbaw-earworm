<?php use App\Http\Controllers\UploadController; ?>
<div class="result-wrapper">
    <div class="result-top-{{$product->id}}" onclick="expandOptions(event, {{$product->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{uploadController::getProductProfilePic($product->id)}}>
            <div class="result-info">
                <p>ID: {{$product->id}}</p>
                <p>Name: {{$product->name}}</p>
                <p>Artist: {{$product->artist->name}}</p>
                <p>Genre: 
                    @foreach ($product->genres as $genre)
                        {{$genre['name']}},
                    @endforeach
                </p>
                <p>Stock: {{$product->stock}}</p>
                <p>Stock Price: {{$product->price / 100}}€</p>
                <p>Discount on Store: {{$product->discount}}
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
                        <input class="text-input" type="number" name="stock" min="0" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="stock">Stock</label>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="price" name="price" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="price">Price (in €) </label>
                    </div>
                    <div class="input-container">
                        <select class="select-input" name="discount" id="sales-form-group">
                            <option value="0" selected hidden> Discount % </option>
                            <option value="0"> Discount: 0% </option> 
                            <option value="10"> Discount: 10% </option> 
                            <option value="20"> Discount: 20% </option> 
                            <option value="30"> Discount: 30% </option> 
                            <option value="50"> Discount: 50% </option> 
                            <option value="70"> Discount: 70% </option> 
                        </select>
                    </div>
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
