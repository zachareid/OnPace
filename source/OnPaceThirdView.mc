using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Activity as Activity;
using Toybox.ActivityRecording as Record;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;




//Session variablees
module appStates
{
	enum 
	{
		STATE_NULL,
		STATE_WAITING,
		STATE_RUNNING_SCREEN1,
		STATE_RUNNING_SCREEN2,
		STATE_SAVEREQUEST
	}
}

var vibrate_alert = 	[
						new Attention.VibeProfile(  100, 100 ),
                        new Attention.VibeProfile(  100, 100 )
                        ];

var vibe_ind = 0;
var reached_pace_range = false;


// State values
var current_state;
var session = null;
var recording = false;
var cur_pace = 0;
var cur_time = 0;
var cur_dist = 0;


var init_time;
var timer_reachpace;
var errorstring = "";
var timer = null;
var metpersec_to_minpermile = 26.8224;


class OnPaceThirdView extends Ui.View 
{	
	function onPosition()
	{
		Sys.println("onPosition call");
	}
    function onShow() 
    {
    	revert_to_first = true;
    	timer_reachpace = new Timer.Timer();
    	timer_reachpace.start(method(:onTimerReachPace), 30000, false);
    	reached_pace_range = false;
    	Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    	Sys.println("Location events enabled");
   	
   		Sys.println(pace_seconds);
   		Sys.println(pace_seconds_min);
   		Sys.println(pace_seconds_max);
   		
   		var tmp_sec;
   		var tmp_min;
   		// Set up pace strings using pace_seconds, pace_seconds_min, pace_seconds_max
		pace_str_min = (pace_seconds_min.toFloat() / 60).toLong().toString() + ":";
		tmp_min = (pace_seconds_min.toFloat() / 60).toLong();
		tmp_sec = (pace_seconds_min - tmp_min*60.000).toLong();
		if( tmp_sec < 10 )
		{
			pace_str_min = pace_str_min + "0";
		}
		pace_str_min = pace_str_min + tmp_sec;
		
		
		
		pace_str_max = (pace_seconds_max.toFloat() / 60).toLong().toString() + ":";
		tmp_min = (pace_seconds_max.toFloat() / 60).toLong();
		tmp_sec = (pace_seconds_max.toFloat() - tmp_min*60.000).toLong();
		if( tmp_sec < 10 )
		{
			pace_str_max = pace_str_max + "0";
		}
		pace_str_max = pace_str_max + tmp_sec;
		

		
		pace_str = (pace_seconds.toFloat() / 60).toLong().toString() + ":";
		tmp_min = (pace_seconds.toFloat() / 60).toLong();
		tmp_sec = (pace_seconds.toFloat() - tmp_min*60.000).toLong();

		if( tmp_sec < 10 )
		{
			pace_str = pace_str + "0";
		}
		pace_str = pace_str + tmp_sec;
		

   		
    	current_state = appStates.STATE_WAITING;
    	Sys.println("State:" + current_state.toString());
    	Sys.println(pace_str_min);
    	Sys.println(pace_str_max);
    	Sys.println(pace_str);
    
    }
    function onHide() 
    {
    	Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    	Sys.println("Location events ended");
    	if( session != null )
    	{
    		//EndSession();
            Sys.println("Session ended");
            
            session.stop();
			session.discard();
            session = null;
            Ui.requestUpdate();
        }
       if( timer != null )
        {
        	Sys.println("Timer ended");
        	timer.stop();
        	timer = null;
        	Ui.requestUpdate();
        }
        if( timer_reachpace != null )
        {
            Sys.println("Timer reach pace ended");
        	timer_reachpace.stop();
        	timer_reachpace = null;
        	Ui.requestUpdate();
        }
    }
    
    function exitView()
    {
    	Sys.print("Exit third view");
    }

	function onTimer()
	{
		Ui.requestUpdate();
	
	}
	function onTimerReachPace()
	{
		reached_pace_range = true;
		if( timer_reachpace != null )
		{
			timer_reachpace.stop();
			timer_reachpace = null;
		}
			
	}
	
