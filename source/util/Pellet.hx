package util;

import flixel.FlxSprite;

/**
 * ...
 * @author 01010111
 */
class Pellet extends FlxSprite
{
	public var whatever:Bool = false;
	
	public function new(_x:Int):Void
	{
		super(_x, 8, "assets/images/pellet.png");
		scrollFactor.set();
		scale.set(0, 2);
	}
	
	#if flash
	var _target:Float = 0.5;
	#else
	var _target:Float = 0.35;
	#end
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (whatever)
		{
			alpha += (_target - alpha) * 0.1;
			scale.x += (1.05 - scale.x) * 0.25;
			scale.y += (1.05 - scale.y) * 0.25;
		}
		else
		{
			alpha += (1 - alpha) * 0.25;
			scale.x += (0 - scale.x) * 0.25;
			scale.y += (2 - scale.y) * 0.25;
		}
	}

}