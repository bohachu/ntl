package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.SimpleButton;
	import flash.net.SharedObject;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.filesystem.File;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.Navigator;
	import tw.cameo.storyMouth.BackgroundMusic;
	import com.greensock.TweenLite;
	import tw.cameo.GetVersionNumber;

	public class Home extends MovieClip {
		
		public static const OPENING_MOVIE_ADDED:String = "Home.OPENING_MOVIE_ADDED";
		public static const CLICK_INTO_GUIDANCE:String = "Home.CLICK_INTO_GUIDANCE";
		public static const CLICK_QRCODE:String = "Home.CLICK_QRCODE";
		public static const CLICK_CHECK_IN:String = "Home.CLICK_CHECK_IN";
		public static const CLICK_TRAFFIC:String = "Home.CLICK_TRAFFIC";
		private const strMusicUrl:String = "data/background.mp3";
		
		private var sharedObjectSavedStatus:SharedObject = SharedObject.getLocal("SavedStatus");
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		private var backgroundMusic:BackgroundMusic = BackgroundMusic.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
		private var welcomeSound:Sound = null;
		private var welcomeSoundChannel:SoundChannel = null;
		private var isPlayingWelcomeSound:Boolean = false;
		private var isShowAnimation:Boolean = false;
		private var homeScreen:MovieClip = null;
		private var openingMovie:MovieClip = null;
		
		private var isMenuShow:Boolean = false;
		private var menuContainer:Sprite = null;

		public function Home(isShowAnimationIn:Boolean = false) {
			// constructor code
			isShowAnimation = isShowAnimationIn;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			titlebar.hideTitlebar();
			guidanceTool.setType(GuidanceTool.GUIDE_BUTTON_TYPE1);
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			if (isShowAnimation) {
				showOpeningAnimation();
				var checkFolder:File = File.applicationStorageDirectory.resolvePath("/sdcard/android/data/air.tw.cameo.NTL/" + strMusicUrl);
				if (checkFolder.exists) {
					backgroundMusic.playMusic("/sdcard/android/data/air.tw.cameo.NTL/" + strMusicUrl, false);
				} else {
					backgroundMusic.playMusic(strMusicUrl, false);
				}
				
			} else {
				showHomeScreen();
				guidanceTool.showGuidanceTool();
			}
		}
		
		public function stopBackgroundMusic() {
			backgroundMusic.stopMusic();
		}
		
		private function playWelcomeAudio(e:MouseEvent = null) {
			if (isPlayingWelcomeSound) {
				removeWelcomeSound();
				return;
			}
			
			switch (language.getLanguageType()) {
				case "CHT":
					welcomeSound = new Welcom_CHT();
				break;
				case "ENU":
					welcomeSound = new Welcom_ENU();
				break;
				case "JPN":
					welcomeSound = new Welcom_JPN();
				break;
			}
			welcomeSoundChannel = welcomeSound.play();
			welcomeSoundChannel.addEventListener(Event.SOUND_COMPLETE, removeWelcomeSound);
			isPlayingWelcomeSound = true;
		}
		
		public function removeWelcomeSound(e:Event = null) {
			if (welcomeSoundChannel) welcomeSoundChannel.stop();
			isPlayingWelcomeSound = false;
			welcomeSoundChannel = null;
			welcomeSound = null;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			stopBackgroundMusic();
			removeLanguageMenu();
			removeHomeScreen();
			removeOpeningMovie();
			removeWelcomeSound();
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function showOpeningAnimation() {
			openingMovie = (isIphone5Layout) ? new OpeningMovieIphone5() : new OpeningMovieIphone4();
			openingMovie.addEventListener(MouseEvent.CLICK, skipOpeningMovie);
			openingMovie.addEventListener("ANIMATION_PLAY_END", onOpeningMoviePlayEnd);
			this.addChild(openingMovie);
		}
		
		private function skipOpeningMovie(e:MouseEvent) {
			backgroundMusic.stopMusic();
			openingMovie.removeEventListener(MouseEvent.CLICK, skipOpeningMovie);
			openingMovie.removeEventListener("ANIMATION_PLAY_END", onOpeningMoviePlayEnd);
			showHomeScreen();
		}
		
		private function removeOpeningMovie() {
			if (openingMovie == null)  return;
			openingMovie.removeEventListener(MouseEvent.CLICK, skipOpeningMovie);
			openingMovie.removeEventListener("ANIMATION_PLAY_END", onOpeningMoviePlayEnd);
			this.removeChild(openingMovie);
			openingMovie = null;
		}
		
		private function onOpeningMoviePlayEnd(e:Event = null) {
			openingMovie.removeEventListener("ANIMATION_PLAY_END", onOpeningMoviePlayEnd);
			
			if (!sharedObjectSavedStatus.data.hasOwnProperty("isNotFirstTimeUse")) {
				sharedObjectSavedStatus.data["isNotFirstTimeUse"] = true;
				sharedObjectSavedStatus.flush();
				playWelcomeAudio();
			}
			
			showHomeScreen();
		}
		
		private function showHomeScreen() {
			eventChannel.writeEvent(new Event(Home.OPENING_MOVIE_ADDED));
			homeScreen = (isIphone5Layout) ? new HomeIphone5() : new HomeIphone4();
			homeScreen.alpha = 0;
			
			var strVersionNumber:String = GetVersionNumber.getAppVersion();
			homeScreen.versionLabel.text = "v " + strVersionNumber;
			
			setButtonLabelAndEventListener();
			this.addChild(homeScreen);
			guidanceTool.showGuidanceTool();
			TweenLite.to(homeScreen, 1.5, {alpha:1, onComplete:removeOpeningMovie});
		}
		
		private function removeHomeScreen() {
			removeButtonEventListener();
			this.removeChild(homeScreen);
			homeScreen = null;
		}
		
		private function setButtonLabelAndEventListener() {
			setButtonLabel();
			addButtonEventListener();
		}
		
		private function setButtonLabel() {
			homeScreen.btnChangeLanguage.gotoAndStop(language.getLanguageType());
			homeScreen.btnIntoGuidance.label.text = i18n.get("IntoGuidance");
			homeScreen.btnQrCode.label.text = i18n.get("QrCode");
			homeScreen.btnTakePhoto.label.text = i18n.get("CheckIn");
			homeScreen.btnTraffic.label.text = i18n.get("Traffic");
			homeScreen.btnWelcome.label.text = i18n.get("Welcome");
			homeScreen.btnWelcome.label.mouseEnabled = false;
		}
		
		private function addButtonEventListener() {
			homeScreen.btnChangeLanguage.addEventListener(MouseEvent.CLICK, onSwitchLanguageClick);
			homeScreen.btnIntoGuidance.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnQrCode.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnTakePhoto.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnTraffic.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnWelcome.addEventListener(MouseEvent.CLICK, playWelcomeAudio);
		}
		
		private function removeButtonEventListener() {
			homeScreen.btnChangeLanguage.removeEventListener(MouseEvent.CLICK, onSwitchLanguageClick);
			homeScreen.btnIntoGuidance.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnQrCode.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnTakePhoto.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnTraffic.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			homeScreen.btnWelcome.removeEventListener(MouseEvent.CLICK, playWelcomeAudio);
		}
		
		private function onHomeMenuButtonClick(e:MouseEvent) {
			if (e.target.parent.name == "btnIntoGuidance") eventChannel.writeEvent(new Event(Home.CLICK_INTO_GUIDANCE));
			if (e.target.parent.name == "btnQrCode")       eventChannel.writeEvent(new Event(Home.CLICK_QRCODE));;
			if (e.target.parent.name == "btnTakePhoto")    eventChannel.writeEvent(new Event(Home.CLICK_CHECK_IN));;
			if (e.target.parent.name == "btnTraffic")      eventChannel.writeEvent(new Event(Home.CLICK_TRAFFIC));;
		}
		
		private function onSwitchLanguageClick(e:MouseEvent) {
			if (isMenuShow) {
				hideLanguageMenu();
			} else {
				showLanguageMenuWithout(language.getLanguageType());
			}
		}
		
		private function hideLanguageMenu() {
			isMenuShow = false;
			if (menuContainer == null) return;
			
			TweenLite.killTweensOf(menuContainer);
			TweenLite.to(menuContainer, 0.5, {alpha:0, onComplete:removeLanguageMenu});
		}
		
		private function removeLanguageMenu() {
			if (menuContainer == null) return;
			this.removeChild(menuContainer);
			while (menuContainer.numChildren > 0) {
				var child:SimpleButton = menuContainer.getChildAt(0) as SimpleButton;
				child.removeEventListener(MouseEvent.CLICK, onChangeLanguageClick);
				menuContainer.removeChild(child);
				child = null;
			}
			menuContainer.removeChildren();
			menuContainer = null;
		}
		
		private function showLanguageMenuWithout(strLanguageType:String) {
			isMenuShow = true;
			
			if (menuContainer == null) {
				menuContainer = new Sprite();
				menuContainer.x = 562.4;
				menuContainer.y = 90;
				menuContainer.alpha = 0;
			
				if (language.getLanguageType() != "CHT") {
					var btnCHT:SimpleButton = new BtnCHT();
					btnCHT.addEventListener(MouseEvent.CLICK, onChangeLanguageClick);
					menuContainer.addChild(btnCHT);
				}
				if (language.getLanguageType() != "ENU") {
					var btnENU:SimpleButton = new BtnENU();
					btnENU.addEventListener(MouseEvent.CLICK, onChangeLanguageClick);
					if (menuContainer.height != 0) btnENU.y = menuContainer.height + 10;
					menuContainer.addChild(btnENU);
				}
				if (language.getLanguageType() != "JPN") {
					var btnJPN:SimpleButton = new BtnJPN();
					btnJPN.addEventListener(MouseEvent.CLICK, onChangeLanguageClick);
					btnJPN.y = menuContainer.height + 10;
					menuContainer.addChild(btnJPN);
				}
			
				this.addChild(menuContainer);
			} else {
				TweenLite.killTweensOf(menuContainer);
			}
			
			TweenLite.to(menuContainer, 0.5, {alpha:1});
		}
		
		private function onChangeLanguageClick(e:MouseEvent) {
			hideLanguageMenu();
			if (e.target is BtnCHT) language.setLanguage("CHT");
			if (e.target is BtnENU) language.setLanguage("ENU");
			if (e.target is BtnJPN) language.setLanguage("JPN");
			setButtonLabel();
		}

	}
	
}
