package objects;

import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import zerolib.util.ZBitmapText;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import zerolib.util.ZMath;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxEase;
import util.Reg;

/**
 * ...
 * @author 01010111
 */
class DepthLastHiScore extends FlxGroup
{
	
	var line:FlxBackdrop;
	var text:ZBitmapText;
	var lines:FlxTypedGroup<LineBreaker>;
	
	public function new():Void
	{
		super();
		
		lines = new FlxTypedGroup();
		
		for (i in 0...Std.int(FlxG.width / 16))
		{
			lines.add(new LineBreaker());
		}
		
		// Std.int( -(dolly.y - FlxG.height + 48) * (10 / FlxG.height));
		// x = -(y - f + 48) * (10 / f)
		// y = -(fx/10) + f - 48
		var _y = -((FlxG.height * Reg.hi_depth) / 10) + FlxG.height;
		
		var _bm:BitmapData = new BitmapData(FlxG.width, 1, true, 0x00ffffff);
		for (i in 0...Std.int(FlxG.width / 16))
		{
			for (x in 0...8)
			{
				_bm.setPixel32(x + i * Std.int(FlxG.width / 16), 0, 0xffffffff);
			}
		}
		
		line = new FlxBackdrop(_bm, 1, 1, true, false);
		line.y = _y;
		line.velocity.x = 15;
		add(line);
		
		text = new ZBitmapText(0, _y - 4, " 0123456789m", FlxPoint.get(7, 7), "assets/images/depth_font.png", FlxTextAlign.CENTER, FlxG.width);
		text.text = "" + Reg.hi_depth + "m";
		text.scrollFactor.set(1, 1);
		add(text);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (line.y > SlengTeng.i.squid.y)
		{
			fireLine();
			SlengTeng.i.confetti.fire(SlengTeng.i.squid.getMidpoint());
			SlengTeng.i.ui.combo_amt = ZMath.clamp(SlengTeng.i.ui.combo_amt + 20, 0, 100);
			SlengTeng.i.explosions.fire(SlengTeng.i.squid.getMidpoint());
			//FlxTween.tween(line, { alpha:0 }, 0.5);
			//FlxTween.tween(text, { alpha:0 }, 0.5).onComplete = function(t:FlxTween):Void { kill(); }
			kill();
		}
		super.update(elapsed);
	}
	
	function fireLine():Void
	{
		for (i in 0...Std.int(FlxG.width / 16)) 
		{
			if (lines.getFirstAvailable() != null) lines.getFirstAvailable().fire(FlxPoint.get(i * Std.int(FlxG.width / 16), line.y));
		}
	}
	
}

class LineBreaker extends FlxSprite
{
	
	public function new()
	{
		super();
		makeGraphic(8, 1);
		exists = false;
		SlengTeng.i.fx_bg.add(this);
	}
	
	public function fire(_p:FlxPoint):Void
	{
		exists = true;
		setPosition(_p.x, _p.y);
		alpha = ZMath.randomRange(0.5, 1);
		new FlxTimer().start(0.5).onComplete = function (t:FlxTimer) : Void { FlxSpriteUtil.flicker(this, 0.5); }
		FlxTween.tween(this, { angle:ZMath.randomRange( -180, 180) }, 1, { ease:FlxEase.quintOut } ).onComplete = function(t:FlxTween):Void { kill(); }
		acceleration.y = 40;
		var _a = ZMath.clamp(270 + (x - SlengTeng.i.squid.x), 180, 360);
		var _s = ZMath.clamp(150 - ZMath.distance(getMidpoint(), SlengTeng.i.squid.getMidpoint()), 0, ZMath.clamp(-SlengTeng.i.squid.velocity.y - 20, 0, 900) + ZMath.randomRange( -10, 20));
		var _v = ZMath.velocityFromAngle(_a, _s);
		velocity.set(_v.x, _v.y);
	}
	
}