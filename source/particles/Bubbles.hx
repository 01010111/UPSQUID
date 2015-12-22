package particles;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import zerolib.util.ZMath;

/**
 * ...
 * @author 01010111
 */
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
