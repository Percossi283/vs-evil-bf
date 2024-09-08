package states.stages;

import states.stages.objects.*;

import openfl.Lib;

class Cycles extends BaseStage
{
	var sky:FlxSprite;

	var tails:FlxSprite;
	var knux:FlxSprite;

	override function create()
	{
		Lib.application.window.title = 'WELCOME BACK';

		sky = new FlxSprite().loadGraphic(Paths.image('cycles/wlecomebackground'));
		sky.scrollFactor.set(0.9, 0.9);
		add(sky);

		tails = new FlxSprite();
		tails.frames = Paths.getSparrowAtlas('cycles/tails_tweaker');
		tails.animation.addByPrefix('idle', 'tails tweaker', 24, true);
		tails.animation.play('idle');
		tails.alpha = 0;
		add(tails);

		knux = new FlxSprite();
		knux.frames = Paths.getSparrowAtlas('cycles/knuckles_tweaker');
		knux.animation.addByPrefix('idle', 'knuckles tweaker', 24, true);
		knux.animation.play('idle');
		knux.alpha = 0;
		add(knux);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.gf.visible = false;

		game.forceDadCamera = true;

		game.camMovementMult = 1.3;

		game.hideOpponentArrows = true;
	}

	override function update(elapsed:Float)
	{
		game.boyfriend.x = game.dad.x;
		game.boyfriend.y = game.dad.y;

		game.boyfriend.cameraPosition = game.dad.cameraPosition;
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		// Code here
	}
	override function sectionHit()
	{
		// Code here
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Add Souls':
				FlxTween.tween(tails, {alpha: 1}, 1);
				FlxTween.tween(knux, {alpha: 1}, 1);
		}
	}
}