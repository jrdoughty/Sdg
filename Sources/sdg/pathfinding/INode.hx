package sdg.pathfinding;

/**
 * ...
 * @author John Doughty
 */
interface INode
{
	public var neighbors:Array<INode>;
	public var parentNode:INode;
	public var g:Int;
	public var modifier:Int;
	public var heiristic:Int;
	public var nodeX:Int;
	public var nodeY:Int;
	/**
	* Concrete var for setting passibility. Once set, actors shouldn't be able to ever tread over it. 
	* Use for say the invisble border around the edge of the map, or indestructable walls
	*/
	private var isPassable:Bool;
	
	public function getFinal():Int;
    public function isPassible():Bool;
}