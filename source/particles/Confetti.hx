package particles;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import zerolib.util.ZMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author 01010111
 */
class Confetti extends FlxTypedGroup<Fetti>
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
	
	public function fire(_p:FlxPoint):Void
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
