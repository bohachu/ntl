package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import tw.cameo.DragAndSlide;
	
	import I18n;
	import Language;
	import Titlebar;
	import GuidanceTool;
	import MappingData;
	import LoadingScreen;
	import LoadExhibitWallPhotoIntro;
	import GuideEvent;
	
	public class RoomExhibitList extends MovieClip {
		
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
		
		private var intContentStartY:int = 0;
		public var strFloor:String = "";
		public var strRoom:String = "";
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var lstExhibit:Array = null;
		private var photoWall:MovieClip = null;
		private var dragAndSlide:DragAndSlide = null;

		public function RoomExhibitList(lstArgs:Array) {
			// constructor code
			strFloor = lstArgs[0];
			strRoom = lstArgs[1];
			titlebar.setTitlebar(i18n.get(strFloor) + "-" + i18n.get(strRoom), Titlebar.TITLE_BUTTON_TYPE_SIDE_MENU);
			titlebar.showTitlebar();
			intContentStartY = titlebar.intTitlebarHeight;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			loadLayout();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePhotoEventListener();
			removeLoadingScreen();
			removeBackground();
			dragAndSlide.dispose();
			dragAndSlide = null;
			lstExhibit = null;
			photoWall = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
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
		
		private function loadLayout() {
			initLoadingScreen();
			lstExhibit = mappingData.getExhibitList(strFloor +  "-" + strRoom);
			photoWall = getLayout(lstExhibit.length);
			photoWall.y = intContentStartY;
			
			for (var i:int = 1; i<lstExhibit.length+1; i++) {
				photoWall["photo" + String(i)].alpha = 0;
				(photoWall["photo" + String(i)] as MovieClip).strGuidanceNumber = lstExhibit[i-1];
				photoWall["photo" + String(i)].addEventListener(MouseEvent.CLICK, onPhotoClick);
			}
			
			this.addChild(photoWall);
			var intMoveLength:Number = intDefaultHeight - titlebar.intTitlebarHeight - guidanceTool.intGuidanceToolHeight;
			dragAndSlide = new DragAndSlide(photoWall, intMoveLength, "Vertical", true, 0, false);
			loadData();
		}
		
		private function removePhotoWall() {
			removePhotoEventListener();
			dragAndSlide.dispose();
			dragAndSlide = null;
			this.removeChild(photoWall);
			photoWall = null;
		}
		
		private function removePhotoEventListener() {
			for (var i:int = 1; i<lstExhibit.length+1; i++) {
				photoWall["photo" + String(i)].removeEventListener(MouseEvent.CLICK, onPhotoClick);
			}
		}
		
		private function loadData() {
			for (var i:int = 0; i<lstExhibit.length; i++) {
				var loadExhibitWallPhotoIntro:LoadExhibitWallPhotoIntro = new LoadExhibitWallPhotoIntro(lstExhibit[i], photoWall["photo" + String(i+1)]);
				loadExhibitWallPhotoIntro.addEventListener(LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE, onLoadIntroComplete);
				loadExhibitWallPhotoIntro.loadIntro();
			}
		}
		
		private function onLoadIntroComplete(e:Event) {
			removeLoadingScreen();
			
			var loadExhibitWallPhotoIntro:LoadExhibitWallPhotoIntro = e.target as LoadExhibitWallPhotoIntro;
			loadExhibitWallPhotoIntro.removeEventListener(LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE, onLoadIntroComplete);
			
			var photoMovieClip:MovieClip = loadExhibitWallPhotoIntro.getPhotoMovieClip();
			loadExhibitWallPhotoIntro.dispose();
			loadExhibitWallPhotoIntro = null;
			
			TweenLite.to(photoMovieClip, 1, {alpha:1});
		}
		
		private function getLayout(intPhotoNumber:int):MovieClip {
			switch (intPhotoNumber) {
				case 3:
					return new Layout3Pics();
				break;
				case 4:
					return new Layout4Pics();
				break;
			}
			
			return new Layout3Pics();
		}
		
		private function onPhotoClick(e:MouseEvent) {
//			trace(e.target.parent.strGuidanceNumber);
			eventChannel.writeEvent(new GuideEvent(GuideEvent.START_GUIDANCE, [e.target.parent.strGuidanceNumber]));
		}
		
		public function resetExhibitList(strFloorIn:String, strRoomIn:String) {
			strFloor = strFloorIn;
			strRoom = strRoomIn;
		}
		
		public function reloadExhibitList() {
			removePhotoWall();
			titlebar.setTitle(i18n.get(strFloor) + "-" + i18n.get(strRoom));
			loadLayout();
		}

	}
	
}
