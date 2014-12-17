package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	public class Titlebar extends EventDispatcher {

		public static const TITLE_BUTTON_TYPE_NONE:String = "Titlebar.TITLE_BUTTON_TYPE_NONE";
		public static const TITLE_BUTTON_TYPE_HOME:String = "TitlebarHomeButton";
		public static const TITLE_BUTTON_TYPE_BACK:String = "TitlebarBackButton";
		public static const TITLE_BUTTON_TYPE_SIDE_MENU:String = "TitlebarSideMenuButton";
		public static const TITLE_BUTTON_TYPE_QRCODE:String = "TitlebarQrCodeButton";
		public static const TITLE_BUTTON_TYPE_OK:String = "TitlebarOkButton";
		public static const TITLE_BUTTON_TYPE_CAMERA:String = "TitlebarCameraButton";
		public static const TITLE_BUTTON_LOCATION_LEFT  : String = "Titlebar.TITLE_BUTTON_LOCATION_LEFT";
		public static const TITLE_BUTTON_LOCATION_RIGHT : String = "Titlebar.TITLE_BUTTON_LOCATION_RIGHT";
		public static const CLICK_BACK:String = "Titlebar.CLIC_BACK";
		public static const CLICK_QRCODE:String = "Titlebar.CLICK_QRCODE";
		public static const CLICK_HOME:String = "Titlebar.CLICK_HOME";
		public static const CLICK_SIDE_MENU_COLUMN:String = "Titlebar.CLICK_SIDE_MENU_COLUMN";
		public static const CLICK_OK:String = "Titlebar.CLICK_OK";
		public static const CLICK_CAMERA:String = "Titlebar.CLICK_Camera";
		public static const SHOW_SIDEMENU:String = "Titlebar.SHOW_SIDEMENU";
		public static const HIDE_SIDEMENU:String = "Titlebar.SHOW_SIDEMENU";
		public static const SIDEMENU_CLOSE:String = "Titlebar.SIDEMENU_CLOSE";
		private static var _instance:Titlebar = null;
		
		private const intDefaultWidth:int = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:int = (LayoutManager.useIphone5Layout()) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		private var intStageWidth:Number = LayoutManager.intScreenWidth;
		private var intStageHeight:Number = LayoutManager.intScreenHeight;
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		
		private var container:DisplayObjectContainer = null;
		private var titleBarContainer:Sprite = null;
		private var titlebarBanner:MovieClip = null;
		public var intTitlebarHeight:int = 0;
		private var intTitlebarMoveY:int = 0;
		private var btnLeft:SimpleButton = null;
		private var btnRight:SimpleButton = null;
		private var btnLeftFunction:Function = null;
		private var btnRightFunction:Function = null;

		public static function getInstance():Titlebar {
			if (_instance == null) _instance = new Titlebar();
			return _instance;
		}
		
		public function initTitleBar(containerIn:DisplayObjectContainer) {
			container = containerIn;
			titleBarContainer = new Sprite();
			container.addChild(titleBarContainer);
			createBanner();
			titleBarContainer.y = -intTitlebarMoveY;
			
//			createSideMenu();
		}
		
		public function dispose() {
		}
		
		private function createBanner() {
			titlebarBanner = new TitlebarBanner();
			intTitlebarMoveY = intTitlebarHeight = titlebarBanner.height;
			titleBarContainer.addChild(titlebarBanner);
		}
		
		public function setTitlebar(strTitle:String, strLeftButtonType:String, strRightButtonType:String = TITLE_BUTTON_TYPE_NONE) {
			setTitle(strTitle);
			setButton(strLeftButtonType, TITLE_BUTTON_LOCATION_LEFT);
			setButton(strRightButtonType, TITLE_BUTTON_LOCATION_RIGHT);
		}
		
		public function setTitle(strTitle:String) {
			titlebarBanner.label.text = strTitle;
			var textFormat:TextFormat = titlebarBanner.label.getTextFormat();
			if (titlebarBanner.label.numLines == 1) textFormat.size = 30;
			if (titlebarBanner.label.numLines > 1)  textFormat.size = 25;
			
			titlebarBanner.label.setTextFormat(textFormat);
			
			if (titlebarBanner.label.numLines == 1) {
				titlebarBanner.label.height = 43.9;
				titlebarBanner.label.y = 20.75;
			}
			if (titlebarBanner.label.numLines > 1) {
				titlebarBanner.label.height = 70.5;
				titlebarBanner.label.y = 8.75;
			}
		}
		
		private function setButton(strButtonType:String, strButtonLocation:String) {
			var oldButton:SimpleButton;
			var newButton:SimpleButton;
			
			oldButton = titleBarContainer.getChildByName(strButtonLocation) as SimpleButton;
			
			if (oldButton) {
				oldButton.removeEventListener(MouseEvent.CLICK, onClickButton);
				titleBarContainer.removeChild(oldButton);
				oldButton = null;
			}
			
			if (strButtonType != TITLE_BUTTON_TYPE_NONE) {
				var classButton = getDefinitionByName(strButtonType) as Class;
				newButton = new classButton();
				newButton.addEventListener(MouseEvent.CLICK, onClickButton);
				newButton.name = strButtonLocation;
				titleBarContainer.addChild(newButton);
			
				if (strButtonLocation == TITLE_BUTTON_LOCATION_LEFT) {
					btnLeftFunction = getTitleButtonDefaultHandler(strButtonType);
				}
			
				if (strButtonLocation == TITLE_BUTTON_LOCATION_RIGHT) {
					newButton.x = 550;
					btnRightFunction = getTitleButtonDefaultHandler(strButtonType);
				}
			}
		}
		
		private function getTitleButtonDefaultHandler(strButtonType:String):Function {
			var func:Function = null;
			switch (strButtonType) {
				case TITLE_BUTTON_TYPE_HOME:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_HOME));
					};
				break;
				case TITLE_BUTTON_TYPE_BACK:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_BACK));
					};
				break;
				case TITLE_BUTTON_TYPE_QRCODE:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_QRCODE));
					};
				break;
				case TITLE_BUTTON_TYPE_OK:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_OK));
					};
				break;
				case TITLE_BUTTON_TYPE_CAMERA:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_CAMERA));
					};
				break;
			}
			return func;
		}
		
		private function onClickButton(e:MouseEvent) {
			var strButtonLocation:String = e.target.name;
			if (strButtonLocation == TITLE_BUTTON_LOCATION_LEFT && btnLeftFunction != null) {
				btnLeftFunction();
			} else if (strButtonLocation == TITLE_BUTTON_LOCATION_RIGHT && btnRightFunction != null) {
				btnRightFunction();
			} else {
				trace("Titlenbar.as / onClickButton: No handler");
			}
		}
		
		public function showTitlebar() {
			titleBarContainer.visible = true;
			if (titleBarContainer.y != 0) TweenLite.to(titleBarContainer, 0.5, {y:0, ease:Strong.easeOut});
		}
		
		public function hideTitlebar() {
			if (titleBarContainer.y != -intTitlebarMoveY) TweenLite.to(titleBarContainer, 0.5, {y:-intTitlebarMoveY, ease:Strong.easeOut, onComplete:invisibleTitlebar});
		}
		
		private function invisibleTitlebar() {
			titleBarContainer.visible = false;
		}
		
		private function forDynamicCreate() {
			var homeButton:TitlebarHomeButton = null;
			var backButton:TitlebarBackButton = null;
			var sideMenuButton:TitlebarSideMenuButton = null;
			var qrCodeButton:TitlebarQrCodeButton = null;
			var okButton:TitlebarOkButton = null;
			var cameraButton:TitlebarCameraButton = null;
		}
	}
	
}
