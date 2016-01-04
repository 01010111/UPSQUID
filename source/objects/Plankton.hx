package objects;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import objects.Plankton.Planky;
import zerolib.util.ZMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.Sounds;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Plankton extends FlxTypedGroup<Planky>
{
	
	public function new()
	{
		super();
		
		for (i in 0...16)
		{
			var _p:Planky = new Planky();
			PlayState.i.enemies.add(_p);
			add(_p);
		}
	}
	
	public function spawn(_p:FlxPoint):Void
	{
		if (getFirstAvailable() != null) getFirstAvailable().spawn(_p);
	}
	
}

class Planky extends Enemy
{
	var bubble_timer:Int = 60;
	var tween:FlxTween;
	
	public function new()
	{
		super();
		loadGraphic("assets/images/babby.png", true, 11, 11);
		animation.add("play", [0, 1, 2, 1], 12);
		bubble_timer = ZMath.randomRangeInt(20, 80);
		exists = false;
	}
	
	public function spawn(_p:FlxPoint):Void
	{
		exists = true;
		setPosition(_p.x + 2, _p.y + 2);
		animation.play("play");
		swoosh();
	}
	
	function swoosh(?t:FlxTween):Void
	{
		if (exists) tween = FlxTween.tween(this, { y:y + 32 }, ZMath.randomRange(1.5, 2.5), { onComplete:second_swoosh } );
	}
	
	function second_swoosh(t:FlxTween):Void
	{
		if (exists) tween = FlxTween.tween(this, { y:y - 32 }, 0.5, { ease:FlxEase.quadIn, onComplete:swoosh } );
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (bubble_timer == 0)
		{
			PlayState.i.bubbles.fire(getMidpoint(), FlxPoint.get());
			bubble_timer = ZMath.randomRangeInt(60, 90);
			if (isOnScreen() && Math.random() > 0.5) Sounds.play("bubble", ZMath.randomRange(0.04, 0.08));
		}
		else bubble_timer--;
		super.update(elapsed);
		if (getScreenPosition().y > FlxG.height) kill();
	}
	
	override public function kill():Void 
	{
		tween.cancel();
		super.kill();
	}
	
}