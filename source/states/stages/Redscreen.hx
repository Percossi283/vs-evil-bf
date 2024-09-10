package states.stages;

import states.stages.objects.*;

class Redscreen extends BaseStage
{
	var bg:FlxSprite;

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('redscreen'));
		bg.scrollFactor.set();
		add(bg);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.gf.visible = false;
		game.dad.visible = false;

		game.camMovementMult = 0;

		camHUD.zoom = 0.75;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Fade BG':
				FlxTween.tween(bg, {alpha: 0}, 1.2, {ease: FlxEase.quadOut});
		}
	}
}