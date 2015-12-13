package;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.addons.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.debug.FlxDebugger.FlxButtonAlignment;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
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
	var dolly:FlxObject;
	var blocks:FlxGroup;
	var enemies:FlxTypedGroup<Enemy>;
	var depth:Int;
	public var squid:SlengSquid;
	public var bubbles:Bubbles;
	public var blood:Blood;
	public var fx_bg_far:FlxGroup;
	public var fx_bg:FlxGroup;
	public var fx_fg:FlxGroup;
	public var ui:UI;
	public static var i:SlengTeng;
	
	override public function create():Void 
	{
		i = this;
		colors = [0xff000000, 0xffff0000, 0xffffffff];
		FlxG.scaleMode.gameSize.set(288, 512);
		
		level = new FlxGroup();
		blocks = new FlxGroup();
		fx_bg_far = new FlxGroup();
		fx_bg = new FlxGroup();
		fx_fg = new FlxGroup();
		enemies = new FlxTypedGroup();
		bubbles = new Bubbles();
		blood = new Blood();
		
		stages = new Array();
		for (i in 0...stage_amt)
		{
			var l:FlxTilemap = new FlxTilemap();
			l.setPosition(0, -i * FlxG.height);
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
		add(blocks);
		add(enemies);
		add(squid);
		add(fx_fg);
		add(dolly);
		add(fade);
		add(ui);
		
		FlxG.camera.follow(dolly);
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height * 3);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
		super.create();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		move_dolly_and_check_tilemaps();
		collisions();
		if (squid.getScreenPosition().y > FlxG.height) openSubState(new GameOver());
	}
	
	function move_dolly_and_check_tilemaps():Void
	{
		if (squid.y < dolly.y) dolly.y += (squid.y - dolly.y) * 0.1;
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
	}
	
	function chomp(s:SlengSquid, e:Enemy):Void
	{
		blood.fire(e.getMidpoint());
		fx_fg.add(new Explosion(e.getMidpoint()));
		e.destroy();
		ui.give(4);
		ui.combo_plus();
	}
	
	function swap_tilemaps():Void
	{
		stages.push(stages.shift());
		stages[stages.length - 1].y -= FlxG.height * stage_amt;
		load_map(stages[stages.length - 1]);
		FlxG.worldBounds.setPosition(0, stages[stages.length - 1].y);
	}
	
	function load_map(t:FlxTilemap):Void
	{
		var o = new FlxOgmoLoader("assets/data/" + ZMath.randomRangeInt(0, 3) + ".oel");
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
	
	public function new()
	{
		super();
		loadGraphic("assets/images/sleng_teng.png", true, 32, 32);
		animation.add("idle",   [12]);
		animation.add("thrust", [0, 1, 2, 3, 2, 1], 24);
		animation.add("in", [10, 11, 12], 20, false);
		animation.add("out", [12, 13, 10], 20, false);
		animation.add("hurt", [8, 9, 8, 9, 8], 15, false);
		animation.add("play", [10, 11, 12, 13]);
		animation.play("play");
		
		setSize(16, 16);
		offset.set(8, 8);
		screenCenter();
		
		angle = -90;
		acceleration.y = 200;
		drag.x = 100;
		
		elasticity = 0.3;
		
		var ghost = new FlxTrail(this);
		//SlengTeng.i.fx_bg_far.add(ghost);
	}
	
	override public function update(elapsed:Float):Void 
	{
		check_collisions();
		controls();
		super.update(elapsed);
	}
	
	var bubble_timer:Int;
	
	function controls():Void
	{
		if (over_boost)
		{
			if (FlxG.keys.pressed.LEFT) angle -= 2;
			if (FlxG.keys.pressed.RIGHT) angle += 2;
			//animation.play("out");
			var v = ZMath.velocityFromAngle(angle, 400);
			velocity.set(v.x, v.y);
			if (justTouched(FlxObject.CEILING)) over_boost = false;
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
			if (FlxG.keys.pressed.LEFT) angle -= 3;
			if (FlxG.keys.pressed.RIGHT) angle += 3;
			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT || velocity.y > 0) thrusty = false;
			if (FlxG.keys.anyJustReleased([FlxKey.LEFT, FlxKey.RIGHT])) thrust();
			if (FlxG.keys.pressed.LEFT && FlxG.keys.pressed.RIGHT && SlengTeng.i.ui.bar_flash) over_boost = true;
			angle = ZMath.clamp(angle, -170, -10);
		}
		animation.curAnim.frameRate = Math.floor(ZMath.map(velocity.y, 100, -300, 0, 40));
	}
	
	function check_collisions():Void
	{
		if (velocity.y > 100) velocity.y = 100;
		
		
		if (justTouched(FlxObject.FLOOR))
		{
			velocity.y = -100;
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
		var v = ZMath.velocityFromAngle(angle, 300);
		velocity.set(v.x, v.y);
		SlengTeng.i.ui.take(1);
		for (i in 0...3)
		{
			new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void { SlengTeng.i.bubbles.fire(getMidpoint(), ZMath.velocityFromAngle(angle + ZMath.randomRange(120, 240), ZMath.randomRange(20, 50))); }
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
	var health:Int = 0;
	var pellets:Array<Pellet>;
	var ready:Bool = true;
	var to_give:Int = 0;
	var to_take:Int = 0;
	var combo_bar:FlxBar;
	var combo_text:ZBitmapText;
	var combo:Int;
	var combo_amt:Float = 0;
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
		
		combo_bar = new FlxBar(48, 20, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 96, 6, this, "combo_amt", 0, 100);
		combo_bar.createFilledBar(0x80000000, 0xffffffff, false);
		combo_bar.scrollFactor.set();
		add(combo_bar);
		
		combo_text = new ZBitmapText(44, 16, " 0123456789m", FlxPoint.get(7, 7), "assets/images/depth_font.png", FlxTextAlign.LEFT);
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
		if (health < 0) SlengTeng.i.openSubState(new GameOver());
		
		if (combo_amt > 75 || SlengTeng.i.squid.over_boost) bar_flash = true;
		else bar_flash = false;
		
		if (combo_amt > 0) combo_amt -= SlengTeng.i.squid.over_boost ? 0.25 : 0.15;
		else combo = 0;
		
		if (combo > 0) combo_text.text = "m" + combo;
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
		combo_amt = ZMath.clamp(combo_amt + 20, 0, 100);
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
		alpha = 0;
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

//	S	U	B	S	T	A	T	E	S

class GameOver extends FlxSubState
{
	
	public function new():Void
	{
		super();
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.keys.justPressed.SPACE) FlxG.resetState();
		
		super.update(elapsed);
	}
	
}