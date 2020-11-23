import haxepunk.debug.Console;
import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.input.Key;
import scenes.Game;
import scenes.MainMenu;

class Main extends Engine
{

	public function new()
	{
		super(640, 400, 60);
	}

	override public function update()
	{
		if (Key.pressed(Key.F)) HXP.fullscreen = !HXP.fullscreen;
		BackgroundMusic.update();
		super.update();
	}

	@:preload(
		["assets/graphics", "gfx"],
		["assets/audio", "sfx"],
		["assets/music", "music"],
		["assets/font", "font"],
		["assets/levels", "levels"],
		["assets/shaders", "shaders"]
	)
	override public function init()
	{
#if debug
		Console.enable();
#end
		BackgroundMusic.play("music/title.xm");
		HXP.scene = new MainMenu();
	}

	override public function focusGained() {
		paused = false;
		BackgroundMusic.resume();
	}

	override public function focusLost() {
		paused = true;
	}

	static function main() new Main();
}
