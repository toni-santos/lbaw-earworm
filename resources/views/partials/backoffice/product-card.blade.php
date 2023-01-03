<?php use App\Http\Controllers\UploadController; ?>
<div class="result-wrapper">
    <div class="result-top-{{$product->id}}" onclick="expandOptions(event, {{$product->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{UploadController::getProductProfilePic($product->id)}}>
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
        <div class="form-bot-wrapper">
            <form method="POST" class="form-bot" action="{{route('adminUpdateProduct', ['id' => $product->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <div class="form-spacer"></div>
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
                </section>
                <button class="confirm-button" type="submit">Change</button> 
            </form>
            <form method="POST" enctype="multipart/form-data" class="form-bot" action="{{route('adminUpdateProductProfilePic', ['id' => $product->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <label for="product-pfp-{{$product->id}}" class="upload-button">
                        <span class="material-icons">file_upload</span>File Upload
                    </label>
                    <input type="file" id="product-pfp-{{$product->id}}" name="product-pfp">
                </section>
                <button class="confirm-button" type="submit">Change photo</button>
            </form>

            <form method="POST" class="form-bot" action="{{route('adminDeleteProduct', ['product' => $product])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>
        </div>
    </div>
    
</div>
