package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.DragAndSlide;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;
	import LoadingScreen;
	import flash.text.StyleSheet;
	
	public class Traffic extends MovieClip {

		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();

		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var infoTextField:TextField = null;
		private var textFormat:TextFormat = null;
		private var textContainer:Sprite = null;
		private var dragAndSlide:DragAndSlide = null;
		
		public function Traffic(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			titlebar.setTitlebar(i18n.get("Traffic"), Titlebar.TITLE_BUTTON_TYPE_BACK, Titlebar.TITLE_BUTTON_TYPE_NONE);
			titlebar.showTitlebar();
			guidanceTool.hideGuidanceTool();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initTextField();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeTextField();
			removeLoadingScreen();
			removeBackground();
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = new BackgroundSprite();
			var contentBg:Sprite = new ContentBg();
			bg.addChild(contentBg);
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function initTextField() {
			initLoadingScreen();
			textContainer = new Sprite();
			var textContainerBg:Sprite = new Sprite();
			textContainerBg.graphics.beginFill(0, 0);
			textContainerBg.graphics.drawRect(0, 0, 640, 640);
			textContainerBg.graphics.endFill();
			textContainer.addChild(textContainerBg);
			this.addChild(textContainer);
			textContainer.y = titlebar.intTitlebarHeight;
			textFormat = new TextFormat();
			infoTextField = new TextField();
			infoTextField.width = 425;
			infoTextField.multiline = true;
			infoTextField.wordWrap = true;
			infoTextField.autoSize = TextFieldAutoSize.LEFT;
			infoTextField.selectable = false;
			textFormat.size = 35;
			textFormat.font = "Arial, _san";
			textFormat.color = 0x003366;
			textFormat.leading = 6;
			infoTextField.setTextFormat(textFormat);
			infoTextField.x = 105;
			infoTextField.y = 40;
			textContainer.addChild(infoTextField);
			
			var showInfoTimer:Timer = new Timer(300, 1);
			showInfoTimer.addEventListener(TimerEvent.TIMER, onShowInfoTimer);
			showInfoTimer.start();
		}
		
		private function removeTextField() {
			dragAndSlide.dispose();
			dragAndSlide = null;
			this.addChild(textContainer);
			textContainer.removeChild(infoTextField);
			infoTextField = null;
			textContainer = null;
			textFormat = null;
		}
		
		private function onShowInfoTimer(e:TimerEvent) {
			var showInfoTimer:Timer = e.target as Timer;
			showInfoTimer.removeEventListener(TimerEvent.TIMER, onShowInfoTimer);
			showInfoTimer.stop();
			showInfoTimer = null;
			
			removeLoadingScreen();
			showTrafficInfo();
		}
		
		private function showTrafficInfo() {
			var strInfo:String = i18n.get("Traffic_Info");

			infoTextField.text = strInfo;
			infoTextField.setTextFormat(textFormat);
			dragAndSlide = new DragAndSlide(textContainer, intDefaultHeight-titlebar.intTitlebarHeight, "Vertical", true);
		}

	}
	
}
