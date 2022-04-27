
// sample settings
window.max_idle_time = 10 // in minutes
window.max_idle_time_ms = window.max_idle_time * 60 * 1000; // in milliseconds 
window.logout_url="./logout";

timer = undefined;

function init_activity_check() 
{
  markActive();

  // for the whole window
  window.addEventListener('click', markActive);
  window.addEventListener('keydown', markActive);

  // for each iframe
  detectIframes();

  resetTimer();
};


function resetTimer()
{
  if (timer)
  {
    clearInterval(timer);
  }
  timer = setInterval(checkForInactivity, window.max_idle_time_ms);
  // will check again to see if the user has been idle
};

function doLogout()
{
     console.error("logging you out");
     window.location = window.logout_url;
};

function checkForInactivity()
{
  curr = Date.now()
  console.log("window.lastActivity :",  window.lastActivity);
  console.log("curr :",  curr);
 
  diff = curr - window.lastActivity ;
  if( diff >= window.max_idle_time_ms )
  {
     console.log("idle for :",  diff);
     doLogout();
  }
  resetTimer();
};

function detectIframes() 
{
  let frameElements = document.getElementsByTagName("iframe");
  for( let i = 0; i < frameElements.length; i++) 
  {
    frameElements[i].contentWindow.document.addEventListener('click', markActive); // on mouse click
    frameElements[i].contentWindow.document.addEventListener('keydown', markActive); // on key press
  }
};

document.addEventListener("visibilitychange", function() 
{
  markActive()
});

function markActive() 
{
  window.lastActivity = Date.now();
  resetTimer(); // clock restarts now
};

//  Main

init_activity_check();
