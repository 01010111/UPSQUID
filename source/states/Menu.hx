package states;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.system.System;
import states.Menu.MenuItem;
import util.Reg;
import util.Sounds;
import zerolib.util.ZBitmapText;

/**
 * ...
 * @author 01010111
 */
class Menu extends FlxSubState
{

	public static var i:Menu;
	
	var items:FlxTypedGroup<MenuItem>;
	var cur_item:Int = 0;
	var return_text:ZBitmapText;
	
	public function new() 
	{
		i = this;
		
		super(0xff000000);
		
		return_text = new ZBitmapText(0, FlxG.height * 0.5, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.RIGHT, Std.int(FlxG.width * 0.4));
		return_text.text = "RETURN";
		add(return_text);
		
		items = new FlxTypedGroup();
		
		if (!PlayState.i.squid.begun)
		{
			var difficulty:MenuItem = new MenuItem("DIFFICULTY");
			difficulty.add_choice("EASY");
			difficulty.add_choice("NORMAL");
			difficulty.add_choice("TOUGH");
			if 		(Reg.diff == "EASY") 	difficulty.cur_choice = 0;
			else if (Reg.diff == "NORMAL") 	difficulty.cur_choice = 1;
			else if (Reg.diff == "TOUGH") 	difficulty.cur_choice = 2;
			difficulty.choice_callback = function():Void
			{
				switch(difficulty.cur_choice)
				{
					case 0: Reg.diff = "EASY";
					case 1: Reg.diff = "NORMAL";
					case 2: Reg.diff = "TOUGH";
				}
				
				PlayState.i.last_depth_indicator.set_position();
			}
			items.add(difficulty);
		}
		else 
		{
			var restart:MenuItem = new MenuItem("RESTART");
			restart.add_choice("ARE YOU SURE?");
			restart.add_choice("YES");
			restart.choice_callback = function():Void
			{
				new FlxTimer().start(0.25).onComplete = function(t:FlxTimer):Void { FlxG.resetState(); }
			}
			items.add(restart);
		}
		
		var color_scheme:MenuItem = new MenuItem("COLORS");
		for (i in 0...Reg.alt_colors.length) color_scheme.add_choice(Reg.color_scheme_names[i]);
		color_scheme.cur_choice = Reg.cur_color;
		color_scheme.choice_callback = function():Void { PlayState.i.change_colors(color_scheme.cur_choice); }
		items.add(color_scheme);
		
		var audio_vol:MenuItem = new MenuItem("SOUND VOL.");
		for (i in 0...11) audio_vol.add_choice("" + i);
		audio_vol.cur_choice = Std.int(Reg.snd_vol * 10);
		audio_vol.choice_callback = function():Void { Reg.snd_vol = audio_vol.cur_choice / 10; }
		items.add(audio_vol);
		
		var music_vol:MenuItem = new MenuItem("MUSIC VOL.");
		for (i in 0...11) music_vol.add_choice("" + i);
		music_vol.cur_choice = Std.int(Reg.mus_vol * 10);
		music_vol.choice_callback = function():Void 
		{
			Reg.mus_vol = music_vol.cur_choice / 10; 
			FlxG.sound.music.volume = Reg.mus_vol * 0.5;
		}
		items.add(music_vol);
		
		var screen_shake:MenuItem = new MenuItem("SCREENSHAKE");
		screen_shake.add_choice(" NONE");
		screen_shake.add_choice(" NORMAL");
		screen_shake.add_choice(" VLAMBEER");
		if 		(Reg.shake == "NONE")		screen_shake.cur_choice = 0;
		else if (Reg.shake == "NORMAL")		screen_shake.cur_choice = 1;
		else if (Reg.shake == "VLAMBEER")	screen_shake.cur_choice = 2;
		screen_shake.choice_callback = function():Void
		{
			switch(screen_shake.cur_choice)
			{
				case 0: Reg.shake = "NONE";
				case 1: Reg.shake = "NORMAL";
				case 2: Reg.shake = "VLAMBEER";
			}
		}
		items.add(screen_shake);
		
		var turn_speed:MenuItem = new MenuItem("TURN SPEED");
		turn_speed.add_choice("SLOW");
		turn_speed.add_choice("NORMAL");
		turn_speed.add_choice("QUICK");
		turn_speed.cur_choice = Reg.turn_speed;
		turn_speed.choice_callback = function():Void
		{
			Reg.turn_speed = turn_speed.cur_choice;
		}
		items.add(turn_speed);
		
		var tutorial:MenuItem = new MenuItem("WATCH TUTORIAL");
		tutorial.add_choice("     ARE YOU SURE?");
		tutorial.add_choice("     YES");
		tutorial.choice_callback = function():Void
		{
			new FlxTimer().start(0.25).onComplete = function(t:FlxTimer):Void
			{
				close();
				PlayState.i.openSubState(new Tutorial());
			}
		}
		items.add(tutorial);
		
		#if !flash
		var exit:MenuItem = new MenuItem("EXIT");
		exit.add_choice("ARE YOU SURE?");
		exit.add_choice("YES");
		exit.choice_callback = function():Void
		{
			new FlxTimer().start(0.25).onComplete = function(t:FlxTimer):Void { System.exit(0); }
		}
		items.add(exit);
		#end
		
		add(items);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		PlayState.i.c.update(elapsed);
		
		for (i in 0...items.members.length)
		{
			items.members[i].color = items.members[cur_item].selected ? 0xff000000 : 0xff808080;
			if (i == cur_item) items.members[i].color = items.members[i].selected ? 0xff808080 : 0xffffffff;
			items.members[i].alpha = items.members[i].color == 0xff000000 ? 0 : 1;
			items.members[i].x += items.members[cur_item].selected ? (FlxG.width * 0.25 - items.members[i].x) * 0.26 : (FlxG.width * 0.5 - items.members[i].x) * 0.26;
			items.members[i].y += ((FlxG.height * 0.5 + i * 10 - cur_item * 10) - items.members[i].y) * 0.26;
		}
		
		var was_selected = items.members[cur_item].selected;
		
		if (PlayState.i.c._l_just_released) items.members[cur_item].selected  = false;
		if (PlayState.i.c._r_just_pressed) items.members[cur_item].selected  = true;
		
		if (items.members[cur_item].selected != was_selected)
		{
			//TODO: MENU SOUNDS
			Sounds.play("bloop1", 0.3);
		}
		
		if (!items.members[cur_item].selected)
		{
			return_text.color = 0xff808080;
			return_text.x += (0 - return_text.x) * 0.26;
			if (PlayState.i.c._d_just_pressed) choice_select(1);
			if (PlayState.i.c._u_just_pressed) choice_select( -1);
			if (PlayState.i.c._l_just_pressed) exit_menu();
		}
		else 
		{
			return_text.color = 0xff000000;
			return_text.x += (FlxG.width * -0.25 - return_text.x) * 0.26;
		}
	}
	
