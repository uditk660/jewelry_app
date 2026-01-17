// This file is the application's JavaScript manifest.
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function initAppUI(){
  var btn = document.querySelector('.nav-toggle');
  if(btn){
    // guard: don't attach duplicate handlers
    if(!btn.__navBound){
      btn.addEventListener('click', function(){
        var menu = document.querySelector('.nav-menu');
        if(menu) menu.classList.toggle('show');
      });
      btn.__navBound = true;
    }
  }
}

// Init on DOMContentLoaded for non-Turbolinks loads
document.addEventListener('DOMContentLoaded', initAppUI);

// Also init on Turbolinks page loads if Turbolinks is present
document.addEventListener('turbolinks:load', initAppUI);
