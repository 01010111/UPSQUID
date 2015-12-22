package;
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
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.Lib;
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

class SlengTeng extends ZState
{
	
	var level:FlxGroup;
	var stages:Array<FlxTilemap>;
	var stage_amt:Int = 3;
	var blocks:FlxGroup;
	var enemies:FlxTypedGroup<Enemy>;
	var depth:Int;
	var dolly:FlxObject;
	public var c:Controls;
	public var squid:Squid;
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
	public static var i:SlengTeng;
	
	var alt_colors:Array<Int> = [
		0xffff0000/*,
		0xffd93963,
		0xff7c0fd8,
		0xff22b764,
		0xffee5564,
		0xff*/
	];
	
	override public function create():Void 
	{
		//FlxG.fullscreen = true;
		
		Reg.initSave();
		i = this;
		colors = [0xff000000, alt_colors[ZMath.randomRangeInt(0, alt_colors.length - 1)], 0xffffffff];
		
		//MUSIC! play intro
		
		FlxG.sound.playMusic("Snd_bgm1", 0.5);
		FlxG.sound.music.pause();
		
		level = new FlxGroup();
		blocks = new FlxGroup();
		fx_bg_far = new FlxGroup();
		fx_bg = new FlxGroup();
		fx_fg = new FlxGroup();
		enemies = new FlxTypedGroup();
		bubbles = new Bubbles();
		blood = new Blood();
		confetti = new Confetti();
		explosions = new Explosions();
		
		stages = new Array();
		for (i in 0...stage_amt)
		{
			var l:FlxTilemap = new FlxTilemap();
			l.setPosition(0, -i * FlxG.height);
			//l.setPosition(FlxG.width * 0.5 - 144, -i * FlxG.height);
			load_map(l);
			stages.push(l);
			level.add(l);
		}
		
		squid = new Squid();
		dolly = new FlxObject(squid.getMidpoint().x, squid.getMidpoint().y, 1, 1);
		
		var blinds = new FlxGroup();
		for (i in 0...Std.int(FlxG.width * 0.25))
		{
			var b = new FlxSprite(i * 4);
			b.makeGraphic(2, FlxG.height, 0xff000000);
			b.scrollFactor.set();
			b.active = false;
			blinds.add(b);
		}
		
		var fade = new FlxSprite(0, 0, "assets/images/fade.png");
		fade.scrollFactor.set();
		fade.blend = BlendMode.MULTIPLY;
		
		ui = new UI();
		
		c = new Controls();
		add(c);
		
		add(fx_bg_far);
		add(blinds);
		if (Reg.hi_depth > 0) add(new DepthLastHiScore());
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
		add(fade);
		add(ui);
		
		FlxG.camera.setSize(288, 512);
		FlxG.camera.setPosition(FlxG.width * 0.5 - 144, FlxG.height * 0.5 - 256);
		FlxG.camera.follow(dolly);
		//FlxG.camera.setScrollBounds(0, 4000, -500000000000000000000000, 140);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height * 3);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
		super.create();
	}
	
