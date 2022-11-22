<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Product;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;


class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $user = User::findOrFail($id);
        if ($user->is_blocked) {
            abort(404);
        }
        
        $favArtists = $user->favouriteArtists->toArray();
        
        return view('pages.user', [
            'user' => $user,
            'favArtists' => $favArtists,
            'purchaseHistory' => Product::all()->take(5),
            'recommendedProducts' => Product::all()->take(5)
        ]);
    }

    public function ownprofile()
    {
        if (Auth::id()) {
            return to_route('profile', ['id' => Auth::id()]);
        }
        else {
            return to_route('login');
        }
    }


    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    public function editProfile(int $id) {
        $user = User::findOrFail($id);
        if (!(Auth::user()->is_admin || Auth::id() == $id)) abort(403);
        return view('pages.settings', ['user' => $user]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, int $id)
    {
        $user = User::findOrFail($id);
        if ($user->is_blocked) {
            abort(404);
        }
        
        $data = $request->toArray();

        if ($user->is_admin) {
            $user->is_blocked = array_key_exists('block', $data);
        }

        $user->username = $data['username'] ?? $user->username;
        $user->email = $data['email'] ?? $user->email;

        $user->save();

        return to_route('profile', ['id' => $id]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function destroy(User $user)
    {
        //
    }
}
