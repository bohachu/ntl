package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.IAddRemoveListener;
	import tw.cameo.DragAndSlide;
	
	import Titlebar;
	import GuidanceTool;
	
	public class Layout extends MovieClip implements IAddRemoveListener {
		
		public static const PHOTO_CLICK:String = "Layout.PHOTO_CLICK";
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (LayoutManager.useIphone5Layout()) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var layout:MovieClip = null;
		private var lstExhibit:Array = null;
		private var intPhotoNumber:int = 1;
		private var dragAndSlide:DragAndSlide = null;
		private var strClickGuideNumber:String = "";

		public function Layout(lstExhibitIn:Array) {
			// constructor code
			lstExhibit = lstExhibitIn;
			intPhotoNumber = lstExhibit.length;
			initLayout();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			this.addChild(layout);
			addEventListenerFunc();
			var intViewLength:Number = intDefaultHeight - titlebar.intTitlebarHeight - guidanceTool.intGuidanceToolHeight;
			dragAndSlide = new DragAndSlide(this, intViewLength, "Vertical", false, 0, true);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			dragAndSlide.dispose();
			dragAndSlide = null;
			removeEventListenerFunc();
			this.removeChild(layout);
			layout = null;
		}
		
		private function initLayout() {
			switch (intPhotoNumber) {
				case 1:
					layout = new Layout1Pics();
				break;
				case 2:
					layout = new Layout2Pics();
				break;
				case 3:
					layout = new Layout3Pics();
				break;
				case 4:
					layout = new Layout4Pics();
				break;
				case 5:
					layout = new Layout5Pics();
				break;
				case 6:
					layout = new Layout6Pics();
				break;
			}
			
			for (var i:int = 1; i<intPhotoNumber+1; i++) {
				layout["photo" + String(i)].alpha = 0;
				(layout["photo" + String(i)] as MovieClip).strGuidanceNumber = lstExhibit[i-1];
			}
		}
		
		public function addEventListenerFunc():void {
			for (var i:int = 1; i<intPhotoNumber+1; i++) {
				layout["photo" + String(i)].addEventListener(MouseEvent.MOUSE_DOWN, onPhotoMouseDown);
			}
		}
		
		private function onPhotoMouseDown(e:MouseEvent) {
			e.target.parent.addEventListener(MouseEvent.MOUSE_UP, onPhotoMouseUp);
		}
		
		private function onPhotoMouseUp(e:MouseEvent) {
			e.target.parent.removeEventListener(MouseEvent.MOUSE_UP, onPhotoMouseUp);
			strClickGuideNumber = (e.target.parent as MovieClip).strGuidanceNumber;
			this.dispatchEvent(new Event(Layout.PHOTO_CLICK));
		}
		
		public function removeEventListenerFunc():void {
			for (var i:int = 1; i<intPhotoNumber+1; i++) {
				layout["photo" + String(i)].removeEventListener(MouseEvent.MOUSE_DOWN, onPhotoMouseDown);
				layout["photo" + String(i)].removeEventListener(MouseEvent.MOUSE_UP, onPhotoMouseUp);
			}
		}
		
		public function getStrGuideNumber():String {
			return strClickGuideNumber;
		}
		
		public function getPhotoMovieClip(intPhotoIndex:int):MovieClip {
			return layout["photo" + String(intPhotoIndex)];
		}
	}
	
}
