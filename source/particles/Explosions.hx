package particles;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import util.Sounds;
import zerolib.util.ZMath;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Explosions extends FlxTypedGroup<Explosion>
{
	
	public function new()
	{
		super();
		
		for (i in 0...8)
		{
			add(new Explosion());
		}
	}
	
	public function fire(_p:FlxPoint):Void
	{
		if (getFirstAvailable() != null) getFirstAvailable().fire(_p);
	}
	}

class Explosion extends FlxSprite
{
	
	public function new()
	{
		super();
		loadGraphic("assets/images/explosion.png", true, 32, 32);
		animation.add("play", [0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7], 30, false);
		offset.set(16, 16);
		exists = false;
	}
	
	public function fire(_p:FlxPoint):Void
	{
		setPosition(_p.x, _p.y);
		animation.play("play");
		angle = 90 * ZMath.randomRangeInt(0, 3);
		for (i in 0...6)
		{
			PlayState.i.bubbles.fire(_p, ZMath.velocityFromAngle(ZMath.randomRange(0, 360), ZMath.randomRange(40, 80)));
		}
		var s = ZMath.randomRange(1, 1.5);
		scale.set(s, s);
		Sounds.play("explosion", ZMath.randomRange(0.2, 0.4));
		exists = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (animation.finished) exists = false;
	}
	
}