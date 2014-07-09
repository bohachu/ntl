package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import tw.cameo.LayoutSettings;
	import tw.cameo.LayoutManager;
	
	public class LoadingPicturePage extends MovieClip {
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:int = LayoutSettings.intDefaultHeightForIphone5;
		
		private var bg:Sprite;
		private var loadingPicture:Sprite;
		
		public function LoadingPicturePage() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			if (LayoutManager.useIphone5Layout()) {
				changeLayoutForIphone5();
			}
			createBackground();
			createLoadingPicture();
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeBackground();
			remvoeLoadingPicture();
		}
		
		private function createBackground() {
			bg = new Sprite();
			bg.graphics.beginFill(0, 0);
			bg.graphics.drawRect(0, 0, intDefaultWidth, intDefaultHeight);
			bg.graphics.endFill();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function createLoadingPicture() {
			loadingPicture = new LoadingPicture();
			loadingPicture.x = intDefaultWidth/2;
			loadingPicture.y = intDefaultHeight/2;
			this.addChild(loadingPicture);
		}
		
		private function remvoeLoadingPicture() {
			this.removeChild(loadingPicture);
			loadingPicture = null;
		}
	}
	
}
