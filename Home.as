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

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.Navigator;
	import tw.cameo.AppAbout;
	import com.greensock.TweenLite;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;

	public class Home extends MovieClip {
		
		public static const CLICK_INTO_GUIDANCE:String = "Home.CLICK_INTO_GUIDANCE";
		public static const CLICK_QRCODE:String = "Home.CLICK_QRCODE";
		public static const CLICK_CHECK_IN:String = "Home.CLICK_CHECK_IN";
		public static const CLICK_TRAFFIC:String = "Home.CLICK_TRAFFIC";
		
		private var sharedObjectSavedStatus:SharedObject = SharedObject.getLocal("SavedStatus");
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
		private var welcomeSound:Sound = null;
		private var welcomeSoundChannel:SoundChannel = null;
		private var isPlayingWelcomeSound:Boolean = false;
		private var isShowAnimation:Boolean = false;
		private var bg:Sprite = null;
		
		private var paintingAnimation:MovieClip = null;
		private var pointPaintingAnimation:Point = new Point(39, (isIphone5Layout) ? 0 : -170);
		
		private var btnChangeLanguage:MovieClip = null;
		private var pointBtnChangeLanguage:Point = new Point(444, 17);
		
		private var appAbout:AppAbout = null;
		private var pointBtnAbout:Point = new Point(103, 17);
		
		private var btnIntoGuidance:MovieClip = null;
		private var pointBtnIntoGuidance:Point = new Point(208, (isIphone5Layout) ? 315 : 205);
		
		private var btnQrCode:MovieClip = null;
		private var pointBtnQrCode:Point = new Point(423, (isIphone5Layout) ? 315 : 205);
		
		private var btnTakePhoto:MovieClip = null;
		private var pointBtnTakePhoto:Point = new Point(208, (isIphone5Layout) ? 565 : 440);
		
		private var btnTraffic:MovieClip = null;
		private var pointBtnTraffic:Point = new Point(423, (isIphone5Layout) ? 565 : 440);
		
		public function Home(isShowAnimationIn:Boolean = false) {
			// constructor code
			isShowAnimation = isShowAnimationIn;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (!sharedObjectSavedStatus.data.hasOwnProperty("isNotFirstTimeUse")) {
				sharedObjectSavedStatus.data["isNotFirstTimeUse"] = true;
				sharedObjectSavedStatus.flush();
				playWelcomeAudio();
			}
			
			titlebar.hideTitlebar();
			guidanceTool.setType(GuidanceTool.GUIDE_BUTTON_TYPE1);
			guidanceTool.showGuidanceTool();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			createPaintingAnimation();
		}
		
		private function playWelcomeAudio() {
			if (isPlayingWelcomeSound) return;
			
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
		
		private function removeWelcomeSound(e:Event = null) {
			if (welcomeSoundChannel) welcomeSoundChannel.stop();
			isPlayingWelcomeSound = false;
			welcomeSoundChannel = null;
			welcomeSound = null;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeButton();
			removePaintingAnimation();
			removeBackground();
			removeWelcomeSound();
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function createBackground() {
			bg = new BackgroundSprite();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function createPaintingAnimation() {
			paintingAnimation = new HomePaintingAnimation();
			paintingAnimation.x = pointPaintingAnimation.x;
			paintingAnimation.y = pointPaintingAnimation.y;
			if (isShowAnimation) {
				paintingAnimation.addEventListener("ANIMATION_PLAY_END", onAnimationPlayEnd);
				this.addChild(paintingAnimation);
			} else {
				this.addChild(paintingAnimation);
				paintingAnimation.gotoAndStop(paintingAnimation.totalFrames);
				onAnimationPlayEnd();
			}
		}
		
		private function removePaintingAnimation() {
			paintingAnimation.removeEventListener("ANIMATION_PLAY_END", onAnimationPlayEnd);
			this.removeChild(paintingAnimation);
			paintingAnimation = null;
			pointPaintingAnimation = null;
		}
		
		private function onAnimationPlayEnd(e:Event = null) {
			paintingAnimation.removeEventListener("ANIMATION_PLAY_END", onAnimationPlayEnd);
			createButton();
		}
		
		private function createButton() {
			appAbout = new AppAbout("Type2");
			appAbout.setAppIconPosition(pointBtnAbout.x, pointBtnAbout.y);
			
			btnChangeLanguage = new ChangeLanguageButton();
			btnChangeLanguage.x = pointBtnChangeLanguage.x;
			btnChangeLanguage.y = pointBtnChangeLanguage.y;
			
			btnIntoGuidance = new IntoGuidanceButton();
			btnIntoGuidance.x = pointBtnIntoGuidance.x;
			btnIntoGuidance.y = pointBtnIntoGuidance.y;
			
			btnQrCode = new QrCodeButton();
			btnQrCode.x = pointBtnQrCode.x;
			btnQrCode.y = pointBtnQrCode.y;
			
			btnTakePhoto = new TakePhotoButton();
			btnTakePhoto.x = pointBtnTakePhoto.x;
			btnTakePhoto.y = pointBtnTakePhoto.y;
			
			btnTraffic = new TrafficButton();
			btnTraffic.x = pointBtnTraffic.x;
			btnTraffic.y = pointBtnTraffic.y;
			
			setButtonLabel();
			addButtonToStage();
			addButtonEventListener();
		}
		
		private function setButtonLabel() {
			btnChangeLanguage.gotoAndStop(language.getLanguageType());
			btnIntoGuidance.label.text = i18n.get("IntoGuidance");
			btnQrCode.label.text = i18n.get("QrCode");
			btnTakePhoto.label.text = i18n.get("CheckIn");
			btnTraffic.label.text = i18n.get("Traffic");
		}
		
		private function addButtonToStage() {
			btnChangeLanguage.alpha = 0;
			btnIntoGuidance.alpha = 0;
			btnQrCode.alpha = 0;
			btnTakePhoto.alpha = 0;
			btnTraffic.alpha = 0;
			appAbout.alpha = 0;
			this.addChild(btnChangeLanguage);
			this.addChild(btnIntoGuidance);
			this.addChild(btnQrCode);
			this.addChild(btnTakePhoto);
			this.addChild(btnTraffic);
			this.addChild(appAbout);
			
			TweenLite.to(appAbout, 1, {alpha:1});
			TweenLite.to(btnChangeLanguage, 1, {alpha:1});
			TweenLite.to(btnIntoGuidance, 1, {alpha:1});
			TweenLite.to(btnQrCode, 1, {alpha:1});
			TweenLite.to(btnTakePhoto, 1, {alpha:1});
			TweenLite.to(btnTraffic, 1, {alpha:1});
		}
		
		private function removeButtonFromStage() {
			this.removeChild(appAbout);
			this.removeChild(btnChangeLanguage);
			this.removeChild(btnIntoGuidance);
			this.removeChild(btnQrCode);
			this.removeChild(btnTakePhoto);
			this.removeChild(btnTraffic);
			
			appAbout = null;
			pointBtnChangeLanguage = null;
			pointBtnIntoGuidance = null;
			pointBtnQrCode = null;
			pointBtnTakePhoto = null;
			pointBtnTraffic = null;
			btnChangeLanguage = null;
			btnIntoGuidance = null;
			btnQrCode = null;
			btnTakePhoto = null;
			btnTraffic = null;
		}
		
		private function removeButton() {
			removeButtonEventListener();
			removeButtonFromStage();
		}
		
		private function addButtonEventListener() {
			appAbout.addEventListener(AppAbout.SHOW_ABOUT, onShowAppAbout);
			btnChangeLanguage.addEventListener(MouseEvent.CLICK, onChangeLanguageClick);
			btnIntoGuidance.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnQrCode.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTakePhoto.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTraffic.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
		}
		
		private function removeButtonEventListener() {
			appAbout.removeEventListener(AppAbout.SHOW_ABOUT, onShowAppAbout);
			appAbout.removeEventListener(AppAbout.HIDE_ABOUT, onHideAppAbout);
			btnChangeLanguage.removeEventListener(MouseEvent.CLICK, onChangeLanguageClick);
			btnIntoGuidance.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnQrCode.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTakePhoto.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTraffic.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
		}
		
		private function onShowAppAbout(e:Event) {
			appAbout.removeEventListener(AppAbout.SHOW_ABOUT, onShowAppAbout);
			appAbout.addEventListener(AppAbout.HIDE_ABOUT, onHideAppAbout);
			playWelcomeAudio();
		}
		
		private function onHideAppAbout(e:Event) {
			appAbout.removeEventListener(AppAbout.HIDE_ABOUT, onHideAppAbout);
			appAbout.addEventListener(AppAbout.SHOW_ABOUT, onShowAppAbout);
			removeWelcomeSound();
		}
		
		private function onChangeLanguageClick(e:MouseEvent) {
			switch (language.getLanguageType()) {
				case "CHT":
					language.setLanguage("ENU");
				break;
				case "ENU":
					language.setLanguage("JPN");
				break;
				case "JPN":
					language.setLanguage("CHT");
				break;
			}
			setButtonLabel();
		}
		
		private function onHomeMenuButtonClick(e:MouseEvent) {
			if (e.target.parent is IntoGuidanceButton) eventChannel.writeEvent(new Event(Home.CLICK_INTO_GUIDANCE));
			if (e.target.parent is QrCodeButton)       eventChannel.writeEvent(new Event(Home.CLICK_QRCODE));;
			if (e.target.parent is TakePhotoButton)    eventChannel.writeEvent(new Event(Home.CLICK_CHECK_IN));;
			if (e.target.parent is TrafficButton)      eventChannel.writeEvent(new Event(Home.CLICK_TRAFFIC));;
		}

	}
	
}
