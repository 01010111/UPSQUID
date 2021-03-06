package util;

import flixel.FlxObject;
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
	var flash_timer:Int = 3;
	var last_flash:Bool = false;
	var combo_flash_timer:Int = 3;
	
	public var combo_amt:Float = 0;
	public var bar_flash:Bool;
	public var combo_flash:Bool;
	
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
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		for (i in 0...16)
		{
			if (i > health) pellets[i].whatever = false;
			else pellets[i].whatever = true;
		}
		if (health < 0 && PlayState.i.linked && (PlayState.i.squid.getScreenPosition().y > FlxG.height * 0.9 || PlayState.i.squid.just_touched_floor)) 
		{
			PlayState.i.game_over();
		}
		
		if (combo_amt > 75 || PlayState.i.squid.over_boost) bar_flash = true;
		else if (combo_amt < 50) bar_flash = false;
		
		if (bar_flash && !last_flash) Sounds.play("combo_available", 0.5);
		
		last_flash = bar_flash;
		
		if (combo_amt > 0) combo_amt -= PlayState.i.squid.over_boost ? 0.25 : 0.15;
		else combo = 0;
		
		if (combo > 0) combo_text.text = "x" + combo;
		else combo_text.text = "";
		
		if (bar_flash)
		{
			if (flash_timer == 0)
			{
				
				combo_bar.color = combo_bar.color == 0xffffffff ? 0xff808080 : 0xffffffff;
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
		#if !flash
		if (combo >= 10) 
		{
			combo_text.alignment = FlxTextAlign.CENTER;
			combo_text.setPosition(PlayState.i.squid.getScreenPosition().x + PlayState.i.squid.width * 0.5 - 2, PlayState.i.squid.getScreenPosition().y + 28);
		}
		else
		{
			combo_text.alignment = FlxTextAlign.LEFT;
			combo_text.setPosition(44, 16);
		}
		combo_text.fieldWidth = 0;
		#end
		
		if (combo > Reg.hi_combo && combo >= PlayState.i.top_combo)
		{
			if (combo_flash_timer <= 0)
			{
				combo_text.color = combo_text.color == 0xffffffff ? 0xff808080 : 0xffffffff;
				combo_flash_timer = 3;
			}
			else combo_flash_timer--;
		}
		else 
		{
			combo_text.color = 0xffffffff;
		}
	}
	
	public function combo_plus():Void
	{
		combo++;
		if (combo > PlayState.i.top_combo) PlayState.i.top_combo = combo;
		combo_amt = ZMath.clamp(combo_amt + 25, 0, 100);
	}
	
}
