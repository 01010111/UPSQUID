package util;

import flixel.FlxG;

/**
 * ...
 * @author 01010111
 */
class Sounds
{
	
	public static function play(_s:String, _v:Float = 0.5):Void
	{
		FlxG.sound.play("Snd_" + _s, _v * 1.2);
	}
	
}
