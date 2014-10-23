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
	import tw.cameo.Navigator;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;
	import LoadingScreen;
	import flash.text.StyleSheet;
	import flash.display.DisplayObject;
	
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
		private var textContainer:Sprite = null;
		private var titleFormat:TextFormat = null;
		private var contentFormat:TextFormat = null;
		private var intCurrentContentHeight:Number = 40;
		private var intTitleSpace:int = 10;
		private var intContentSpace:int = 60;
		
		private var dragAndSlide:DragAndSlide = null;
		
		public function Traffic(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			eventChannel.addEventListener(Navigator.TWEEN_COMPLETE, onTweenComplete);
		}
		
		private function onTweenComplete(e:Event) {
			eventChannel.removeEventListener(Navigator.TWEEN_COMPLETE, onTweenComplete);
			initInfo();
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			titlebar.setTitlebar(i18n.get("Traffic"), Titlebar.TITLE_BUTTON_TYPE_HOME, Titlebar.TITLE_BUTTON_TYPE_NONE);
			titlebar.showTitlebar();
			guidanceTool.hideGuidanceTool();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initTextFieldContainer();
			initTextFormat();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeTextFieldContainer();
			removeLoadingScreen();
			removeBackground();
			contentFormat = null;
			eventChannel.removeEventListener(Navigator.TWEEN_COMPLETE, onTweenComplete);
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
		
		private function initTextFieldContainer() {
			initLoadingScreen();
			textContainer = new Sprite();
			textContainer.x = 90;
			var textContainerBg:Sprite = new Sprite();
			textContainerBg.graphics.beginFill(0, 0);
			textContainerBg.graphics.drawRect(0, 0, 320, 1);
			textContainerBg.graphics.endFill();
			textContainer.addChild(textContainerBg);
			this.addChild(textContainer);
			textContainer.y = titlebar.intTitlebarHeight;
		}
		
		private function removeTextFieldContainer() {
			dragAndSlide.dispose();
			dragAndSlide = null;
			this.removeChild(textContainer);
			textContainer.removeChildren();
			textContainer = null;
		}
		
		private function initTextFormat() {
			titleFormat = new TextFormat();
			titleFormat.size = 40;
			titleFormat.font = "Arial, _san";
			titleFormat.color = 0x330000;
			titleFormat.bold = true;
			
			contentFormat = new TextFormat();
			contentFormat.size = 35;
			contentFormat.font = "Arial, _san";
			contentFormat.color = 0x000000;
			contentFormat.leading = 6;
			contentFormat.bold = true;
		}
		
		private function initInfo() {
			textContainer.addChild(newTitleMovieClip(i18n.get("Traffic_Info_Location_Title")));
			textContainer.addChild(newContentText(i18n.get("Traffic_Info_Location_Content")));
			
			textContainer.addChild(newTitleMovieClip(i18n.get("Traffic_Info_Tel_Title")));
			textContainer.addChild(newContentText(i18n.get("Traffic_Info_Tel_Content")));
			
			textContainer.addChild(newTitleMovieClip(i18n.get("Traffic_Info_Title")));
			textContainer.addChild(newContentText(i18n.get("Traffic_Info_Content")));
			
			textContainer.addChild(newTitleMovieClip(i18n.get("Traffic_Info_Open_Title")));
			textContainer.addChild(newContentText(i18n.get("Traffic_Info_Open_Content")));
			
			var showInfoTimer:Timer = new Timer(300, 1);
			showInfoTimer.addEventListener(TimerEvent.TIMER, onShowInfoTimer);
			showInfoTimer.start();
		}
		
		private function newTitleMovieClip(strLabel:String):MovieClip {
			var addressTitle:MovieClip = new TrafficContentTitle();
			addressTitle.label.text = strLabel;
			addressTitle.label.setTextFormat(titleFormat);
			addressTitle.y = intCurrentContentHeight;
			intCurrentContentHeight += addressTitle.height + intTitleSpace;
			
			return addressTitle;
		}
		
		private function newContentText(strContent:String):TextField {
			var contentText:TextField = new TextField();
			
			contentText.width = 460;
			contentText.multiline = true;
			contentText.wordWrap = true;
			contentText.autoSize = TextFieldAutoSize.LEFT;
			contentText.selectable = contentText.mouseEnabled = false;
			contentText.text = strContent;
			contentText.setTextFormat(contentFormat);
			contentText.alpha = 0.7;
			contentText.y = intCurrentContentHeight;
			intCurrentContentHeight += contentText.height + intContentSpace;

			return contentText;
		}
		
		private function onShowInfoTimer(e:TimerEvent) {
			var showInfoTimer:Timer = e.target as Timer;
			showInfoTimer.removeEventListener(TimerEvent.TIMER, onShowInfoTimer);
			showInfoTimer.stop();
			showInfoTimer = null;
			
			removeLoadingScreen();
			adjustContentPositionAndAddControl();
		}
		
		private function adjustContentPositionAndAddControl() {
			for (var i:int = 2; i<textContainer.numChildren; i++) {
				var childBefore:DisplayObject = textContainer.getChildAt(i-1) as DisplayObject;
				var child:DisplayObject = textContainer.getChildAt(i) as DisplayObject;
				if (childBefore is TrafficContentTitle) {
					child.y = childBefore.y + childBefore.height + intTitleSpace;
				} else {
					child.y = childBefore.y + childBefore.height + intContentSpace;
				}
			}
			
			dragAndSlide = new DragAndSlide(textContainer, intDefaultHeight-titlebar.intTitlebarHeight, "Vertical", true);
		}

	}
	
}
