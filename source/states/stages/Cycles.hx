package states.stages;

import states.stages.objects.*;

import openfl.Lib;
import lime.graphics.Image;

class Cycles extends BaseStage
{
	var sky:FlxSprite;

	override function create()
	{
		var icon:Image = Image.fromFile(Paths.modsImages('blank'));
		Lib.application.window.setIcon(icon);

		Lib.application.window.title = 'WELCOME BACK';

		sky = new FlxSprite().loadGraphic(Paths.image('cycles/wlecomebackground'));
		sky.scrollFactor.set(0.9, 0.9);
		add(sky);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.gf.visible = false;
	}

	override function update(elapsed:Float)
	{
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
			case "My Event":
		}
	}
}