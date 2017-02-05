package sdg.event;

interface IEventDispatcher
{
	public function dispatchEvent(name:String, eventObject:EventObject = null):Void;
}