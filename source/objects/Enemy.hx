package objects;

import flixel.FlxSprite;
import flixel.FlxG;

/**
 * ...
 * @author 01010111
 */
class Enemy extends FlxSprite
{
	
	override public function update(elapsed:Float):Void 
	{
		if (getScreenPosition().y > FlxG.height) kill();
		super.update(elapsed);
	}
	
}