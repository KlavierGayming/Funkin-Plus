package;

//import NoteSplash;
import sys.FileSystem;
//import polymod.fs.SysFileSystem;
import Section.SwagSection;
import Song.SwagSong;
//import WiggleEffect.WiggleEffectType;
//import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
//import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
//import flixel.FlxState;
import flixel.FlxSubState;
//import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
//import flixel.addons.effects.FlxTrailArea;
//import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
//import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
//import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
//import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
//import haxe.Json;
//import lime.utils.Assets;
//import openfl.display.BlendMode;
//import openfl.display.StageQuality;
//import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	
	public static var returnLocation:String = "main";
	public static var returnSong:Int = 0;
	
	private var canHit:Bool = false;
	private var noMissCount:Int = 0;

	public static var stageSongs:Array<String>;
	public static var spookySongs:Array<String>;
	public static var phillySongs:Array<String>;
	public static var limoSongs:Array<String>;
	public static var mallSongs:Array<String>;
	public static var evilMallSongs:Array<String>;
	public static var schoolSongs:Array<String>;
	public static var schoolScared:Array<String>;
	public static var evilSchoolSongs:Array<String>;

	var camFocus:String = "";
	var camTween:FlxTween;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var invulnCount:Int = 0;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['Minus is ass', 'Plus is cool >:)'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var bgHALLO:FlxSprite;
	var bgHALLOend:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];
	
	override public function create()
	{

		FlxG.mouse.visible = false;

		FlxG.sound.cache("assets/music/" + SONG.song + "_Inst" + TitleState.soundExt);
		FlxG.sound.cache("assets/music/" + SONG.song + "_Voices" + TitleState.soundExt);
		
		if(Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		else
			openfl.Lib.current.stage.frameRate = 144;

		Conductor.setSafeZone();
		camTween = FlxTween.tween(this, {}, 0);
	
		stageSongs = ["tutorial", "bopeebo", "fresh", "dadbattle"];
		spookySongs = ["spookeez", "south", "monster"];
		phillySongs = ["pico", "philly", "blammed"];
		limoSongs = ["satin-panties", "high", "milf"];
		mallSongs = ["cocoa", "eggnog"];
		evilMallSongs = ["winter-horrorland"];
		schoolSongs = ["senpai", "roses"];
		schoolScared = ["roses"];
		evilSchoolSongs = ["thorns"];
		
		canHit = !Config.noRandomTap;
		noMissCount = 0;
		invulnCount = 0;
	
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);

		if(FileSystem.exists("assets/data/" + SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue.txt")){
			try{
				dialogue = CoolUtil.coolTextFile("assets/data/" + SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue.txt");
			}
			catch(e){}
		}

		if (spookySongs.contains(SONG.song.toLowerCase()))
		{
			curStage = "spooky";
			trace('song is ' + SONG.song);
			//halloweenLevel = true;
			bgHALLOend = new FlxSprite(-600, -200).loadGraphic('assets/images/betastuff/halloweenbg.png');
			trace('loaded png');
			bgHALLOend.antialiasing = true;
			bgHALLOend.scrollFactor.set(0.9, 0.9);
			bgHALLOend.setGraphicSize(Std.int(bgHALLOend.width * 1.9));
			bgHALLOend.active = false;
			add(bgHALLOend);
			/*var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/halloween_bg.png', 'assets/images/halloween_bg.xml');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);*/
			bgHALLO = new FlxSprite(500, 200).loadGraphic('assets/images/betastuff/halloweenbg.png');
			bgHALLO.antialiasing = true;
			bgHALLO.scrollFactor.set(0.9, 0.9);
			//bgHALLO.setGraphicSize(Std.int(bgHALLO.width * 1.1));
			bgHALLO.scale.set(1.9, 1.9);
			bgHALLO.active = false;
			switch (SONG.song.toLowerCase()){
			    case 'south':
		    	    bgHALLO.alpha = 0;
		    	    bgHALLOend.alpha = 0;
		    	case 'spookeez'
		    	    bgHALLO.alpha = 1;
			}
			add(bgHALLO);

			//isHalloween = true;
		}
		else if (phillySongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic('assets/images/philly/sky.png');
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic('assets/images/philly/city.png');
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic('assets/images/philly/win' + i + '.png');
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic('assets/images/philly/behindTrain.png');
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic('assets/images/philly/train.png');
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic('assets/images/philly/street.png');
			add(street);
		}
		else if (limoSongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic('assets/images/limo/limoSunset.png');
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = FlxAtlasFrames.fromSparrow('assets/images/limo/bgLimo.png', 'assets/images/limo/bgLimo.xml');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('assets/images/limo/limoOverlay.png');
			overlayShit.alpha = 0.5;
			// add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			var limoTex = FlxAtlasFrames.fromSparrow('assets/images/limo/limoDrive.png', 'assets/images/limo/limoDrive.xml');

			limo = new FlxSprite(-120, 550);
			limo.frames = limoTex;
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic('assets/images/limo/fastCarLol.png');
			// add(limo);
		}
		else if (mallSongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic('assets/images/christmas/bgWalls.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/upperBop.png', 'assets/images/christmas/upperBop.xml');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic('assets/images/christmas/bgEscalator.png');
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic('assets/images/christmas/christmasTree.png');
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/bottomBop.png', 'assets/images/christmas/bottomBop.xml');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic('assets/images/christmas/fgSnow.png');
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = FlxAtlasFrames.fromSparrow('assets/images/christmas/santa.png', 'assets/images/christmas/santa.xml');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (evilMallSongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic('assets/images/christmas/evilBG.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic('assets/images/christmas/evilTree.png');
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assets/images/christmas/evilSnow.png");
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (schoolSongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic('assets/images/weeb/weebSky.png');
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic('assets/images/weeb/weebSchool.png');
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic('assets/images/weeb/weebStreet.png');
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic('assets/images/weeb/weebTreesBack.png');
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = FlxAtlasFrames.fromSpriteSheetPacker('assets/images/weeb/weebTrees.png', 'assets/images/weeb/weebTrees.txt');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/petals.png', 'assets/images/weeb/petals.xml');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (schoolScared.contains(SONG.song.toLowerCase()))
			{
				bgGirls.getScared();
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (evilSchoolSongs.contains(SONG.song.toLowerCase()))
		{
			curStage = 'schoolEvil';

			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

			var posX = 400;
			var posY = 200;

			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/animatedEvilSchool.png', 'assets/images/weeb/animatedEvilSchool.xml');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);

			/* 
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolBG.png');
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);
				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolFG.png');
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);
				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
			 */

			// bg.shader = wiggleShit.shader;
			// fg.shader = wiggleShit.shader;

			/* 
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);
				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);
				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();
				add(waveSprite);
				add(waveSpriteFG);
			 */
		}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
			// bg.setGraphicSize(Std.int(bg.width * 2.5));
			// bg.updateHitbox();
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		switch(SONG.song.toLowerCase()){
			case "tutorial":
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "spookeez":
				dadBeats = [0, 1, 2, 3];
			case "south":
				dadBeats = [0, 1, 2, 3];
			case "monster":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "cocoa":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "thorns":
				dadBeats = [0, 1, 2, 3];
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall':
				gfVersion = 'gf-christmas';
			case 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		if (SONG.song.toLowerCase() == 'south'){
			dad.alpha = 0;
			boyfriend.alpha = 0;
			gf.alpha = 0;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);
		
		if (curStage == 'limo')
			add(limo);
		
		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if(Config.downscroll){
			strumLine = new FlxSprite(0, 570).makeGraphic(FlxG.width, 10);
		}
		else {
			strumLine = new FlxSprite(0, 30).makeGraphic(FlxG.width, 10);
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		defaultCamZoom += 0.3;
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, Config.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.875).loadGraphic('assets/images/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		
		scoreTxt = new FlxText(healthBarBG.x - 105, (FlxG.height * 0.9) + 36, 800, "", 22);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		healthBar.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play('assets/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function updateAccuracy()
		{

			totalPlayed += 1;
			accuracy = totalNotesHit / totalPlayed * 100;
			//trace(totalNotesHit + '/' + totalPlayed + '* 100 = ' + accuracy);
			if (accuracy >= 100.00)
			{
					accuracy = 100;
			}
		
		}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 5.5));
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		//senpaiEvil.x -= 120;
		senpaiEvil.y -= 115;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('assets/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if(dadBeats.contains((swagCounter % 4)))
				dad.dance();

			gf.dance();

			if(bfBeats.contains((swagCounter % 4)))
				boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready.png', "set.png", "go.png"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[0]);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[1]);
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic("assets/music/" + SONG.song + "_Inst" + TitleState.soundExt, 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if(!paused)
			resyncVocals();
		});

	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded("assets/music/" + curSong + "_Voices" + TitleState.soundExt);
		}
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, false, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, false, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic('assets/images/weeb/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				enemyStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String){
					if(name == "confirm"){
						babyArrow.animation.play('static', true);
						babyArrow.centerOffsets();
					}
				}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		switch(Config.accuracy){
			case "none":
				scoreTxt.text = "Score:" + songScore;
			default:
				scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		//Heath Icons
		if (healthBar.percent < 20){
			iconP1.animation.curAnim.curFrame = 1;
			if(Config.betterIcons){ //Better Icons Win Anim
				iconP2.animation.curAnim.curFrame = 2;
			}
		}
		else if (healthBar.percent > 80){
			iconP2.animation.curAnim.curFrame = 1;
			if(Config.betterIcons){ //Better Icons Win Anim
				iconP1.animation.curAnim.curFrame = 2;
			}
		}
		else{
			iconP2.animation.curAnim.curFrame = 0;
			iconP1.animation.curAnim.curFrame = 0;
		}
			
		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT){
			if(FlxG.keys.pressed.SHIFT){
				FlxG.switchState(new AnimationDebug(SONG.player1));
			}
			else if(FlxG.keys.pressed.CONTROL){
				FlxG.switchState(new AnimationDebug(gf.curCharacter));
			}
			else{
				FlxG.switchState(new AnimationDebug(SONG.player2));
			}
		}
			

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{

				camTween.cancel();
				
				camFocus = "dad";

				var followX = dad.getMidpoint().x + 150;
				var followY = dad.getMidpoint().y - 100;
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case "mom" | "mom-car":
						followY = dad.getMidpoint().y;
					case 'senpai':
						followY = dad.getMidpoint().y - 430;
						followX = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						followY = dad.getMidpoint().y - 430;
						followX = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}

				camTween = FlxTween.tween(camFollow, {x: followX, y: followY}, 1.9, {ease: FlxEase.quintOut});

			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{

				camTween.cancel();

				camFocus = "bf";

				var followX = boyfriend.getMidpoint().x - 100;
				var followY = boyfriend.getMidpoint().y - 100;

				switch (curStage)
				{
					case 'limo':
						followX = boyfriend.getMidpoint().x - 300;
					case 'mall':
						followY = boyfriend.getMidpoint().y - 200;
					case 'school':
						followX = boyfriend.getMidpoint().x - 200;
						followY = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						followX = boyfriend.getMidpoint().x - 200;
						followY = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}

				camTween = FlxTween.tween(camFollow, {x: followX, y: followY}, 1.95, {ease: FlxEase.quintOut});

			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("totalBeats: ", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 48:
					gfSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 80:
					gfSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 112:
					gfSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		/*if (curSong == 'Bopeebo')
		{
			switch (totalBeats)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}*/
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !startingSong)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollow.getScreenPosition().x, camFollow.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					//trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

					if(dad.canAutoAnim){
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
					}

					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						}
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.destroy();
				}

				if(Config.downscroll){
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
				}
				else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));


				//MOVE NOTE TRANSPARENCY CODE BECAUSE REASONS 
				if(daNote.tooLate){

					if (daNote.alpha > 0.3){

						if(Config.newInput){
							noteMiss(daNote.noteData, 0.055, false, true);
							vocals.volume = 0;
						}

						daNote.alpha = 0.3;
		
					}

				}

				//Guitar Hero Type Held Notes
				if(Config.newInput && daNote.isSustainNote && daNote.mustPress){

					if(daNote.prevNote.tooLate){
						daNote.tooLate = true;
						daNote.destroy();
					}
	
					if(daNote.prevNote.wasGoodHit){
						
						var upP = controls.UP;
						var rightP = controls.RIGHT;
						var downP = controls.DOWN;
						var leftP = controls.LEFT;
	
						switch(daNote.noteData){
							case 0:
								if(!leftP){
									noteMiss(0, 0.03, true, true);
									vocals.volume = 0;
									daNote.tooLate = true;
									daNote.destroy();
								}
							case 1:
								if(!downP){
									noteMiss(1, 0.03, true, true);
									vocals.volume = 0;
									daNote.tooLate = true;
									daNote.destroy();
								}
							case 2:
								if(!upP){
									noteMiss(2, 0.03, true, true);
									vocals.volume = 0;
									daNote.tooLate = true;
									daNote.destroy();
								}
							case 3:
								if(!rightP){
									noteMiss(3, 0.03, true, true);
									vocals.volume = 0;
									daNote.tooLate = true;
									daNote.destroy();
								}
						}
					}
				}

				if (Config.downscroll ? (daNote.y > strumLine.y + daNote.height + 50) : (daNote.y < strumLine.y - daNote.height - 50))
				{
					if(Config.newInput){

						if (daNote.tooLate){
								
							daNote.active = false;
							daNote.visible = false;
			
							daNote.destroy();
		
						}

					}
					else{

						if (daNote.tooLate || !daNote.wasGoodHit){
							
							health -= 0.0475 * Config.healthDrainMultiplier;
							misses += 1;
							updateAccuracy();
							vocals.volume = 0;
						}
		
						daNote.active = false;
						daNote.visible = false;
		
						daNote.destroy();

					}
					
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		//FlxG.camera.followLerp = 0.04 * (6 / Main.fpsDisplay.currentFPS); 

	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic("assets/music/klaskiiLoop.ogg", 0.75);

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * Conductor.shitZone)
			{
				daRating = 'shit';
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.shitZone;
				}
				else {
					totalNotesHit += 1;
				}
				score = 50;
			}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.badZone)
			{
				daRating = 'bad';
				score = 100;
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.badZone;
				}
				else {
					totalNotesHit += 1;
				}
			}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.goodZone)
			{
				daRating = 'good';
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.goodZone;
				}
				else {
					totalNotesHit += 1;
				}
				score = 200;
			}
		if (daRating == 'sick')
			totalNotesHit += 1;
	
		//trace('hit ' + daRating);

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic('assets/images/' + pixelShitPart1 + daRating + pixelShitPart2 + ".png");
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);

					if(Config.noRandomTap)
						setCanMiss();
				}

			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
					switch (daNote.noteData)
					{
						case 2: // NOTES YOU JUST PRESSED
							if (upP || rightP || downP || leftP)
								noteCheck(upP, daNote);
						case 3:
							if (upP || rightP || downP || leftP)
								noteCheck(rightP, daNote);
						case 1:
							if (upP || rightP || downP || leftP)
								noteCheck(downP, daNote);
						case 0:
							if (upP || rightP || downP || leftP)
								noteCheck(leftP, daNote);
					}
				 */
				if (daNote.wasGoodHit)
				{
					daNote.destroy();
				}
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 0:
							if (left)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing'))
				boyfriend.idleEnd();
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!up)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!right)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!down)
						spr.animation.play('static');
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!left)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, ?healthLoss:Float = 0.04, ?playAudio:Bool = true, ?skipInvCheck:Bool = false):Void
	{
		if (!boyfriend.stunned && !startingSong && (!boyfriend.invuln || skipInvCheck) )
		{
			health -= healthLoss * Config.healthDrainMultiplier;
			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			misses += 1;
			combo = 0;

			songScore -= 100;
			
			if(playAudio){
				FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			}
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			if(Config.newInput)
				setBoyfriendInvuln(0.08);
			else
				setBoyfriendStunned();

			if(boyfriend.canAutoAnim){
				switch (direction)
				{
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
				}
			}

			updateAccuracy();
		}
	}

	function noteMissWrongPress(direction:Int = 1, ?healthLoss:Float = 0.0475):Void
		{
			if (!startingSong && !boyfriend.invuln)
			{
				health -= healthLoss * Config.healthDrainMultiplier;
				if (combo > 5)
				{
					gf.playAnim('sad');
				}
				combo = 0;
	
				songScore -= 25;
				
				FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
				
				// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
				// FlxG.log.add('played imss note');
	
				setBoyfriendInvuln(0.04);
	
				if(boyfriend.canAutoAnim){
					switch (direction)
					{
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
					}
				}
			}
		}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if(Config.noRandomTap && !canHit){}
		else{

			switch(Config.newInput){
				case true:
					if (leftP)
						noteMissWrongPress(0);
					if (upP)
						noteMissWrongPress(2);
					if (rightP)
						noteMissWrongPress(3);
					if (downP)
						noteMissWrongPress(1);
	
				case false:
					if (leftP)
						noteMiss(0);
					if (upP)
						noteMiss(2);
					if (rightP)
						noteMiss(3);
					if (downP)
						noteMiss(1);

			}
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			{
			goodNoteHit(note);
			}
		else
		{
			badNoteCheck();
		}
	}

	function setBoyfriendInvuln(time:Float = 5 / 60){

		invulnCount++;
		var invulnCheck = invulnCount;

		boyfriend.invuln = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if(invulnCount == invulnCheck){

				boyfriend.invuln = false;

			}
			
		});

	}

	function setCanMiss(time:Float = 0.185){

		noMissCount++;
		var noMissCheck = noMissCount;

		canHit = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if(noMissCheck == noMissCount){

				canHit = false;

			}
			
		});

	}

	function setBoyfriendStunned(time:Float = 5 / 60){

		boyfriend.stunned = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});

	}

	function goodNoteHit(note:Note):Void
	{

		//Guitar Hero Styled Hold Notes
		if(Config.newInput && note.isSustainNote && !note.prevNote.wasGoodHit){
			noteMiss(note.noteData, 0.05, true, true);
			note.prevNote.tooLate = true;
			note.prevNote.destroy();
			vocals.volume = 0;
		}

		else if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			if (note.noteData >= 0){
				switch(Config.newInput){
					case true:
						health += 0.015 * Config.healthMultiplier;
					case false:
						health += 0.023 * Config.healthMultiplier;
				}
			}
			else{
				switch(Config.newInput){
					case true:
						health += 0.0015 * Config.healthMultiplier;
					case false:
						health += 0.004 * Config.healthMultiplier;
				}
			}
				
			if(boyfriend.canAutoAnim){
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
			}

			if(Config.newInput && !note.isSustainNote){
				setBoyfriendInvuln(0.02);
			}
			

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.destroy();
			
			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play('assets/sounds/carPass' + FlxG.random.int(0, 1) + TitleState.soundExt, 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		//halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var crap:Bool = false;
	var oldR:Int = 0;
	var oldG:Int = 0;
	var oldB:Int = 0;
	var newR:Int = 0;
	var newG:Int = 0;
	var newB:Int = 0;
//FlxG.random.int(0, 150)
	override function stepHit()
	{
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		/*if (dad.curCharacter == 'spooky' && totalSteps % 4 == 2)
		{
			// dad.dance();
		}*/

		if (dad.animation.curAnim.name == 'singLEFT' || dad.animation.curAnim.name == 'singRIGHT' || dad.animation.curAnim.name == 'singUP' || dad.animation.curAnim.name == 'singDOWN'){
			if (!crap){
				defaultCamZoom -= 0.3;
				crap = true;
			}
		}
		switch (SONG.song.toLowerCase()){
			case 'south':
				//south song events
				switch (curStep){
					case 0:
						new FlxTimer().start(0.01, function(tmr:FlxTimer){
							dad.alpha += 0.1;
							if (dad.alpha != 1){
								tmr.reset(0.1);
							}
						});
					case 66:
						new FlxTimer().start(0.1, function(tmr:FlxTimer){
							boyfriend.alpha += 0.1;
							gf.alpha += 0.1;
							if (boyfriend.alpha != 1){
								tmr.reset(0.1);
							}
						});
					case 100:
						new FlxTimer().start(0.1, function(tmr:FlxTimer){
							bgHALLO.alpha += 0.1;
							if (bgHALLO.alpha != 1){
								tmr.reset(0.1);
							}
							else{
							    bgHALLOend.alpha = 1;
							}
						});
					case 910:
						new FlxTimer().start(0.1, function(tmr:FlxTimer){
				        	bgHALLO.alpha -= 0.05;
				        	if (bgHALLO.alpha != 0){
				        	    tmr.reset(0.1);
				        	}
			        	});
				}
				if (curStep % 4 == 0 && curStep > 100){
				    newR = FlxG.random.int(0, 150);
				    newB = FlxG.random.int(0, 150);
				    newG = FlxG.random.int(0, 150);
				    new FlxTimer().start(0.1, function(tmr:FlxTimer){
				    	FlxTween.color(bgHALLO, 0.4, FlxColor.fromRGB(oldR, oldG, oldB), FlxColor.fromRGB(0, 0, 0));
			    	});
				    new FlxTimer().start(0.5 function(tmr:FlxTimer){
			    		oldR = newR;
			    		oldG = newG;
			    		oldB = newB;
			    	});
				}
		}

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				if(dadBeats.contains(curBeat % 4) && dad.canAutoAnim)
					dad.dance();
			
		}
		else{
			if(dadBeats.contains(curBeat % 4))
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			dadBeats = [0, 1, 2, 3];
			bfBeats = [0, 1, 2, 3];
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			dadBeats = [0, 2];
			bfBeats = [1, 3];
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && totalBeats % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat % 1 == 0){
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			FlxTween.tween(iconP1, {iconScale: iconP1.defualtIconScale}, 0.2, {ease: FlxEase.quintOut});
			FlxTween.tween(iconP2, {iconScale: iconP2.defualtIconScale}, 0.2, {ease: FlxEase.quintOut});
		}

		if (totalBeats % gfSpeed == 0)
		{
			gf.dance();
		}

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim)
			boyfriend.dance();

		if (totalBeats % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);

		}
		
		// if (SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
		// {
			// dad.playAnim('cheer', true);
		// }

		switch (curStage)
		{
			case "school":
				bgGirls.dance();

			case "mall":
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case "limo":
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		/*if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
			
		}*/
	}

	var curLight:Int = 0;
}