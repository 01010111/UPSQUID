package objects;

import flixel.addons.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxObject;
import zerolib.util.ZMath;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import util.*;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Squid extends FlxSprite
{
	
	public var over_boost:Bool = false;
	var ghost:FlxTrail;
	var begun:Bool = false;
	public var kickin:Bool = true;
	
	public function new()
	{
		super();
		loadGraphic("assets/images/sleng_teng.png", true, 32, 32);
		animation.add("idle",   [12]);
		animation.add("thrust", [0, 1, 2, 3, 2, 1], 24);
		animation.add("in", [10, 11, 12], 20, false);
		animation.add("out", [12, 13, 10], 20, false);
		animation.add("hurt", [8, 9], 15, true);
		animation.add("play", [10, 10, 11, 11, 12, 13], 1);
		animation.play("play");
		
		setSize(16, 16);
		offset.set(8, 8);
		screenCenter();
		y += Reg.cam_offs;
		
		angle = -90;
		drag.x = 100;
		
		elasticity = 0.3;
		
		ghost = new FlxTrail(this);
		PlayState.i.fx_bg_far.add(ghost);
		
		FlxG.watch.add(animation.curAnim, "frameRate", "R: ");
	}
	
	override public function update(elapsed:Float):Void 
	{
		check_collisions();
		if (kickin) controls();
		else 
		{
			velocity.set();
			allowCollisions = 0x0000;
		}
		super.update(elapsed);
	}
	
	var bubble_timer:Int;
	
	function controls():Void
	{
		if (begun)
		{
			if (over_boost)
			{
				if (PlayState.i.c._l) angle -= 2;
				if (PlayState.i.c._r) angle += 2;
				var v = ZMath.velocityFromAngle(angle, 400);
				velocity.set(v.x, v.y);
				if (justTouched(FlxObject.CEILING)) stop_over_boost();
				if (PlayState.i.ui.combo_amt <= 0) stop_over_boost();
				if (bubble_timer == 0)
				{
					PlayState.i.bubbles.fire(getMidpoint(), ZMath.velocityFromAngle(angle + 180, ZMath.randomRange(10, 30)));
					bubble_timer = ZMath.randomRangeInt(3, 6);
				}
				else bubble_timer--;
			}
			else 
			{
				var thrusty = true;
				if (PlayState.i.c._l) angle -= 3;
				if (PlayState.i.c._r) angle += 3;
				if (PlayState.i.c._l || PlayState.i.c._r || velocity.y > 0) thrusty = false;
				if (PlayState.i.c._l_released || PlayState.i.c._r_released) thrust();
				if (PlayState.i.c._l && PlayState.i.c._r && PlayState.i.ui.bar_flash) go_over_boost();
				angle = ZMath.clamp(angle, -170, -10);
			}
			animation.curAnim.frameRate = Std.int(FlxMath.remapToRange(velocity.y, 100, -300, 1, 4));
		}
		else
		{
			if (PlayState.i.c._l && PlayState.i.c._r)
			{
				begun = true;
				acceleration.y = 200;
				//MUSIC! stop intro, play main
				//FlxG.sound.playMusic("Snd_bgm1", 0.5);
				FlxG.sound.music.play();
			}
		}
		ghost.visible = over_boost;
	}
	
	function go_over_boost():Void
	{
		Sounds.play("boost_in");
		over_boost = true;
		over_boost_fx();
	}
	
	function stop_over_boost():Void
	{
		Sounds.play("boost_out");
		over_boost = false;
		over_boost_fx();
	}
	
	function over_boost_fx():Void
	{
		PlayState.i.confetti.fire(getMidpoint());
		FlxG.camera.shake(0.01, 0.1);
		//PlayState.i.fx_fg.add(new Explosion(getMidpoint()));
	}
	
	function check_collisions():Void
	{
		if (velocity.y > 100) velocity.y = 100;
		
		if (justTouched(FlxObject.CEILING))
		{
			velocity.y = 100;
			Sounds.play("ouch", 0.15);
		}
		
		if (justTouched(FlxObject.FLOOR))
		{
			velocity.y = -100;
			Sounds.play("bounce", 0.25);
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
		if (PlayState.i.ui.health >= 0)
		{
			Sounds.play("bloop" + ZMath.randomRangeInt(1, 5), ZMath.randomRange(0.1, 0.2));
			var v = ZMath.velocityFromAngle(angle, 300);
			velocity.set(v.x, v.y);
			PlayState.i.ui.take(1);
			for (i in 0...3)
			{
				new FlxTimer().start(i * 0.05).onComplete = function(t:FlxTimer):Void { PlayState.i.bubbles.fire(getMidpoint(), ZMath.velocityFromAngle(angle + ZMath.randomRange(120, 240), ZMath.randomRange(20, 50))); }
			}
		}
	}
	
}
