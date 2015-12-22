package util;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxObject;

/**
 * ...
 * @author 01010111
 */
class Controls extends FlxObject
{
	
	public var _l:Bool;
	public var _r:Bool;
	public var _l_released:Bool;
	public var _r_released:Bool;
	
#if mobile
	var _debug_text:FlxText;
#else
	var joypad:FlxGamepad;
#end
	
	public function new()
	{
		super();
#if !mobile
		joypad = FlxG.gamepads.firstActive;
#else
		_debug_text = new FlxText(10, 20);
		_debug_text.color = 0xffffff;
		SlengTeng.i.fx_fg.add(_debug_text);
#end
	}
	
	var padchk:Int = 60;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
#if !mobile
		_l = FlxG.keys.anyPressed([FlxKey.LEFT, FlxKey.X, FlxKey.A]) || joypad != null && joypad.pressed.LEFT_SHOULDER;
		_r = FlxG.keys.anyPressed([FlxKey.RIGHT, FlxKey.C, FlxKey.D]) || joypad != null && joypad.pressed.RIGHT_SHOULDER;
		_l_released = FlxG.keys.anyJustReleased([FlxKey.LEFT, FlxKey.X, FlxKey.A]) || joypad != null && joypad.justReleased.LEFT_SHOULDER;
		_r_released = FlxG.keys.anyJustReleased([FlxKey.RIGHT, FlxKey.C, FlxKey.D]) || joypad != null && joypad.justReleased.RIGHT_SHOULDER;
		
		if (padchk == 0)
		{
			if (joypad == null) joypad = FlxG.gamepads.firstActive;
			padchk = 120;
		}
		else padchk--;
#else
		_l = _r = _l_released = _r_released = false;
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.screenY > FlxG.height * 0.5)
				{
					if (touch.screenX < FlxG.width * 2 * 0.6) _l = true;
					if (touch.screenX > FlxG.width * 2 * 0.4) _r = true;
					_debug_text.text = "" + touch.screenX + " : " + FlxG.width * FlxG.camera.zoom + " : " + FlxG.camera.zoom;
				}
			}
			
			if (touch.justReleased)
			{
				if (touch.screenY > FlxG.height * 0.5)
				{
					if (touch.screenX < FlxG.width * 2 * 0.6) _l_released = true;
					if (touch.screenX > FlxG.width * 2 * 0.4) _r_released = true;
				}
			}
		}
#end
	}
	
}