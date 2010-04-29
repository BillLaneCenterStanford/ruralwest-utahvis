package
{
	import fl.controls.CheckBox;
	
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
		private var tt_papn:TextSprite;
		
		private var urbanBorderCB:CheckBox = new CheckBox();
		
		private var myLegend:LegendBar;
		
		public function Utah()
		{
			blackBG = new Sprite();
			blackBG.graphics.beginFill(0xeeeeee);
			blackBG.graphics.drawRect(0, 0, 810, 650);
			blackBG.graphics.endFill();
			addChild(blackBG); // !!!
			
			
			ZUI = new ZoomUI(1.2, 0.1, 10.0);
			this.addEventListener( MouseEvent.MOUSE_DOWN, onDrag);
			ZUI.addEventListener(Event.CHANGE, ZUIHandler);
			ZUI.addMapControl();
			
			loadMap();
			
			var ctrlPanel : Sprite = new Sprite();
			ctrlPanel.graphics.beginFill(0x000000, 0.7);  // !!!
			ctrlPanel.graphics.drawRect(610, 35, 195, 610);
			ctrlPanel.graphics.endFill();
			addChild(ctrlPanel);
			
			var divider : Sprite = new Sprite();
			divider.graphics.beginFill(0xeeeeee);
			divider.graphics.drawRect(610, 35, 5, 610);
			divider.graphics.endFill();
			
			divider.graphics.beginFill(0xeeeeee);
			divider.graphics.drawRect(610, 505, 195, 5);
			divider.graphics.endFill();
			
			divider.graphics.beginFill(0xeeeeee);
			divider.graphics.drawRect(610, 285, 195, 5);
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
			//addChild(tl);
			
			year_display = new TextSprite();
			year_display.x = 10;
			year_display.y = 5;
			year_display.color = 0x333333;
			year_display.font = "Calibri";
			year_display.text = "Relative change in physicians and allied health professional per capita in Utah, 1998-2003";
			year_display.size = 19;
			year_display.bold = true;
			addChild(year_display);
			
			
			var tt_title:TextSprite = new TextSprite("Data tooltips");
			tt_title.color = 0xffffff;
			tt_title.size = 18;
			tt_title.font = "Calibri";
			tt_title.x = 630;
			tt_title.y = 515;
			addChild(tt_title);
			
			// tooltip configurations
			var tt_text_size:int = 16;
			var tt_vert_spacing:int = 18;
			var tt_ox:int = 635;
			var tt_oy:int = 542;
			
			tt_county = new TextSprite();
			tt_county.color = 0xffffff;
			tt_county.alpha = 0.8;
			tt_county.size = tt_text_size;
			tt_county.font = "Calibri";
			tt_county.x = tt_ox;
			tt_county.y = tt_oy;
			tt_county.visible = true;
			addChild(tt_county);
			
			tt_category = new TextSprite("Roll over a Utah ");
			tt_category.color = 0xffffff;
			tt_category.alpha = 0.8;
			tt_category.size = tt_text_size;
			tt_category.font = "Calibri";
			tt_category.x = tt_ox;
			tt_category.y = tt_oy + tt_vert_spacing*1;
			tt_category.visible = true;
			addChild(tt_category);
			
			tt_pop = new TextSprite("county for physicians");
			tt_pop.color = 0xffffff;
			tt_pop.alpha = 0.8;
			tt_pop.size = tt_text_size;
			tt_pop.font = "Calibri";
			tt_pop.x = tt_ox;
			tt_pop.y = tt_oy + tt_vert_spacing*2;
			tt_pop.visible = true;
			addChild(tt_pop);
			
			tt_ph = new TextSprite("data.");
			tt_ph.color = 0xffffff;
			tt_ph.alpha = 0.8;
			tt_ph.size = tt_text_size;
			tt_ph.font = "Calibri";
			tt_ph.x = tt_ox;
			tt_ph.y = tt_oy + tt_vert_spacing*3;
			tt_ph.visible = true;
			addChild(tt_ph);
			
			tt_papn = new TextSprite();
			tt_papn.color = 0xffffff;
			tt_papn.alpha = 0.8;
			tt_papn.size = tt_text_size;
			tt_papn.font = "Calibri";
			tt_papn.x = tt_ox;
			tt_papn.y = tt_oy + tt_vert_spacing*4;
			tt_papn.visible = true;
			addChild(tt_papn);
			
			
			urbanBorderCB = new CheckBox();
			urbanBorderCB.x = 630;
			urbanBorderCB.y = 220;
			urbanBorderCB.selected = false;
			urbanBorderCB.label = "";
			addChild(urbanBorderCB);
			
			urbanBorderCB.addEventListener(Event.CHANGE, CBUrbanHandler);
			
			var ub_label:TextSprite = new TextSprite("highlight urban \r   county borders");
			ub_label.font = "Calibri";
			ub_label.size = 16;
			ub_label.color = 0xffffff;
			ub_label.alpha = 0.8;
			ub_label.x = 657;
			ub_label.y = 215;
			addChild(ub_label);
			
			var ltitle:TextSprite = new TextSprite("Legend");
			ltitle.color = 0xffffff;
			ltitle.alpha = 1.0;
			ltitle.size = 18;
			ltitle.font = "Calibri";
			ltitle.x = 630;
			ltitle.y = 295;
			addChild(ltitle);
			
			var lph:TextSprite = new TextSprite("PH = Practicing Physicians");
			lph.color = 0xffffff;
			lph.alpha = 0.7;
			lph.size = 12;
			lph.font = "Calibri";
			lph.x = 635;
			lph.y = 320;
			addChild(lph);
			
			var lpa:TextSprite = new TextSprite("PA = Physician's Assistants");
			lpa.color = 0xffffff;
			lpa.alpha = 0.7;
			lpa.size = 12;
			lpa.font = "Calibri";
			lpa.x = 635;
			lpa.y = 335;
			addChild(lpa);
			
			var lpn:TextSprite = new TextSprite("NP = Nurse Practitioners");
			lpn.color = 0xffffff;
			lpn.alpha = 0.7;
			lpn.size = 12;
			lpn.font = "Calibri";
			lpn.x = 635;
			lpn.y = 350;
			addChild(lpn);
			// legend
			myLegend = new LegendBar(640, 375, 30, 6, "utah");
			addChild(myLegend);
		}
		
		private function CBUrbanHandler(event:Event):void {
		  mapObj.getHighlightUrban(urbanBorderCB.selected);
      mapObj.updateMapColor();

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
			mapObj = new ShpMapObject(800, 610, mapContainer, _bar);
			mapObj.addEventListener("all map loaded", allMapLoaded);
			mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			mapObj.showMode = "utah";
			
			mapObj.SetMapColor(0xff0000);
			mapObj.SetMap(0, 0, 800, 610);
			
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
			//trace(ZUI.getImageLeft());
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
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
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
				tt_county.text = mapObj.getCounty().toUpperCase() + " county";
				tt_category.text = mapObj.getCategory();
				tt_pop.text = "Population: " + mapObj.getPop();
				tt_ph.text = "PH: " + mapObj.getPh();
				tt_papn.text = "PA+PN: " + mapObj.getPapn();
			}
			else{
				tt_county.text = "";
				tt_category.text = "Roll over a Utah ";
				tt_pop.text = "county for physicians";
				tt_ph.text = "data.";
				tt_papn.text = "";
			}
			
		}
		
		private function tlHandler(evt:Event):void
		{
			trace("tlHandler " + tl.getSelectedZone() + ", year " + tl.getSelectedYear());
			this_year = tl.getSelectedYear();
			year_display.text = "Relative change in physicians and allied health professional per capita in Utah, 1998-2003";
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