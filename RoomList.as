package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Shape;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	import tw.cameo.DragAndSlide;
	import tw.cameo.ILoadData;
	import tw.cameo.TempData;
	
	public class RoomList extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var language:Language = Language.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var tempData:TempData = TempData.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		
		private var intContentStartY:int = 0;
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var roomListContainer:Sprite = null;
		private var roomListItem:RoomListItem = null;
		private var dragAndSlide:DragAndSlide = null;

		public function RoomList(... args) {
			// constructor code
			titlebar.setTitlebar(i18n.get("IntoGuidance"), Titlebar.TITLE_BUTTON_TYPE_HOME, Titlebar.TITLE_BUTTON_TYPE_QRCODE);
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
			createRoomListContainer();
			createRoomListItem();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			tempData.saveTempData("intRoomListMoveY", roomListItem.y);
			remvoeRoomListItem();
			removeRoomListContainer();
			removeLoadingScreen();
			removeBackground();
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function createBackground() {
			bg = (isIphone5Layout) ? new RoomListBgIphone5() : new RoomListBgIphone4();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function createRoomListContainer() {
			roomListContainer = new Sprite();
			roomListContainer.graphics.beginFill(0, 0.4);
			roomListContainer.graphics.drawRect(0, 0, 610, 1136);
			roomListContainer.graphics.endFill();
			roomListContainer.x = 15;
			roomListContainer.y = intContentStartY;
			var roomListMask:Shape = new Shape();
			roomListMask.graphics.beginFill(0);
			roomListMask.graphics.drawRect(0, 0, 610, 1136);
			roomListMask.graphics.endFill();
			roomListMask.cacheAsBitmap = true;
			roomListContainer.cacheAsBitmap = true;
			roomListContainer.addChild(roomListMask);
			roomListContainer.mask = roomListMask;
			
			this.addChild(roomListContainer);
		}
		
		private function removeRoomListContainer() {
			this.removeChild(roomListContainer);
			roomListContainer.mask = null;
			roomListContainer = null
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		public function createRoomListItem():void {
			initLoadingScreen();
			roomListItem = new RoomListItem();
			roomListContainer.addChild(roomListItem);
			
			var intRoomListMoveY:int = (tempData.getTempData("intRoomListMoveY")) ? tempData.getTempData("intRoomListMoveY") : 0;
			dragAndSlide = new DragAndSlide(roomListItem, intDefaultHeight - titlebar.intTitlebarHeight - guidanceTool.intGuidanceToolHeight, "Verrical", true, 0xFFFFFF, true, true);
			roomListItem.y = intRoomListMoveY;
			removeLoadingScreen();
		}
		
		private function remvoeRoomListItem() {
			dragAndSlide.dispose();
			dragAndSlide = null;
			roomListContainer.removeChild(roomListItem);
			roomListItem = null;
		}
		
		public function getClickColumnName():String {
			return roomListItem.getClickColumnName();
		}

	}
	
}
