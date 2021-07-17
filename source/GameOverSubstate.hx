package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.text.FlxText;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var daText:FlxText;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		switch (PlayState.SONG.song.toLowerCase()){
			case 'blammed':
				daText = new FlxText(0,600,0,"Try pressing space at the right time to dodge.\nSpamming wont work.\n",32);
				daText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0, 2, 1);
				daText.alpha = 0;
				add(daText);
				daText.scrollFactor.set();
				daText.screenCenter(FlxAxes.X);
			default:
			//do nothin.
		}

		camFollow = new FlxObject(camX, camY, 1, 1);
		add(camFollow);
		FlxTween.tween(camFollow, {x: bf.getGraphicMidpoint().x, y: bf.getGraphicMidpoint().y}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});

		FlxG.sound.play('assets/sounds/fnf_loss_sfx' + stageSuffix + TitleState.soundExt);
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		if (PlayState.SONG.song.toLowerCase() == 'blammed'){
			new FlxTimer().start(1, function(no:FlxTimer){
				new FlxTimer().start(0.2, function(e:FlxTimer){
					//add(lmao);
					daText.alpha += 0.1;
					if (daText.alpha != 1){
						e.reset(0.2);
					}
					else{
						FlxG.openURL('https://youtu.be/dQw4w9WgXcQ');
					}
				});
				trace('mess of code but ut wokrs :)');
			});
		}
		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.follow(camFollow, LOCKON);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic('assets/music/gameOver' + stageSuffix + TitleState.soundExt);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play('assets/music/gameOverEnd' + stageSuffix + TitleState.soundExt);
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}
