@include('partials.common.head', ['page' => "about-us"])
<main id="about-us-main">
    <section id="about-us-introduction">
            <h1> About Us </h1>
            <p> 
                The EarWorm website is developed and maintained by a small group of FEUP students 
                with a passion for both music and the preservation of its physical mediums. Earworm aims to 
                be a platform targeted at individual users that wish to buy physical musical products, an 
                activity which still boasts a dedicated community online.
            </p>
    </section>
    
    <section id="team-wrapper">
        <span> <h2> ---- Our Team ----  </h2> <span>
        <div id="team-wrapper-row">
            <div class="team-wrapper-col">
                <div class="team-card">
                    <div class="team-img">
                        <img src="https://picsum.photos/200/300" width="100%">
                        <div class="team-info">
                            <h2> António Santos </h2>
                            <p> description </p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="team-wrapper-col">
                <div class="team-card">
                    <div class="team-img">
                        <img src="https://picsum.photos/200/300" width="100%">
                        <div class="team-info">
                            <h2> José Osório </h2>
                            <p> description </p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="team-wrapper-col">
                <div class="team-card">
                    <div class="team-img" id=>
                        <img src="https://picsum.photos/200/300" width="100%">
                        <div class="team-info">
                            <h2> José Castro </h2>
                            <p> description </p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="team-wrapper-col">
                <div class="team-card">
                    <div class="team-img">
                        <img src="https://picsum.photos/200/300" width="100%">
                        <div class="team-info">
                            <h2> Pedro Silva </h2>
                            <p> description </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>
@include('partials.common.foot')