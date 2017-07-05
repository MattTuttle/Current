import flash.system.Capabilities;
import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.input.Input;
import haxepunk.input.Key;
import scenes.Game;
import scenes.MainMenu;
import flash.display.Stage;

class Main extends Engine
{

	public static var backgroundMusic:audaxe.Channel;

	public function new()
	{
		super(640, 400, 60);

		backgroundMusic = audaxe.Engine.createChannel();
		backgroundMusic.sound = audaxe.Sound.loadTracker("music/title.xm");
		backgroundMusic.sound.play();
	}

	override public function update()
	{
		if (Key.pressed(Key.F)) HXP.fullscreen = !HXP.fullscreen;
		audaxe.Engine.volume = HXP.volume;
		super.update();
	}

	override public function init()
	{
#if debug
		haxepunk.debug.Console.enable();
#end
		// HXP.orientations = [Stage.OrientationLandscapeLeft, Stage.OrientationLandscapeRight];
		HXP.defaultFont = "font/bubblesstandard.ttf";
		HXP.scene = new MainMenu();

		// ripple = new PostProcess("shaders/ripple.frag");
		// ripple.setUniform("speed", 2.0);
		// ripple.setUniform("density", 1.4);
		// ripple.setUniform("scale", 2.5);

		// blur = new PostProcess("shaders/hq2x.frag");

		// blur.enable(ripple);
		// ripple.enable();
	}

}
