<?php

namespace App\View\Components;

use Illuminate\View\Component;

class Carousel extends Component
{

    private bool $promo = false;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->promo = false;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\Contracts\View\View|\Closure|string
     */
    public function render()
    {
        if ($this->promo) {
            return view('components.promos');
        } else {
            return view('components.carousel');
        }
    }
}
