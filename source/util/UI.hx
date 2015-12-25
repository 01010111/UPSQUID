package util;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import zerolib.util.ZBitmapText;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import zerolib.util.ZMath;
import flixel.FlxSprite;
import flixel.FlxG;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
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
		
		combo_text = new ZBitmapText(44, 16, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.LEFT);
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
	var last_flash:Bool = false;
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		for (i in 0...16)
		{
			if (i > health) pellets[i].whatever = false;
			else pellets[i].whatever = true;
		}
		if (health < 0 && PlayState.i.linked && PlayState.i.squid.velocity.y >= 100) 
		{
			PlayState.i.game_over();
		}
		
		if (combo_amt > 75 || PlayState.i.squid.over_boost) bar_flash = true;
		else if (combo_amt < 50) bar_flash = false;
		
		if (bar_flash && !last_flash) Sounds.play("combo_available", 0.25);
		
		last_flash = bar_flash;
		
		if (combo_amt > 0) combo_amt -= PlayState.i.squid.over_boost ? 0.25 : 0.15;
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
		if (combo > PlayState.i.top_combo) PlayState.i.top_combo = combo;
		combo_amt = ZMath.clamp(combo_amt + 25, 0, 100);
	}
	
}
