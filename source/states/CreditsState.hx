package states;

import states.TrueMenuState;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence('Credits', null);
		#end
	
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) MusicBeatState.switchState(new TrueMenuState());

		super.update(elapsed);
	}
}
