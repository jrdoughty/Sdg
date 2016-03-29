package sdg.manager;

import kha.Scheduler;
import tween.Delta;

class TweenDelta extends Manager
{	
	/*var sample:Float = 0.0;
	public var time:Float = 0.0;
	public var delta:Float;*/
	
	public function new():Void
	{
		super();		
	}
	
	override public function update():Void 
	{		
		Delta.step(Sdg.dt);
		
		//Delta.step(tock()); // Update the tween engine with a delta in seconds

        //tick(); // Store frame time for next tock
	}
	
	/*inline public function tick():Void 
	{
		sample = Scheduler.time();
	}
	
	inline public function tock():Float 
	{
		delta = Scheduler.time() - sample;
		time += delta;
		
		return delta;
	}*/
}