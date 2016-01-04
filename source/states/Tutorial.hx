package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import objects.Plankton;
import objects.Squid;
import states.Prompt.CircleHighLight;
import states.Prompt.CircleSegment;
import util.UI;
import zerolib.util.ZBitmapText;

/**
 * ...
 * @author 01010111
 */
class Tutorial extends FlxSubState
{
	var _controls:FlxGroup;
	var _text_group:FlxGroup;
	var stage:Int = -1;
	
	public function new() 
	{
		super(0xff000000);
		_text_group = new FlxGroup();
		add(_text_group);
		show_controls();
		FlxG.watch.add(this, "stage", "STAGE");
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		PlayState.i.c.update(elapsed);
		
		switch(stage)
		{
			case 0:
				if (PlayState.i.c._l && PlayState.i.c._r) show_squid();
			case 1:
				if (PlayState.i.c._l && PlayState.i.c._r) show_ui();
			case 2:
				if (PlayState.i.c._l && PlayState.i.c._r) show_plankton();
			case 3:
				if (PlayState.i.c._l && PlayState.i.c._r) tell_combo();
			case 4:
				if (PlayState.i.c._l && PlayState.i.c._r) exit_tutorial();
		}
	}
	
	function show_controls():Void
	{
		_controls = new FlxGroup();
		add(_controls);
		
		var _keyboard:FlxSprite = new FlxSprite(FlxG.width * 0.5, FlxG.height * 0.55);
		_keyboard.loadGraphic("assets/images/controls.png", true, 64, 64);
		_keyboard.animation.add("play", [0, 1, 0, 2], 6);
		_keyboard.animation.play("play");
		_keyboard.offset.set(32, 32);
		_keyboard.alpha = 0;
		
		var _mouse:FlxSprite = new FlxSprite(FlxG.width * 0.25, FlxG.height * 0.6);
		_mouse.loadGraphic("assets/images/controls.png", true, 64, 64);
		_mouse.animation.add("play", [3, 4, 3, 5], 6);
		_mouse.animation.play("play");
		_mouse.offset.set(32, 32);
		_mouse.alpha = 0;
		
		var _gamepad:FlxSprite = new FlxSprite(FlxG.width * 0.75, FlxG.height * 0.6);
		_gamepad.loadGraphic("assets/images/controls.png", true, 64, 64);
		_gamepad.animation.add("play", [6, 7, 6, 8], 6);
		_gamepad.animation.play("play");
		_gamepad.offset.set(32, 32);
		_gamepad.alpha = 0;
		
		_controls.add(_keyboard);
		_controls.add(_mouse);
		_controls.add(_gamepad);
		
		new FlxTimer().start(0.0).onComplete = function(t:FlxTimer):Void { FlxTween.tween(_keyboard,	{ alpha:1 }, 1); }
		new FlxTimer().start(0.5).onComplete = function(t:FlxTimer):Void { FlxTween.tween(_mouse, 		{ alpha:1 }, 1); }
		new FlxTimer().start(1.0).onComplete = function(t:FlxTimer):Void { FlxTween.tween(_gamepad, 	{ alpha:1 }, 1); }
		new FlxTimer().start(2.0).onComplete = function(t:FlxTimer):Void { stage = 0; }
		
		add_text(FlxG.height * 0.8, 	"THIS GAME USES FOUR BUTTONS:\nLEFT, RIGHT, UP, AND DOWN.",	0);
		add_text(FlxG.height * 0.85, 	"YOU CAN USE THE KEYBOARD,\nA MOUSE, OR A GAMEPAD",			1);
		add_text(FlxG.height * 0.9, 	"PRESS LEFT + RIGHT TO CONTINUE!",							2);
	}
	
	var _squid_group:FlxGroup;
	var circle:CircleHighLight;
	
