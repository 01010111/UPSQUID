package;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.effects.FlxTrail;
import flixel.effects.postprocess.PostProcess;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.debug.FlxDebugger.FlxButtonAlignment;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import zerolib.util.ZBitmapText;
import zerolib.util.ZMath;
import flixel.FlxSubState;


/**
 * ...
 * @author x01010111
 */

//	S	T	A	T	E

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
	public var squid:SlengSquid;
	public var bubbles:Bubbles;
	public var blood:Blood;
	public var confetti:Fettis;
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
		
		c = new Controls();
		add(c);
		
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
		confetti = new Fettis();
		
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
		
		squid = new SlengSquid();
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
		
		add(fx_bg_far);
		add(blinds);
		add(fx_bg);
		add(bubbles);
		add(level);
		add_title_stuff();
		add(blocks);
		add(enemies);
		add(confetti);
		add(squid);
		add(fx_fg);
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
		instruction_text.text = "PRESS LEFT Q RIGHT TO PLAY";
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
			restart_text.text = "PRESS LEFT Q RIGHT TO RESTART";
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
			dolly.velocity.y = -20;
		}
		if (dolly.y < stages[1].y) swap_tilemaps();
	}
	
	function collisions():Void
	{
		FlxG.collide(squid, level);
		squid.over_boost ? FlxG.overlap(squid, blocks, break_block) : FlxG.collide(squid, blocks);
		FlxG.overlap(squid, enemies, chomp);
	}
	
	function break_block(s:SlengSquid, b:Block):Void
	{
		fx_fg.add(new Explosion(b.getMidpoint()));
		for (i in 0...12) bubbles.fire(b.getMidpoint(), ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(20, 40)));
		b.kill();
		FlxG.camera.shake(0.01, 0.1);
	}
	
	function chomp(s:SlengSquid, e:Enemy):Void
	{
		blood.fire(e.getMidpoint());
		fx_fg.add(new Explosion(e.getMidpoint()));
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
				enemies.add(new Babby(p));
		}
	}
	
}

//	S	Q	U	I	D

class SlengSquid extends FlxSprite
{
	
	public var over_boost:Bool = false;
	var ghost:FlxTrail;
	var begun:Bool = false;
	public var kickin:Bool = true;
	
	public function new()
	{
		super();
		loadGraphic("assets/images/sleng_teng.png", true, 32, 32);
		animation.add("idle",   [12]);
		animation.add("thrust", [0, 1, 2, 3, 2, 1], 24);
		animation.add("in", [10, 11, 12], 20, false);
		animation.add("out", [12, 13, 10], 20, false);
		animation.add("hurt", [8, 9], 15, true);
		animation.add("play", [10, 10, 11, 11, 12, 13], 1);
		animation.play("play");
		
		setSize(16, 16);
		offset.set(8, 8);
		screenCenter();
		y += Reg.cam_offs;
		
		angle = -90;
		drag.x = 100;
		
		elasticity = 0.3;
		
		ghost = new FlxTrail(this);
		SlengTeng.i.fx_bg_far.add(ghost);
		
		FlxG.watch.add(animation.curAnim, "frameRate", "R: ");
	}
	
	override public function update(elapsed:Float):Void 
	{
		check_collisions();
		if (kickin) controls();
		else 
		{
			velocity.set();
			allowCollisions = 0x0000;
		}
		super.update(elapsed);
	}
	
	var bubble_timer:Int;
	
