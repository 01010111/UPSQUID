package util;
import zerolib.util.ZMath;

/**
 * ...
 * @author 01010111
 */
class LevelUtil
{
	var num_levels:Int = 12;
	var level_array:Array<String>;
	var cur_level:Int = 0;
	
	public function new() 
	{
		
		level_array = new Array();
		
		for (i in 0...num_levels)
		{
			level_array.push("" + i);
		}
		shuffle_array();
		
		level_array.unshift("start");
		
	}
	
	function shuffle_array():Void
	{
		for (i in 1...level_array.length)
		{
			var j = ZMath.randomRangeInt(0, i - 1);
			var temp = level_array[i];
			level_array[i] = level_array[j];
			level_array[j] = temp;
		}
	}
	
	public function get_level():String
	{
		var _s = level_array[cur_level];
		if (_s == "start") level_array.remove("start");
		else cur_level++;
		if (cur_level == num_levels)
		{
			cur_level = 0;
			shuffle_array();
		}
		return _s;
	}
	
}