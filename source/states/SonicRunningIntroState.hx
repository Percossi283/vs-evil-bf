package states;

class SonicRunningIntroState extends MusicBeatState
{
    var logo:FlxSprite;

    override function create()
	{
        #if DISCORD_ALLOWED
        DiscordClient.HOVER_TEXT = 'WELCOME BACK';
        DiscordClient.changePresence('Welcome Back.', null);
        #end
        
        super.create();

        logo = new FlxSprite().loadGraphic(Paths.image('lgo'));
        logo.scale.set(0.5, 0.5);
        logo.updateHitbox();
        logo.screenCenter();
        logo.alpha = 0;
        add(logo);

        FlxTimer.wait(0.8, ()->
        {
            FlxTween.tween(logo, {alpha: 1}, 1, {ease: FlxEase.expoOut, onComplete: (twn:FlxTween)->
            {
                FlxTimer.wait(1.3, ()->
                {
                    FlxTween.tween(logo, {alpha: 0}, 1, {ease: FlxEase.expoIn, onComplete: (twn:FlxTween)->
                    {
                        MusicBeatState.switchState(new TrueMenuState());
                    }});
                });
            }});
        });
    }

    override function update(dt:Float)
    {
        if (controls.ACCEPT)
        {
            FlxG.camera.alpha = 0;
            MusicBeatState.switchState(new TrueMenuState());
        }
    }
}