	function exit_menu():Void
	{
		Reg.save();
		close();
	}
	
	function choice_select(_dir:Int):Void
	{
		var new_choice = false;
		if (_dir > 0)
		{
			if (cur_item < items.members.length - 1) 
			{
				new_choice = true;
				cur_item++;
			}
		}
		else
		{
			if (cur_item > 0) 
			{
				new_choice = true;
				cur_item--;
			}
		}
		if (new_choice) 
		{
			//TODO: Menu Sounds
			Sounds.play("bloop4", 0.3);
		}
	}
	
}

class MenuItem extends ZBitmapText
{
	public var choices_text:Array<String>;
	public var cur_choice:Int;
	public var choice_callback:Void -> Void = function() { };
	public var selected:Bool = false;
	
	public var choices:FlxTypedGroup<ZBitmapText>;
	
	public function new(_item_name:String):Void
	{
		super(FlxG.width * 0.5, FlxG.height * 0.5, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.LEFT);
		text = _item_name;
		choices = new FlxTypedGroup();
		choices_text = new Array();
	}
	
	public function add_choice(_choice:String):Void
	{
		var _c = new ZBitmapText(0, 0, PlayState.i.large_alphabet, FlxPoint.get(7, 9), "assets/images/large_font.png", FlxTextAlign.LEFT);
		_c.text = _choice;
		choices.add(_c);
		choices_text.push(_choice);
		Menu.i.add(_c);
	}
	
	public function choice_select(_dir:Int):Void
	{
		var new_choice = false;
		if (_dir > 0)
		{
			if (cur_choice < choices.members.length - 1) 
			{
				new_choice = true;
				cur_choice++;
			}
		}
		else
		{
			if (cur_choice > 0) 
			{
				new_choice = true;
				cur_choice--;
			}
		}
		if (new_choice) 
		{
			choice_callback();
			//TODO: MENU SOUNDS
			Sounds.play("bloop5", 0.3);
		}
	}
	
	override public function update(e:Float):Void 
	{
		for (i in 0...choices.members.length)
		{
			choices.members[i].color = selected ? 0xff808080 : 0xff000000;
			if (selected && i == cur_choice) choices.members[i].color = 0xffffffff;
			
			choices.members[i].alpha = choices.members[i].color == 0xff000000 ? 0 : 1;
			
			choices.members[i].x += selected ? (FlxG.width * 0.5 - choices.members[i].x) * 0.26 : (FlxG.width * 0.75 - choices.members[i].x) * 0.26;
			choices.members[i].y += ((FlxG.height * 0.5 + i * 10 - cur_choice * 10) - choices.members[i].y) * 0.26;
		}
		super.update(e);
		
		if (selected)
		{
			if (PlayState.i.c._d_just_pressed) choice_select(1);
			if (PlayState.i.c._u_just_pressed) choice_select(-1);
		}
	}
	
}