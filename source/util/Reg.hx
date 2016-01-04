package util;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.effects.postprocess.PostProcess;
import states.PlayState;

/**
 * ...
 * @author 01010111
 */
class Reg
{
	
	public static var newgrounds_build:Bool = false;
	
	public static var cam_offs:Int = 64;
	
	public static var hi_combo:Int = 0;
	public static var hi_depth:Int = 0;
	public static var cur_color:Int = 0;
	public static var snd_vol:Float = 1;
	public static var mus_vol:Float = 0.6;
	public static var played_b4:Bool = false;
	public static var diff:String = "NORMAL";
	public static var shake:String = "NORMAL";
	public static var turn_speed:Int = 1;
	
	public static var loaded:Bool = false;
	public static var _save:FlxSave;
	
	public static var shader:PostProcess;
	
	public static function init():Void
	{
		if (!loaded)
		{
			_save = new FlxSave();
			_save.bind("SQUID_DATA");
			if (_save.data.hi_combo != null) load();
			loaded = true;
			#if !flash
			shader = new PostProcess("assets/data/SquidShader.frag");
			FlxG.addPostProcess(shader);
			#end
		}
	}
	
	public static function load():Void
	{
		hi_combo = 		_save.data.hi_combo;
		hi_depth = 		_save.data.hi_depth;
		cur_color =		_save.data.cur_color;
		snd_vol = 		_save.data.snd_vol;
		mus_vol = 		_save.data.mus_vol;
		played_b4 = 	_save.data.played_b4;
		diff =			_save.data.diff;
		shake = 		_save.data.shake;
		turn_speed =	_save.data.turn_speed;
	}
	
	public static function save():Void
	{
		_save.data.hi_combo =		hi_combo;
		_save.data.hi_depth =		hi_depth;
		_save.data.cur_color =		cur_color;
		_save.data.snd_vol =		snd_vol;
		_save.data.mus_vol =		mus_vol;
		_save.data.played_b4 =		played_b4;
		_save.data.diff =			diff;
		_save.data.shake =			shake;
		_save.data.turn_speed =		turn_speed;
		
		_save.flush();
	}
	
	public static var alt_colors:Array<Array<Int>> = [
		[0xff000000, 0xffff0000, 0xffffffff],
		[0xff0b0830, 0xffd93963, 0xfffcffe2],
		[0xff000000, 0xff7c0fd8, 0xffd5ffbc],
		[0xff051834, 0xff22b764, 0xfffff5b8],
		[0xff111f34, 0xffdc6b76, 0xfff7efc2],
		[0xffeaf3b4, 0xff00b3b0, 0xffc40059],
		[0xff343d28, 0xff8a9973, 0xffdce2d3]/*,
		0xff*/
	];
	
	public static var color_scheme_names:Array<String> = [
		"UPSQUID",
		"SQUIDSHIFT",
		"NAUTILUS",
		"ALGAEIC",
		"RETROSQUID",
		"NEGASQUID",
		"GAMESQUID"
	];
	
	public static function shader_update():Void
	{
		#if !flash
		var _c1 = toRGB(alt_colors[cur_color][0]);
		var _c2 = toRGB(alt_colors[cur_color][1]);
		var _c3 = toRGB(alt_colors[cur_color][2]);
		shader.setUniform("c_1_r", _c1.r);
		shader.setUniform("c_1_g", _c1.g);
		shader.setUniform("c_1_b", _c1.b);
		shader.setUniform("c_2_r", _c2.r);
		shader.setUniform("c_2_g", _c2.g);
		shader.setUniform("c_2_b", _c2.b);
		shader.setUniform("c_3_r", _c3.r);
		shader.setUniform("c_3_g", _c3.g);
		shader.setUniform("c_3_b", _c3.b);
		#else
		
		#end
	}
	
	public static inline function toRGB(int:Int):RGB
    {
        return {
            r: ((int >> 16) & 255) / 255,
            g: ((int >> 8) & 255) / 255,
            b: (int & 255) / 255,
        }
    }
	
}

typedef RGB = {
	var r:Float;
	var g:Float;
	var b:Float;
}
