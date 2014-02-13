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

#if !flash
		ripple = new PostProcess("shaders/ripple.frag");
		ripple.setUniform("speed", 2.0);
		ripple.setUniform("density", 1.4);
		ripple.setUniform("scale", 2.5);

		blur = new PostProcess("shaders/hq2x.frag");

		blur.enable(ripple);
		ripple.enable();
#end
	}

#if !flash
	override public function resize()
	{
		super.resize();
		if (ripple != null) ripple.rebuild();
		if (blur != null) blur.rebuild();
	}

	override public function render()
	{
		blur.capture();

		// render to a back buffer
		super.render();
	}

	var ripple:PostProcess;
	var blur:PostProcess;
#end

	public static function main()
	{
		new Main();
	}

}