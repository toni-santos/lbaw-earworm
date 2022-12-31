<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class UploadController extends Controller
{   
    public function uploadUserProfilePic(Request $request, int $id) {

        if ($id != Auth::id() && !Auth::user()->is_admin) abort(403);        
        $is_admin = $id != Auth::id() && Auth::user()->is_admin;

        $validator = Validator::make($request->all(), [
            'user-pfp' => 'required|mimes:jpeg,jpg,png,svg'
        ]);
        
        if ($validator->fails()) 
            return back()->withErrors(['error' => 'Invalid or no picture uploaded.']);
        
        $image = $request->file('user-pfp');
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();

        $pfp_filepath = glob(storage_path('app/public/images/users/' . $id . '.*'));
        if (!empty($pfp_filepath)) {

            $pfp_filepath = explode('/', $pfp_filepath[0]);
            $pfp_filename = end($pfp_filepath);
            Storage::delete('public/images/users/' . $pfp_filename);

        }
        
        Storage::putFileAs('public/images/users', $image, $filename);

        if ($is_admin) return to_route('adminUser');
        return redirect()->route('profile', ['id' => $id])->with(['message' => 'Profile picture updated!']);
        
    }
    
    public static function getUserProfilePic($id) {

        $pfp_filepath = glob(storage_path('app/public/images/users/' . $id . '.*'));
    
        if (empty($pfp_filepath)) {
            $pfp = url('storage/images/default.png');
        } else {
            $pfp = explode('/', $pfp_filepath[0]);
            $pfp = url('storage/images/users/' . end($pfp));
        }

        return $pfp;
    }

    public function uploadArtistProfilePic(Request $request) {

        $data = $request->all();
        $validator = Validator::make($request->all(), [
            'artist-pfp' => 'required|mimes:jpeg,jpg,png,svg'
        ]);

        if ($validator->fails()) 
            return back()->withErrors(['error' => 'Invalid or no picture uploaded.']);

        $image = $request->file('artist-pfp');
        $id = $data['id'];
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();

        $pfp_filepath = glob(storage_path('app/public/images/artists/' . $id . '.*'));
        if (!empty($pfp_filepath)) {

            $pfp_filepath = explode('/', $pfp_filepath[0]);
            $pfp_filename = end($pfp_filepath);
            Storage::delete('public/images/artists/' . $pfp_filename);

        }

        Storage::putFileAs('public/images/artists', $image, $filename);
        return to_route('adminArtist')->with(['message' => 'Artist profile picture updated!']);;

    }

    public static function getArtistProfilePic($id) {

        $pfp_filepath = glob(storage_path('app/public/images/artists/' . $id . '.*'));
    
        if (empty($pfp_filepath)) {
            $pfp = url('storage/images/default.png');
        } else {
            $pfp = explode('/', $pfp_filepath[0]);
            $pfp = url('storage/images/artists/' . end($pfp));
        }

        return $pfp;
        
    }

    public function uploadProductProfilePic(Request $request) {

        $data = $request->all();
        $validator = Validator::make($request->all(), [
            'product-pfp' => 'required|mimes:jpeg,jpg,png,svg'
        ]);

        if ($validator->fails()) 
            return back()->withErrors(['error' => 'Invalid or no picture uploaded.']);

        $image = $request->file('product-pfp');
        $id = $data['id'];
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();

        $pfp_filepath = glob(storage_path('app/public/images/products/' . $id . '.*'));
        if (!empty($pfp_filepath)) {

            $pfp_filepath = explode('/', $pfp_filepath[0]);
            $pfp_filename = end($pfp_filepath);
            Storage::delete('public/images/products/' . $pfp_filename);

        }

        Storage::putFileAs('public/images/products', $image, $filename);
        return to_route('adminProduct')->with(['message' => 'Product image updated!']);;

    }

    public static function getProductProfilePic($id) {

        $pfp_filepath = glob(storage_path('app/public/images/products/' . $id . '.*'));
    
        if (empty($pfp_filepath)) {
            $pfp = url('storage/images/default.png');
        } else {
            $pfp = explode('/', $pfp_filepath[0]);
            $pfp = url('storage/images/products/' . end($pfp));
        }

        return $pfp;
    }
    
}
