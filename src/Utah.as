package
{
	import fl.controls.CheckBox;
	
	import flare.display.TextSprite;
	import flare.widgets.ProgressBar;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	
	[SWF(width="810", height="650", backgroundColor="#EBD6A5", frameRate="30")]
	
	
	public class Utah extends Sprite
	{
		
		// the map object for the SVG map and frame
		private var mapObj:ShpMapObject;
		private var mapContainer:Sprite;
		
		private var blackBG:Sprite;
		
		private var ZUI:ZoomUI;
		
		private var tl:timeline;
		private var this_year:int;
		private var title:TextSprite;
		
		private var _bar: ProgressBar;
		
		private var urbanBorderCB:CheckBox = new CheckBox();
		
		private var ruralCB:CheckBox = new CheckBox();
		
		private var myLegend:LegendBar;
		
		//
		// project specific data interface
		//
		//private var dataInterface:DataInterface = new DataUtahByCounty();
		//private var dataInterface:DataInterface = new DataUtahByZip();
		private var dataInterface:DataInterface = new DataUtahByZcta();
		//
		//
		//
		
		[Embed(source = "../img/lightBW.png")]
		private var lightMap:Class;
		private var instLightMap:Bitmap;
		
		public function Utah()
		{
			blackBG = new Sprite();
			blackBG.graphics.beginFill(0xeeeeee);
			blackBG.graphics.drawRect(0, 0, 810, 650);
			blackBG.graphics.endFill();
			addChild(blackBG);
			
			ZUI = new ZoomUI(
				this.dataInterface,
				this.dataInterface.getInitialZoom(),
				this.dataInterface.getMinZoom(),
				this.dataInterface.getMaxZoom());
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
			
			title = new TextSprite();
			title.x = 10;
			title.y = 5;
			title.color = 0x333333;
			title.font = "Calibri";
			title.text = "Relative change in physicians and allied health professional per capita in Utah, 1998-2003";
			title.size = 19;
			title.bold = true;
			addChild(title);
			
			
			// TOOLTIP
			this.dataInterface.drawTooltip(this);
			
			// HIGHLIGHT URBAN CHECK BOX
			/*
			urbanBorderCB = new CheckBox();
			urbanBorderCB.x = 630;
			urbanBorderCB.y = 220;
			urbanBorderCB.selected = false;
			urbanBorderCB.label = "";
			urbanBorderCB.addEventListener(Event.CHANGE, CBUrbanHandler);
			addChild(urbanBorderCB);
			
			var ub_label:TextSprite = new TextSprite("highlight urban \r   county borders");
			ub_label.font = "Calibri";
			ub_label.size = 16;
			ub_label.color = 0xffffff;
			ub_label.alpha = 0.8;
			ub_label.x = 657;
			ub_label.y = 215;
			addChild(ub_label);
			*/
			
			// RURAL OVERLAY
			ruralCB = new CheckBox();
			ruralCB.x = 630;
			ruralCB.y = 220;
			ruralCB.selected = false;
			ruralCB.label = "";
			ruralCB.addEventListener(Event.CHANGE, CBRuralHandler);
			addChild(ruralCB);
			
			var rural_label:TextSprite = new TextSprite("Rural Overlay");
			rural_label.font = "Calibri";
			rural_label.size = 16;
			rural_label.color = 0xffffff;
			rural_label.alpha = 0.8;
			rural_label.x = 657;
			rural_label.y = 218;
			addChild(rural_label);
			
			// LEGEND
			var ltitle:TextSprite = new TextSprite("Legend");
			ltitle.color = 0xffffff;
			ltitle.alpha = 1.0;
			ltitle.size = 18;
			ltitle.font = "Calibri";
			ltitle.x = 630;
			ltitle.y = 295;
			addChild(ltitle);
			
			var lph:TextSprite = new TextSprite("MD = Practicing Physicians");
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
			
			myLegend = new LegendBar(640, 375, 30, 6, dataInterface);
			addChild(myLegend);
		}
		
		private function CBUrbanHandler(event:Event):void {
			mapObj.getHighlightUrban(urbanBorderCB.selected);
			mapObj.updateMapColor();
		}
		
		private function CBRuralHandler(event:Event):void {
			instLightMap.visible = this.ruralCB.selected;
		}
		
		private function loadMap():void
		{
			mapContainer = new Sprite();
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
			mapObj = new ShpMapObject(800, 610, mapContainer, this.dataInterface, _bar);
			mapObj.addEventListener("all map loaded", allMapLoaded);
			mapObj.addEventListener(Event.CHANGE, ttHandler);    // handles tooltips events
			
			mapObj.SetMapColor(0xff0000);
			mapObj.SetMap(0, 0, 800, 610);
			
			//initTTGraphics();
			
			addChild(_bar);
			
			// Overlay map
			instLightMap = new lightMap as Bitmap;
			var boundLightMap:Shape = new Shape();
			boundLightMap.graphics.clear();
			boundLightMap.graphics.beginFill(0x000000);
			boundLightMap.graphics.drawRect(0, 50, 810, 560);
			boundLightMap.graphics.endFill();
			instLightMap.mask = boundLightMap;
			
			/*
			instLightMap.scaleX = ZUI.getScaleFactor()*0.9;
			instLightMap.scaleY = ZUI.getScaleFactor()*0.9;
			instLightMap.x = ZUI.getImageLeft2();
			instLightMap.y = ZUI.getImageTop2();
			*/
			instLightMap.scaleX = 0.7;
			instLightMap.scaleX = 0.7;
			instLightMap.x = -280;
			instLightMap.y = -680;
		}
		
		private function allMapLoaded(event:Event):void {
			// Overlay map
			instLightMap.visible = false;
			mapContainer.addChild(instLightMap);
			
			
			try {
				removeChild(_bar);
			} catch (e:ArgumentError) {
				//DO NOTHING
			}
			mapObj.updateMapColor();
			mapObj.SetMapEmbedSrc(this.dataInterface.getDefaultMapIndex());
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
			// do rescale functions here
			mapObj.ScaleAndTranslateMap(ZUI.getScaleFactor(), ZUI.getImageLeft(), ZUI.getImageTop());
			
			// also update overlay map
			instLightMap.scaleX = ZUI.getScaleFactor()*0.9;
			instLightMap.scaleY = ZUI.getScaleFactor()*0.9;
			instLightMap.x = ZUI.getImageLeft2();
			instLightMap.y = ZUI.getImageTop2();
		}
		
		private function ttHandler(event:Event):void
		{
			dataInterface.handleTooltip(mapObj, event);
		}
		
		private function tlHandler(evt:Event):void
		{
			trace("tlHandler " + tl.getSelectedZone() + ", year " + tl.getSelectedYear());
			this_year = tl.getSelectedYear();
			title.text = "Relative change in physicians and allied health professional per capita in Utah, 1998-2003";
			mapObj.SetMapEmbedSrc(tl.getSelectedZone());
		}
		
		/*
		* used for debugging
		* add a big text message on upper left corner
		*/
		private function DEBUGInfo(info:String):void {
			var title : TextSprite = new TextSprite();
			title.color = 0;
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