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
	import flash.text.StyleSheet;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.DisplayObjectContainer;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.DragAndSlide;
	import tw.cameo.Navigator;
	import tw.cameo.ILoadData;
	import tw.cameo.net.HttpLink;
	
	import com.greensock.TweenLite;
	
	public class Traffic extends MovieClip implements ILoadData {

		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();

		private var bgClear:Sprite = null;
		private var bgBlur:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var textContainer:Sprite = null;
		private var titleFormat:TextFormat = null;
		private var contentFormat:TextFormat = null;
		private var linkContentFormat:TextFormat = null;
		
		private const intContentBgWidth:int = 610;
		private const intContentWidth:int = 560;
		private const intContentWithPicWidth:int = 430;
		private const intContentMargin:int = 25;
		private const intContentBlockSpacing:int = 25;
		private const intContentStartXWithPic:int = 130;
		
		private var lstContentBlock:Array = null;
		
		private var intCurrentContentHeight:Number = 40;
		private var intTitleSpace:int = 10;
		private var intContentSpace:int = 60;
		
		private var dragAndSlide:DragAndSlide = null;
		
		public function Traffic(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
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
			createClearBackground();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeTextFieldContainer();
			removeLoadingScreen();
			removeBlurBackground();
			removeClearBackground();
			contentFormat = null;
			lstContentBlock.length = 0;
			lstContentBlock = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createClearBackground() {
			bgClear = (isIphone5Layout) ? new TrafficBgIphone5Clear() : new TrafficBgIphone4Clear();
			this.addChild(bgClear);
		}
		
		private function removeClearBackground() {
			if (bgClear == null) return;
			this.removeChild(bgClear);
			bgClear = null;
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		public function loadData():void {
			initLoadingScreen();
			var loadDataTimer:Timer = new Timer(1500, 1);
			loadDataTimer.addEventListener(TimerEvent.TIMER, onLoadDataTimer);
			loadDataTimer.start();
		}
		
		private function onLoadDataTimer(e:TimerEvent) {
			var loadDataTimer:Timer = e.target as Timer;
			loadDataTimer.removeEventListener(TimerEvent.TIMER, onLoadDataTimer);
			loadDataTimer.stop();
			
			showBlurBg();
			initTextFieldContainer();
			initTextFormat();
			initInfo();
		}
		
		private function showBlurBg() {
			bgBlur = (isIphone5Layout) ? new TrafficBgIphone5Blur() : new TrafficBgIphone4Blur();
			bgBlur.alpha = 0;
			this.addChild(bgBlur);
			TweenLite.to(bgBlur, 1, {alpha:1, onComplete:removeClearBackground});
		}
		
		private function removeBlurBackground() {
			if (bgBlur == null) return;
			this.removeChild(bgBlur);
			bgBlur = null;
		}
		
		private function initTextFieldContainer() {
			textContainer = new Sprite();
			textContainer.x = 15;
			var textContainerBg:Sprite = new Sprite();
			textContainerBg.graphics.beginFill(0, 0);
			textContainerBg.graphics.drawRect(0, 0, intContentBgWidth, 1);
			textContainerBg.graphics.endFill();
			textContainer.addChild(textContainerBg);
			
			var textContainerMask:Shape = new Shape();
			textContainerMask.graphics.beginFill(0, 0);
			textContainerMask.graphics.drawRect(0, 0, 640, 1136);
			textContainerMask.graphics.endFill();
			textContainerMask.y = titlebar.intTitlebarHeight;
			textContainerMask.cacheAsBitmap = true;
			this.addChild(textContainerMask);
			
			textContainer.mask = textContainerMask;
			textContainer.addChild(textContainerBg);
		
			textContainer.alpha = 0;
			this.addChild(textContainer);
			textContainer.y = titlebar.intTitlebarHeight;
		}
		
		private function removeTextFieldContainer() {
			dragAndSlide.dispose();
			dragAndSlide = null;
			this.removeChild(textContainer);
			textContainer.mask = null;
			textContainer.removeChildren();
			textContainer = null;
		}
		
		private function initTextFormat() {
			titleFormat = new TextFormat();
			titleFormat.size = 35;
			titleFormat.font = "Arial, Helvetica, _san, _serif, _typewriter";
			titleFormat.color = 0xFFFFFF;
			titleFormat.bold = true;
			
			contentFormat = new TextFormat();
			contentFormat.size = 30;
			contentFormat.font = "Arial, Helvetica, _san, _serif, _typewriter";
			contentFormat.color = 0xFFFFFF;
			contentFormat.leading = 6;
			
			linkContentFormat = new TextFormat();
			linkContentFormat.size = 30;
			linkContentFormat.font = "Arial, Helvetica, _san, _serif, _typewriter";
			linkContentFormat.color = 0x0099FF;
			linkContentFormat.leading = 6;
			linkContentFormat.bold = true;
			linkContentFormat.underline = true;
				
			if (language.getLanguageType() == "CHT" || language.getLanguageType() == "JPN") {
				titleFormat.letterSpacing = 5;
				titleFormat.leading = 10;
				contentFormat.letterSpacing = 5;
				contentFormat.leading = 10;
				linkContentFormat.letterSpacing = 5;
				linkContentFormat.leading = 10;
			}
		}
		
		private function initInfo() {
			lstContentBlock = new Array();
			
			createAddressBlock();
			createTeleponeBlock();
			createTrafficInfoBlock();
			createTimeInfoBlock();
			createRentalInfoBlock();
			
			var showInfoTimer:Timer = new Timer(300, 1);
			showInfoTimer.addEventListener(TimerEvent.TIMER, onShowInfoTimer);
			showInfoTimer.start();
		}
		
		private function createAddressBlock() {
			var infoBlock:Sprite = createInfoBlock();
			textContainer.addChild(infoBlock);
			
			newTitleMovieClip(infoBlock, i18n.get("Traffic_Info_Location_Title"));
			newContentWithPicFrontSprite(infoBlock, new IconAddress(), i18n.get("Traffic_Info_Location_Content"));
		}
		
		private function createTeleponeBlock() {
			var infoBlock:Sprite = createInfoBlock();
			textContainer.addChild(infoBlock);
			
			newTitleMovieClip(infoBlock, i18n.get("Traffic_Info_Tel_Title"));
			newContentWithPicFrontSprite(infoBlock, new IconPhone(), i18n.get("Traffic_Info_Tel_Content"));
		}
		
		private function createTrafficInfoBlock() {
			var infoBlock:Sprite = createInfoBlock();
			textContainer.addChild(infoBlock);
			
			newTitleMovieClip(infoBlock, i18n.get("Traffic_Info_Title"));
			createIcon(infoBlock, new IconMrtToBus());
			newContentText(infoBlock, i18n.get("Traffic_Info_Content_1"));
			createDashLine(infoBlock);
			createIcon(infoBlock, new IconBus());
			newContentText(infoBlock, i18n.get("Traffic_Info_Content_2"));
		}
		
		private function createTimeInfoBlock() {
			var infoBlock:Sprite = createInfoBlock();
			textContainer.addChild(infoBlock);
			
			newTitleMovieClip(infoBlock, i18n.get("Traffic_Info_Open_Title"));
			newContentWithPicFrontSprite(infoBlock, new IconTime(), i18n.get("Traffic_Info_Open_Content_1"));
			createDashLine(infoBlock);
			newContentText(infoBlock, i18n.get("Traffic_Info_Open_Content_2"));
			createDashLine(infoBlock);
			newContentText(infoBlock, i18n.get("Traffic_Info_Open_Content_3"));
		}
		
		private function createRentalInfoBlock() {
			var infoBlock:Sprite = createInfoBlock();
			textContainer.addChild(infoBlock);
			
			newTitleMovieClip(infoBlock, i18n.get("Rental_Info_Title"));
			newContentText(infoBlock, i18n.get("Rental_Info_1"));
			newLinkContentText(infoBlock, i18n.get("Rental_Info_2"));
			createDashLine(infoBlock);
			newContentText(infoBlock, i18n.get("Rental_Info_3"));
		}
		
		private function createInfoBlock():Sprite {
			var infoBlock:Sprite = new Sprite();
			var infoBlockBg:Shape = new Shape();
			infoBlockBg.graphics.beginFill(0, 0.5);
			infoBlockBg.graphics.drawRect(0, 0, intContentBgWidth, 10);
			infoBlockBg.graphics.endFill();
			infoBlockBg.name = "bg";
			infoBlock.addChild(infoBlockBg);
			
			return infoBlock;
		}
		
		private function newTitleMovieClip(container:Sprite, strLabel:String) {
			var titleMovieClip:MovieClip = new TrafficContentTitle();
			titleMovieClip.label.text = "【 " + strLabel + " 】";
			titleMovieClip.label.setTextFormat(titleFormat);
			titleMovieClip.x = intContentMargin;
			titleMovieClip.y = intContentMargin;
			container.addChild(titleMovieClip);
		}
		
		private function newContentWithPicFrontSprite(container:Sprite, iconSprite:Sprite, strContent:String) {
			var contentSprite:Sprite = new Sprite();
			contentSprite.addChild(iconSprite);
			var contentTextField:TextField = createContentText(strContent, true);
			contentTextField.name = "textField";
			contentTextField.x = intContentStartXWithPic;
			contentSprite.addChild(contentTextField);
			contentSprite.x = intContentMargin;
			contentSprite.y = container.height + intContentMargin;
			container.addChild(contentSprite);
			contentTextField.height = contentTextField.textHeight;
		}
		
		private function newContentText(container:Sprite, strContent:String) {
			var contentText:TextField = createContentText(strContent, false);
			contentText.x = intContentMargin;
			contentText.y = container.height + intContentMargin;
			container.addChild(contentText);
			contentText.height = contentText.textHeight;
		}
		
		private function newLinkContentText(container:Sprite, strContent:String) {
			var linkContainer:Sprite = new Sprite();
			var contentText:TextField = createContentText(strContent, false, true);
			contentText.x = intContentMargin;
			contentText.y = container.height + intContentMargin;
			linkContainer.addChild(contentText);
			linkContainer.addEventListener(MouseEvent.CLICK, function openUrl(e:MouseEvent) {
				HttpLink.openUrl(strContent);
			});
			container.addChild(linkContainer);
			contentText.height = contentText.textHeight;
		}
		
		private function createContentText(strContent:String, isWithPicFrom:Boolean = false, isLink:Boolean = false):TextField {
			var contentText:TextField = new TextField();
			
			var intContentTextWidth:int = (isWithPicFrom) ? intContentWithPicWidth : intContentWidth;
			contentText.width = intContentTextWidth*LayoutManager.intScaleX;
			contentText.multiline = true;
			contentText.wordWrap = true;
			contentText.autoSize = TextFieldAutoSize.LEFT;
			contentText.selectable = contentText.mouseEnabled = false;
			contentText.text = strContent;
//			trace(contentText.text, "====>", contentText.height);
			if (isLink) contentText.setTextFormat(linkContentFormat);
			if (!isLink) contentText.setTextFormat(contentFormat);
//			contentText.background = true;
//			contentText.backgroundColor = 0xFF0000;
//			trace(contentText.height, contentText.textHeight, contentText.numLines);
			contentText.width = intContentTextWidth;
//			trace(contentText.height, contentText.textHeight, contentText.numLines);
			TweenLite.delayedCall(0.5, adjustTextField, [contentText]);
			
			return contentText;
		}
		
		private function adjustTextField(contentText:TextField) {
//			trace(contentText.text, "====>");
//			trace(contentText.height, contentText.textHeight, contentText.numLines);
			contentText.autoSize = TextFieldAutoSize.NONE;
			if (contentText.textHeight > contentText.height) {
				contentText.height = contentText.textHeight + 10;
			} else {
				contentText.height += 10;
			}
//			trace(contentText.height, contentText.textHeight, contentText.numLines);
		}
		
		private function createIcon(container:Sprite, iconSprite:Sprite) {
			iconSprite.x = intContentMargin;
			iconSprite.y = container.height + intContentMargin;
			container.addChild(iconSprite);
		}
		
		private function createDashLine(container:Sprite) {
			var dashLine:Sprite = new DashLine();
			dashLine.x = intContentMargin;
			dashLine.y = container.height + intContentMargin;
			container.addChild(dashLine);
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
			for (var i:int = 1; i<textContainer.numChildren; i++) {
				var child:DisplayObjectContainer = textContainer.getChildAt(i) as DisplayObjectContainer;
				var childBg:Shape = child.getChildByName("bg") as Shape;
				childBg.height = child.height + intContentMargin;
				
				if (i != 1) {
					var childBefore:DisplayObject = textContainer.getChildAt(i-1) as DisplayObject;
					child.y = childBefore.y + childBefore.height + intContentBlockSpacing;
				}
			}
			
			dragAndSlide = new DragAndSlide(textContainer, intDefaultHeight-titlebar.intTitlebarHeight, "Vertical", false);
			TweenLite.to(textContainer, 1, {alpha:1});
		}

	}
	
}
