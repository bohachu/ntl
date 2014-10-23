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
	
	import I18n;
	import Language;
	import MappingData;
	import SideMenu;
	
	public class Titlebar extends EventDispatcher {

		public static const TITLE_BUTTON_TYPE_NONE:String = "Titlebar.TITLE_BUTTON_TYPE_NONE";
		public static const TITLE_BUTTON_TYPE_HOME:String = "TitlebarHomeButton";
		public static const TITLE_BUTTON_TYPE_BACK:String = "TitlebarBackButton";
		public static const TITLE_BUTTON_TYPE_SIDE_MENU:String = "TitlebarSideMenuButton";
		public static const TITLE_BUTTON_TYPE_QRCODE:String = "TitlebarQrCodeButton";
		public static const TITLE_BUTTON_TYPE_OK:String = "TitlebarOkButton";
		public static const TITLE_BUTTON_LOCATION_LEFT  : String = "Titlebar.TITLE_BUTTON_LOCATION_LEFT";
		public static const TITLE_BUTTON_LOCATION_RIGHT : String = "Titlebar.TITLE_BUTTON_LOCATION_RIGHT";
		public static const CLICK_BACK:String = "Titlebar.CLIC_BACK";
		public static const CLICK_QRCODE:String = "Titlebar.CLICK_QRCODE";
		public static const CLICK_HOME:String = "Titlebar.CLICK_HOME";
		public static const CLICK_SIDE_MENU_COLUMN:String = "Titlebar.CLICK_SIDE_MENU_COLUMN";
		public static const CLICK_OK:String = "Titlebar.CLICK_OK";
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
		private var sideMenuContainer:Sprite = null;
		private var titlebarBanner:MovieClip = null;
		public var intTitlebarHeight:int = 0;
		private var intTitlebarMoveY:int = 0;
		private var btnLeft:SimpleButton = null;
		private var btnRight:SimpleButton = null;
		private var btnLeftFunction:Function = null;
		private var btnRightFunction:Function = null;
		private var sideMenu:SideMenu = null;
		private var snapShotContainer:Sprite = null;

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
			
			createSideMenu();
		}
		
		public function dispose() {
			removeSideMenu();
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
			if (titlebarBanner.label.numLines == 1) textFormat.size = 35;
			if (titlebarBanner.label.numLines > 1)  textFormat.size = 30;
			
			titlebarBanner.label.setTextFormat(textFormat);
			
			if (titlebarBanner.label.numLines == 1) {
				titlebarBanner.label.height = 50.5;
				titlebarBanner.label.y = 21.75;
			}
			if (titlebarBanner.label.numLines > 1) {
				titlebarBanner.label.height = 83.8;
				titlebarBanner.label.y = 7.75;
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
				case TITLE_BUTTON_TYPE_SIDE_MENU:
					func = function() { 
						showSideMenu();
					};
				break;
				case TITLE_BUTTON_TYPE_OK:
					func = function() { 
						this.dispatchEvent(new Event(Titlebar.CLICK_OK));
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
		
		private function createSideMenu() {
			sideMenuContainer = new Sprite();
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0x79C1BA);
			bg.graphics.drawRect(0, 0, 640, 1136);
			bg.graphics.endFill();
			sideMenuContainer.addChild(bg);
			sideMenu = new SideMenu();
			sideMenu.addEventListener(SideMenu.CLICK_HOME, onClickHome);
			sideMenu.addEventListener(SideMenu.ITEM_UNCHANGE, onItemUnchange);
			sideMenu.addEventListener(SideMenu.ITME_CHANGED, onItemChanged);
			sideMenuContainer.addChild(sideMenu);
			sideMenuContainer.visible = false;
			container.addChild(sideMenuContainer);
		}
		
		private function removeSideMenu() {
			sideMenuContainer.removeChildren();
			container.removeChild(sideMenuContainer);
			sideMenu.removeEventListener(SideMenu.CLICK_HOME, onClickHome);
			sideMenu.removeEventListener(SideMenu.ITEM_UNCHANGE, onItemUnchange);
			sideMenu.removeEventListener(SideMenu.ITME_CHANGED, onItemChanged);
			sideMenu = null;
			sideMenuContainer = null;
		}
		
		private function showSideMenu() {
			snapShotContainer = new Sprite();
			var snapShotShadow:Sprite = new SideMenuSnapShotShadow();
			snapShotShadow.height = intDefaultHeight;
			snapShotShadow.scaleX = -1;
			snapShotShadow.x = 640;
			
			snapShotContainer.addChild(snapShotShadow);
			var snapShotBitmapData:BitmapData = new BitmapData(intDefaultWidth, intDefaultHeight, false, 0);
			snapShotBitmapData.draw(container.stage, new Matrix(intDefaultWidth/intStageWidth, 0, 0, intDefaultHeight/intStageHeight));
			var snapShotBitmap:Bitmap = new Bitmap(snapShotBitmapData);
			snapShotBitmap.smoothing = true;
			snapShotContainer.addChild(snapShotBitmap);
			
			container.addChild(snapShotContainer);
			sideMenuContainer.visible = true;
			TweenLite.to(snapShotContainer, 0.6, {x:530, ease:Strong.easeOut});
			this.dispatchEvent(new Event(Titlebar.SHOW_SIDEMENU));
			snapShotContainer.addEventListener(MouseEvent.CLICK, onClickSnapShot);
		}
		
		private function onClickSnapShot(e:MouseEvent) {
			hideSideMenu();
		}
		
		public function hideSideMenu() {
			TweenLite.to(snapShotContainer, 0.6, {x:0, ease:Strong.easeOut, onComplete:removeShapShot});
		}
		
		private function removeShapShot() {
			this.dispatchEvent(new Event(Titlebar.HIDE_SIDEMENU));
			if (snapShotContainer) {
				snapShotContainer.removeEventListener(MouseEvent.CLICK, onClickSnapShot);
				container.removeChild(snapShotContainer);
				snapShotContainer = null;
			}
			sideMenuContainer.visible = false;
		}
		
		private function onClickHome(e:Event) {
			TweenLite.to(snapShotContainer, 0.6, {x:0, ease:Strong.easeOut, onComplete:closeWithClickHome});
		}
		
		private function onItemUnchange(e:Event) {
			TweenLite.to(snapShotContainer, 0.6, {x:0, ease:Strong.easeOut, onComplete:removeShapShot});
		}
		
		private function onItemChanged(e:Event) {
			TweenLite.to(snapShotContainer, 0.6, {x:0, ease:Strong.easeOut, onComplete:closeWithItemChanged});
			this.dispatchEvent(new Event(Titlebar.CLICK_SIDE_MENU_COLUMN));
		}
		
		private function closeWithClickHome() {
			removeShapShot();
			this.dispatchEvent(new Event(Titlebar.CLICK_HOME));
		}
		
		private function closeWithItemChanged() {
			removeShapShot();
			eventChannel.writeEvent(new Event(Titlebar.SIDEMENU_CLOSE));
		}
		
		public function showTitlebar() {
			titleBarContainer.visible = true;
			if (titleBarContainer.y != 0) TweenLite.to(titleBarContainer, 0.5, {y:0, ease:Strong.easeOut});
		}
		
		public function hideTitlebar() {
			if (titleBarContainer.y != -intTitlebarMoveY) TweenLite.to(titleBarContainer, 0.5, {y:-intTitlebarMoveY, ease:Strong.easeOut, onComplete:invisibleTitlebar});
		}
		
		public function getClickSideMenuColumn():String {
			return sideMenu.getCurrentSelectedColumnName();
		}
		
		public function setSideMenuColumn(strColumnName:String) {
			sideMenu.setSelectColumn(strColumnName);
		}
		
		public function isSideMenuOpen():Boolean {
			return sideMenuContainer.visible;
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
		}
	}
	
}
