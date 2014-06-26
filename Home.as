﻿package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.SimpleButton;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	
	import I18n;
	import Language;

	public class Home extends MovieClip {
		
		public static const CLICK_INTO_GUIDANCE:String = "Home.CLICK_INTO_GUIDANCE";
		public static const CLICK_QRCODE:String = "Home.CLICK_QRCODE";
		public static const CLICK_CHECK_IN:String = "Home.CLICK_CHECK_IN";
		public static const CLICK_TRAFFIC:String = "Home.CLICK_TRAFFIC";
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();

		private var bg:Sprite = null;
		
		private var btnChangeLanguage:MovieClip = null;
		private var pointBtnChangeLanguage:Point = new Point(528, 30);
		
		private var btnIntoGuidance:MovieClip = null;
		private var pointBtnIntoGuidance:Point = new Point(178, (isIphone5Layout) ? 282 : 282);
		
		private var btnQrCode:MovieClip = null;
		private var pointBtnQrCode:Point = new Point(471, (isIphone5Layout) ? 282 : 282);
		
		private var btnTakePhoto:MovieClip = null;
		private var pointBtnTakePhoto:Point = new Point(178, (isIphone5Layout) ? 594 : 594);
		
		private var btnTraffic:MovieClip = null;
		private var pointBtnTraffic:Point = new Point(471, (isIphone5Layout) ? 594 : 594);
		
		public function Home(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			createButton();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeButton();
			removeBackground();
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
		
		private function createButton() {
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
			addButtonEventListener();
			addButtonToStage();
		}
		
		private function setButtonLabel() {
			btnChangeLanguage.gotoAndStop(language.getLanguageType());
			btnIntoGuidance.label.text = i18n.get("IntoGuidance");
			btnQrCode.label.text = i18n.get("QrCode");
			btnTakePhoto.label.text = i18n.get("CheckIn");
			btnTraffic.label.text = i18n.get("Traffic");
		}
		
		private function addButtonToStage() {
			this.addChild(btnChangeLanguage);
			this.addChild(btnIntoGuidance);
			this.addChild(btnQrCode);
			this.addChild(btnTakePhoto);
			this.addChild(btnTraffic);
		}
		
		private function removeButtonFromStage() {
			this.removeChild(btnChangeLanguage);
			this.removeChild(btnIntoGuidance);
			this.removeChild(btnQrCode);
			this.removeChild(btnTakePhoto);
			this.removeChild(btnTraffic);
			
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
			btnChangeLanguage.addEventListener(MouseEvent.CLICK, onChangeLanguageClick);
			btnIntoGuidance.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnQrCode.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTakePhoto.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTraffic.addEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
		}
		
		private function removeButtonEventListener() {
			btnChangeLanguage.removeEventListener(MouseEvent.CLICK, onChangeLanguageClick);
			btnIntoGuidance.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnQrCode.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTakePhoto.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
			btnTraffic.removeEventListener(MouseEvent.CLICK, onHomeMenuButtonClick);
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