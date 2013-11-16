package scenes;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.Tween;
import com.haxepunk.graphics.Image;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.tweens.sound.Fader;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Data;
import com.haxepunk.Scene;
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
		var whiteout:VarTween = new VarTween(null, TweenType.OneShot);
		whiteout.tween(white, "alpha", 0, 1);
		addTween(whiteout);

		addGraphic(new Image("gfx/menu/backdrop.png"), 100);

		// menu logo
		var logoGraphic = new Image("gfx/menu/logo.png");
		logoGraphic.alpha = 0;
		var logo = addGraphic(logoGraphic, 50, Std.int(HXP.screen.width / 2 - 250), -300);

		var logoTween:VarTween = new VarTween(logoComplete, TweenType.OneShot);
		logoTween.tween(logo, "y", -10, 2);
		addTween(logoTween);

		var logoAlphaTween:VarTween = new VarTween(null, TweenType.OneShot);
		logoAlphaTween.tween(logoGraphic, "alpha", 1, 2, Ease.cubeIn);
		addTween(logoAlphaTween);
	}

	private function logoComplete(_)
	{
		var hw:Float = HXP.screen.width / 2;
		add(new Button(hw, 280, "gfx/menu/new_game.png", onNewGame));
		add(new Button(hw, 330, "gfx/menu/continue.png", onContinue));
//		add(new Button(hw, 380, "gfx/menu/about.png", onAbout));
	}

	private function onNewGame()
	{
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
		addTween(screenFader);

		var fader = new Fader(fadeComplete, TweenType.OneShot);
		fader.fadeTo(0, fadeTime);
		addTween(fader);
	}

	private function onAbout()
	{
	}

	private function fadeComplete(_)
	{
		HXP.scene = new Game();
	}

}