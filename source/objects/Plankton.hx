package objects;

import flixel.math.FlxPoint;
import zerolib.util.ZMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.Sounds;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Plankton extends Enemy
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
			PlayState.i.bubbles.fire(getMidpoint(), FlxPoint.get());
			bubble_timer = ZMath.randomRangeInt(60, 90);
			if (isOnScreen() && Math.random() > 0.5) Sounds.play("bubble", ZMath.randomRange(0.02, 0.04));
		}
		else bubble_timer--;
		super.update(elapsed);
	}
	
}