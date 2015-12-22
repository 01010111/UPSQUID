package util;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.effects.postprocess.PostProcess;

/**
 * ...
 * @author 01010111
 */
class Reg
{
	
	public static var hi_combo:Int = 0;
	public static var hi_depth:Int = 0;
	public static var cam_offs:Int = 48;
	
	public static var loaded:Bool = false;
	public static var _save:FlxSave;
	
	public static function initSave():Void
	{
		if (!loaded)
		{
			_save = new FlxSave();
			_save.bind("SQUID_DATA");
			if (_save.data.hi_combo != null) load();
			loaded = true;
			#if !flash
			FlxG.addPostProcess(new PostProcess("assets/data/paletteMapSimple.frag"));
			#end
		}
	}
	
	public static function load():Void
	{
		hi_combo = _save.data.hi_combo;
		hi_depth = _save.data.hi_depth;
		//cam_offs = _save.data.cam_offs;
	}
	
	public static function save():Void
	{
		_save.data.hi_combo = hi_combo;
		_save.data.hi_depth = hi_depth;
		//_save.data.cam_offs = cam_offs;
		_save.flush();
	}
	
}