	function controls():Void
	{
		if (begun)
		{
			if (over_boost)
			{
				if (SlengTeng.i.c._l) angle -= 2;
				if (SlengTeng.i.c._r) angle += 2;
				var v = ZMath.velocityFromAngle(angle, 400);
				velocity.set(v.x, v.y);
				if (justTouched(FlxObject.CEILING)) stop_over_boost();
				if (SlengTeng.i.ui.combo_amt <= 0) stop_over_boost();
				if (bubble_timer == 0)
				{
					SlengTeng.i.bubbles.fire(getMidpoint(), ZMath.velocityFromAngle(angle + 180, ZMath.randomRange(10, 30)));
					bubble_timer = ZMath.randomRangeInt(3, 6);
				}
				else bubble_timer--;
			}
			else 
			{
				var thrusty = true;
				if (SlengTeng.i.c._l) angle -= 3;
				if (SlengTeng.i.c._r) angle += 3;
				if (SlengTeng.i.c._l || SlengTeng.i.c._r || velocity.y > 0) thrusty = false;
				if (SlengTeng.i.c._l_released || SlengTeng.i.c._r_released) thrust();
				if (SlengTeng.i.c._l && SlengTeng.i.c._r && SlengTeng.i.ui.bar_flash) go_over_boost();
				angle = ZMath.clamp(angle, -170, -10);
			}
			animation.curAnim.frameRate = Std.int(FlxMath.remapToRange(velocity.y, 100, -300, 1, 4));
		}
		else
		{
			if (SlengTeng.i.c._l && SlengTeng.i.c._r)
			{
				begun = true;
				acceleration.y = 200;
				//MUSIC! stop intro, play main
				//FlxG.sound.playMusic("Snd_bgm1", 0.5);
				FlxG.sound.music.play();
			}
		}
		ghost.visible = over_boost;
	}
	
	function go_over_boost():Void
	{
		Sounds.play("boost_in");
		over_boost = true;
		over_boost_fx();
	}
	
	function stop_over_boost():Void
	{
		Sounds.play("boost_out");
		over_boost = false;
		over_boost_fx();
	}
	
	function over_boost_fx():Void
	{
		SlengTeng.i.confetti.fire(getMidpoint());
		FlxG.camera.shake(0.01, 0.1);
		//SlengTeng.i.fx_fg.add(new Explosion(getMidpoint()));
	}
	
	function check_collisions():Void
	{
		if (velocity.y > 100) velocity.y = 100;
		
		if (justTouched(FlxObject.CEILING))
		{
			velocity.y = 100;
			Sounds.play("ouch", 0.15);
		}
		
		if (justTouched(FlxObject.FLOOR))
		{
			velocity.y = -100;
			Sounds.play("bounce", 0.25);
		}
	}
	
	function ouch(_amt:Int = 0):Void
	{
		hurt(_amt);
	}
	
	override public function hurt(Damage:Float):Void 
	{
		animation.play("hurt");
	}
	
	function thrust():Void
	{
		if (SlengTeng.i.ui.health >= 0)
		{
			Sounds.play("bloop" + ZMath.randomRangeInt(1, 5), ZMath.randomRange(0.1, 0.2));
			var v = ZMath.velocityFromAngle(angle, 300);
			velocity.set(v.x, v.y);
			SlengTeng.i.ui.take(1);
			for (i in 0...3)
			{
				new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void { SlengTeng.i.bubbles.fire(getMidpoint(), ZMath.velocityFromAngle(angle + ZMath.randomRange(120, 240), ZMath.randomRange(20, 50))); }
			}
		}
	}
	
}

//	B	L	O	C	K

class Block extends FlxSprite
{
	
	public function new(_p:FlxPoint)
	{
		super(_p.x, _p.y);
		loadGraphic("assets/images/blocks.png", true, 16, 16);
		animation.frameIndex = ZMath.randomRangeInt(0, 4);
		immovable = true;
		active = false;
	}
	
}

//	B	U	B	B	L	E	S
class Bubbles extends FlxTypedGroup<Bubble>
{
	
	public function new()
	{
		super();
		
		for (i in 0...16)
		{
			add(new Bubble());
		}
	}
	
	public function fire(_p:FlxPoint, _v:FlxPoint):Void
	{
		if (getFirstAvailable() != null) getFirstAvailable().fire(_p, _v);
	}
	
}

//	B	U	B	B	L	E

class Bubble extends FlxSprite
{
	public function new()
	{
		super();
		loadGraphic("assets/images/bubble.png", true, 8, 8);
		animation.add("play", [0, 1, 2, 3, 4, 3, 2, 1], ZMath.randomRangeInt(10, 20));
		animation.play("play");
		offset.set(4, 4);
		FlxTween.tween(offset, { x:ZMath.randomRange( -8, 8) }, ZMath.randomRange(0.5, 1.5), { ease:FlxEase.sineInOut, type:FlxTween.PINGPONG } );
		acceleration.y = -100;
		drag.x = 100;
		exists = false;
	}
	
