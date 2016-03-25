package sdg;

import kha.Color;
import kha.Image;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;

class Engine
{
	public var backbuffer:Image;
	var g2:Graphics;
	
	var currTime:Float = 0;
	var prevTime:Float = 0;
	var active:Bool;
	
	public var backgrounRender:Graphics->Void;	
	
	public function new(width:Int, height:Int):Void
	{
		active = true;
		
		backbuffer = Image.createRenderTarget(width, height);
		g2 = backbuffer.g2;
		
		currTime = Scheduler.time();
		
		Sdg.windowWidth = System.windowWidth();
		Sdg.windowHeight = System.windowHeight();
		
		System.notifyOnApplicationState(onForeground, null, null, onBackground, null);
	}
	
	function onForeground()
	{
		active = true;
		
		if (Sdg.timeTasks != null)
		{
			for (id in Sdg.timeTasks)
				Scheduler.pauseTimeTask(id, false);
		}
	}	
	
	function onBackground()
	{
		active = false;
		
		if (Sdg.timeTasks != null)
		{
			for (id in Sdg.timeTasks)
				Scheduler.pauseTimeTask(id, true);
		}
	}
	
	public function update():Void
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();
		
		Sdg.dt = currTime - prevTime;
		
		if (active && Sdg.screen != null)
		{
			Sdg.screen.updateLists();
			Sdg.screen.update();
			Sdg.screen.updateLists(false);
		}		
	}
	
	public function render():Void
	{
		if (Sdg.screen != null)
		{
			if (Sdg.screen.clearScreen)
				g2.begin(true, Sdg.screen.bgColor);
			else
				g2.begin(false);
					
			Sdg.screen.render(g2);
		}
		else
			g2.begin(true, Color.Black);
		
		if (!active && backgrounRender != null)
			backgrounRender(g2);
			
		g2.end();
	}
}