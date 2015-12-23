package particles;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import zerolib.util.ZMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
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
			PlayState.i.fx_fg.add(this);
		}
		else 
		{
			var s = ZMath.randomRangeInt(6, 16);
			makeGraphic(s, s, 0x00ffffff);
			FlxSpriteUtil.drawCircle(this, -1, -1, -1, 0xff808080);
			offset.set(s * 0.5, s * 0.5);
			acceleration.y = -50;
			PlayState.i.fx_bg_far.add(this);
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