	function add_title_stuff():Void
	{
		var title = new FlxSprite(0, FlxG.height * 0.25, "assets/images/title.png");
		title.scale.set(2, 2);
		title.screenCenter(FlxAxes.X);
		add(title);
		
		var instruction_text:ZBitmapText = new ZBitmapText(0, FlxG.height * 0.75, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x+", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
		instruction_text.text = "PRESS LEFT + RIGHT TO PLAY";
		instruction_text.alpha = 0;
		instruction_text.scrollFactor.set(1, 1);
		add(instruction_text);
		FlxTween.tween(instruction_text, { alpha:1 }, 1);
		
		var _o = Reg.cam_offs > 32 ? 0.4 : 0.6;
		
		if (Reg.hi_combo > 0)
		{
			var combo_text:ZBitmapText = new ZBitmapText(0, FlxG.height * _o, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x+", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			combo_text.text = "HI COMBO : " + Reg.hi_combo;
			combo_text.alpha = 0;
			combo_text.scrollFactor.set(1, 1);
			add(combo_text);
			FlxTween.tween(combo_text, { alpha:1 }, 2);
		}
		
		if (Reg.hi_depth > 0)
		{
			var depth_text:ZBitmapText = new ZBitmapText(0, FlxG.height * (_o + 0.025), " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x+", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			depth_text.text = "HI POINT : " + Reg.hi_depth;
			depth_text.alpha = 0;
			depth_text.scrollFactor.set(1, 1);
			add(depth_text);
			FlxTween.tween(depth_text, { alpha:1 }, 2);
		}
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		move_dolly_and_check_tilemaps();
		collisions();
		if (squid.getScreenPosition().y > FlxG.height && linked) 
		{
			game_over();
			//openSubState(new GameOver());
		}
		
		if (press_to_continue && c._l && c._r) FlxG.resetState();
	}
	
	var press_to_continue:Bool = false;
	
	public function game_over():Void
	{
		Sounds.play("drown", 0.6);
		Sounds.play("explosion", 0.25);
		//MUSIC! stop
		FlxG.sound.music.stop();
		
		linked = false;
		
		new FlxTimer().start(1).onComplete = function(t:FlxTimer):Void
		{
			var top_blinds = new FlxGroup();
			add(top_blinds);
			for (i in 0...Std.int(FlxG.height * 0.1))
			{
				var blind = new FlxSprite(0, i * 52);
				blind.makeGraphic(FlxG.width, 52, 0x80000000);
				blind.scale.y = 0;
				blind.scrollFactor.set();
				top_blinds.add(blind);
				new FlxTimer().start(i * 0.1).onComplete = function(t:FlxTimer):Void
				{
					FlxTween.tween(blind.scale, { y:1 }, 0.5);
				}
			}
			
			var game_over_text:ZBitmapText = new ZBitmapText(0, FlxG.height * 0.4, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			game_over_text.text = "GAME OVER";
			game_over_text.alpha = 0;
			game_over_text.scale.set(2, 2);
			add(game_over_text);
			
			var _d = Std.int( -(dolly.y - FlxG.height + 48) * (10 / FlxG.height));
			
			var high_point_text:ZBitmapText = new ZBitmapText(0, FlxG.height * 0.45, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			high_point_text.text = "HIGH POINT:" + _d;
			high_point_text.alpha = 0;
			add(high_point_text);
			
			var top_combo_text:ZBitmapText = new ZBitmapText(0, FlxG.height * 0.47, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			top_combo_text.text = "HIGHEST COMBO:" + top_combo;
			top_combo_text.alpha = 0;
			add(top_combo_text);
			
			var restart_text:ZBitmapText = new ZBitmapText(0, FlxG.height * 0.6, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x+", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
			restart_text.text = "PRESS LEFT + RIGHT TO RESTART";
			restart_text.alpha = 0;
			add(restart_text);
			
			if (_d > Reg.hi_depth) Reg.hi_depth = _d;
			if (top_combo > Reg.hi_combo) Reg.hi_combo = top_combo;
			
			Reg.save();
			
			new FlxTimer().start(0.8).onComplete = function(t:FlxTimer):Void
			{
				FlxTween.tween(game_over_text, { alpha:1 }, 1);
				FlxTween.tween(high_point_text, { alpha:1.5 }, 1);
				FlxTween.tween(top_combo_text, { alpha:2 }, 1);
				FlxTween.tween(restart_text, { alpha:2.75 }, 1);
				new FlxTimer().start(1).onComplete = function(t:FlxTimer):Void
				{
					press_to_continue = true;
				}
			}
		}
		
	}
	
	function move_dolly_and_check_tilemaps():Void
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
		if (dolly.y < stages[1].y) swap_tilemaps();
	}
	
	function collisions():Void
	{
		FlxG.collide(squid, level);
		squid.over_boost ? FlxG.overlap(squid, blocks, break_block) : FlxG.collide(squid, blocks);
		FlxG.overlap(squid, enemies, chomp);
	}
	
	function break_block(s:Squid, b:Block):Void
	{
		explosions.fire(b.getMidpoint());
		for (i in 0...12) bubbles.fire(b.getMidpoint(), ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(20, 40)));
		b.kill();
		FlxG.camera.shake(0.01, 0.1);
	}
	
	function chomp(s:Squid, e:Enemy):Void
	{
		blood.fire(e.getMidpoint());
		explosions.fire(e.getMidpoint());
		e.destroy();
		ui.give(4);
		ui.combo_plus();
		FlxG.camera.shake(0.005, 0.1);
		Sounds.play("chomp", 0.3);
	}
	
	function swap_tilemaps():Void
	{
		stages.push(stages.shift());
		stages[stages.length - 1].y -= FlxG.height * stage_amt;
		load_map(stages[stages.length - 1]);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
	}
	
	var first_map:Bool = true;
	
	function load_map(t:FlxTilemap):Void
	{
		var s = "";
		if (first_map)
		{
			s = "assets/data/start.oel";
			first_map = false;
		}
		else
		{
			s = "assets/data/" + ZMath.randomRangeInt(0, 11) + ".oel";
		}
		var o = new Oggo(s);
		t.loadMapFromCSV(o.getString(), "assets/images/tiles.png", 16, 16, FlxTilemapAutoTiling.AUTO);
		_loaded_object_y_offset = t.y;
		o.loadEntities(load_objects, "objects");
		depth++;
		if (depth % 5 == 0) fx_bg.add(new DepthIndicator(depth, t.y + 8));
	}
	
	var _loaded_object_y_offset:Float;
	
	function load_objects(entityName:String, entityData:Xml):Void
	{
		var p:FlxPoint = FlxPoint.get(Std.parseInt(entityData.get("x")), Std.parseInt(entityData.get("y")) + _loaded_object_y_offset);
		switch(entityName)
		{
			case "block":
				blocks.add(new Block(p));
			case "babby":
				enemies.add(new Plankton(p));
		}
	}
	
}