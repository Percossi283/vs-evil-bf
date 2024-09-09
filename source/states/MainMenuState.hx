package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.Song;
import backend.WeekData;

import openfl.Lib;
import lime.graphics.Image;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var usableOptions:Array<String> = [
		'story_mode',
		'options'
	];

	var magenta:FlxSprite;
	var bg:FlxSprite;
	var camFollow:FlxObject;

	var screen:FlxSprite;

	var myLittleFinger:FlxSprite;

	var evilVer:FlxText;
	var fnfVer:FlxText;

	var isEvil:Bool = false;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image(getMenuSprite('menuBG')));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image(getMenuSprite('menuDesat')));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);

		screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		screen.scrollFactor.set();
		screen.alpha = 0;
		add(screen);

		myLittleFinger = new FlxSprite();
		myLittleFinger.frames = Paths.getSparrowAtlas('finger');
		myLittleFinger.animation.addByPrefix('twiddlefinger', 'my finger', 24, true);		
		myLittleFinger.animation.play('twiddlefinger');
		myLittleFinger.alpha = 0;
		myLittleFinger.scrollFactor.set();
		myLittleFinger.screenCenter();
		add(myLittleFinger);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
		}

		evilVer = new FlxText(12, FlxG.height - 44, 0, "Vs EVIL BF v0.0.1", 12);
		evilVer.scrollFactor.set();
		evilVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(evilVer);
		fnfVer = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (controls.BACK)
		{	
			if (isEvil)
			{
				FlxG.sound.playMusic(Paths.music('cryingTheme'));
				FlxG.sound.music.pitch = 1;

				TitleState.isEvil = true;
			}
			else
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}

			MusicBeatState.switchState(new TitleState());
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.ACCEPT)
			{
				if (!usableOptions.contains(optionShit[curSelected]))
					return;

				var isStory:Bool = optionShit[curSelected] == 'story_mode';
				selectedSomethin = true;

				if (ClientPrefs.data.flashing && !isStory)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				if (!isStory)
					pressButton();
				else
					evilBoyfriendMode();

				for (i in 0...menuItems.members.length)
				{
					if (i == curSelected && !isStory)
						continue;

					FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							menuItems.members[i].kill();
						}
					});
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function pressButton()
	{
		FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
		{
			MusicBeatState.switchState(new OptionsState());
			OptionsState.onPlayState = false;
			if (PlayState.SONG != null)
			{
				PlayState.SONG.arrowSkin = null;
				PlayState.SONG.splashSkin = null;
				PlayState.stageUI = 'normal';
			}
		});

		FlxG.sound.play(Paths.sound('confirmMenu'));
	}

	function evilBoyfriendMode()
	{
		// evil boyfriend mode

		FlxTimer.wait(0.4, ()->
		{
			var icon:Image = Image.fromFile(Paths.modsImages('blank'));
			Lib.application.window.setIcon(icon);
		});


		FlxTimer.wait(0.9, ()->
		{
			FlxTween.tween(fnfVer, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
			FlxTween.tween(evilVer, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
		});

		FlxTimer.wait(1.3, ()->
		{
			Lib.application.window.title = '';
		});

		FlxTween.tween(FlxG.sound.music, {pitch: 0}, 9, {ease: FlxEase.expoIn});

		FlxTimer.wait(2.6, ()->
		{
			Main.fpsVar.visible = false;

			FlxTween.tween(screen, {alpha: 1}, 3.2, {onComplete: (twn:FlxTween)->
			{
				FlxTimer.wait(0.9, ()->
				{
					myLittleFinger.scale.set(0.8, 0.8);

					myLittleFinger.angle = 10;
					FlxTween.tween(myLittleFinger, {alpha: 1, angle: 0}, 2, {ease: FlxEase.expoOut});
					FlxTween.tween(myLittleFinger.scale, {x: 1, y: 1}, 2, {ease: FlxEase.expoOut});

					FlxTimer.wait(2.7, ()->
					{
						FlxTween.tween(myLittleFinger, {alpha: 0, y: myLittleFinger.y + 20}, 1.6, {ease: FlxEase.expoIn});
						FlxTween.tween(myLittleFinger.scale, {x: 0.7, y: 0.7}, 1.6, {ease: FlxEase.expoIn, onComplete: (twn:FlxTween)->
						{
							PlayState.SONG = Song.loadFromJson('cycles', 'cycles');
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = 1;

							MusicBeatState.switchState(new PlayState());
						}});
					});

					isEvil = true;

					#if DISCORD_ALLOWED
					DiscordClient.HOVER_TEXT = 'WELCOME BACK';
					DiscordClient.changePresence('Welcome Back.', null);
					#end
				});
			}});
		});
	}

	public static function getMenuSprite(name:String):String
	{
		var freaky:Bool = FlxG.random.bool(0.000001);

		return TitleState.isEvil ? (freaky ? 'FREAKY menu' : 'EVIL menu') : name;
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}
