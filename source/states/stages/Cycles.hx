package states.stages;

import states.stages.objects.*;

import openfl.Lib;
import objects.HealthIcon;
import flixel.effects.FlxFlicker;

class Cycles extends BaseStage
{
	var sky:FlxSprite;
	var god:FlxSprite;

	var tails:FlxSprite;
	var knux:FlxSprite;

	var ii:FlxSprite;

	var icon:HealthIcon;

	var rise:FlxSprite;

	override function create()
	{
		//Lib.application.window.title = 'WELCOME BACK';

		sky = new FlxSprite().loadGraphic(Paths.image('cycles/wlecomebackground'));
		sky.scrollFactor.set(0.9, 0.9);
		sky.alpha = 0;
		add(sky);

		god = new FlxSprite(0, 20);
		god.frames = Paths.getSparrowAtlas('cycles/welcome_bg');
		god.animation.addByPrefix('idle', 'welcome bg', 24, true);
		god.animation.play('idle');
		god.scale.set(0.9, 0.9);
		god.scrollFactor.set(0.9, 0.9);
		god.alpha = 0;
		add(god);

		tails = new FlxSprite(360, 10);
		tails.frames = Paths.getSparrowAtlas('cycles/tails_tweaker');
		tails.animation.addByPrefix('idle', 'tails tweaker', 24, true);
		tails.animation.play('idle');
		tails.alpha = 0;
		tails.scale.set(0.7, 0.7);
		add(tails);

		knux = new FlxSprite(-120, 50);
		knux.frames = Paths.getSparrowAtlas('cycles/knuckles_tweaker');
		knux.animation.addByPrefix('idle', 'knuckles tweaker', 24, true);
		knux.animation.play('idle');
		knux.alpha = 0;
		knux.scale.set(0.7, 0.7);
		add(knux);

		icon = new HealthIcon('x');
		icon.cameras = [game.camOther];
		icon.x += 10;
		icon.y = FlxG.height - 150;
		icon.alpha = 0;
		add(icon);

		rise = new FlxSprite();
		rise.frames = Paths.getSparrowAtlas('my_finger');
		rise.animation.addByPrefix('twiddlefinger', 'my finger', 24, false);		
		rise.alpha = 0;
		rise.scrollFactor.set();
		rise.scale.set(0.6, 0.6);
		rise.screenCenter();
		add(rise);
	}
	
	override function createPost()
	{
		game.boyfriend.visible = false;
		game.gf.visible = false;

		game.dad.alpha = 0;

		game.forceDadCamera = true;

		game.camMovementMult = 1.3;

		game.hideOpponentArrows = true;

		ii = new FlxSprite(450, 590).loadGraphic(Paths.image('cycles/illegal'));
		ii.antialiasing = false;
		ii.alpha = 0;
		ii.origin.set();
		ii.updateHitbox();
		add(ii);
	}

	override function countdownTick(countdown, num)
	{
		if (num != 3)
			return;

		rise.alpha = 1;
		rise.animation.play('twiddlefinger');
	}

	override function update(elapsed:Float)
	{
		game.boyfriend.x = game.dad.x;
		game.boyfriend.y = game.dad.y;

		game.boyfriend.cameraPosition = game.dad.cameraPosition;

		rise.setPosition(game.dad.x - 1175, game.dad.y - 450);

		var lerp:Float = Math.exp(-elapsed * 9.8 * game.playbackRate);
		icon.scale.x = FlxMath.lerp(0.45, icon.scale.x, lerp);
		icon.scale.y = FlxMath.lerp(0.45, icon.scale.y, lerp);
		icon.updateHitbox();

		icon.animation.curAnim.curFrame = (game.health < 0.3) ? 1 : 0;
	}

	override function stepHit()
	{
		// Code here
	}

	override function beatHit()
	{
		icon.scale.set(0.6, 0.6);
	}

	override function sectionHit()
	{
		// Code here
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Add Tails':
				FlxTween.tween(tails, {alpha: 1, y: tails.y - 50}, 1, {ease: FlxEase.expoOut});

			case 'Add Knux':
				FlxTween.tween(knux, {alpha: 1, y: knux.y - 50}, 1, {ease: FlxEase.expoOut});

			case 'Add Icon':
				FlxTween.tween(icon, {alpha: 1}, 0.9, {ease: FlxEase.quadOut});

			case 'Add Instruction':
				ii.alpha = 1;
				FlxFlicker.flicker(ii, 0.3, 0.1);

			case 'Fade BG':
				FlxTween.tween(sky, {alpha: 1}, 1.2, {ease: FlxEase.quadOut});

			case 'Remove Rise':
				remove(rise);
				rise.destroy();

				game.dad.alpha = 1;

			// 800 250

			case 'Phase 2':
				FlxTween.tween(sky, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});

				FlxTween.tween(tails, {alpha: 0}, 0.6, {ease: FlxEase.expoOut});
				FlxTween.tween(tails.scale, {x: 0.6, y: 0.6}, 0.6, {ease: FlxEase.backIn});

				FlxTween.tween(knux, {alpha: 0}, 0.6, {ease: FlxEase.expoOut});
				FlxTween.tween(knux.scale, {x: 0.6, y: 0.6}, 0.6, {ease: FlxEase.backIn});

				FlxTween.tween(game.dad, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				FlxTween.tween(game.dad.scale, {x: 0.8, y: 0.8}, 0.8, {ease: FlxEase.expoIn});

				FlxFlicker.flicker(ii, 0.4, 0.1, false);

			case 'I AM GOD':
				FlxTween.cancelTweensOf(game.dad);

				game.dad.alpha = 1;
				game.dad.scale.set(1, 1);

				game.triggerEvent('Change Character', 'dad', 'god');

				game.dad.playAnim('appear');
				game.dad.specialAnim = true;

				FlxTween.tween(god, {alpha: 1}, 0.8, {ease: FlxEase.quadOut});

				if (game.health > 1)
					game.health = 1;

			case 'End':
				FlxG.camera.visible = false;
				camHUD.alpha = 0;
				camOther.alpha = 0;
		}
	}
}
