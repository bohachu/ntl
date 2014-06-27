package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.EventDispatcher;
	
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import I18n;
	import Language;
	
	public class Titlebar extends EventDispatcher {

		public static const NO_BUTTON:String = "Titlebar.NO_BUTTON";
		public static const BACK_BUTTON:String = "Titlebar.BACK_BUTTON";
		public static const SIDE_MENU_BUTTON:String = "Titlebar.SIDE_MENU";
		public static const QRCODE_BUTTON:String = "Titlebar.QRCODE_BUTTON";
		
		private static var _instance:Titlebar = null;
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		
		private var container:DisplayObjectContainer = null;
		private var titleBarContainer:Sprite = null;
		private var bg:MovieClip = null;
		private var btnLeft:SimpleButton = null;
		private var btnRight:SimpleButton = null;

		public static function getInstance():Titlebar {
			if (_instance == null) _instance = new Titlebar();
			return _instance;
		}
		
		public function initTitleBar(containerIn:DisplayObjectContainer) {
			container = containerIn;
			titleBarContainer = new Sprite();
			container.addChild(titleBarContainer);
			createBackground();
			titleBarContainer.y = -titleBarContainer.height;
		}
		
		private function createBackground() {
			bg = new TitlebarBackground();
			titleBarContainer.addChild(bg);
		}
		
		public function setTitlebar(strTitle:String, strLeftButtonType:String, strRightButtonType:String = "") {
			if (strTitle != "") setTitle(strTitle);
		}
		
		public function setTitle(strTitle:String) {
			bg.label.text = i18n.get(strTitle);
		}
		
		public function showTitlebar() {
			if (titleBarContainer.y != 0) TweenLite.to(titleBarContainer, 0.5, {y:0, ease:Strong.easeOut});
		}
		
		public function hideTitlebar() {
			if (titleBarContainer.y != -titleBarContainer.height) TweenLite.to(titleBarContainer, 0.5, {y:-titleBarContainer.height, ease:Strong.easeOut});
		}
	}
	
}
