package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	
	import I18n;
	import Language;
	import Titlebar;
	import MappingData;
	import LoadingScreen;
	
	public class RoomExhibitList extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
		private var strFloor:String = "";
		private var strRoom:String = "";
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var lstExhibit:Array = null;
		private var lstExhibitInfo:Array = null;
		private var lstExhibitPhoto:Array = null;
		private var photoWall:MovieClip = null;

		public function RoomExhibitList(lstArgs:Array) {
			// constructor code
			strFloor = lstArgs[0];
			strRoom = lstArgs[1];
			titlebar.setTitlebar(i18n.get(strFloor) + "-" + i18n.get(strRoom), Titlebar.TITLE_BUTTON_TYPE_SIDE_MENU);
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
			loadingData();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeLoadingScreen();
			removeBackground();
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
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function loadingData() {
			lstExhibit = mappingData.getExhibitList(strFloor + "-" + strRoom);
		}

	}
	
}
