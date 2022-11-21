<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Genre;
use Illuminate\Auth\Access\HandlesAuthorization;

class GenrePolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any models.
     *
     * @param  \App\Models\Genre  $genre
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function viewAny(Genre $genre)
    {
        //
    }

    /**
     * Determine whether the user can view the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Genre  $genre
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function view(User $user, Genre $genre)
    {
        //
    }

    /**
     * Determine whether the user can create models.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function create(User $user)
    {
        return $user->is_admin;
    }

    /**
     * Determine whether the user can update the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Genre  $genre
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function update(User $user, Genre $genre)
    {
        return $user->is_admin;
    }

    /**
     * Determine whether the user can delete the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Genre  $genre
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function delete(User $user, Genre $genre)
    {
        return $user->is_admin;
    }
}