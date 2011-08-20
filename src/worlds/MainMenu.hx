package worlds;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.Tween;
import com.haxepunk.graphics.Image;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.tweens.sound.Fader;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Data;
import com.haxepunk.World;
import ui.Button;

class MainMenu extends World
{

	public function new() 
	{
		super();
		
		addGraphic(new Image(GfxMenuBackdrop), 100);
		Game.musicPlayer.loadSong(new ModTitle());
	}
	
	public override function begin()
	{
		var logoGraphic = new Image(GfxMenuLogo);
		logoGraphic.alpha = 0;
		var logo = addGraphic(logoGraphic, 50, Std.int(HXP.screen.width / 2 - 250), -300);
		
		var logoTween:VarTween = new VarTween(logoComplete, TweenType.OneShot);
		logoTween.tween(logo, "y", -10, 2);
		addTween(logoTween);
		
		var logoAlphaTween:VarTween = new VarTween(null, TweenType.OneShot);
		logoAlphaTween.tween(logoGraphic, "alpha", 1, 2, Ease.cubeIn);
		addTween(logoAlphaTween);
	}
	
	private function logoComplete()
	{
		var hw:Float = HXP.screen.width / 2;
		add(new Button(hw, 280, GfxMenuNewGame, onNewGame));
		add(new Button(hw, 330, GfxMenuContinue, onContinue));
		add(new Button(hw, 380, GfxMenuAbout, onAbout));
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
	
	private function fadeComplete()
	{
		HXP.world = new Game();
	}
	
}