	public function fire(_p:FlxPoint, _v:FlxPoint):Void
	{
		setPosition(_p.x, _p.y);
		velocity.set(_v.x, _v.y);
		alpha = ZMath.randomRange(0.4, 1);
		new FlxTimer().start(1).onComplete = function(t:FlxTimer):Void
		{
			FlxSpriteUtil.flicker(this, 0.5);
			new FlxTimer().start(0.5).onComplete = function(t:FlxTimer):Void
			{
				kill();
			}
		}
		exists = true;
	}
}

//	C	O	N	F	E	T	T	I

class Fettis extends FlxTypedGroup<Fetti>
{
	
	public function new()
	{
		super();
		
		for (i in 0...20)
		{
			add(new Fetti());
		}
	}
	
	public function fire(_p:FlxPoint):Void
	{
		for (i in 0...10) if (getFirstAvailable() != null) getFirstAvailable().fire(_p);
	}
	
}

class Fetti extends FlxSprite
{
	
	public function new()
	{
		super();
		loadGraphic("assets/images/confetti.png", true, 6, 8);
		animation.add("play", [0, 1, 2, 3, 4, 5], ZMath.randomRangeInt(10, 24));
		animation.play("play");
		exists = false;
		drag.set(ZMath.randomRange(50, 100), ZMath.randomRange(50, 100));
		acceleration.y = 40;
	}
	
	public function fire(_p):Void
	{
		var v = ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(60, 100));
		velocity.set(v.x, v.y);
		exists = true;
		setPosition(_p.x, _p.y);
		angle = 90 * ZMath.randomRangeInt(0, 3);
		new FlxTimer().start(ZMath.randomRange(0.5, 1)).onComplete = function(t:FlxTimer):Void
		{
			FlxSpriteUtil.flicker(this, 0.4);
			new FlxTimer().start(0.5).onComplete = function(t:FlxTimer):Void
			{
				kill();
			}
		}
	}
	
}

//	E	N	E	M	Y

class Enemy extends FlxSprite
{
	
	override public function update(elapsed:Float):Void 
	{
		if (getScreenPosition().y > FlxG.height) kill();
		super.update(elapsed);
	}
	
}

//	B	A	B	B	Y

class Babby extends Enemy
{
	
	var bubble_timer:Int = 60;
	
	public function new(_p:FlxPoint)
	{
		super(_p.x + 2, _p.y + 2);
		loadGraphic("assets/images/babby.png", true, 11, 11);
		animation.add("play", [0, 1, 2, 1], 12);
		animation.play("play");
		swoosh();
		bubble_timer = ZMath.randomRangeInt(20, 80);
	}
	
	function swoosh():Void
	{
		FlxTween.tween(this, { y:y + 32 }, ZMath.randomRange(1.5, 2.5)).onComplete = function(t:FlxTween):Void
		{
			FlxTween.tween(this, { y:y - 32 }, 0.5, { ease:FlxEase.quadIn } ).onComplete = function(t:FlxTween):Void
			{
				swoosh();
			}
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (bubble_timer == 0)
		{
			SlengTeng.i.bubbles.fire(getMidpoint(), FlxPoint.get());
			bubble_timer = ZMath.randomRangeInt(60, 90);
			if (isOnScreen() && Math.random() > 0.5) Sounds.play("bubble", ZMath.randomRange(0.02, 0.04));
		}
		else bubble_timer--;
		super.update(elapsed);
	}
	
}

//	B	L	O	O	D

class Blood extends FlxTypedGroup<BloodSpot>
{
	
	public function new()
	{
		super();
		
		for (i in 0...32)
		{
			add(new BloodSpot());
		}
	}
	
