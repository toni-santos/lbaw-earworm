<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;


class AdminController extends Controller
{
    /**
     * Display the specified resource.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function show(Request $request)
    {
        if (!Auth::user() || !Auth::user()->is_admin) abort(403);

        $search = !empty($request->toArray()) ? $request->toArray()['user'] : '';
        
        $users = User::search($search)->where('is_admin', 0)->get();//->paginate(20);
        return view('pages.admin', ['users' => $users]);
    }

    public function showUserCreate() 
    {
        if (!Auth::user() || !Auth::user()->is_admin) abort(403);

        return view('auth.admin-create');
    }

   /**
     * Create a new user after a valid registration.
     *
     * @param  array  $data
     * @return \App\Models\User
     */
    public function create(Request $request) {

        $data = $request->toArray();

        $user = User::where('email', $data['email'])->first();
        
        if (!is_null($user))
            return back()->withErrors('User already exists.');

        User::create([
            'email' => $data['email'],
            'username' => $data['username'],
            'password' => bcrypt($data['pwd']),
            'is_admin' => array_key_exists('admin', $data)
        ]);

        return to_route('adminpage');
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function edit(User $user)
    {
        return view('pages.settings', ['id' => $user->id]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, int $id)
    {
        $user = User::findOrFail($id);
        $data = $request->toArray();

        $user->username = $data['username'] ?? $user->username;
        $user->email = $data['email'] ?? $user->email;
        $user->is_blocked = array_key_exists('block', $data); 

        $user->save();

        return to_route('adminpage');
    }

    public function findUser() {
        // $users = User::search(request('search'))->paginate(20);

        // return view('pages.admin', ['users' => $users]);
    }
}
