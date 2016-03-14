package sdg;

import kha.Scheduler;

class Sdg
{
	public static var dt(default, null):Float = 0;
	
	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	
	public static function init():Void
	{
		currTime = Scheduler.time();
	}
	
	public static function update():Void
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();
		
		dt = currTime - prevTime;
	}
}