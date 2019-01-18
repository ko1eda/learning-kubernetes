<?php

use App\User;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return [
        'name' => 'test :)'
    ];
});


Route::get('/users', function () {
    return User::all();
});

Route::get('/user', function () {
    $user = new User();

    $user->name = 'guy fieri';
    $user->password = \Hash::make('secret');
    $user->email = 'fake@fake.com';

    $user->save();
});
