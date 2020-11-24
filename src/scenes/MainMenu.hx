package scenes;

import haxepunk.HXP;
import haxepunk.Tween;
import haxepunk.graphics.Image;
import haxepunk.tweens.misc.VarTween;
import haxepunk.tweens.sound.Fader;
import haxepunk.utils.Ease;
import haxepunk.utils.Data;
import haxepunk.Scene;
import ui.Button;

class MainMenu extends Scene
{

	public function new()
	{
		super();

		HXP.volume = 1;

		HXP.camera.x = HXP.camera.y = 0; // reset camera
	}

	public override function begin()
	{
		// fade from white
		var white:Image = Image.createRect(HXP.screen.width, HXP.screen.height);
		addGraphic(white).layer = 0;
		var whiteout:VarTween = new VarTween(TweenType.OneShot);
		whiteout.tween(white, "alpha", 0, 1);
		addTween(whiteout, true);

		addGraphic(new Image("gfx/menu/backdrop.png"), 100);

		// menu logo
		var logoGraphic = new Image("gfx/menu/logo.png");
		logoGraphic.alpha = 0;
		var logo = addGraphic(logoGraphic, 50, Std.int(HXP.screen.width / 2 - 250), -300);

		var logoTween:VarTween = new VarTween(TweenType.OneShot);
		logoTween.onComplete.bind(logoComplete);
		logoTween.tween(logo, "y", -10, 2);
		addTween(logoTween, true);

		var logoAlphaTween:VarTween = new VarTween(TweenType.OneShot);
		logoAlphaTween.tween(logoGraphic, "alpha", 1, 2, Ease.cubeIn);
		addTween(logoAlphaTween, true);
	}

	private function logoComplete()
	{
		var hw:Float = HXP.screen.width / 2;
		add(new Button(hw, 280, "gfx/menu/new_game.png", onNewGame));
		add(new Button(hw, 330, "gfx/menu/continue.png", onContinue));
	}

	private function onNewGame()
	{
		Data.load(); // wipe out old game
		Data.save("Current");
		onContinue();
	}

	private function onContinue()
	{
		var fadeTime:Float = 1;

		var black:Image = Image.createRect(HXP.screen.width, HXP.screen.height, 0);
		black.alpha = 0;
		addGraphic(black);
		var screenFader = new VarTween();
		screenFader.tween(black, "alpha", 1, fadeTime);
		addTween(screenFader, true);

		var fader = new Fader(TweenType.OneShot);
		fader.onComplete.bind(fadeComplete);
		fader.fadeTo(0, fadeTime);
		addTween(fader, true);
	}

	private function fadeComplete()
	{
		HXP.scene = new Game();
	}

}
