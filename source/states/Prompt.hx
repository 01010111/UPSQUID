package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import zerolib.util.ZBitmapText;
import zerolib.util.ZMath;

/**
 * ...
 * @author 01010111
 */
class Prompt extends FlxSubState
{
	
	public var yes_callback:Void -> Void = function() { };
	public var no_callback:Void -> Void = function() { };
	
	var yes_circle:CircleHighLight;
	var no_circle:CircleHighLight;
	
	var num_segments:Int = 12;
	
	public function new(_message:String, _extra_message:String, _bg_color:FlxColor = FlxColor.BLACK, _yes_string:String = "YES", _no_string:String = "NO") 
	{
		super(_bg_color);
		
		var _message_text = new ZBitmapText(0, FlxG.height * 0.4, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
		_message_text.scale.set(2, 2);
		_message_text.text = _message;
		add(_message_text);
		
		var _extra_message_text = new ZBitmapText(0, FlxG.height * 0.9, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER);
		_extra_message_text.text = _extra_message;
		add(_extra_message_text);
		
		var _yes_text = new ZBitmapText(FlxG.width * 0.7, FlxG.height * 0.645, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER, Std.int(FlxG.width * 0.1));
		_yes_text.text = _yes_string;
		add(_yes_text);
		
		var _no_text = new ZBitmapText(FlxG.width * 0.2, FlxG.height * 0.645, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.CENTER, Std.int(FlxG.width * 0.1));
		_no_text.text = _no_string;
		add(_no_text);
		
		no_circle = new CircleHighLight(FlxPoint.get(FlxG.width * 0.25, FlxG.height * 0.65), num_segments);
		yes_circle = new CircleHighLight(FlxPoint.get(FlxG.width * 0.75, FlxG.height * 0.65), num_segments);
		
		add(yes_circle);
		add(no_circle);
	}
	
	override public function update(elapsed:Float):Void 
	{
		PlayState.i.c.update(elapsed);
		if (PlayState.i.c._l_just_released && !PlayState.i.c._r) no_callback();
		if (PlayState.i.c._r_just_released && !PlayState.i.c._l) yes_callback();
		var _l_rad = PlayState.i.c._l ? 48 : 32.0;
		var _r_rad = PlayState.i.c._r ? 48 : 32.0;
		yes_circle.radius += (_r_rad - yes_circle.radius) * 0.1;
		no_circle.radius += (_l_rad - no_circle.radius) * 0.1;
		super.update(elapsed);
	}
	
}

class CircleHighLight extends FlxTypedGroup<CircleSegment>
{
	
	public var center:FlxPoint;
	public var radius:Float;
	
	public function new(_p:FlxPoint, _num_of_segments:Int = 12, _radius:Float = 16.0):Void
	{
		super();
		center = _p;
		radius = _radius;
		for (i in 0..._num_of_segments)
		{
			add(new CircleSegment(i * (360 / _num_of_segments)));
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		for (segment in members)
		{
			segment.center = center;
			segment.radius = radius;
		}
		super.update(elapsed);
	}
	
}

class CircleSegment extends FlxSprite
{
	public var center:FlxPoint;
	public var radius:Float;
	
	public function new(_angle:Float):Void
	{
		super();
		makeGraphic(2, 8);
		scrollFactor.set();
		angle = _angle;
	}
	
	override public function update(elapsed:Float):Void 
	{
		var _c = ZMath.placeOnCircle(center, angle, radius);
		setPosition(_c.x, _c.y);
		angle++;
		super.update(elapsed);
	}
	
}