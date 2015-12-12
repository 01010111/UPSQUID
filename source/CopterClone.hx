package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import zerolib.util.ZMath;

class CopterClone extends FlxState
{
	public static var i:CopterClone;
	
	public var speed:Float;
	public var last_top:Float;
	public var last_bottom:Float;
	public var max_distance:Float;
	public var min_distance:Float;
	public var corridor_direction:Float = 0;
	public var segment_width:Int = 8;
	
	var max_speed:Float = 1200;
	var min_speed:Float = 600;
	var ground:FlxGroup;
	var hazard:FlxSprite;
	var ship:Ship;
	
	var begun:Bool = false;
	
	override public function create():Void 
	{
		i = this;
		FlxG.camera.pixelPerfectRender = true;
		
		corridor_direction = FlxMath.bound(corridor_direction + ZMath.randomRange( -0.2, 0.2), -1, 1);
		
		max_distance = FlxG.height * 0.9;
		min_distance = FlxG.height * 0.25;
		last_top = Std.int(FlxG.height * 0.25);
		last_bottom = Std.int(FlxG.height * 0.75);
		speed = 1000;
		
		hazard = new FlxSprite( -FlxG.width);
		hazard.makeGraphic(FlxG.width, FlxG.height, 0xffff0000);
		add(hazard);
		
		ground = new FlxGroup();
		add(ground);
		
		for (i in 0...Math.ceil(FlxG.width / segment_width) + 4)
		{
			ground.add(new GroundSegment(i * segment_width));
		}
		
		ship = new Ship();
		add(ship);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (begun)
		{
			corridor_direction = FlxMath.bound(corridor_direction + ZMath.randomRange( -0.1, 0.1), -0.3, 0.3);
			super.update(elapsed);
			
			if (FlxG.keys.pressed.C) 
			{
				speed += (max_speed - speed) * 0.1;
				hazard.velocity.x = -20;
			}
			else 
			{
				speed += (min_speed - speed) * 0.1;
				hazard.velocity.x = 15;
			}
			if (hazard.x < -FlxG.width - 16) hazard.x = -FlxG.width - 16;
			
			if (hazard.x + FlxG.width >= ship.getMidpoint().x || FlxG.overlap(ship, ground)) FlxG.resetState();
		}
		
		else if (FlxG.keys.justPressed.X) begun = true;
	}
	
	public function set_new_lasts(_top:Float, _bottom:Float):Void
	{
		last_top = _top;
		last_bottom = _bottom;
	}
}

class GroundSegment extends FlxGroup
{
	var top:FlxSprite;
	var bottom:FlxSprite;
	
	public function new (_x:Float):Void
	{
		super();
		top = new FlxSprite(_x, 0);
		top.makeGraphic(CopterClone.i.segment_width, FlxG.height);
		
		bottom = new FlxSprite(_x, 0);
		bottom.makeGraphic(CopterClone.i.segment_width, FlxG.height);
		
		add(top);
		add(bottom);
		
		init();
	}
	
	function init():Void
	{
		var _t = ZMath.randomRange( -1.5, 1.5) + CopterClone.i.corridor_direction;
		var _b = ZMath.randomRange( -1.5, 1.5) + CopterClone.i.corridor_direction;
		
		top.y = CopterClone.i.last_top + _t;
		bottom.y = CopterClone.i.last_bottom + _b;
		
		if (top.y < FlxG.height * 0.1) top.y += 2;
		if (bottom.y > FlxG.height * 0.9) bottom.y -= 2;
		
		if (bottom.y - top.y > CopterClone.i.max_distance) 
		{
			top.y++;
			bottom.y--;
		}
		
		if (bottom.y - top.y < CopterClone.i.min_distance)
		{
			top.y--;
			bottom.y++;
		}
		
		CopterClone.i.set_new_lasts(top.y, bottom.y);
		
		top.y -= FlxG.height;
	}
	
	override public function update(elapsed:Float):Void 
	{
		top.velocity.x = -CopterClone.i.speed;
		bottom.velocity.x = -CopterClone.i.speed;
		super.update(elapsed);
		if (top.x <= -top.width) 
		{
			top.x += FlxG.width + top.width;
			bottom.x += FlxG.width + top.width;
			init();
		}
	}
}

class Ship extends FlxSprite
{
	var vert_thrust:Float = 400;
	
	public function new()
	{
		super(FlxG.width * 0.3, FlxG.height * 0.5);
		makeGraphic(16, 8, 0x00ffffff);
		FlxSpriteUtil.drawPolygon(this, [FlxPoint.get(0, 0), FlxPoint.get(width, height * 0.5), FlxPoint.get(0, height)]);
		maxVelocity.y = 150;
		setSize(2, 2);
		offset.set(6, 2);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.keys.pressed.X) 
		{
			if (velocity.y > 0) velocity.y *= 0.75;
			acceleration.y = -vert_thrust;
		}
		else
		{
			if (velocity.y < 0) velocity.y *= 0.75;
			acceleration.y = vert_thrust;
		}
		super.update(elapsed);
		
		angle = velocity.y * 0.1;
	}
}