package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import zerolib.util.ZBitmapText;
import zerolib.util.ZMath;
import flixel.util.FlxAxes;
import particles.*;
import objects.*;
import util.*;

/**
 * ...
 * @author 01010111
 */

class PlayState extends ZState
{
	var level:FlxGroup;
	var stages:Array<FlxTilemap>;
	var stage_amt:Int = 3;
	var blocks:FlxGroup;
	var plankton:Plankton;
	var depth:Int;
	var dolly:FlxObject;
	var levels:LevelUtil;
	var walls:FlxTypedGroup<FlxObject>;
	var loaded_object_y_offset:Float;
	var press_to_continue:Bool = false;
	
	public var squid:Squid;
	public var enemies:FlxTypedGroup<Enemy>;
	public var bubbles:Bubbles;
	public var blood:Blood;
	public var confetti:Confetti;
	public var explosions:Explosions;
	public var fx_bg_far:FlxGroup;
	public var fx_bg:FlxGroup;
	public var fx_fg:FlxGroup;
	public var ui:UI;
	public var linked:Bool = true;
	public var top_combo:Int = 0;
	public var last_depth_indicator:DepthLastHiScore;
	public var large_alphabet:String = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+x:.,!?/*";
	
	public static var i:PlayState;
	
	override public function create():Void 
	{
		#if !flash
		//FlxG.fullscreen = true;
		#else
		flash(0, 1);
		#end
		
		i = this;
		Reg.init();
		
		//MUSIC! play intro
		FlxG.sound.playMusic("Snd_bgm1", Reg.mus_vol * 0.5);
		FlxG.sound.music.pause();
		
		level = new FlxGroup();
		blocks = new FlxGroup();
		fx_bg_far = new FlxGroup();
		fx_bg = new FlxGroup();
		fx_fg = new FlxGroup();
		enemies = new FlxTypedGroup();
		plankton = new Plankton();
		bubbles = new Bubbles();
		blood = new Blood();
		confetti = new Confetti();
		explosions = new Explosions();
		levels = new LevelUtil();
		stages = new Array();
		squid = new Squid();
		dolly = new FlxObject(squid.getMidpoint().x, squid.getMidpoint().y, 1, 1);
		ui = new UI();
		
		var _blinds = new FlxGroup();
		var _fade = new FlxSprite(0, 0, "assets/images/fade.png");
		_fade.scrollFactor.set();
		_fade.blend = BlendMode.MULTIPLY;
		
		for (i in 0...stage_amt)
		{
			var _l:FlxTilemap = new FlxTilemap();
			_l.setPosition(0, -i * FlxG.height);
			load_map(_l);
			stages.push(_l);
			level.add(_l);
		}
		
		for (i in 0...Std.int(FlxG.width * 0.25))
		{
			var _b = new FlxSprite(i * 4);
			_b.makeGraphic(2, FlxG.height, 0xff000000);
			_b.scrollFactor.set();
			_b.active = false;
			_blinds.add(_b);
		}
		
		last_depth_indicator = new DepthLastHiScore();
		
		add(fx_bg_far);
		add(_blinds);
		if (Reg.hi_depth > 0) add(last_depth_indicator);
		add(fx_bg);
		add(bubbles);
		add(level);
		add_title_stuff();
		add(blocks);
		add(enemies);
		add(confetti);
		add(squid);
		add(fx_fg);
		add(explosions);
		add(dolly);
		add(_fade);
		add(ui);
		add_walls();
		
		FlxG.camera.setSize(288, 512);
		FlxG.camera.setPosition(FlxG.width * 0.5 - 144, FlxG.height * 0.5 - 256);
		FlxG.camera.follow(dolly);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height * 3);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
		super.create();
		
		change_colors(Reg.cur_color);
		
		/*if (!Reg.played_b4)
		{
			var _tut_prompt = new Prompt("EVER PLAYED\nUPSQUID BEFORE?", "PRESS LEFT OR RIGHT TO CHOOSE");
			_tut_prompt.yes_callback = function():Void
			{
				Reg.played_b4 = true;
				_tut_prompt.close();
			}
			_tut_prompt.no_callback = function():Void
			{
				Reg.played_b4 = true;
				_tut_prompt.close();
				openSubState(new Tutorial());
			}
			openSubState(_tut_prompt);
		}*/
	}
	
	function load_map(_t:FlxTilemap):Void
	{
		var s = "assets/data/" + levels.get_level() + ".oel";
		var o = new Oggo(s);
		_t.loadMapFromCSV(o.getString(), "assets/images/tiles.png", 16, 16, FlxTilemapAutoTiling.AUTO);
		loaded_object_y_offset = _t.y;
		o.loadEntities(load_objects, "objects");
		depth++;
		if (depth % 5 == 0) fx_bg.add(new DepthIndicator(depth, _t.y + 8));
	}
	
	
	function load_objects(_entityName:String, _entityData:Xml):Void
	{
		var _p:FlxPoint = FlxPoint.get(Std.parseInt(_entityData.get("x")), Std.parseInt(_entityData.get("y")) + loaded_object_y_offset);
		switch(_entityName)
		{
			case "block":
				blocks.add(new Block(_p));
			case "babby":
				plankton.spawn(_p);
		}
	}
	
	function add_walls():Void
	{
		walls = new FlxTypedGroup();
		
		var _l_wall = new FlxObject(2, 0, 32, 32);
		_l_wall.immovable = true;
		walls.add(_l_wall);
		
		var _r_wall = new FlxObject(FlxG.width - 34, 0, 32, 32);
		_r_wall.immovable = true;
		walls.add(_r_wall);
		
		add(walls);
	}
	
	function add_title_stuff():Void
	{
		var _title = new FlxSprite(0, FlxG.height * 0.25, "assets/images/title.png");
		_title.scale.set(2, 2);
		_title.screenCenter(FlxAxes.X);
		add(_title);
		
		var _o = Reg.cam_offs > 32 ? 0.4 : 0.6;
		
		add_text(FlxG.height * 0.75, "PRESS LEFT + RIGHT TO PLAY\nPRESS UP FOR MENU", 1);
		if (Reg.hi_combo > 0) add_text(FlxG.height * _o, "HI COMBO : " + Reg.hi_combo, 2);
		if (Reg.hi_combo > 0) add_text(FlxG.height * (_o + 0.025), "HI POINT : " + Reg.hi_depth, 2);
	}
	
	function add_text(_y:Float, _text:String, _tween_time:Float, _scale:Float = 1, _scroll_factor:Float = 1):Void
	{
		var _t = new ZBitmapText(0, _y, large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
		_t.text = _text;
		_t.alpha = 0;
		_t.scale.set(_scale, _scale);
		_t.scrollFactor.set(_scroll_factor, _scroll_factor);
		add(_t);
		FlxTween.tween(_t, { alpha:1 }, _tween_time);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		move_dolly();
		collisions();
		for (wall in walls) wall.y = squid.y - 8;
		if (dolly.y < stages[1].y) swap_tilemaps();
		if (squid.getScreenPosition().y > FlxG.height && linked) game_over();
		if (press_to_continue && c._l && c._r) FlxG.resetState();
		if (c._u_just_pressed) openSubState(new Menu());
	}
	
	function move_dolly():Void
	{
		if (linked)
		{
			if (squid.y - Reg.cam_offs < dolly.y) dolly.y += (squid.y - Reg.cam_offs - dolly.y) * 0.1;
		}
		else
		{
			if (squid.kickin)
			{
				squid.kickin = false;
			}
			dolly.acceleration.y = -20;
			dolly.maxVelocity.y = 100;
		}
	}
	
	function collisions():Void
	{
		FlxG.collide(squid, level);
		FlxG.collide(squid, walls);
		squid.over_boost ? FlxG.overlap(squid, blocks, break_block) : FlxG.collide(squid, blocks);
		FlxG.overlap(squid, enemies, chomp);
	}
	
	function break_block(_s:Squid, _b:Block):Void
	{
		explosions.fire(_b.getMidpoint());
		for (i in 0...12) bubbles.fire(_b.getMidpoint(), ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(20, 40)));
		_b.kill();
		screen_shake();
	}
	
	function chomp(_s:Squid, _e:Enemy):Void
	{
		blood.fire(_e.getMidpoint());
		explosions.fire(_e.getMidpoint());
		_e.kill();
		switch(Reg.diff)
		{
			case "EASY" : ui.give(8);
			case "NORMAL" : ui.give(4);
			case "TOUGH" : ui.give(2);
		}
		ui.combo_plus();
		screen_shake(0.5);
		Sounds.play("chomp", 0.6);
	}
	
	function swap_tilemaps():Void
	{
		stages.push(stages.shift());
		stages[stages.length - 1].y -= FlxG.height * stage_amt;
		load_map(stages[stages.length - 1]);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
	}
	
	public function game_over():Void
	{
		Sounds.play("drown");
		Sounds.play("explosion", 0.5);
		//MUSIC! stop
		FlxG.sound.music.stop();
		
		linked = false;
		
		new FlxTimer().start(1).onComplete = function(t:FlxTimer):Void
		{
			var _top_blinds = new FlxGroup();
			add(_top_blinds);
			for (i in 0...Std.int(FlxG.height * 0.1))
			{
				var _blind = new FlxSprite(0, i * 52);
				_blind.makeGraphic(FlxG.width, 52, 0x80000000);
				_blind.scale.y = 0;
				_blind.scrollFactor.set();
				_top_blinds.add(_blind);
				new FlxTimer().start(i * 0.1).onComplete = function(t:FlxTimer):Void
				{
					FlxTween.tween(_blind.scale, { y:1 }, 0.5);
				}
			}
			
			var _d_star = "";
			var _c_star = "";
			var _d = Std.int( -(dolly.y - FlxG.height + 48) * (10 / FlxG.height));
			if (Reg.diff == "EASY") _d = Std.int(_d * 0.5);
			if (Reg.diff == "TOUGH") _d = Std.int(_d * 2);
			if (_d > Reg.hi_depth) 
			{
				_d_star = "*";
				Reg.hi_depth = _d;
			}
			if (top_combo > Reg.hi_combo) 
			{
				_c_star = "*";
				Reg.hi_combo = top_combo;
			}
			
			Reg.save();
			
			new FlxTimer().start(0.8).onComplete = function(t:FlxTimer):Void
			{
				add_text(FlxG.height * 0.4,		"GAME OVER", 										1, 		2, 0);
				add_text(FlxG.height * 0.45,	_d_star + "HIGH POINT:" + _d + _d_star,				1.5, 	1, 0);
				add_text(FlxG.height * 0.47,	_c_star + "HIGHEST COMBO:" + top_combo + _c_star,	2, 		1, 0);
				add_text(FlxG.height * 0.6,		"PRESS LEFT + RIGHT TO RESTART",					2.75, 	1, 0);
				new FlxTimer().start(1).onComplete = function(t:FlxTimer):Void { press_to_continue = true; }
			}
		}
		
	}
	
	public function change_colors(_colors:Int):Void
	{
		Reg.cur_color = _colors;
		#if web
		colors = Reg.alt_colors[_colors];
		initColorPalette();
		#else
		Reg.shader_update();
		#end
	}
	
	public function screen_shake(_amount:Float = 1):Void
	{
		var _amt = _amount;
		if (Reg.shake == "NONE") _amt *= 0;
		if (Reg.shake == "VLAMBEER") _amt *= 3;
		
		var _time = Reg.shake == "VLAMBEER" ? 0.25 : 0.1;
		
		FlxG.camera.shake(_amt * 0.01, _time);
	}
	
}