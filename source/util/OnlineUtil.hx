package util;

#if flash
import com.newgrounds.*;
import com.newgrounds.components.*;
#end

/**
 * ...
 * @author 01010111
 */
class OnlineUtil
{

	public function new() 
	{
		
	}
	
	/*
	 * 	LEADERBOARD
	 */
	
	/*
	 * 	ACHIEVEMENTS
	 */
	
#if flash
	
	public function give_achievement(ID:Int):Void
	{
		if (Reg.newgrounds_build) give_achievement_ng(ID);
		else give_achievement_internal(ID);
	}
	
	function give_achievement_ng(ID:Int):Void
	{
		give_achievement_internal(ID);
	}
	
	
#else
	
	public function give_achievement(ID:Int):Void
	{
		
	}
	
#end
	
	function give_achievement_internal(ID:Int):Void
	{
		
	}
	
}