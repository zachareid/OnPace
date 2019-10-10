using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

//View1 globals
var min_pace = 7;
var sec_pace = 0;
var change_pace_min = true;

var pace_seconds = 0;
var pace_seconds_min = 0;
var pace_seconds_max = 0;
var pace_str_min = "";
var pace_str_max = "";
var pace_str = "";

var cur_pace_seconds = 0;
var cur_pace_str = "";

//View2 globals
var min_rad = 0;
var sec_rad = 30;
var change_rad_min = true;

//Set this true when a session has been initialized
var revert_to_first;



class OnPaceApp extends App.AppBase {
	var firstView;

    //! onStart() is called on application start up
    function onStart() 
    {
    	revert_to_first = false;
    }

    //! onStop() is called when your application is exiting
    function onStop() 
    {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	firstView = new OnPaceFirstView();
        return [ firstView, new OnPaceFirstDelegate() ];
    }
}
