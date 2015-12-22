package util;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import openfl.system.System;
import openfl.display.BitmapData;
import openfl.filters.ColorMatrixFilter;
import flixel.FlxG;
import openfl.geom.Point;

/**
 * Adds a few things - use a color palette with this.colors and this.b (brightness), set this.esc_exits to true and you can exit with the escape button.
 * Thanks to _rxi for help with 4 color palette stuff!
 * @author 01010111
 */
class ZState extends FlxState
{
	var colors:Array<Int>;
	var esc_exits:Bool = false;
	
	public function new() 
	{
		FlxG.mouse.visible = false;
		super();
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (esc_exits && FlxG.keys.justPressed.ESCAPE) System.exit(0);
		checkCollisions();
		super.update(elapsed);
	}
	
	function checkCollisions():Void
	{
		
	}
	
	override public function draw():Void
	{
		super.draw();
		//#if !debug
		if (colors != null) paletteMap();
		//#end
	}
	
	var colorPalette:Array<Array<Int>>;
	
	public function initColorPalette():Void
	{
		colorPalette = new Array();
		for (i in 0...4) colorPalette.push(new Array<Int>());
		for (i in 0...256) 
		{
			var c = colors[Math.floor(i / (256 / colors.length))];
			colorPalette[0].push(c & 0xFF0000);
			colorPalette[1].push(c & 0x00FF00);
			colorPalette[2].push(c & 0x0000FF);
		}
	}
	
	var b:Float = 0.3;
	
	function paletteMap():Void
	{
		#if web
		var pnt = new Point();
		var matrix = 
		[
			b, b, b, 0, 0,
			b, b, b, 0, 0,
			b, b, b, 0, 0,
			0, 0, 0, 1, 0
		];
		var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		FlxG.camera.buffer.applyFilter(FlxG.camera.buffer, FlxG.camera.buffer.rect, pnt, filter);
		if (colorPalette == null) initColorPalette();
		FlxG.camera.buffer.paletteMap(FlxG.camera.buffer, FlxG.camera.buffer.rect, pnt, colorPalette[0], colorPalette[1], colorPalette[2]);
		#end
	}
	
	function paletteMapFade(FROM:Float, TO:Float, TIME:Float):Void
	{
		b = FROM;
		FlxTween.tween(this, { b:TO }, TIME);
	}
	
	public function flash(FROM:Float = 1, TIME:Float = 0.25):Void
	{
		paletteMapFade(FROM, 0.3, TIME);
	}
	
	public function fade(TO:Float = 0, TIME:Float = 1):Void
	{
		paletteMapFade(0.3, TO, TIME);
	}
	
}