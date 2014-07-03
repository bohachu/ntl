package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	
	public class LoadingScreen {
		
		private var container:DisplayObjectContainer = null;
		private var loadingMovieClip:MovieClip = null;

		public function LoadingScreen(containerIn:DisplayObjectContainer, strType:String = "Type02") {
			// constructor code
			container = containerIn;
			switch (strType) {
				case "Type01":
					loadingMovieClip = new LoadingScreenType01();
				break;
				case "Type02":
					loadingMovieClip = new LoadingScreenType02();
				break;
			}
			
			container.addChild(loadingMovieClip);
		}
		
		public function dispose() {
			container.removeChild(loadingMovieClip);
			loadingMovieClip = null;
		}

	}
	
}
