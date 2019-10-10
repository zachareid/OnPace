using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Activity as Activity;
using Toybox.ActivityRecording as Record;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

var secondView;

var xhalf;
var yhalf;
var tapText = "";


var timer_new = null;

var holding_viewone= false;
var holding_x = 1;
var holding_y = 1;




class OnPaceFirstView extends Ui.View {
	

    //! Restore the state of the app and prepare the view to be shown
    function onShow() 
    {
    	revert_to_first = false;
    	holding_viewone = false;
    	if( timer_new == null )
    	{
    		change_pace_min = true;
    		timer_new = new Timer.Timer();
    		timer_new.start(method(:onTimer), 100, true );
    	}
    	
    }
    function onTimer()
    {
    	Ui.requestUpdate();
    }
    
    function exitView()
    {
    	//secondView.exitView();
    }


    //! Update the view
    function onUpdate(dc) {
    	if( holding_viewone == true )
    	{
    		//processFingerOne( holding_x, holding_y );
    	}
        dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        xhalf = dc.getWidth()/2;
        yhalf = dc.getHeight()/2;
        
    	if( min_pace < 3 )
    	{
    		min_pace = 3;
    	}
    	if( sec_pace < 0 or sec_pace > 59)
    	{
    		sec_pace = 0;
    	}
    	var sec_pacetext = sec_pace.toString();
    	if( sec_pace < 10 )
    	{
    		sec_pacetext = "0" + sec_pacetext;
    	}
        var text = min_pace.toString() + ":" + sec_pacetext;
        dc.fillCircle(dc.getWidth() / 2, 0, 10);
        dc.fillCircle(dc.getWidth() / 2, dc.getHeight(), 10);
        dc.fillCircle(0, dc.getHeight() / 2, 10);
        dc.fillCircle(dc.getWidth(), dc.getHeight() / 2, 10);
        //tapText = "x:"+ mx.toString() + " y:" + my.toString();
        
        dc.drawText( dc.getWidth() / 2, 30, Gfx.FONT_TINY, "Set Your Pace.", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
		//dc.drawText( dc.getWidth() / 2, 25, Gfx.FONT_XTINY, tapText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER ); 
        dc.drawText( dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_NUMBER_THAI_HOT, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
        
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        if( change_pace_min == true )
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
    	if( timer_new != null )
    	{
    		timer_new.stop();
    		timer_new = null;
    	}
    }
}

function processFingerOne( x, y)
{
	if( (x > xhalf - 50 and x < xhalf + 50) and ( y < 70  ) )
    {
   		Sys.println("top");
    	if( change_pace_min == true )
    	{
    		min_pace = min_pace + 1;
    	}
    	else
    	{
    		sec_pace = sec_pace + 1;
    	}
    	
    }
    else if( (x > xhalf - 50 and x < xhalf + 50) and ( y > 2*yhalf - 70  ) )
    {
    	Sys.println("bottom");
    	if( change_pace_min == true )
    	{
    		min_pace = min_pace - 1;
    	}
    	else
    	{
    		sec_pace = sec_pace - 1;
    	}
    	
    }
    //else if( (x < 40) and (y > yhalf - 40 and y < yhalf/2 + 40) )
	else if( x < 50 )
    {
    	Sys.println("left");
    	change_pace_min = true;
    }
    //else if( ( x > 2*xhalf - 30  ) and (y > yhalf/2 - 40 and y < yhalf/2 + 40) )
	else if( x > 150 )
    {
    	Sys.println("right");
    	if( change_pace_min == true )
    	{
    		change_pace_min = false;
    	}
    	else
    	{
    	  	pace_seconds = 60*min_pace + sec_pace;
  			secondView = new OnPaceSecondView();
  			Ui.pushView(secondView, new OnPaceSecondDelegate(), Ui.SLIDE_LEFT);
    	}
    }
}

class OnPaceFirstDelegate extends Ui.BehaviorDelegate 
{
	function onTap(evt)
	{
	  	var x,y;
    	x = evt.getCoordinates()[0];
    	y = evt.getCoordinates()[1];
    
    	processFingerOne( x, y );
	
	
	}
  	function onKey(evt)
 	{
		if( evt.getKey() == WatchUi.KEY_UP )
		{
			processFingerOne( xhalf, 0 );
		}
		else if( evt.getKey() == WatchUi.KEY_DOWN )
		{
			processFingerOne( xhalf, yhalf*2 );
		}
		else if( evt.getKey() == WatchUi.KEY_ENTER )
		{
			processFingerOne( xhalf*2, yhalf );
		}
  	}
  	function onRelease(evt)
  	{
  		//holding_viewone = false;
  	}
  	function onHold(evt)
  	{
  		Sys.println("holding");
  		//holding_viewone = true;
    	holding_x = evt.getCoordinates()[0];
    	holding_y = evt.getCoordinates()[1];
    	Ui.requestUpdate();
    }
}