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
		
		private var lstExhibitFolder:Array = null;
		private var intCurrentExhibitIndex:int = 0;
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var dicExhibitData:Object = null;
		private var soundAudio:Sound = null;
		private var lstPhoto:Array = null;

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
			initLoadingScreen();
			loadData();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
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
		
		private function loadData() {
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
			
			titlebar.setTitlebar(dicExhibitData["Title_" + language.getLanguageType()], Titlebar.TITLE_BUTTON_TYPE_SIDE_MENU);
			
			loadExhibitData.dispose();
			loadExhibitData = null;
		}

	}
	
}
