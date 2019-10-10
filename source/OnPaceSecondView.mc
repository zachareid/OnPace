using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Activity as Activity;
using Toybox.ActivityRecording as Record;
using Toybox.System as Sys;
using Toybox.Timer as Timer;


var thirdView;


var holding = false;
var timer = null;

class OnPaceSecondView extends Ui.View {

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    	if( revert_to_first == true )
    	{
    		Ui.switchToView(new OnPaceFirstView(), new OnPaceFirstDelegate(), Ui.SLIDE_LEFT);
    	}
    	else
    	{
	    	change_rad_min = true;
	    	holding = false;
	    	Ui.requestUpdate();
	    	if( timer == null )
	    	{
	    		timer = new Timer.Timer();
	    		timer.start(method(:onTimer), 100, true);
	    	}
    	}

    }
    
    function exitView()
    {
    	//thirdView.exitView();
    }

    //! Update the view
    function onUpdate(dc) {
    	if( holding == true )
    	{
    		//Sys.println("here");
    		//processFinger( hold_x, hold_y );
    	}
        xhalf = dc.getWidth()/2;
        yhalf = dc.getHeight()/2;
        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        
    	if( min_rad < 0 )
    	{
    		min_rad = 0;
    	}
    	if( sec_rad < 0 or sec_rad > 59)
    	{
    		sec_rad = 0;
    	}   	
    	if( min_rad == 0 and sec_rad < 15 )
    	{
    		sec_rad = 15;
    	}
    	
    	
    	var sec_radtext = sec_rad.toString();
    	if( sec_rad < 10 )
    	{
    		sec_radtext = "0" + sec_radtext;
    	}
        var text = min_rad.toString() + ":" + sec_radtext;
        dc.fillCircle(dc.getWidth() / 2, 0, 10);
        dc.fillCircle(dc.getWidth() / 2, dc.getHeight(), 10);
        dc.fillCircle(0, dc.getHeight() / 2, 10);
        dc.fillCircle(dc.getWidth(), dc.getHeight() / 2, 10);
        
        dc.drawText( dc.getWidth() / 2, 30, Gfx.FONT_XTINY, "Set Your Pace Range", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
        dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_NUMBER_THAI_HOT, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
        
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        if( change_rad_min == true )
        {
        	dc.fillCircle(dc.getWidth()/3, 3 * dc.getHeight() / 4, 10);
        }
        else
        {
        	dc.fillCircle(2*dc.getWidth()/3, 3 * dc.getHeight() / 4, 10);
        }
          
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() 
    {
    	if( timer != null )
    	{
    		timer.stop();
    		timer = null;
    	}
    }
	function onTimer()
	{
		Ui.requestUpdate();
	}

}

function processFinger( x, y )
  	{
	  	if( (x > xhalf - 50 and x < xhalf + 50) and ( y < 70  ) )
	    {
	        Sys.println("top");
	    	if( change_rad_min == true )
	    	{
	    		min_rad = min_rad + 1;
	    		
	    	}
	    	else
			{
	    		sec_rad = sec_rad + 1;
	    	}
	    	
	    }
	    else if( (x > xhalf - 50 and x < xhalf + 50) and ( y > 2*yhalf - 70  ) )
	    {
	    	Sys.println("bottom");
	    	if( change_rad_min == true )
	    	{
	    		min_rad = min_rad - 1;
	    	}
	    	else
	    	{
	    		sec_rad = sec_rad - 1;
	    	}
	    	
	    }
		else if( x < 50 )
	    {
	    	Sys.println("left");
	    	if( change_rad_min == true)
	    	{
	    		Ui.pushView( new OnPaceFirstView(), new OnPaceFirstDelegate(), Ui.SLIDE_RIGHT);
	    	}
	    	else
	    	{
	    		change_rad_min = true;
	    	}
	    }
		else if( x > 150 )
	    {
	    	Sys.println("right");
	    	if( change_rad_min == true )
	    	{
	    		change_rad_min = false;
	    	}
	    	else
	    	{
	    		pace_seconds_min = pace_seconds - (60*min_rad + sec_rad);
		  	 	pace_seconds_max = pace_seconds + (60*min_rad + sec_rad);
		  	 	if( pace_seconds_min < 0 )
		  	 	{
		  	 		pace_seconds_min = 0;
		  	 	}
		  	 	Sys.println("Pace min = " + pace_seconds_min.toString());
		  	 	Sys.println("Pace = " + pace_seconds.toString());
		  	 	Sys.println("Pace max = " + pace_seconds_max.toString());
	
		  		Ui.pushView( new OnPaceThirdView(), new OnPaceThirdDelegate(), Ui.SLIDE_LEFT);
	    	}
	    }
  	}


var hold_x = 1;
var hold_y = 1;
class OnPaceSecondDelegate extends Ui.BehaviorDelegate 
{
	function onKey(evt)
 	{
		if( evt.getKey() == WatchUi.KEY_UP )
		{
			processFinger( xhalf, 0 );
		}
		else if( evt.getKey() == WatchUi.KEY_DOWN )
		{
			processFinger( xhalf, yhalf*2 );
		}
		else if( evt.getKey() == WatchUi.KEY_ENTER )
		{
			processFinger( xhalf*2, yhalf );
		}
		Ui.requestUpdate();
  	}
  	function onRelease(evt)
  	{
  		//holding = false;
  	}
  	function onHold(evt)
  	{
  		Sys.println("holding");
  		//holding = true;
  		var x,y;
    	hold_x = evt.getCoordinates()[0];
    	hold_y = evt.getCoordinates()[1];
    	Ui.requestUpdate();
  	}
  	
  	  
  function onTap(evt) 
  {
  	var x,y;
    x = evt.getCoordinates()[0];
    y = evt.getCoordinates()[1];
    
    processFinger( x, y );

   }


}