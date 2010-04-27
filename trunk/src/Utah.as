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
		
		// the map object for the SVG map and frame
		private var mapObj:Object;
		
		private var blackBG:Sprite;
		
		private var ZUI:ZoomUI;
		
		private var tl:timeline;
		private var this_year:int;
		private var year_display:TextSprite;
		
		private var _bar: ProgressBar;
		
		// tooltip text sprites
		private var tt_county:TextSprite;
		private var tt_category:TextSprite;
		private var tt_pop:TextSprite;
		private var tt_ph:TextSprite;
		private var tt_pa:TextSprite;

		public function Utah()
		{
			blackBG = new Sprite();
			blackBG.graphics.beginFill(0xeeeeee);
			blackBG.graphics.drawRect(0, 0, 810, 650);
			blackBG.graphics.endFill();
			addChild(blackBG); // !!!
			
			ZUI = new ZoomUI(0.3, 0.1, 10.0);
			this.addEventListener( MouseEvent.MOUSE_DOWN, onDrag);
			ZUI.addEventListener(Event.CHANGE, ZUIHandler);
			ZUI.addMapControl();
			
			loadMap();
			
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
			
			addChild(ZUI);
			
			
			// timeline configuration
			tl = new timeline(33, 560, 330, 1998, 2008);
			var yrArray:Array = new Array(1998, 2003, 2008);
			var intArray:Array = new Array(0, 33, 66);
			tl.setYearsInts(yrArray, intArray);
			tl.DrawTimeline();
			tl.addEventListener(Event.CHANGE, tlHandler);
			addChild(tl);
			
			year_display = new TextSprite();
			year_display.x = 10;
			year_display.y = 2;
			year_display.color = 0x0D658A;
			year_display.font = "Calibri";
			year_display.text = "Utah PH vs. PA Year " + tl.getSelectedYear().toString();
			year_display.size = 24;
			addChild(year_display);
			
			
			// tooltip configurations
			var tt_text_size:int = 16;
			var tt_vert_spacing:int = 18;
			var tt_ox:int = 630;
			var tt_oy:int = 320;
			
			tt_county = new TextSprite();
			tt_county.color = 0xffffff;
			tt_county.size = tt_text_size;
			tt_county.font = "Calibri";
			tt_county.x = tt_ox;
			tt_county.y = tt_oy;
			tt_county.visible = true;
			addChild(tt_county);
			
			tt_category = new TextSprite();
			tt_category.color = 0xffffff;
			tt_category.size = tt_text_size;
			tt_category.font = "Calibri";
			tt_category.x = tt_ox;
			tt_category.y = tt_oy + tt_vert_spacing*1;
			tt_category.visible = true;
			addChild(tt_category);
			
			tt_pop = new TextSprite();
			tt_pop.color = 0xffffff;
			tt_pop.size = tt_text_size;
			tt_pop.font = "Calibri";
			tt_pop.x = tt_ox;
			tt_pop.y = tt_oy + tt_vert_spacing*2;
			tt_pop.visible = true;
			addChild(tt_pop);
			
			tt_ph = new TextSprite();
			tt_ph.color = 0xffffff;
			tt_ph.size = tt_text_size;
			tt_ph.font = "Calibri";
			tt_ph.x = tt_ox;
			tt_ph.y = tt_oy + tt_vert_spacing*3;
			tt_ph.visible = true;
			addChild(tt_ph);
			
			tt_pa = new TextSprite();
			tt_pa.color = 0xffffff;
			tt_pa.size = tt_text_size;
			tt_pa.font = "Calibri";
			tt_pa.x = tt_ox;
			tt_pa.y = tt_oy + tt_vert_spacing*4;
			tt_pa.visible = true;
			addChild(tt_pa);
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
			mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			mapObj.showMode = "utah";
			
			mapObj.SetMapColor(0xff0000);
			mapObj.SetMap(0, 0, 767, 611);
			
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
			mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			
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
			mapObj.SetMapEmbedSrc(3-1);  // hard code
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
		
		private function ttHandler(event:Event):void
		{
			var cnty:String = mapObj.getCounty();
			if(cnty.length > 0){
				tt_county.text = mapObj.getCounty();
				tt_category.text = mapObj.getCategory();
				tt_pop.text = "Population: " + mapObj.getPop();
				tt_ph.text = "PH: " + mapObj.getPh();
				tt_pa.text = "PA: " + mapObj.getPa();
			}
			else{
				tt_county.text = "";
				tt_category.text = "";
				tt_pop.text = "";
				tt_ph.text = "";
				tt_pa.text = "";
			}
			
		}
		
		private function tlHandler(evt:Event):void
		{
			trace("tlHandler " + tl.getSelectedZone() + ", year " + tl.getSelectedYear());
			this_year = tl.getSelectedYear();
			year_display.text = "Utah PH vs. PA Year " + this_year.toString();
			mapObj.SetMapEmbedSrc(tl.getSelectedZone());
		}
		
		/*
		 * used for debugging
		 * add a big text message on upper left corner
		 */
		private function DEBUGInfo(info:String):void {
			var title : TextSprite = new TextSprite();
			title.color = 0x000000;
			title.alpha = 1;
			title.font = "Calibri";
			title.x = 0;
			title.y = 0;
			title.size = 30;
			title.text = info;
			this.addChild(title);
		}
	}
}