	function doVibe( modder )
	{
		if( vibe_ind % modder == 0 )
		{
			Attention.vibrate(vibrate_alert);
		}
		vibe_ind = (vibe_ind + 1) % modder;
	
	}
    //! Update the view
    function onUpdate(dc) 
    {
        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK );
        dc.clear();

		//dc.drawText( 50,50, Gfx.FONT_TINY, "STATE:"+current_state.toString(), Gfx.TEXT_JUSTIFY_RIGHT );   
		//dc.drawText( 100,10, Gfx.FONT_TINY, errorstring, Gfx.TEXT_JUSTIFY_RIGHT );   

        if( current_state == appStates.STATE_RUNNING_SCREEN1 )
        {
	    	var actInf = Activity.getActivityInfo();
	    	if( actInf != null )
	    	{
	    		var sp = actInf.currentSpeed;
	    		if( sp == null )
	    		{
	    			sp = .0001;
	    		}
	    		else if( sp < .0001 and sp > -.0001 )
	    		{
	    			sp = .0001;
	    		}
	    	    cur_pace =  metpersec_to_minpermile / sp;
	    	    var cur_pace_secs = cur_pace * 60;

	    	    if( cur_pace_secs <= pace_seconds_max and cur_pace_secs >= pace_seconds_min )
	    	    {
	    	    	reached_pace_range = true;
	    	    }
	    	    
		    	Sys.print("Current pace is ");
		    	Sys.println(cur_pace);
		    	var mins = cur_pace.toLong();
		    	var secs = ((cur_pace - mins) * 60).toLong();
		    	var secstr = secs.toString();
		    	if( secs < 10 )
		    	{
		    		secstr = "0" + secstr;
		    	}
		    	var cur_pace_str = mins.toString() + ":" + secstr;
		    	
		        dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
		        if( reached_pace_range == true )
		        {
			        if( cur_pace_secs > pace_seconds_max )
			        {
			            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
			            doVibe( 1 );
			            Sys.println("fast");
			        }
			        else if( cur_pace_secs < (pace_seconds_min ) )
			        {
			        	dc.setColor( Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT );
			            doVibe( 4 );
			            Sys.println("slow");
			        }
			    }

		       	dc.drawText( dc.getWidth() / 2, dc.getHeight() / 4, Gfx.FONT_NUMBER_HOT, cur_pace_str, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );  
		        
		        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
		        dc.drawText( dc.getWidth() / 2, 2*dc.getHeight() / 3, Gfx.FONT_NUMBER_HOT, pace_str, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   
   			
   		   	   	dc.setColor( Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT );
   		   	    dc.drawText( 0, 7*dc.getHeight() / 8, Gfx.FONT_NUMBER_MILD, pace_str_min, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER );   
		        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );   		        
   		        dc.drawText( dc.getWidth(), 7*dc.getHeight() / 8, Gfx.FONT_NUMBER_MILD, pace_str_max, Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER );   
   			
   			}
   			else
   			{
   				dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
   				dc.drawText( dc.getWidth() / 2, dc.getHeight() / 4, Gfx.FONT_SMALL, "RunScreen1 Error", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   	        
	        	
   			}
   		}
   		else if( current_state == appStates.STATE_RUNNING_SCREEN2 )
   		{
   			var actInf = Activity.getActivityInfo();
	    	if( actInf != null )
	    	{
	    	    cur_time = actInf.elapsedTime;
	    	    cur_dist = actInf.elapsedDistance;
	    	    if( cur_time == null )
	    	    {
	    	    	cur_time = 0;
	    	    }
	    	    if( cur_dist == null )
	    	    {
	    	    	cur_dist = 0;
	    	    }
	    	    
	    	    
	    	    
	    	    
	    	    var sp = actInf.currentSpeed;
	    		if( sp == null )
	    		{
	    			sp = .0001;
	    		}
	    		else if( sp < .0001 and sp > -.0001 )
	    		{
	    			sp = .0001;
	    		}
	    	    cur_pace =  metpersec_to_minpermile / sp;
	    	    var cur_pace_secs = cur_pace * 60;

	    	   // if( cur_pace_secs <= pace_seconds_max  and cur_pace_secs >= pace_seconds_min )
	    	   // {
	    	    //	reached_pace_range = true;
	    	   //reached_pace_range }
	    	    
		    	Sys.print("Current pace is ");
		    	Sys.println(cur_pace);

		        if( reached_pace_range == true )
		        {
			        if( cur_pace_secs > pace_seconds_max )
			        {
			            doVibe( 1 );
			            Sys.println("fast");
			        }
			        else if( cur_pace_secs < (pace_seconds_min ) )
			        {
			            doVibe( 4 );
			            Sys.println("slow");
			        }
			    }
	    	    var min_passed = cur_time / 60000;
	    	    var sec_passed = (cur_time % 60000 ) / 1000;
	    	    var time_str = min_passed.toLong().toString()+":";
	    	    if( sec_passed < 10 )
	    	    {
	    	    	time_str = time_str + "0";
	    	    }
	    	    time_str = time_str + sec_passed.toLong().toString();
	    	    
	    	    dc.setColor( Gfx.COLOR_PURPLE, Gfx.COLOR_TRANSPARENT );
   				dc.drawText( dc.getWidth() / 2, dc.getHeight() / 4, Gfx.FONT_NUMBER_HOT, time_str, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   	        
	    	    dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
	        	dc.drawText( dc.getWidth() / 2, 3*dc.getHeight() / 4, Gfx.FONT_LARGE, (cur_dist/1609.43).format("%2.2f").toString() + " mi", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   
	    	}
	    	else
	    	{
	    		dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
   				dc.drawText( dc.getWidth() / 2, dc.getHeight() / 4, Gfx.FONT_SMALL, "RunScreen2 Error", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   	        
	        	
	    	}
   		}
   		else if( current_state == appStates.STATE_WAITING )
   		{
				dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
   				dc.drawText( dc.getWidth() / 2, dc.getHeight() / 5, Gfx.FONT_LARGE, "Press Enter ", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );   	        
	        	dc.drawText( dc.getWidth() / 2, 2*dc.getHeight() / 5, Gfx.FONT_LARGE, "To Begin", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER ); 
   			    dc.drawText( dc.getWidth() / 2, 3*dc.getHeight() / 5, Gfx.FONT_LARGE, "and", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER ); 
   			    dc.drawText( dc.getWidth() / 2, 4*dc.getHeight() / 5, Gfx.FONT_LARGE, "Finish", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER ); 
   		
   		
   		}
   		else if( current_state == appStates.STATE_SAVEREQUEST )
   		{
	    	    dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
   				dc.drawText( dc.getWidth()/2, 2*dc.getHeight() / 3, Gfx.FONT_MEDIUM, "Back to Discard", Gfx.TEXT_JUSTIFY_CENTER );   	        
	        	dc.drawText( dc.getWidth()/2, dc.getHeight() / 3, Gfx.FONT_MEDIUM, "Enter to Save", Gfx.TEXT_JUSTIFY_CENTER );   
	    	 	
   		}
    }



}

class OnPaceThirdDelegate extends Ui.BehaviorDelegate 
{
        
	function onKey(evt)
 	{
	  	 if( evt.getKey() == Ui.KEY_ENTER )
	  	 {
	  	 	Sys.println("Key enter");
		 	if( current_state == appStates.STATE_WAITING )
		 	{
		 		Sys.println("enter, waiting");
		 		if( Toybox has :ActivityRecording ) 
		 		{
           			if( ( session == null ) ) 
           			{
               			 session = Record.createSession({:name=>"Run", :sport=>Record.SPORT_RUNNING});
               			 session.start();
               			 Ui.requestUpdate();
               			 Sys.println("session began");
               			 errorstring = "session began";
               			 current_state = appStates.STATE_RUNNING_SCREEN1;
               		}
               		else
               		{
               			errorstring = "session failed";
               		}
                	if( timer == null )
                	{
						 timer = new Timer.Timer();
       					 timer.start( method(:onTimer), 500, true );
       					 Sys.println("timer began");
       					 current_state = appStates.STATE_RUNNING_SCREEN1;
       					 Sys.println("State:" + current_state.toString());
       				}
       				else
       				{
   				       	 errorstring = errorstring + " timer failed";
       				
       				}
           		}
           		else
           		{
           			Sys.println("error in trying to start recording");
           			errorstring = "noactivity recording";
           		}
		 	}
		 	else if( current_state == appStates.STATE_RUNNING_SCREEN1 or current_state == appStates.STATE_RUNNING_SCREEN2 )
		 	{
		 		current_state = appStates.STATE_SAVEREQUEST;
				session.stop();
		 		Sys.println("State:" + current_state.toString());
		 	}
		 	else if( current_state == appStates.STATE_SAVEREQUEST )
		 	{
		 		if( session != null )
    			{
    				//EndSession();
           			Sys.println("Session ended");
            
	            	session.save();
	            	session = null;
	            	Ui.switchToView(new OnPaceFirstView(), new OnPaceFirstDelegate(), Ui.SLIDE_DOWN);
	            	Ui.requestUpdate();
	        	}
	        	else
	        	{
	        		errorstring = "session was null";
	        	}
	       		if( timer != null )
       		 	{
        			Sys.println("Timer ended");
        			timer.stop();
        			timer = null;
        			Ui.requestUpdate();
      		  	}
      		  	else
      		  	{
      		  		errorstring = errorstring + " timer was null";
      		  	}
		 	}
	  	 }
		 else if( evt.getKey() == WatchUi.KEY_ESC )
		 {
		 	Ui.popView(Ui.SLIDE_RIGHT);
		 }
	  	 else if( evt.getKey() == WatchUi.KEY_UP or evt.getKey() == WatchUi.KEY_DOWN )
	  	 {
	  	    if( current_state == appStates.STATE_RUNNING_SCREEN1 )
    		{
    			current_state = appStates.STATE_RUNNING_SCREEN2;
    			Sys.println("State:" + current_state.toString());
   			}
    		else if( current_state == appStates.STATE_RUNNING_SCREEN2 )
    		{
    			current_state = appStates.STATE_RUNNING_SCREEN1;
    			Sys.println("State:" + current_state.toString());
   			 }  
	  	 }
  	}
  function onTimer()
  {
  	Ui.requestUpdate();
  }
  	  
  function onTap(evt) 
  {
  	var x,y;
    x = evt.getCoordinates()[0];
    y = evt.getCoordinates()[1];
    Sys.println(x);
    Sys.println(y);
    
    if( current_state == appStates.STATE_RUNNING_SCREEN1 )
    {
    	current_state = appStates.STATE_RUNNING_SCREEN2;
    	Sys.println("State:" + current_state.toString());
    }
    else if( current_state == appStates.STATE_RUNNING_SCREEN2 )
    {
    	current_state = appStates.STATE_RUNNING_SCREEN1;
    	Sys.println("State:" + current_state.toString());
    }   
    
    
    if( (x > xhalf - 20 and x < xhalf + 20) and ( y < 20  ) )
    {
        Sys.println("top");
    
    }
    else if( (x > xhalf - 20 and x < xhalf + 20) and ( y > 2*yhalf - 30  ) )
    {
    	Sys.println("bottom");
    
    }
    else if( (x < 20) and (y > yhalf - 20 and y < yhalf + 20) )
    {
    	Sys.println("left");
    	
    }
    else if( ( x > 2*xhalf - 30  ) and (y > yhalf - 20 and y < yhalf + 20) )
    {
    	Sys.println("right");
    	
    }
    Ui.requestUpdate();
   }

}