package sdg;

import kha.Color;
import kha.Image;
import kha.Scheduler;
import kha.System;
import kha.graphics2.Graphics;
import sdg.manager.Manager;

class Engine
{
	public var backbuffer:Image;
	var g2:Graphics;
	
	var currTime:Float = 0;
	var prevTime:Float = 0;
	var active:Bool;
	
	var managers:Array<Manager>;
	
	public var backgroundRender:Graphics->Void;
    
    #if debug
    public var editor:Editor;
    #end
	
	public function new(width:Int, height:Int):Void
	{
		active = true;
		
		backbuffer = Image.createRenderTarget(width, height);
		g2 = backbuffer.g2;
		
		currTime = Scheduler.time();
		
		Sdg.windowWidth = System.windowWidth();
        Sdg.halfWinWidth = Std.int(Sdg.windowWidth / 2);
		Sdg.windowHeight = System.windowHeight();
        Sdg.halfWinHeight = Std.int(Sdg.windowHeight / 2);
        
        Sdg.gameWidth = backbuffer.width;
        Sdg.halfGameWidth = Std.int(backbuffer.width / 2);
		Sdg.gameHeight = backbuffer.height;
        Sdg.halfGameHeight = Std.int(backbuffer.height / 2);
        
        calcGameScale();
        
        Sdg.object = new Object();
		
		managers = new Array<Manager>(); 
		
		//System.notifyOnApplicationState(onForeground, null, null, onBackground, null);
	}
    
    function calcGameScale()
    {
        // TODO
        Sdg.gameScale = Sdg.windowWidth / Sdg.gameWidth;
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
		
		if (active)
		{
			if (Sdg.screen != null && Sdg.screen.active)
			{
				Sdg.screen.updateLists();
				Sdg.screen.update();
				Sdg.screen.updateLists(false);
			}
            
            #if debug
            if (editor != null)
            {
                editor.checkMode();
                
                if (editor.active)
                {
                    Sdg.screen.updateLists();
                    editor.update();
                }
                    
            }
            #end
            			
			// Events will always trigger first, and we want the active screen
			// to react to the changes before the manager processes them.
			for (m in managers)
			{
				if (m.active)
					m.update();
			}
		}		
	}
	
	public function addManager(manager:Manager):Void
	{
		managers.push(manager);
	}
	
	public function render():Void
	{
		if (Sdg.screen != null)
		{			
			g2.begin(true, Sdg.screen.bgColor);
			Sdg.screen.render(g2);
		}
		else
			g2.begin(true, Color.Black);
		
		if (!active && backgroundRender != null)
			backgroundRender(g2);
            
		#if debug
        else if (editor != null && editor.active)
            editor.render(g2);
        #end
        	
		g2.end();
	}
}