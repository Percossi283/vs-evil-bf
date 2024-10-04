package states;

import backend.Paths;
import backend.Song;

import flixel.math.FlxMath;

import flixel.FlxG;
import flixel.text.FlxText;

import states.MainMenuState;
import options.OptionsState;

typedef MenuOption =
{
    var text:FlxText;
    var desiredScale:Float;
}

class TrueMenuState extends MusicBeatState
{
    var options:Array<String> = [
        'Try Again?',
        'Mania Mode',
        'Options',
        'Credits'
    ];

    var items:Array<MenuOption> = [];

    var curSelected:Int = 0;

    var FONT_SIZE:Int = 40;

    var bg:FlxSprite;

    override function create()
    {
        #if DISCORD_ALLOWED
        DiscordClient.HOVER_TEXT = 'WELCOME BACK';
        DiscordClient.changePresence('Welcome Back.', null);
        #end

        super.create();

        TitleState.isEvil = true;

        bg = new FlxSprite().loadGraphic(Paths.image('TRUE menu'));
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.expoOut, startDelay: 1});
        add(bg);

        var START_Y:Float = 90;

        var i:Int = 1;
        for (option in options)
        {
            var text:FlxText = new FlxText(0, 0, 0, option);
            text.antialiasing = false;
            text.setFormat(Paths.font('true.ttf'), FONT_SIZE, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.alignment = 'center';
            text.x = FlxG.width / 2 - text.width / 2;
            text.y =  START_Y + (text.height * i + 40);
            text.y += 62 * (i - 1);
            items.push(cast {text: text, desiredScale: 1});
            add(text);

            text.alpha = 0;
            text.scale.set(1.4, 0.8);
            FlxTween.tween(text, {alpha: 1}, 1, {ease: FlxEase.expoOut, startDelay: 0.05 * i});
            FlxTween.tween(text.scale, {x: 1, y: 1}, 1, {ease: FlxEase.backOut, startDelay: 0.05 * i});

            i++;
        }

        canInteract = false;
        FlxTimer.wait(1.15, ()->
        {
            canInteract = true;
            changeSelect(0, false);
        });

        FlxG.sound.playMusic(Paths.music('cryingTheme'));

	#if mobile
	addVirtualPad(UP_DOWN, A_B);
	#end
    }

    var canInteract:Bool = true;
    override function update(dt:Float)
    {
        if (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end && canInteract) MusicBeatState.switchState(new TitleState());

        if (controls.UI_UP_P #if mobile || _virtualpad.buttonUp.justPressed #end && canInteract) changeSelect(-1);
        if (controls.UI_DOWN_P#if mobile || _virtualpad.buttonDown.justPressed #end && canInteract) changeSelect(1);

        if (controls.ACCEPT #if mobile || _virtualpad.buttonA.justPressed #end && canInteract) chooseOption();

        for (item in items)
        {
            var scaleLerp:Float = FlxMath.lerp(item.desiredScale, item.text.scale.x, Math.exp(-dt * 9.5));
			item.text.scale.set(scaleLerp, scaleLerp);
        }
	super.update(elapsed);
    }

    function chooseOption()
    {
        canInteract = false;

        FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoOut});

        var i:Int = -1;
        for (item in items)
        {
            i++;

            if (curSelected == i)
                continue;

            FlxTween.tween(item.text, {alpha: 0}, 0.6, {ease: FlxEase.quadOut, startDelay: i * 0.05});
            FlxTween.tween(item.text.scale, {x: 1.4, y: 0.8}, 0.6, {ease: FlxEase.backIn, startDelay: i * 0.05});
        }

        switch(options[curSelected])
        {
            case 'Try Again?':
                FlxG.sound.play(Paths.sound('tryAgain'), 0.7);

            case 'Mania Mode':
                FlxG.sound.play(Paths.sound('redscreen'), 1);
        }

        FlxTimer.wait(1, ()->
        {
            switch(options[curSelected])
            {
                case 'Try Again?':
                    loadSong('cycles');

                case 'Mania Mode':
                    loadSong('redscreen');

                case 'Options':
                    MusicBeatState.switchState(new OptionsState());
                    OptionsState.onPlayState = false;
                    if (PlayState.SONG != null)
                    {
                        PlayState.SONG.arrowSkin = null;
                        PlayState.SONG.splashSkin = null;
                        PlayState.stageUI = 'normal';
                    }

                case 'Credits':
                    MusicBeatState.switchState(new CreditsState());
            }

            FlxTween.tween(items[curSelected].text.scale, {x: 0.8, y: 0.8}, 1, {ease: FlxEase.expoOut});
        });
    }

    function loadSong(name:String)
    {
        PlayState.SONG = Song.loadFromJson(name, name);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = 1;

        MusicBeatState.switchState(new PlayState());
    }

    function changeSelect(amt:Int, sound:Bool = true)
    {
        curSelected += amt;

        if (curSelected < 0)
            curSelected = items.length - 1;

        if (curSelected == items.length)
            curSelected = 0;

        for (i in 0...items.length)
        {
            var curText = items[i].text;

            var selected:Bool = i == curSelected;
            curText.setBorderStyle(FlxTextBorderStyle.OUTLINE, selected ? FlxColor.WHITE : FlxColor.BLACK, 4, 8);

            items[i].desiredScale = selected ? 1.3 : 1;
        }

        if (sound)
            FlxG.sound.play(Paths.sound('trueSelect'), 0.7);
    }
}
