package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;
	import MappingData;
	import LoadingScreen;
	import GuideEvent;
	import LoadExhibitData;
	import SlideShow;
	
	public class Guide extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
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

		public function Guide(lstExhibitFolderIn:Array) {
			// constructor code
			lstExhibitFolder = lstExhibitFolderIn;
			titlebar.showTitlebar();
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
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
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
			
			titlebar.setTitlebar(dicExhibitData["Title_" + language.getLanguageType()], Titlebar.TITLE_BUTTON_TYPE_SIDE_MENU, Titlebar.TITLE_BUTTON_TYPE_QRCODE);
			
			loadExhibitData.dispose();
			loadExhibitData = null;
			removeLoadingScreen();
			
			var slideShow:SlideShow = new SlideShow(dicExhibitData, lstPhoto, soundAudio);
			
			playGuide(slideShow);
		}
		
		private function removeSlideShow() {
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			if (slideShow) slideShowContainer.removeChild(slideShow);
			slideShow = null;
		}
		
		private function playGuide(slideShow:SlideShow) {
			slideShowContainer.addChild(slideShow);
			createPauseButton();
			titlebar.hideTitlebar();
			guidanceTool.hideGuidanceTool();
			slideShow.playSlideShow();
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
		
		private function pauseSlideShow(e:MouseEvent) {
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			removePauseButton();
			titlebar.showTitlebar();
			guidanceTool.showGuidanceTool();
			showControlTool();
			slideShow.stopSlideShow();
		}

		private function continuePlayGuide() {
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			removeControlTool();
			createPauseButton();
			titlebar.hideTitlebar();
			guidanceTool.hideGuidanceTool();
			slideShow.playSlideShow();
		}
		
		private function showControlTool() {
			slideShowControlTool = new SlideShowControlTool();
			slideShowControlTool.y = (isIphone5Layout) ? 0 : -88;
			this.addChild(slideShowControlTool);
			slideShowControlTool.playButton.addEventListener(MouseEvent.CLICK, onClickPlayButton);
			slideShowControlTool.replayButton.addEventListener(MouseEvent.CLICK, onClickReplayButton);
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
		
		public function replayGuide() {
			trace("Guide.as / replayGuide.");
			var slideShow:SlideShow = slideShowContainer.getChildAt(0) as SlideShow;
			removeControlTool();
			createPauseButton();
			slideShow.resetAndPlay();
			titlebar.hideTitlebar();
			guidanceTool.hideGuidanceTool();
		}

		public function reloadGuide() {
			trace("Guide.as / reloadGuide.", lstExhibitFolder);
			removeControlTool();
			removeSlideShow();
			loadData();
		}
	}
	
}
