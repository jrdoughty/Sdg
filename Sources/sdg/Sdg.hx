package sdg;

import kha.Scheduler;
import kha.System;

class Sdg
{
	public static var dt(default, null):Float = 0;	
	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	
	public static var windowWidth:Int;
	public static var windowHeight:Int;
	
	public static function init():Void
	{
		currTime = Scheduler.time();
		
		windowWidth = System.windowWidth();
		windowHeight = System.windowHeight();
	}
	
	public static function update():Void
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();
		
		dt = currTime - prevTime;
	}
	
	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear(array:Array<Dynamic>)
	{
		#if (cpp || php)
		array.splice(0, array.length);
		#else
		untyped array.length = 0;
		#end
	}
	
	/**
	 * Binary insertion sort
	 * @param list     A list to insert into
	 * @param key      The key to insert
	 * @param compare  A comparison function to determine sort order
	 */
	public static function insertSortedKey<T>(list:Array<T>, key:T, compare:T->T->Int):Void
	{
		var result:Int = 0,
			mid:Int = 0,
			min:Int = 0,
			max:Int = list.length - 1;
			
		while (max >= min)
		{
			mid = min + Std.int((max - min) / 2);
			result = compare(list[mid], key);
			if (result > 0) max = mid - 1;
			else if (result < 0) min = mid + 1;
			else return;
		}

		list.insert(result > 0 ? mid : mid + 1, key);
	}
}