package states;

import backend.Paths;
import backend.Song;

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

    override function create()
    {
        super.create();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('TRUE menu'));
        add(bg);

        var START_Y:Float = 90;

        var i:Int = 1;
        for (option in options)
        {
            var text:FlxText = new FlxText(0, 0, 0, option, 16);
            text.antialiasing = false;
            text.setFormat('Sonic 1 Debug', 16, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.alignment = 'center';
            text.x = FlxG.width / 2;
            text.y =  START_Y + (text.height * i + 20);
            items.push(cast {text: text, desiredScale: 1});
            add(text);

            i++;
        }

        changeSelect(0);
    }

    override function update(dt:Float)
    {
        if (controls.BACK) MusicBeatState.switchState(new MainMenuState());

        if (controls.UI_UP_P) changeSelect(-1);
        if (controls.UI_DOWN_P) changeSelect(1);

        if (controls.ACCEPT) chooseOption();

        var lerp:Float = -dt * 9.3;
        for (item in items)
        {
            item.text.scale.x = FlxMath.lerp(item.text.scale.x, item.desiredScale, lerp);
            item.text.scale.y = FlxMath.lerp(item.text.scale.y, item.desiredScale, lerp);
        }
    }

    function chooseOption()
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
    }

    function loadSong(name:String)
    {
        PlayState.SONG = Song.loadFromJson(name, name);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = 1;

        MusicBeatState.switchState(new PlayState());
    }

    function changeSelect(amt:Int)
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
            curText.setFormat('Sonic 1 Debug', 16, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, selected ? FlxColor.WHITE : FlxColor.BLACK);

            items[i].desiredScale = selected ? 1.3 : 1;
        }
    }
}