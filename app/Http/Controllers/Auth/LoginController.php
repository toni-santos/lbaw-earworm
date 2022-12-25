<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = '/';

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function authenticate(Request $request) {

        $credentials = [
            'email' => $request->all()['email'],
            'password' => $request->all()['pwd']
        ];

        if (Auth::attempt($credentials)) {
        
            if (Auth::user()->is_blocked){ 
                $this->logout($request);
                return back();
            }

            $request->session()->regenerate();

            if (Auth::User()->is_admin) {
                return to_route('adminIndex');
            }
            
            return redirect()->intended('/');
        }

        return back()->withErrors([
            'email' => 'Incorrect credentials.'
        ])->onlyInput('email');

    }

    public function logout(Request $request) {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }

    /*
    public function getUser(){
        return $request->user();        echo "auth attempt";

    }

    public function home() {
        return redirect('login');
    }
    */

}
