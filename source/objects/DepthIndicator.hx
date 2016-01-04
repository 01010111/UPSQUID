package objects;

import flixel.group.FlxGroup;
import flixel.FlxSprite;
import util.Reg;
import zerolib.util.ZBitmapText;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.math.FlxPoint;

/**
 * ...
 * @author 01010111
 */
class DepthIndicator extends FlxGroup
{
	
	var line:FlxSprite;
	var text:ZBitmapText;
	
	public function new(_d:Int, _y:Float):Void
	{
		super();
		
		line = new FlxSprite(0, _y);
		line.makeGraphic(FlxG.width, 1, 0xff808080);
		add(line);
		
		var _d_adjusted = _d * 10;
		if (Reg.diff == "EASY") _d_adjusted = Std.int(_d_adjusted * 0.5);
		if (Reg.diff == "TOUGH") _d_adjusted = Std.int(_d_adjusted * 2);
		
		text = new ZBitmapText(0, _y - 4, " 0123456789m", FlxPoint.get(7, 7), "assets/images/depth_font.png", FlxTextAlign.CENTER, FlxG.width);
		text.text = "" + _d_adjusted + "m";
		text.color = 0xff808080;
		text.scrollFactor.set(1, 1);
		add(text);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (line.getScreenPosition().y > FlxG.height)
		{
			kill();
		}
		super.update(elapsed);
	}
	
}