	function show_squid():Void
	{
		_controls.kill();
		
		_squid_group = new FlxGroup();
		add(_squid_group);
		
		stage = -1;
		
		add_text(FlxG.height * 0.75, 	"THIS IS UPSQUID.", 							0, true);
		add_text(FlxG.height * 0.8, 	"CONTROL UPSQUID BY\nTURNING LEFT OR RIGHT", 	1);
		add_text(FlxG.height * 0.85, 	"RELEASE LEFT OR RIGHT\nTO THRUST FORWARD", 	2);
		add_text(FlxG.height * 0.9, 	"PRESS LEFT + RIGHT TO CONTINUE!",			 	3);
		
		var squid = new Squid(true);
		squid.scrollFactor.set();
		_squid_group.add(squid);
		
		circle = new CircleHighLight(squid.getMidpoint(), 12, 48);
		add(circle);
		
		new FlxTimer().start(2).onComplete = function(t:FlxTimer):Void { stage = 1; }
	}
	
	function show_ui():Void
	{
		stage = -1;
		
		var ui = new UI();
		_squid_group.add(ui);
		
		FlxTween.tween(circle.center, { x:42, y:10 }, 0.25);
		FlxTween.tween(circle, { radius:24 }, 0.25);
		
		add_text(FlxG.height * 0.75, 	"HERE IS UPSQUID'S HEALTH.", 				0, true);
		add_text(FlxG.height * 0.8, 	"EVERY TIME YOU THRUST,\nYOU LOSE ENERGY.", 1);
		add_text(FlxG.height * 0.85, 	"BE CAREFUL NOT TO RUN OUT!", 				2);
		add_text(FlxG.height * 0.9, 	"PRESS LEFT + RIGHT TO CONTINUE!",		 	3);
		
		new FlxTimer().start(2).onComplete = function(t:FlxTimer):Void { stage = 2; }
	}
	
	function show_plankton():Void
	{
		stage = -1;
		
		var p = new Planky();
		p.spawn(FlxPoint.get(FlxG.width * 0.75, FlxG.height * 0.3));
		p.scrollFactor.set();
		_squid_group.add(p);
		
		FlxTween.tween(circle.center, { x:p.getMidpoint().x, y:p.getMidpoint().y }, 0.25);
		FlxTween.tween(circle, { radius:48 }, 0.25);
		
		add_text(FlxG.height * 0.75, 	"THIS IS A LITTLE OCEAN CREATURE.",			0, true);
		add_text(FlxG.height * 0.8, 	"THEY ARE UPSQUID'S FAVORITE SNACK", 		1);
		add_text(FlxG.height * 0.85, 	"EAT THEM TO REPLENISH ENERGY!", 			2);
		add_text(FlxG.height * 0.9, 	"PRESS LEFT + RIGHT TO CONTINUE!",		 	3);
		
		new FlxTimer().start(2).onComplete = function(t:FlxTimer):Void { stage = 3; }
	}
	
	function tell_combo():Void
	{
		stage = -1;
		
		add_text(FlxG.height * 0.75,	"EAT A BUNCH IN A ROW AND YOU\nWILL BUILD UP A COMBO METER",	0, true);
		add_text(FlxG.height * 0.8,		"WHEN IT FILLS UP ALL THE WAY\nPRESS LEFT + RIGHT TO BOOST", 	1);
		add_text(FlxG.height * 0.85,	"WHILE BOOSTING, YOU WON'T\nLOSE ANY ENERGY!", 					2);
		add_text(FlxG.height * 0.9,		"PRESS LEFT + RIGHT TO CONTINUE!",		 						3);
		
		new FlxTimer().start(2).onComplete = function(t:FlxTimer):Void { stage = 4; }
	}
	
	function exit_tutorial():Void
	{
		stage = -1;
		
		_squid_group.kill();
		circle.kill();
		
		add_text(FlxG.height * 0.5, "THANKS FOR PLAYING!\nHAVE FUN!!!",	0, true);
		
		new FlxTimer().start(3).onComplete = function(t:FlxTimer):Void { close(); }
	}
	
	function add_text(_y:Float, _text:String, _fade_in_time:Float, _reset:Bool = false):Void
	{
		if (_reset) for (t in _text_group) t.kill();
		
		var _t = new ZBitmapText(0, _y, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
		_t.text = _text;
		_t.alpha = 0;
		_text_group.add(_t);
		
		new FlxTimer().start(_fade_in_time).onComplete = function(t:FlxTimer):Void { FlxTween.tween(_t, { alpha:1 }, 1); }
	}
	
}