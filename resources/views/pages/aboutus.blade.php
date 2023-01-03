@include('partials.common.head', ['page' => "about-us", 'title' => ' - About Us'])

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
        <h2>Our Team</h2>
        <div id="team-members">
            <a href="https://github.com/toni-santos/" class="team-card">
                <img alt="Member Image" class="member-img tilt" src="https://avatars.githubusercontent.com/u/72560332?v=4">
                <div class="team-info">
                    <h2> António Santos </h2>
                    <p> CEO </p>
                </div>
            </a>
            <a href="https://github.com/PogfLux" class="team-card">
                <img alt="Member Image" class="member-img tilt" src="https://avatars.githubusercontent.com/u/80978330?v=4">
                <div class="team-info">
                    <h2>José Osório</h2>
                    <p> CEO </p>
                </div>
            </a>
            <a href="https://github.com/zeshillin/" class="team-card">
                <img alt="Member Image" class="member-img tilt" src="https://avatars.githubusercontent.com/u/79976078?v=4">
                <div class="team-info">
                    <h2> José Castro </h2>
                    <p> CEO </p>
                </div>
            </a>
            <a href="https://github.com/pedrosilva17/" class="team-card">
                <img alt="Member Image" class="member-img tilt" src="https://avatars.githubusercontent.com/u/75742355?v=4">
                <div class="team-info">
                    <h2> Pedro Silva </h2>
                    <p> CEO </p>
                </div>
            </a>
        </div>
    </section>
</main>
@include('partials.common.foot')