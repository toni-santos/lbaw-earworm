<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class UploadController extends Controller
{

    public function showUploadUserProfilePic() {
        return view();
    }
    
    public function showUploadArtistProfilePic() {
        return view();
    }

    public function showUploadProductProfilePic() {
        return view();
    }

    
    public function uploadUserProfilePic(Request $request) {
        
        $validator = Validator::make($request->all(), [
            'image' => 'required|mimes:jpeg,jpg,png,svg'
        ]);
        
        if ($validator->fails()) return back()->withErrors(['error' => 'Invalid or no picture uploaded']);
        
        $image = $request->file('image');
        $id = Auth::id();
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();
        
        Storage::putFileAs('public/images/users', $image, $filename);
        
        return to_route('profile', ['id' => $id]);
        
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
            'image' => 'required|mimes:jpeg,jpg,png,svg'
        ]);

        if ($validator->fails()) return back()->withErrors(['error' => 'Invalid or no picture uploaded']);

        $image = $request->file('image');
        $id = $data['id'];
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();

        Storage::putFileAs('public/images/artists', $image, $filename);

        return to_route('adminArtist');

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
            'image' => 'required|mimes:jpeg,jpg,png,svg'
        ]);

        if ($validator->fails()) return back()->withErrors(['error' => 'Invalid or no picture uploaded']);

        $image = $request->file('image');
        $id = $data['id'];
        $filename = strval($id) . '.' . $image->getClientOriginalExtension();

        Storage::putFileAs('public/images/products', $image, $filename);

        return to_route('adminProduct');

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