	public function fire(_p:FlxPoint):Void
	{
		var p = _p;
		for (i in 0...8)
		{
			new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void
			{
				if (getFirstAvailable() != null) getFirstAvailable().fire(p);
				p.set(p.x + ZMath.randomRange( -8, 8), p.y + ZMath.randomRange( -8, 8));
			}
		}
		for (i in 0...8)
		{
			new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void
			{
				if (getFirstAvailable() != null) getFirstAvailable().fire(p);
				p.set(p.x + ZMath.randomRange( -8, 8), p.y + ZMath.randomRange( -8, 8));
			}
		}
	}
	
}

class BloodSpot extends FlxSprite
{
	public function new()
	{
		super();
		exists = false;
		if (Math.random() > 0.5)
		{
			var s = ZMath.randomRangeInt(4, 16);
			makeGraphic(s, s, 0x00ffffff);
			FlxSpriteUtil.drawCircle(this, -1, -1, -1, 0xff808080);
			offset.set(s * 0.5, s * 0.5);
			acceleration.y = -60;
			SlengTeng.i.fx_fg.add(this);
		}
		else 
		{
			var s = ZMath.randomRangeInt(6, 16);
			makeGraphic(s, s, 0x00ffffff);
			FlxSpriteUtil.drawCircle(this, -1, -1, -1, 0xff808080);
			offset.set(s * 0.5, s * 0.5);
			acceleration.y = -50;
			SlengTeng.i.fx_bg_far.add(this);
		}
	}
	
	public function fire(_p):Void
	{
		velocity.y = 0;
		scale.set(1, 1);
		setPosition(_p.x, _p.y);
		FlxTween.tween(scale, { x:0, y:0 }, ZMath.randomRange(1, 3)).onComplete = function(t:FlxTween):Void
		{
			kill();
		}
		exists = true;
	}
}

//	E	X	P	L	O	S	I	O	N

class Explosion extends FlxSprite
{
	
	public function new(_p:FlxPoint)
	{
		super(_p.x, _p.y);
		loadGraphic("assets/images/explosion.png", true, 32, 32);
		animation.add("play", [0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7], 30, false);
		animation.play("play");
		angle = 90 * ZMath.randomRangeInt(0, 3);
		for (i in 0...6)
		{
			SlengTeng.i.bubbles.fire(_p, ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(40, 80)));
		}
		var s = ZMath.randomRange(1, 1.5);
		scale.set(s, s);
		offset.set(16, 16);
		Sounds.play("explosion", ZMath.randomRange(0.2, 0.4));
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (animation.finished) destroy();
	}
	
}

//	U	I

class UI extends FlxGroup
{
	public var health:Int = 0;
	var pellets:Array<Pellet>;
	var ready:Bool = true;
	var to_give:Int = 0;
	var to_take:Int = 0;
	var combo_bar:FlxBar;
	var combo_text:ZBitmapText;
	var combo:Int;
	public var combo_amt:Float = 0;
	public var bar_flash:Bool;
	
	public function new()
	{
		super();
		
		var heart = new FlxSprite(38, 6, "assets/images/heart.png");
		heart.scrollFactor.set();
		heart.color = 0xff808080;
		add(heart);
		
		pellets = new Array();
		for (i in 0...16)
		{
			var p = new Pellet(48 + 12 * i);
			pellets.push(p);
			add(p);
		}
		give(16);
		
		combo_bar = new FlxBar(48, 20, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 96, 3, this, "combo_amt", 0, 100);
		combo_bar.createFilledBar(0x00000000, 0xffffffff, false);
		combo_bar.scrollFactor.set();
		add(combo_bar);
		
		combo_text = new ZBitmapText(44, 16, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?/:x", FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.LEFT);
		combo_text.scrollFactor.set();
		add(combo_text);
	}
	
	public function give(_i:Int):Void
	{
		for (i in 0..._i)
		{
			new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void
			{
				if (health < 15)
				{
					health++;
				}
			}
		}
	}
	
	public function take(_i:Int):Void
	{
		for (i in 0..._i)
		{
			new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void
			{
				if (health > -1)
				{
					health--;
				}
			}
		}
	}
	
	var flash_white:Bool = false;
	var flash_timer:Int = 3;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		for (i in 0...16)
		{
			if (i > health) pellets[i].whatever = false;
			else pellets[i].whatever = true;
		}
		if (health < 0 && SlengTeng.i.linked && SlengTeng.i.squid.velocity.y >= 100) 
		{
			SlengTeng.i.game_over();
		}
		//if (health < 0) SlengTeng.i.openSubState(new GameOver());
		
		if (combo_amt > 75 || SlengTeng.i.squid.over_boost) bar_flash = true;
		else bar_flash = false;
		
		if (combo_amt > 0) combo_amt -= SlengTeng.i.squid.over_boost ? 0.25 : 0.15;
		else combo = 0;
		
		if (combo > 0) combo_text.text = "x" + combo;
		else combo_text.text = "";
		
		if (bar_flash)
		{
			if (flash_timer == 0)
			{
				if (flash_white)
				{
					flash_white = false;
					combo_bar.color = 0xffffffff;
				}
				else 
				{
					flash_white = true;
					combo_bar.color = 0xff808080;
				}
				flash_timer = 3;
			}
			else 
			{
				flash_timer--;
			}
		}
		else 
		{
			combo_bar.color = 0xff808080;
		}
	}
	
