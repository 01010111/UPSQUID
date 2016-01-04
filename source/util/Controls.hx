package util;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Controls extends FlxObject
{
	
	public var _u:Bool;
	public var _d:Bool;
	public var _l:Bool;
	public var _r:Bool;
	public var _u_just_pressed:Bool;
	public var _d_just_pressed:Bool;
	public var _l_just_pressed:Bool;
	public var _r_just_pressed:Bool;
	public var _u_just_released:Bool;
	public var _d_just_released:Bool;
	public var _l_just_released:Bool;
	public var _r_just_released:Bool;
	
	#if !mobile
	var pad:FlxGamepad;
	#end
	
	public function new()
	{
		super();
		#if !mobile
		set_gamepad();
	}
	// DON'T PUT STUFF HERE - SEE CONDITIONAL!
	function set_gamepad(?t:FlxTimer):Void
	{
		pad = FlxG.gamepads.firstActive;
		if (pad == null) new FlxTimer().start(1, set_gamepad);
		#end
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		_u = _d = _l = _r = 
		_u_just_pressed = _d_just_pressed = _l_just_pressed = _r_just_pressed = 
		_u_just_released = _d_just_released = _l_just_released = _r_just_released = false;
		
		get_pressed();
		get_just_pressed();
		get_just_released();
	}
	
	#if !mobile
	
	function get_pressed():Void
	{
		_u = 
			FlxG.keys.anyPressed([FlxKey.UP, FlxKey.W]) || 
			pad != null && (pad.anyPressed([FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.Y]));
		_d = 
			FlxG.keys.anyPressed([FlxKey.DOWN, FlxKey.S]) || 
			pad != null && (pad.anyPressed([FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.A]));
		_l = 
			FlxG.keys.anyPressed([FlxKey.LEFT, FlxKey.A]) || 
			FlxG.mouse.pressed || 
			pad != null && (pad.anyPressed([FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.X, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_TRIGGER]));
		_r = 
			FlxG.keys.anyPressed([FlxKey.RIGHT, FlxKey.D]) || 
			FlxG.mouse.pressedRight || 
			pad != null && (pad.anyPressed([FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.RIGHT_TRIGGER]));
	}
	
	function get_just_pressed():Void
	{
		_u_just_pressed = 
			FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W]) || 
			FlxG.mouse.wheel > 0 || 
			pad != null && (pad.anyJustPressed([FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.Y]));
		_d_just_pressed = 
			FlxG.keys.anyJustPressed([FlxKey.DOWN, FlxKey.S]) || 
			FlxG.mouse.wheel < 0 || 
			pad != null && (pad.anyJustPressed([FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.A]));
		_l_just_pressed = 
			FlxG.keys.anyJustPressed([FlxKey.LEFT, FlxKey.A]) || 
			FlxG.mouse.justPressed || 
			pad != null && (pad.anyJustPressed([FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.X, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_TRIGGER]));
		_r_just_pressed = 
			FlxG.keys.anyJustPressed([FlxKey.RIGHT, FlxKey.D]) || 
			FlxG.mouse.justPressedRight || 
			pad != null && (pad.anyJustPressed([FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.RIGHT_TRIGGER]));
	}
	
	function get_just_released():Void
	{
		_u_just_released = 
			FlxG.keys.anyJustReleased([FlxKey.UP, FlxKey.W]) || 
			pad != null && (pad.anyJustReleased([FlxGamepadInputID.DPAD_UP, FlxGamepadInputID.Y]));
		_d_just_released = 
			FlxG.keys.anyJustReleased([FlxKey.DOWN, FlxKey.S]) || 
			pad != null && (pad.anyJustReleased([FlxGamepadInputID.DPAD_DOWN, FlxGamepadInputID.A]));
		_l_just_released = 
			FlxG.keys.anyJustReleased([FlxKey.LEFT, FlxKey.A]) || 
			FlxG.mouse.justReleased || 
			pad != null && (pad.anyJustReleased([FlxGamepadInputID.DPAD_LEFT, FlxGamepadInputID.X, FlxGamepadInputID.LEFT_SHOULDER, FlxGamepadInputID.LEFT_TRIGGER]));
		_r_just_released = 
			FlxG.keys.anyJustReleased([FlxKey.RIGHT, FlxKey.D]) || 
			FlxG.mouse.justReleasedRight || 
			pad != null && (pad.anyJustReleased([FlxGamepadInputID.DPAD_RIGHT, FlxGamepadInputID.B, FlxGamepadInputID.RIGHT_SHOULDER, FlxGamepadInputID.RIGHT_TRIGGER]));
	}
	
	#else
	
	//TODO: Mobile Controls
	
	function get_pressed():Void
	{
		
	}
	
	function get_just_pressed():Void
	{
		
	}
	
	function get_just_released():Void
	{
		
	}
	
	#end
	
}