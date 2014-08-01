package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import com.greensock.BlitMask;
	import com.greensock.easing.*;
	import tw.cameo.DragAndSlide;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;
	import MappingData;
	import LoadingScreen;
	import GuideEvent;
	import LoadExhibitData;
	import SlideShow;
	import Utils;
	
	public class Guide extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (isIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		public var lstExhibitFolder:Array = null;
		private var intCurrentExhibitIndex:int = 0;
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var dicExhibitData:Object = null;
		private var soundAudio:Sound = null;
		private var lstPhoto:Array = null;
		private var slideShowContainer:Sprite = null;
		
		private var slideShowControlTool:MovieClip = null;
		private var pauseSprite:Sprite = null;
		
		private var isShowGuideText:Boolean = false;
		private var guideText:Sprite = null;
		private var guideTextContainer:Sprite = null;
		private var dragAndSlide:DragAndSlide = null;

		public function Guide(lstExhibitFolderIn:Array) {
			// constructor code
			lstExhibitFolder = lstExhibitFolderIn;
			titlebar.showTitlebar();
			guidanceTool.setType(GuidanceTool.GUIDE_BUTTON_TYPE2);
			guidanceTool.addEventListener(GuidanceTool.SHOW_GUIDE_TEXT_CLICK, onShowGuideTextClick);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			initSlideShowContainer();
			loadData();
		}
		
		private function destructor(e:Event) {
			Utils.keepAppIdleModeNormal();
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			guidanceTool.removeEventListener(GuidanceTool.SHOW_GUIDE_TEXT_CLICK, onShowGuideTextClick);
			removeGuideText();
			removePauseButton();
			removeControlTool();
			removeSlideShow();
			removeSlideShowContainer();
			removeLoadingScreen();
			removeBackground();
			lstExhibitFolder = null;
			dicExhibitData = null;
			soundAudio = null;
			lstPhoto = null;
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
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function initSlideShowContainer() {
			slideShowContainer = new Sprite();
			this.addChild(slideShowContainer);
		}
		
		private function removeSlideShowContainer() {
			this.removeChild(slideShowContainer);
			slideShowContainer = null;
		}
		
		private function loadData() {
			initLoadingScreen();
			var strFolder:String = lstExhibitFolder[intCurrentExhibitIndex];
			var loadExhibitData:LoadExhibitData = new LoadExhibitData(strFolder);
			loadExhibitData.addEventListener(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE, onLoadExhibitDataComplete);
			loadExhibitData.loadData();
		}
		
		private function onLoadExhibitDataComplete(e:Event) {
			var loadExhibitData:LoadExhibitData = e.target as LoadExhibitData;
			loadExhibitData.removeEventListener(LoadExhibitData.LOAD_EXHIBIT_DATA_COMPLETE, onLoadExhibitDataComplete);
			dicExhibitData = loadExhibitData.getExhibitInfo();
			lstPhoto = loadExhibitData.getImageList();
			soundAudio = loadExhibitData.getAudio();
			
//			titlebar.setTitlebar(dicExhibitData["Title_" + language.getLanguageType()], Titlebar.TITLE_BUTTON_TYPE_SIDE_MENU, Titlebar.TITLE_BUTTON_TYPE_QRCODE);
			titlebar.setTitlebar(dicExhibitData["Title_" + language.getLanguageType()], Titlebar.TITLE_BUTTON_TYPE_BACK, Titlebar.TITLE_BUTTON_TYPE_QRCODE);
			
			loadExhibitData.dispose();
			loadExhibitData = null;
			removeLoadingScreen();
			
			var slideShow:SlideShow = new SlideShow(dicExhibitData, lstPhoto, soundAudio);
			slideShow.addEventListener(SlideShow.PLAY_END, onSlideShowPlayEnd);
			
			playGuide(slideShow);
		}
		
		private function removeSlideShow() {
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			if (slideShow) {
				slideShow.removeEventListener(SlideShow.PLAY_END, onSlideShowPlayEnd);
				slideShowContainer.removeChild(slideShow);
			}
			slideShow = null;
		}
		
		private function onSlideShowPlayEnd(e:Event) {
			if (intCurrentExhibitIndex < lstExhibitFolder.length-1) {
				intCurrentExhibitIndex++;
				removePauseButton();
				loadData();
			} else {
				Utils.keepAppIdleModeNormal();
				showToolsAndRemovePauseButton();
			}
		}
		
		private function playGuide(slideShow:SlideShow) {
			if (slideShowContainer.numChildren != 0) {
				var oldSlideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
				oldSlideShow.removeEventListener(SlideShow.PLAY_END, onSlideShowPlayEnd);
				slideShowContainer.removeChild(oldSlideShow);
				oldSlideShow = null;
			}
			slideShowContainer.addChild(slideShow);
			hideToolsAndCreatePauseButton();
			slideShow.playSlideShow();
			Utils.keepAppIdleModeAwake();
		}
		
		private function createPauseButton() {
			pauseSprite = new Sprite();
			pauseSprite.graphics.beginFill(0, 0);
			pauseSprite.graphics.drawRect(0, 0, 640, 1136);
			pauseSprite.graphics.endFill();
			this.addChild(pauseSprite);
			pauseSprite.addEventListener(MouseEvent.CLICK, pauseSlideShow);
		}
		
		private function removePauseButton() {
			if (pauseSprite) {
				pauseSprite.removeEventListener(MouseEvent.CLICK, pauseSlideShow);
				this.removeChild(pauseSprite);
			}
			pauseSprite = null;
		}
		
		public function pauseSlideShow(e:MouseEvent = null) {
			showToolsAndRemovePauseButton();
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			slideShow.stopSlideShow();
			Utils.keepAppIdleModeNormal();
		}

		private function continuePlayGuide() {
			hideToolsAndCreatePauseButton();
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			slideShow.playSlideShow();
			Utils.keepAppIdleModeAwake();
		}
		
		private function showControlTool() {
			if (slideShowControlTool == null) {
				slideShowControlTool = new SlideShowControlTool();
				slideShowControlTool.y = (isIphone5Layout) ? 0 : -88;
				this.addChild(slideShowControlTool);
				slideShowControlTool.playButton.addEventListener(MouseEvent.CLICK, onClickPlayButton);
				slideShowControlTool.replayButton.addEventListener(MouseEvent.CLICK, onClickReplayButton);
			}
		}
		
		private function showToolsAndRemovePauseButton() {
			removePauseButton();
			titlebar.showTitlebar();
			guidanceTool.showGuidanceTool();
			showControlTool();
		}
		
		private function hideToolsAndCreatePauseButton() {
			removeControlTool();
			createPauseButton();
			titlebar.hideTitlebar();
			guidanceTool.hideGuidanceTool();
		}
		
		private function removeControlTool() {
			if (slideShowControlTool) {
				slideShowControlTool.playButton.removeEventListener(MouseEvent.CLICK, onClickPlayButton);
				slideShowControlTool.replayButton.removeEventListener(MouseEvent.CLICK, onClickReplayButton);
				this.removeChild(slideShowControlTool);
			}
			slideShowControlTool = null;
		}
		
		private function onClickPlayButton(e:MouseEvent) {
			continuePlayGuide();
		}
		
		private function onClickReplayButton(e:MouseEvent) {
			replayGuide();
		}
		
		private function onShowGuideTextClick(e:Event) {
			if (isShowGuideText) {
				hideGuideText();
			} else {
				showGuideText();
			}
		}
		
		public function showGuideText() {
			isShowGuideText = true;
			if (guideTextContainer == null) {
				guideTextContainer = new Sprite();
				guideTextContainer.addChild(new BackgroundSprite());
				guideTextContainer.addChild(new ContentBg());
				guideTextContainer.y = intDefaultHeight;
				
				guideText = new Sprite();
				guideText.x = 90;
				guideText.y = titlebar.intTitlebarHeight + 20;
				var textFormat:TextFormat = new TextFormat();
				textFormat.size = 40;
				textFormat.font = "Arial, _san";
				textFormat.color = 0x330000;
				
				var guideTextField:TextField = new TextField();
				guideTextField.width = 460;
				guideTextField.multiline = true;
				guideTextField.wordWrap = true;
				guideTextField.autoSize = TextFieldAutoSize.LEFT;
				guideTextField.selectable = guideTextField.mouseEnabled = false;
				guideTextField.text = Utils.removeDoubleQuote(dicExhibitData["Content_" + language.getLanguageType()]);
				guideTextField.setTextFormat(textFormat);
				guideText.addChild(guideTextField);
				guideTextContainer.addChild(guideText);
				this.addChild(guideTextContainer);
				
				dragAndSlide = new DragAndSlide(guideText, intDefaultHeight-titlebar.intTitlebarHeight-guidanceTool.intGuidanceToolHeight, "Vertical", true);
			}
			TweenLite.to(guideTextContainer, 1, {y:0, ease:Strong.easeOut, onComplete:setSlideShowInvisible});
		}
		
		private function setSlideShowInvisible() {
			slideShowContainer.visible = false;
		}
		
		public function hideGuideText() {
			isShowGuideText = false;
			slideShowContainer.visible = true;
			var textMask:Sprite = new Sprite();
			textMask.graphics.beginFill(0);
			textMask.graphics.drawRect(0, 0, 640, 1136);
			textMask.graphics.endFill();
			guideTextContainer.addChild(textMask);
			guideTextContainer.mask = textMask;
			TweenLite.to(guideTextContainer, 1, {y:intDefaultHeight, ease:Strong.easeOut, onComplete:removeGuideText, onCompleteParams:[textMask]});
		}
		
		private function removeGuideText(textMask:Sprite = null) {
			if (guideTextContainer) {
				if (textMask) {
					guideTextContainer.removeChild(textMask);
					guideTextContainer.mask = null;
					textMask = null;
				}
				
				dragAndSlide.dispose();
				dragAndSlide = null;
				this.removeChild(guideTextContainer);
				guideTextContainer.removeChild(guideText);
				var guideTextField:TextField = guideText.getChildAt(0) as TextField;
				guideText.removeChild(guideTextField);
				guideTextField = null;
			}
			guideText = null;
			guideTextContainer = null;
		}
		
		public function replayGuide() {
			trace("Guide.as / replayGuide.");
			if (intCurrentExhibitIndex != 0) {
				intCurrentExhibitIndex = 0;
				loadData();
			} else {
				hideToolsAndCreatePauseButton();
				var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
				slideShow.resetAndPlay();
				Utils.keepAppIdleModeAwake();
			}
		}

		public function reloadGuide() {
			trace("Guide.as / reloadGuide.", lstExhibitFolder);
			removeGuideText();
			isShowGuideText = false;
			removeControlTool();
			removeSlideShow();
			loadData();
		}
		
		public function isGuideTextShow():Boolean {
			return isShowGuideText;
		}
	}
	
}
