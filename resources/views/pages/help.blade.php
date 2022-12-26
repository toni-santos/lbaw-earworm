@include('partials.common.head', ['page' => "help"])
<main>
    @include('partials.common.subtitle', ['title' => "FAQ"])
    <div id="faq-wrapper">
        <div class="faq-section-container">
            <div id="faq-section-top-account" onclick="toggleFAQSection(event, 'account')"> 
                <h3> Account & Site Features </h3> 
                <span class="material-icons">expand_more</span>
            </div>
            <div id="faq-section-bot-account" style="display:none">
                <div id="faq-drop-top-account-1" onclick="toggleFAQ(event, 'account', 1)"> 
                    <p> How do I edit my account profile? </p>
                    <span class="material-icons">expand_more</span>
                </div>
                <div id="faq-drop-bot-account-1" style="display:none">
                    Changing your username is possible from your profile settings. You are free to 
                    change your username as many times as you like.
                    <br>
                    Make sure you are logged in to your account. In the profile navbar dropdown on the top-right,
                    click on <a href={{route('editprofile', ['id' => Auth::id()])}}> settings. </a>
                    <ol> 
                        <li> In the navbar in top-centre of the page, click on "Account Information". </li>
                        <li> Input your new account username or email. </li>
                        <li> Click on the submit "Change" button </li>
                    </ol>
                        
                    All done! Your account has been updated.
                </div>
            
                <div id="faq-drop-top-account-2" onclick="toggleFAQ(event, 'account', 2)"> 
                    <p>How do I change my password?</p>
                    <span class="material-icons">expand_more</span>
                </div>
                <div id="faq-drop-bot-account-2" style="display:none">
                    Changing your password is possible from your profile settings. You are free to 
                    change your password as many times as you like.
                    <br>
                    Make sure you are logged in to your account. In the profile navbar dropdown on the top-right,
                    click on <a href={{route('editprofile', ['id' => Auth::id()])}}> settings </a>.
                    <ol> 
                        <li> In the navbar in top-centre of the page, click on "Change Password". </li>
                        <li> Input your old password in the first text-box and your new password in the next two. </li>
                        <li> Click on the submit "Change Password" button </li>
                    </ol>
                        
                    All done! Your account has been updated.
                </div>
            </div>
        </div>
        <div class="faq-section-container">
            <div id="faq-section-top-policy" onclick="toggleFAQSection(event, 'policy')"> 
                <h3> Site Policy</h3> 
                <span class="material-icons">expand_more</span>
            </div>
            <div id="faq-section-bot-policy" style="display:none">
                <div id="faq-drop-top-policy-1" onclick="toggleFAQ(event, 'policy', 1)"> 
                    <p> Community Guidelines </p>
                    <span class="material-icons">expand_more</span>
                </div>
                <div id="faq-drop-bot-policy-1" style="display:none">
                    <p style="font-weight:bold"> A certain kind of behaviour is expected at EarWorm. </p>
                    <br>
                    <ul>
                        <li> Always be helpful and polite </li>
                        <li> Be kind to new users </li>
                        <li> Leave truthful and appropriate reviews </li>
                        <li> Respect intellectual property rights </li>
                    </ul>
                    <br>
                    <p style="font-weight:bold"> What kind of behaviour is unacceptable? </p>
                    <br>
                    <ul>
                        <li> Rudeness and belittling language are not tolerated </li>
                        <li> Keep your opinions respectful, especially if they are of political nature </li>
                        <li> If you are having trouble with another user, notify staff using the Help & Ticket section at the bottom of this page </li>
                        <li> DO NOT post private information publicly </li>
                        <li> Don't impersonate other users </li>
                        <li> No spam </li>
                    </ul>
                </div>
            
                <div id="faq-drop-top-policy-2" onclick="toggleFAQ(event, 'policy', 2)"> 
                    <p> Business Rules </p>
                    <span class="material-icons">expand_more</span>
                </div>
                <div id="faq-drop-bot-policy-2" style="display:none">
                    Our team is fully commited to providing an inclusive and accessible user experience while keeping the site
                    available and robust. To this end, we make sure that the following rules are followed:
                    <br>
                    <ul>
                        <li> Site Availability: The system must be available 99 percent of the time in each 24-hour period. </li>
                        <li> Site Usability: The system should be simple and easy to use. </li>
                        <li> Site Robustness: The system must be prepared to handle and continue operating when runtime errors occur </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</main>
@include('partials.common.foot')