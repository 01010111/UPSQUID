package util;

import flixel.system.FlxBasePreloader;
import flash.display.*;
import flash.text.*;
import flash.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import com.newgrounds.*;
import com.newgrounds.components.*;

@:bitmap("assets/images/title_color.png") class LogoImage extends BitmapData { }

/**
 * ...
 * @author 01010111
 */
class Preloader extends FlxBasePreloader
{
	var bmpBar:Bitmap;
	
	public function new(?AllowedURLs:Array<String>) 
	{
		var _min_display_time = Reg.newgrounds_build ? 8 : 2;
		super(_min_display_time, AllowedURLs);
	}

	override function create():Void 
	{
		this._width = Lib.current.stage.stageWidth;
		this._height = Lib.current.stage.stageHeight;
		
		var _logo_y:Float = _height * 0.4;
		if (Reg.newgrounds_build)
		{
			API.connect(root, "42602:BifDaKrx", "LFGMiLvHTkSBiqu4CV50R2DQp0fT2W9Z");
			if (API.isNewgrounds)
			{
				var ad:FlashAd = new FlashAd();
				ad.width *= 0.9;
				ad.height *= 0.9;
				ad.x = (_width / 2) - (ad.width/2);
				//ad.y = 4;
				ad.y = (_height / 2.5) - (ad.height / 2);
				addChild(ad);
				minDisplayTime = 8;	
			}
			
			_logo_y = 12;
		}
		var _logo = new Sprite();
		_logo.addChild(new Bitmap(new LogoImage(0, 0)));
		_logo.scaleX = _logo.scaleY = 2;
		_logo.x = _width * 0.5 - _logo.width * 0.5;
		_logo.y = _logo_y;
		addChild(_logo);
		
		bmpBar = new Bitmap(new BitmapData(1, 4, false, 0xffffff));
		bmpBar.x = 4;
		bmpBar.y = _height - 11;
		addChild(bmpBar);
		
		super.create();
	}

	override function update(Percent:Float):Void 
	{
		super.update(Percent);
		bmpBar.scaleX = Percent * (_width - 8);
	}
}