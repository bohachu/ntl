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
	import tw.cameo.ILoadData;
	import flash.display.Shape;
	
	public class RoomExhibitList extends MovieClip implements ILoadData {
		
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
		private var photoWallContainer:Sprite = null;
		private var photoWall:Layout = null;

		public function RoomExhibitList(lstArgs:Array) {
			// constructor code
			strFloor = lstArgs[0];
			strRoom = lstArgs[1];
			titlebar.setTitlebar(i18n.get(strFloor) + "-" + i18n.get(strRoom), Titlebar.TITLE_BUTTON_TYPE_BACK, Titlebar.TITLE_BUTTON_TYPE_QRCODE);
			titlebar.showTitlebar();
			guidanceTool.setType(GuidanceTool.GUIDE_BUTTON_TYPE1);
			guidanceTool.showGuidanceTool();
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
			initPhotoWallContainer();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePhotoWall();
			removeLoadingScreen();
			removeBackground();
			lstExhibit = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = (isIphone5Layout) ? new ExhibitListBgIphone5() : new ExhibitListBgIphone4();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function initPhotoWallContainer() {
			photoWallContainer = new Sprite();
			var photoWallMask:Shape = new Shape();
			photoWallMask.graphics.beginFill(0);
			photoWallMask.graphics.drawRect(0, 0, intDefaultWidth, intDefaultHeight);
			photoWallMask.graphics.endFill();
			photoWallMask.cacheAsBitmap = true;
			photoWallContainer.cacheAsBitmap = true;
			photoWallContainer.addChild(photoWallMask);
			photoWallContainer.mask = photoWallMask;
			photoWallContainer.y = intContentStartY;
			this.addChild(photoWallContainer);
		}
		
		private function removePhotoWallContainer() {
			this.removeChild(photoWallContainer);
			photoWallContainer.mask = null;
			photoWallContainer = null;
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function removePhotoWall() {
			photoWall.removeEventListener(Layout.PHOTO_CLICK, onPhotoClick);
			photoWallContainer.removeChild(photoWall);
			photoWall = null;
		}
		
		public function loadData():void {
			initLoadingScreen();
			lstExhibit = mappingData.getExhibitList(strFloor +  "-" + strRoom);
			photoWall = new Layout(lstExhibit);
			photoWall.addEventListener(Layout.PHOTO_CLICK, onPhotoClick);
			photoWallContainer.addChild(photoWall);
			
			for (var i:int = 0; i<lstExhibit.length; i++) {
				var loadExhibitWallPhotoIntro:LoadExhibitWallPhotoIntro = new LoadExhibitWallPhotoIntro(lstExhibit[i], photoWall.getPhotoMovieClip(i));
				loadExhibitWallPhotoIntro.addEventListener(LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE, onLoadIntroComplete);
				loadExhibitWallPhotoIntro.loadIntro();
			}
		}
		
		private function onLoadIntroComplete(e:Event) {
			removeLoadingScreen();
			
			var loadExhibitWallPhotoIntro:LoadExhibitWallPhotoIntro = e.target as LoadExhibitWallPhotoIntro;
			loadExhibitWallPhotoIntro.removeEventListener(LoadExhibitWallPhotoIntro.LOAD_INTRO_COMPLETE, onLoadIntroComplete);
			
			var photoMovieClip:MovieClip = loadExhibitWallPhotoIntro.getPhotoMovieClip();
			var strGuidanceNumber:String = photoMovieClip.strGuidanceNumber;
			if (mappingData.checkIsTopTenCollection(strGuidanceNumber)) photoMovieClip.label.text = "[" + i18n.get("Recommend") + "] " + photoMovieClip.label.text;
			loadExhibitWallPhotoIntro.dispose();
			loadExhibitWallPhotoIntro = null;
			
			TweenLite.to(photoMovieClip, 1, {alpha:1});
		}
		
		private function onPhotoClick(e:Event) {
			eventChannel.writeEvent(new GuideEvent(GuideEvent.START_GUIDANCE, [photoWall.getStrGuideNumber()]));
		}
		
		public function resetExhibitList(strFloorIn:String, strRoomIn:String) {
			strFloor = strFloorIn;
			strRoom = strRoomIn;
		}
		
		public function reloadExhibitList() {
			removePhotoWall();
			titlebar.setTitle(i18n.get(strFloor) + "-" + i18n.get(strRoom));
			loadData();
		}

	}
	
}
