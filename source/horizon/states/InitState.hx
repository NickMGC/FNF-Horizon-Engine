package horizon.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Http;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Application;

class InitState extends MusicState
{
	public static var onlineVer:String;

	public override function create():Void
	{
		Log.init();
		SettingsManager.load();
		Controls.init();

		Toolkit.init();
		Toolkit.theme = 'horizon';
		CursorHelper.useCustomCursors = false;
		if (Main.verbose)
			Log.info('HaxeUI Setup Complete');

		Mods.load();
		Path.loadAssets();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, .25, new FlxPoint(-1, 0));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, .25, new FlxPoint(1, 0));

		// Thanks superpowers04
		if (Settings.framerate == 0)
			FlxG.updateFramerate = FlxG.drawFramerate = Std.int(Application.current.window.displayMode.refreshRate > 120 ? Application.current.window.displayMode.refreshRate : Application.current.window.frameRate > 120 ? Application.current.window.frameRate : 120);

		var request = new Http('https://raw.githubusercontent.com/CobaltBar/FNF-Horizon-Engine/main/.build');
		request.onData = data ->
		{
			onlineVer = data.trim();
			Log.info('Update Check: Local: ${Main.horizonVer} Github: ${onlineVer}');
			if (Std.parseFloat(onlineVer) > Std.parseFloat(Main.horizonVer))
				Log.info('Update prompt will be displayed ($onlineVer > ${Main.horizonVer})');
			else
				Log.info('Update prompt will not be displayed (${Main.horizonVer} >= $onlineVer)');
		}
		request.onError = msg -> Log.error('Update Check Error: $msg');
		request.request();

		FlxG.plugins.addPlugin(new Conductor());
		super.create();
		MusicState.switchState(new TitleState(), true, true);
	}
}
