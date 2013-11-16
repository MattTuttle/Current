import flash.system.Capabilities;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
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
		if (Input.pressed(Key.F)) HXP.fullscreen = !HXP.fullscreen;
		audaxe.Engine.volume = HXP.volume;
		super.update();
	}

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
#if !flash
		HXP.orientations = [Stage.OrientationLandscapeLeft, Stage.OrientationLandscapeRight];
#end
		HXP.defaultFont = "font/bubblesstandard.ttf";
		HXP.scene = new MainMenu();
	}

	public static function main()
	{
		new Main();
	}

}