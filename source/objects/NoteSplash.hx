package objects;

import backend.animation.PsychAnimationController;

import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;

class NoteSplash extends FlxSprite
{
	public static var SPLASH_SKIN(default, never):String = 'notesplash';

	public function new(x:Float = 0, y:Float = 0) 
	{
		super(x, y);

		animation = new PsychAnimationController(this);
		scrollFactor.set();
	}

	public function setupNoteSplash(x:Float, y:Float, direction:Int = 0, ?note:Note = null) 
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		aliveTime = 0;

		alpha = ClientPrefs.data.splashAlpha;

		loadAnims();
		animation.play('splash', true);
		
		offset.x = 380;
		offset.y = 360;
	}

	function loadAnims() 
	{
		frames = Paths.getSparrowAtlas(SPLASH_SKIN);
		animation.addByPrefix('splash', 'notesplash', 64, false);
	}

	static var aliveTime:Float = 0;
	static var buggedKillTime:Float = 0.5; //automatically kills note splashes if they break to prevent it from flooding your HUD
	override function update(elapsed:Float) 
	{
		aliveTime += elapsed;
		if((animation.curAnim != null && animation.curAnim.finished) ||
			(animation.curAnim == null && aliveTime >= buggedKillTime)) kill();

		super.update(elapsed);
	}
}