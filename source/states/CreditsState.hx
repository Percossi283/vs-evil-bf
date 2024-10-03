package states;

import backend.CoolUtil;

import states.TrueMenuState;

typedef CreditsPopupData = 
{
	var png:String;
	var name:String;
	var credit:String;
}

enum CreditState
{
	CLOSED;
	OPENED;
}

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	var peeps:Array<String> = [
		'triki',
		'cooey',
		'awaken',
		'alyssa',
		'june'
	];

	var formattedNames:Map<String, String> = [
		'alyssa' => '[A2]',
		'cooey' => 'Cooey',
		'triki' => 'Triki Troy',
		'awaken' => 'Awaken',
		'june' => 'Junebug'
	];

	var positions:Map<String, Array<Float>> = [
		'alyssa' => [125, 250],
		'cooey' => [275, 190],
		'triki' => [425, 180],
		'awaken' => [685, 180],
		'june' => [800, 240],
	];

	var boxDimensions:Map<String, Array<Int>> = [
		'alyssa' => [200, 400],
		'cooey' => [100, 400],
		'triki' => [225, 175],
		'awaken' => [100, 400],
		'june' => [200, 400],
	];

	var boxOffsets:Map<String, Array<Int>> = [
		'alyssa' => [30, 30],
		'cooey' => [100, 30],
		'triki' => [55, 0],
		'awaken' => [30, 30],
		'june' => [30, 30]
	];

	var credits:Map<String, String> = [
		'alyssa' => 'Programmer\nAnimator',
		'cooey' => 'Artist\nAnimator',
		'triki' => 'Artist\nAnimator',
		'awaken' => 'Animator',
		'june' => 'Charter'
	];

	var people:Array<FlxSprite> = [];
	var boxes:Array<FlxSprite> = [];

	var evilBF:FlxSprite;

	var joe:FlxSprite;
	var honkish:FlxSprite;

	var creditsMap:Map<FlxSprite, CreditsPopupData> = new Map();
	var links:Map<String, String> = [
		'Evil BF' => 'https://raw.githubusercontent.com/A2source/A2archive/main/safe.png',
		'JoeDoughBoi' => 'https://twitter.com/losermakesgames',
		'H0nkish' => 'https://twitter.com/H0nkish',
		'[A2]' => 'https://a2source.github.io',
		'Cooey' => 'https://twitter.com/cooey05',
		'Triki Troy' => 'https://twitter.com/Triki_Tr0y',
		'Awaken' => 'https://twitter.com/BakingMeshes',
		'Junebug' => 'https://twitter.com/junebug_7801'
	];

	var creditImage:FlxSprite;
	var linkHitbox:FlxSprite;

	var creditMonitor:FlxSprite;

	var creditTitleText:FlxText;
	var creditText:FlxText;

	var curState:CreditState = CLOSED;

	var creditsTextPoint:FlxPoint = FlxPoint.weak(823, 485);

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Credits', null);
		#end

		FlxG.sound.playMusic(Paths.music('credits'), 0.8);

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		#if mobile
		addVirtualPad(NONE,B);
		#end
	
		super.create();

		FlxG.worldBounds.set();

		var circle:FlxSprite = new FlxSprite(500, 400).loadGraphic(Paths.image('credits/circle'));
		circle.screenCenter();
		circle.x -= 50;
		circle.y += 300;
		add(circle);

		evilBF = new FlxSprite(50, 50).loadGraphic(Paths.image('credits/evil bf'));
		add(evilBF);

		joe = new FlxSprite(50 + evilBF.width, 50).loadGraphic(Paths.image('credits/joe'));
		add(joe);

		var runningSonicGif:FlxSprite = new FlxSprite(895, 205);
		runningSonicGif.frames = Paths.getSparrowAtlas('credits/sonic');
		runningSonicGif.animation.addByPrefix('idle', 'sonic', 24, true);
		runningSonicGif.animation.play('idle');
		runningSonicGif.scale.set(0.35, 0.4);
		runningSonicGif.alpha = 0.4;
		add(runningSonicGif);

		var tv:FlxSprite = new FlxSprite(1050, 200).loadGraphic(Paths.image('credits/i fucking love tvs'));
		add(tv);

		for (name in peeps)
		{
			var sprite:FlxSprite = new FlxSprite(positions[name][0], positions[name][1]);
			sprite.frames = Paths.getSparrowAtlas('credits/$name');
			sprite.animation.addByPrefix('idle', '$name idle');
			sprite.animation.addByPrefix('reveal', '$name revealed');
			sprite.updateHitbox();
			people.push(sprite);
			add(sprite);

			var hitbox:FlxSprite = new FlxSprite(sprite.x, sprite.y).makeGraphic(boxDimensions[name][0], boxDimensions[name][1], 0xFFFF0000);
			hitbox.x += boxOffsets[name][0];
			hitbox.y += boxOffsets[name][1];
			hitbox.alpha = 0;
			boxes.push(hitbox);
			add(hitbox);
		}

		honkish = new FlxSprite(520, 360).loadGraphic(Paths.image('credits/honkish'));
		add(honkish);

		creditsMap = [
			evilBF => {png: 'mark', name: 'Evil BF', credit: 'Get well\nsoon!'},
			joe => {png: 'joe', name: 'JoeDoughBoi', credit: 'Creator of\nLORD X'},
			honkish => {png: 'honkish', name: 'H0nkish', credit: 'Cycles\nComposer'}
		];

		for (i in 0...people.length)
		{
			var sprite = boxes[i];
			var name = peeps[i];

			creditsMap.set(sprite, {png: name, name: formattedNames[name], credit: credits[name]});
		}

		creditImage = new FlxSprite();
		add(creditImage);

		creditMonitor = new FlxSprite().loadGraphic(Paths.image('credits/monitor'));
		creditMonitor.y += creditMonitor.height;
		creditImage.y += creditMonitor.height;
		add(creditMonitor);

		linkHitbox = new FlxSprite().makeGraphic(367, 274, 0xFFFF0000);
		linkHitbox.screenCenter();
		linkHitbox.y -= 65;
		linkHitbox.alpha = 0;
		add(linkHitbox);

		creditTitleText = new FlxText(0, 30, 0, '');
		creditTitleText.setFormat(Paths.font('blood.ttf'), 64, FlxColor.RED, CENTER);
		creditTitleText.alignment = 'center';
		creditTitleText.y += creditMonitor.height;
		add(creditTitleText);

		creditText = new FlxText(0, 0, 0, '');
		creditText.setFormat(Paths.font('blood.ttf'), 18, FlxColor.RED, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		creditText.alignment = 'center';
		creditText.angle = -4;
		creditText.y += creditMonitor.height;
		add(creditText);
	}

	var canInteract:Bool = true;
	override function update(elapsed:Float)
	{
		if (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end && canInteract) 
		{
			switch(curState)
			{
				case CLOSED:
					FlxG.mouse.visible = false;
					MusicBeatState.switchState(new TrueMenuState());

				case OPENED:
					closeCredit();
			}
		}

		updateOverlap();
		clickCheck();

		updateCredit();

		super.update(elapsed);
	}

	function updateOverlap()
	{
		if (curState == OPENED || !canInteract)
			return;

		evilBF.color = FlxG.mouse.overlaps(evilBF) ? 0xFFFF0000 : 0xFFFFFFFF;

		joe.color = FlxG.mouse.overlaps(joe) ? 0xFFFF0000 : 0xFFFFFFFF;
		honkish.color = FlxG.mouse.overlaps(honkish) ? 0xFFFF0000 : 0xFFFFFFFF;

		for (i in 0...people.length)
		{
			var sprite = people[i];
			var name = peeps[i];
			var hitbox = boxes[i];

			if (FlxG.mouse.overlaps(hitbox))
				sprite.animation.play('reveal');
			else
				sprite.animation.play('idle');
		}
	}

	function clickCheck()
	{
		if (curState == OPENED || !canInteract)
			return;

		if (FlxG.mouse.justPressed)
		{
			for (sprite in creditsMap.keys())
			{
				if (FlxG.mouse.overlaps(sprite))
				{
					var cur = creditsMap.get(sprite);

					creditTitleText.text = cur.name;
					creditText.text = cur.credit;

					canInteract = false;

					creditTitleText.x = FlxG.width / 2 - creditTitleText.width / 2;

					creditText.x = creditsTextPoint.x - creditText.width / 2;

					creditText.y = creditsTextPoint.y - creditText.height / 2;
					creditText.y += creditMonitor.height;

					FlxTween.tween(creditTitleText, {y: creditTitleText.y - creditMonitor.height}, 1, {ease: FlxEase.expoOut});
					FlxTween.tween(creditText, {y: creditText.y - creditMonitor.height}, 1, {ease: FlxEase.expoOut});

					creditImage.loadGraphic(Paths.image('credits/popup/${cur.png}'));
					FlxTween.tween(creditImage, {y: creditImage.y - creditMonitor.height}, 1, {ease: FlxEase.expoOut});

					if (cur.name == 'JoeDoughBoi')
						CoolUtil.steamMessage(add);

					FlxTween.tween(creditMonitor, {y: 0}, 1, {ease: FlxEase.expoOut, onComplete: (twn:FlxTween) ->
					{
						canInteract = true;
						curState = OPENED;
					}});
				}
			}
		}
	}

	function updateCredit()
	{
		if (curState == CLOSED || !canInteract)
			return;

		if (controls.ACCEPT)
			CoolUtil.browserLoad(links[creditTitleText.text]);

		if (!FlxG.mouse.justPressed)
			return;

		if (!FlxG.mouse.overlaps(linkHitbox))
			closeCredit();
		else
			CoolUtil.browserLoad(links[creditTitleText.text]);
	}

	function closeCredit()
	{
		canInteract = false;

		FlxTween.tween(creditTitleText, {y: creditTitleText.y + creditMonitor.height}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(creditText, {y: creditText.y + creditMonitor.height}, 1, {ease: FlxEase.expoOut});

		FlxTween.tween(creditImage, {y: creditImage.y + creditMonitor.height}, 1, {ease: FlxEase.expoOut});

		FlxTween.tween(creditMonitor, {y: creditMonitor.height}, 1, {ease: FlxEase.expoOut, onComplete: (twn:FlxTween) ->
		{
			canInteract = true;
			curState = CLOSED;
		}});
	}
}
