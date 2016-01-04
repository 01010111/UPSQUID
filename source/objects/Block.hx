package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import zerolib.util.ZMath;

/**
 * ...
 * @author 01010111
 */
class Block extends FlxSprite
{
	
	public function new(_p:FlxPoint)
	{
		super(_p.x, _p.y);
		loadGraphic("assets/images/blocks.png", true, 16, 16);
		animation.frameIndex = ZMath.randomRangeInt(0, 4);
		immovable = true;
		active = false;
	}
	
}