	public function combo_plus():Void
	{
		combo++;
		if (combo > SlengTeng.i.top_combo) SlengTeng.i.top_combo = combo;
		combo_amt = ZMath.clamp(combo_amt + 25, 0, 100);
	}
	
}

class PoopNugget extends FlxSprite
{
	// TODO: poop
}

class Pellet extends FlxSprite
{
	public var whatever:Bool = false;
	
	public function new(_x:Int):Void
	{
		super(_x, 8, "assets/images/pellet.png");
		scrollFactor.set();
		scale.set(0, 2);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (whatever)
		{
			alpha += (0.5 - alpha) * 0.1;
			scale.x += (1.05 - scale.x) * 0.25;
			scale.y += (1.05 - scale.y) * 0.25;
		}
		else
		{
			alpha += (1 - alpha) * 0.25;
			scale.x += (0 - scale.x) * 0.25;
			scale.y += (2 - scale.y) * 0.25;
		}
	}

}

class DepthIndicator extends FlxGroup
{
	
	var line:FlxSprite;
	var text:ZBitmapText;
	
	public function new(_d:Int, _y:Float):Void
	{
		super();
		
		line = new FlxSprite(0, _y);
		line.makeGraphic(FlxG.width, 1, 0xff808080);
		add(line);
		
		text = new ZBitmapText(0, _y - 4, " 0123456789m", FlxPoint.get(7, 7), "assets/images/depth_font.png", FlxTextAlign.CENTER, FlxG.width);
		text.text = "" + _d + "0m";
		text.color = 0xff808080;
		text.scrollFactor.set(1, 1);
		add(text);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (line.getScreenPosition().y > FlxG.height)
		{
			kill();
		}
		super.update(elapsed);
	}
	
}

//	A	U	D	I	O

class Sounds
{
	
	public static function play(_s:String, _v:Float = 0.5):Void
	{
		FlxG.sound.play("Snd_" + _s, _v * 1.2);
	}
	
}

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

class Controls extends FlxObject
{
	
	public var _l:Bool;
	public var _r:Bool;
	public var _l_released:Bool;
	public var _r_released:Bool;
	
#if mobile
	var _l_pad:FlxObject;
	var _r_pad:FlxObject;
#else
	var joypad:FlxGamepad;
#end
	
	public function new()
	{
		super();
#if !mobile
		joypad = FlxG.gamepads.firstActive;
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
					if (touch.screenX < FlxG.width * 0.6) _l = true;
					if (touch.screenX > FlxG.width * 0.4) _r = true;
				}
			}
			
			if (touch.justReleased)
			{
				if (touch.screenY > FlxG.height * 0.5)
				{
					if (touch.screenX < FlxG.width * 0.6) _l_released = true;
					if (touch.screenX > FlxG.width * 0.4) _r_released = true;
				}
			}
		}
#end
	}
	
}

class Oggo extends FlxOgmoLoader { public function getString(TileLayer:String = "tiles"):String { return _fastXml.node.resolve(TileLayer).innerData; } }