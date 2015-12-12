package;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import zerolib.util.ZMath;

/**
 * ...
 * @author x01010111
 */
class Sploder extends FlxState 
{

	override public function create():Void 
	{
		super.create();
		var bd = new BitmapData(15, 15, true, 0xff000000);
		bd.setPixel(0, 0, 0x808080);
		var b = new FlxBackdrop(bd);
		add(b);
		
		var e = new Explodee();
		add(e);
		FlxG.camera.follow(e, FlxCameraFollowStyle.TOPDOWN, null, 0.2);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
}

class Explodee extends FlxSprite
{
	public function new()
	{
		super();
		makeGraphic(16, 16, 0x00ffffff);
		FlxSpriteUtil.drawCircle(this);
		FlxSpriteUtil.drawRect(this, getMidpoint().x, getMidpoint().y - 1, width * 0.5, 2, 0xffff0000);
		angle = -90;
		acceleration.y = 200;
		drag.x = 100;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (FlxG.keys.pressed.LEFT) angle -= 2;
		if (FlxG.keys.pressed.RIGHT) angle += 2;
		if (FlxG.keys.anyJustReleased([FlxKey.LEFT, FlxKey.RIGHT])) jump();
	}
	
	function jump():Void
	{
		var v = ZMath.velocityFromAngle(angle, 200);
		velocity.set(v.x, v.y);
	}
}