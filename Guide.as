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
	import flash.display.Shape;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import com.greensock.BlitMask;
	import com.greensock.easing.*;
	import tw.cameo.DragAndSlide;
	import tw.cameo.Log;
	import tw.cameo.WebViewLog;
	import tw.cameo.TempData;
	
	public class Guide extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var tempData:TempData = TempData.getInstance();
		
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (isIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		public var lstExhibitFolder:Array = null;
		private var isBackToHome:Boolean = false;
		private var intCurrentExhibitIndex:int = 0;
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var dicExhibitData:Object = null;
		private var soundAudio:Sound = null;
		private var lstPhoto:Array = null;
		private var slideShowContainer:Sprite = null;
		
		private var toolTextBg:Shape = null;
		private var slideShowControlTool:MovieClip = null;
		private var pauseSprite:Sprite = null;
		
		private var isShowGuideText:Boolean = false;
		private var guideText:Sprite = null;
		private var guideTextContainer:Sprite = null;
		private var dragAndSlide:DragAndSlide = null;

		public function Guide(lstParameters:Array) {
			// constructor code
			
			lstExhibitFolder = lstParameters[0];
			isBackToHome = lstParameters[1];
			titlebar.showTitlebar();
			titlebar.setTitle("");
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
			removeToolTextBg();
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
			
			var strTitle:String = "[" + lstExhibitFolder[intCurrentExhibitIndex] + "] " + Utils.removeDoubleQuote(dicExhibitData["Title_" + language.getLanguageType()]);
			var strButtonType:String = (isBackToHome) ? Titlebar.TITLE_BUTTON_TYPE_HOME : Titlebar.TITLE_BUTTON_TYPE_BACK;
			titlebar.setTitlebar(strTitle, strButtonType, Titlebar.TITLE_BUTTON_TYPE_CAMERA);
			
			loadExhibitData.dispose();
			loadExhibitData = null;
			removeLoadingScreen();
			
			var slideShow:SlideShow = new SlideShow(dicExhibitData, lstPhoto, soundAudio);
			slideShow.addEventListener(SlideShow.PLAY_END, onSlideShowPlayEnd);
			
			if (tempData.getTempData("isNavigatorBackToGuide")) {
				trace("Guide.as / isNavigatorBack.");
				tempData.deleteTempData("isNavigatorBackToGuide");
				slideShowContainer.addChild(slideShow);
				showToolsAndRemovePauseButton();
			} else {
				playGuide(slideShow);
			}
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
		
		private function createToolTextBg() {
			if (toolTextBg) return;
			toolTextBg = new Shape();
			toolTextBg.graphics.beginFill(0, 0.7);
			toolTextBg.graphics.drawRect(0, 0, 640, 1136);
			toolTextBg.graphics.endFill();
			toolTextBg.alpha = 0;
			this.addChild(toolTextBg);
		}
		
		private function showToolTextBg() {
			createToolTextBg();
			TweenLite.killTweensOf(toolTextBg);
			TweenLite.to(toolTextBg, 0.5, {alpha:1});
		}
		
		private function hideToolTextBg() {
			if (toolTextBg == null) return;
			TweenLite.killTweensOf(toolTextBg);
			TweenLite.to(toolTextBg, 0.5, {alpha:0, onComplete:removeToolTextBg});
		}
		
		private function removeToolTextBg() {
			if (toolTextBg == null) return;
			this.removeChild(toolTextBg);
			toolTextBg = null;
		}
		
		private function showControlTool() {
			showToolTextBg();
			createControlTool();
			TweenLite.killTweensOf(slideShowControlTool);
			TweenLite.to(slideShowControlTool, 0.5, {alpha:1});
		}
		
		private function createControlTool() {
			if (slideShowControlTool) return;
			slideShowControlTool = new SlideShowControlTool();
			slideShowControlTool.y = (isIphone5Layout) ? 0 : -88;
			slideShowControlTool.playLabel.text = i18n.get("Label_Play");
			slideShowControlTool.replayLabel.text = i18n.get("Label_Replay");
			slideShowControlTool.alpha = 0;
			this.addChild(slideShowControlTool);
			slideShowControlTool.playButton.addEventListener(MouseEvent.CLICK, onClickPlayButton);
			slideShowControlTool.replayButton.addEventListener(MouseEvent.CLICK, onClickReplayButton);
		}
		
		private function showToolsAndRemovePauseButton() {
			removePauseButton();
			titlebar.showTitlebar();
			guidanceTool.showGuidanceTool();
			showControlTool();
		}
		
		private function hideToolsAndCreatePauseButton() {
			hideToolTextBg();
			hideControlTool();
			createPauseButton();
			titlebar.hideTitlebar();
			guidanceTool.hideGuidanceTool();
		}
		
		private function hideControlTool() {
			if (slideShowControlTool == null) return;
			TweenLite.killTweensOf(slideShowControlTool);
			TweenLite.to(slideShowControlTool, 0.5, {alpha:0, onComplete:removeControlTool});
		}
		
		private function removeControlTool() {
			if (slideShowControlTool == null) return;
			slideShowControlTool.playButton.removeEventListener(MouseEvent.CLICK, onClickPlayButton);
			slideShowControlTool.replayButton.removeEventListener(MouseEvent.CLICK, onClickReplayButton);
			this.removeChild(slideShowControlTool);
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
			hideControlTool();
			isShowGuideText = true;
			if (guideTextContainer == null) {
				guideTextContainer = new Sprite();
				guideTextContainer.graphics.beginFill(0, 0);
				guideTextContainer.graphics.drawRect(0, 0, 640, 1136);
				guideTextContainer.graphics.endFill();
				guideTextContainer.y = intDefaultHeight;
				var textMask:Sprite = new Sprite();
				textMask.graphics.beginFill(0);
				textMask.graphics.drawRect(0, 0, 640, 1136);
				textMask.graphics.endFill();
				textMask.y = titlebar.intTitlebarHeight;
				guideTextContainer.addChild(textMask);
				guideTextContainer.mask = textMask;
				
				guideText = new Sprite();
				guideText.x = 55;
				guideText.y = titlebar.intTitlebarHeight;
				var textFormat:TextFormat = new TextFormat();
				
				if (language.getLanguageType() == "CHT" || language.getLanguageType() == "JPN") {
					textFormat.size = 35;
					textFormat.letterSpacing = 5;
					textFormat.leading = 10;
				} else {
					textFormat.size = 35;
				}
				
				textFormat.font = "Arial, Helvetica, _san, _serif, _typewriter";
				textFormat.color = 0xFFFFFF;
				
				var guideTextField:TextField = new TextField();
				guideTextField.y = 20;
				guideTextField.width = 525*LayoutManager.intScaleX;
				guideTextField.multiline = true;
				guideTextField.autoSize = TextFieldAutoSize.LEFT;
				guideTextField.wordWrap = true;
				guideTextField.selectable = guideTextField.mouseEnabled = false;
				guideTextField.text = Utils.removeDoubleQuote(dicExhibitData["Content_" + language.getLanguageType()], language.getLanguageType());
				guideTextField.setTextFormat(textFormat);
				guideText.addChild(guideTextField);
//				guideTextField.height = guideTextField.textHeight;
				guideTextField.width = 525;
				guideTextContainer.addChild(guideText);
				this.addChild(guideTextContainer);
				
				TweenLite.delayedCall(0.5, adjustGuideText);
				dragAndSlide = new DragAndSlide(guideText, intDefaultHeight-titlebar.intTitlebarHeight-guidanceTool.intGuidanceToolHeight, "Vertical", false);
			}
			TweenLite.killTweensOf(guideTextContainer);
			TweenLite.to(guideTextContainer, 1, {y:0, ease:Strong.easeOut});
		}
		
		private function adjustGuideText() {
			if (guideText == null) return;
			var guideTextField:TextField = guideText.getChildAt(0) as TextField;
			guideTextField.autoSize = TextFieldAutoSize.NONE;
			if (guideTextField.textHeight > guideTextField.height) {
				guideTextField.height = guideTextField.textHeight + 10;
			} else {
				guideTextField.height += 10;
			}
		}
		
		public function hideGuideText() {
			isShowGuideText = false;
			showControlTool();
			TweenLite.killTweensOf(guideTextContainer);
			TweenLite.to(guideTextContainer, 1, {y:intDefaultHeight, onComplete:removeGuideText});
		}
		
		private function removeGuideText() {
			if (guideTextContainer == null) return;
			guideTextContainer.mask = null;
			dragAndSlide.dispose();
			dragAndSlide = null;
			this.removeChild(guideTextContainer);
			guideTextContainer.removeChild(guideText);
			var guideTextField:TextField = guideText.getChildAt(0) as TextField;
			guideText.removeChild(guideTextField);
			guideTextField = null;
			guideText = null;
			guideTextContainer = null;
		}
		
		public function replayGuide() {
			trace("Guide.as / replayGuide.");
			removeGuideTextAndShowSlideShow();
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
			removeGuideTextAndShowSlideShow();
			removeControlTool();
			removeSlideShow();
			intCurrentExhibitIndex = 0;
			loadData();
		}
		
		private function removeGuideTextAndShowSlideShow() {
			removeGuideText();
			isShowGuideText = false;
		}
		
		public function isGuideTextShow():Boolean {
			return isShowGuideText;
		}
	}
	
}
