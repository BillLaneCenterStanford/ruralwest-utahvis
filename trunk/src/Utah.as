package
{
	import flare.display.TextSprite;
	import flare.widgets.ProgressBar;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	
	[SWF(width="810", height="650", backgroundColor="#EBD6A5", frameRate="30")]

	
	public class Utah extends Sprite
	{
		
		private var blackBG:Sprite;
		
		private var ZUI:ZoomUI;
		
		private var mapObj:Object;
		
		private var _bar: ProgressBar;


		public function Utah()
		{
			blackBG = new Sprite();
			blackBG.graphics.beginFill(0xeeeeee);
			blackBG.graphics.drawRect(0, 0, 810, 650);
			blackBG.graphics.endFill();
			addChild(blackBG); // !!!
			
			//loadMap();
		
			
			var ctrlPanel : Sprite = new Sprite();
			ctrlPanel.graphics.beginFill(0x000000, 0.6);  // !!!
			ctrlPanel.graphics.drawRect(610, 35, 195, 610);
			ctrlPanel.graphics.endFill();
			addChild(ctrlPanel);
			
			var divider : Sprite = new Sprite();
			divider.graphics.beginFill(0xeeeeee);
			divider.graphics.drawRect(610, 35, 5, 610);
			divider.graphics.endFill();
			addChild(divider);
			
			ZUI = new ZoomUI(0.3, 0.1, 10.0);
			this.addEventListener( MouseEvent.MOUSE_DOWN, onDrag);
			ZUI.addEventListener(Event.CHANGE, ZUIHandler);
			ZUI.addMapControl();
			addChild(ZUI);
			
			var title : TextSprite = new TextSprite();
			title.color = 0xff0000;
			title.alpha = 1;
			title.font = "Calibri";
			title.x = 10;
			title.y = 2;
			title.size = 18;
			title.text = "Utah 1998 - 2003";
			addChild(title);
			
		}
		
		
		private function loadMap():void
		{
			
			var mapContainer : Sprite = new Sprite();
			mapContainer.graphics.beginFill(0x555555);
			mapContainer.graphics.drawRect(5 ,35, 800, 610);
			mapContainer.graphics.endFill();
			addChild(mapContainer);
			
			_bar = new ProgressBar();
			_bar.bar.filters = [new DropShadowFilter(1)];
			_bar.x = 250;
			_bar.y = 300;
			_bar.progress = 0.0;    
			
			// *********** Below code loads shp object ************ //
			mapObj = new ShpMapObject(797, 611, mapContainer, _bar);
			mapObj.addEventListener("all map loaded", allMapLoaded);
			//mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			mapObj.showMode = "percapita_physicians";
			
			mapObj.SetMapColor(0xff0000);
			mapObj.SetMap(0, 0, 767, 611);
			
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
			//mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			
			//initTTGraphics();
			
			addChild(_bar);
		}
		
		private function allMapLoaded(event:Event):void {
			
			try {
				removeChild(_bar);
			} catch (e:ArgumentError) {
				//DO NOTHING
			}
			mapObj.updateMapColor();
			//single_selected = tl_single.getCurSelectedZone();
			mapObj.SetMapEmbedSrc(3);
		}
		
		
		private var orgX:int;
		private var orgY:int;
		private var orgLeft:int;
		private var orgTop:int;
		private var orgLeft2:int;
		private var orgTop2:int;
		
		private function onDrag(event:MouseEvent):void
		{
			trace(event.stageX + ":" + event.stageY + " -- " + ZUI.getImageLeft() + ":" + ZUI.getImageTop() + ":" + ZUI.getScaleFactor());
			
			if (event.stageX > 0 && event.stageX < ZUI.getFrameWidth() &&
				event.stageY > 0 && event.stageY < ZUI.getFrameHeight() - 40 )
			{
				
				orgX = event.stageX;
				orgY = event.stageY;
				orgLeft = ZUI.getImageLeft();
				orgTop = ZUI.getImageTop();
				orgLeft2 = ZUI.getImageLeft2();
				orgTop2 = ZUI.getImageTop2();
				this.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				this.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			}
		}
		
		private function onMove(event:MouseEvent):void
		{
			if (event.stageX > 0 && event.stageX < ZUI.getFrameWidth() &&
				event.stageY > 0 && event.stageY < 10 + ZUI.getFrameHeight() )
			{
				ZUI.setImageLeft(orgLeft + (event.stageX - orgX), orgLeft2 + (event.stageX - orgX));
				ZUI.setImageTop(orgTop  + (event.stageY - orgY), orgTop2 + (event.stageY - orgY));
				
				mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
			}
		}
		
		private function onDrop(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
		}
		
		private function ZUIHandler(event:Event):void
		{
			//RescaleDots();
			//RescaleMap();
			// do rescale functions here
			
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
		}
	}
}