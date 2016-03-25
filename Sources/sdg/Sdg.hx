package sdg;

import kha.Scheduler;
import kha.System;

@:allow(sdg.Engine)
class Sdg
{
	public static var dt(default, null):Float = 0;	
	public static var windowWidth(default, null):Int;
	public static var windowHeight(default, null):Int;
	public static var screen:Screen;
	
	static var timeTasks:Array<Int>;
	
	public static function addTimeTask(task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0):Int
	{
		if (timeTasks == null)
			timeTasks = new Array<Int>();
		
		timeTasks.push(Scheduler.addTimeTask(task, start, period, duration));
		
		return timeTasks[timeTasks.length - 1];
	}
	
	public static function removeTimeTasks(id:Int):Void
	{
		if (timeTasks != null)
		{
			timeTasks.remove(id);
			Scheduler.removeTimeTask(id);
		}
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