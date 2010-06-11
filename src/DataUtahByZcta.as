package
{
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class DataUtahByZcta implements DataInterface
	{
		private var years:Array = new Array(1998, 2003);
		
		// tooltip text sprites
		private var tt_zcta:TextSprite;
		private var tt_empty:TextSprite;
		private var tt_panp:TextSprite;
		private var tt_ph:TextSprite;
		private var tt_pop:TextSprite;
		
		// attribute strings for tooltip
		private var zcta:String;
		private var pop:String;
		private var ph:String;
		private var panp:String;
		private var change_ph:String;
		private var change_panp:String;
		private var prevZcta:String;
		
		private var debugString:String = "$DataUtahByZcta$";
		
		public function DataUtahByZcta()
		{
			// do nothing right now, all hard coded...
		}
		
		public function getYears():Array
		{
			return this.years;
		}
		
		public function getXmlFileName(year:String):String
		{
			return "../dat/utah_by_zcta_" + year + ".xml";
		}
		
		public function getShpFileName(year:String):String
		{
			return "../shp/utah_zcta.shp";
		}
		
		public function getDbfFileName(year:String):String
		{
			return "../shp/utah_zcta.dbf";
		}
		
		public function getDataAttributes():Array
		{
			return new Array("zcta", "year", "panp", "ph",
				"pop", "change_panp", "change_ph", "change_pop");
		}
		
		public function getKeyAttribute():String
		{
			return "zcta";
		}
		
		public function keyAttributeNameInDbfFile():String
		{
			return "ZCTA";
		}
		
		public function updateMapColor(dictData:Dictionary, 
									   features:Array,
									   highlightBorder:Boolean, 
									   highlightUrban:Boolean):void
		{
			for (var i:int = 0; i < features.length; i++) {
				if (!features[i].values) {
					continue;
				}
				
				zcta = trim(features[i].values["ZCTA"]);
				var color:uint = 0xCCCCCC;
				if (zcta.length > 0 && dictData.hasOwnProperty(zcta)) {
					var change_ph:Number = dictData[zcta].change_ph;
					var change_panp:Number = dictData[zcta].change_panp;
					var panp03:Number = dictData[zcta].panp;
					var ph03:Number = dictData[zcta].ph;
					var panp98:Number = panp03 - change_panp;
					var ph98:Number = ph03 - change_ph;
					
					var ratio98:Number = ph98 / panp98;
					var ratio03:Number = ph03 / panp03;
					
					if (change_panp > 0 || change_ph > 0) {			// increase
						if (ratio03 >= ratio98) {
							color = 0x489100;
						}
						else {
							color = 0x9FDB64;
						}
					}
					else if (change_panp < 0 || change_ph < 0) {	// decrease
						color = 0xCC0000;
					}
					else if (panp03 == 0 && ph03 == 0 &&			// no data
						     panp98 == 0 && ph98 == 0) {
						color = 0xFFFFCC;
					}
					else {											// no change
						color = 0xFFFF00;
					}
				}
				else {
					color = 0xAAAAAA;
				}
				
				features[i].draw(0x666666, color);
			}
		}
		
		public function drawLegendForLegendBar(ox:int, oy:int, 
											   segLength:int, 
											   legendSprite:Sprite, 
											   textContainer:Sprite):void
		{
			var arrayColor:Array = new Array(
				0x489100,
				0x9FDB64,
				0xCC0000,
				0xFFFF00,
				0xFFFFCC);
			var arrayLegend:Array = new Array(
				"MD/(PA+NP) 03' > 98'",
				"MD/(PA+NP) 03' < 98'",
				"MD or PA+NP decreasing",
				"MD and PA+NP no change",
				"no MD and PA+NP");
			
			var offsetY:int = 10;
			var L:int = 15;
			for (var i:int = 0; i < arrayColor.length; i++) {
				var colorBox:Sprite = new Sprite();
				colorBox.x = ox - 3;
				colorBox.y = oy + i * L + offsetY;
				colorBox.graphics.beginFill(arrayColor[i]);
				colorBox.graphics.drawRect(0, 0, L, L);
				colorBox.graphics.endFill();
				textContainer.addChild(colorBox);
				
				var legend:TextSprite = new TextSprite();
				legend.text = arrayLegend[i];
				legend.x = ox + 15;
				legend.y = oy + i * L + offsetY;
				legend.color = 0xFFFFFF;
				legend.font = "Arial";
				legend.size = 10;
				textContainer.addChild(legend);
			}
		}
		
		public function drawTooltip(root:Sprite):void
		{
			var tt_title:TextSprite = new TextSprite("Data tooltips");
			tt_title.color = 0xffffff;
			tt_title.size = 18;
			tt_title.font = "Calibri";
			tt_title.x = 630;
			tt_title.y = 515;
			root.addChild(tt_title);
			
			var tt_text_size:int = 16;
			var tt_vert_spacing:int = 18;
			var tt_ox:int = 635;
			var tt_oy:int = 542;
			
			tt_zcta = new TextSprite("zcta area");
			tt_zcta.color = 0xffffff;
			tt_zcta.alpha = 0.8;
			tt_zcta.size = tt_text_size;
			tt_zcta.font = "Calibri";
			tt_zcta.x = tt_ox;
			tt_zcta.y = tt_oy;
			tt_zcta.visible = true;
			root.addChild(tt_zcta);
			
			tt_empty = new TextSprite("Mouse over");
			tt_empty.color = 0xffffff;
			tt_empty.alpha = 0.8;
			tt_empty.size = tt_text_size;
			tt_empty.font = "Calibri";
			tt_empty.x = tt_ox;
			tt_empty.y = tt_oy + tt_vert_spacing*1;
			tt_empty.visible = true;
			root.addChild(tt_empty);
			
			tt_pop = new TextSprite("area for physicians");
			tt_pop.color = 0xffffff;
			tt_pop.alpha = 0.8;
			tt_pop.size = tt_text_size;
			tt_pop.font = "Calibri";
			tt_pop.x = tt_ox;
			tt_pop.y = tt_oy + tt_vert_spacing*2;
			tt_pop.visible = true;
			root.addChild(tt_pop);
			
			tt_ph = new TextSprite("data.");
			tt_ph.color = 0xffffff;
			tt_ph.alpha = 0.8;
			tt_ph.size = tt_text_size;
			tt_ph.font = "Calibri";
			tt_ph.x = tt_ox;
			tt_ph.y = tt_oy + tt_vert_spacing*3;
			tt_ph.visible = true;
			root.addChild(tt_ph);
			
			tt_panp = new TextSprite();
			tt_panp.color = 0xffffff;
			tt_panp.alpha = 0.8;
			tt_panp.size = tt_text_size;
			tt_panp.font = "Calibri";
			tt_panp.x = tt_ox;
			tt_panp.y = tt_oy + tt_vert_spacing*4;
			tt_panp.visible = true;
			root.addChild(tt_panp);
		}
		
		public function handleTooltip(mapObj:ShpMapObject, event:Event):void
		{
			var zipArea:String = this.getDataByFieldName("zcta");
			if (zipArea.length > 0) {
				var abs_change_ph:String = this.change_ph;
				if (parseInt(abs_change_ph) >= 0) {
					abs_change_ph = "+" + abs_change_ph;
				}
				var abs_change_panp:String = this.change_panp;
				if (parseInt(abs_change_panp) >= 0) {
					abs_change_panp = "+" + abs_change_panp;
				}
				
				
				this.tt_zcta.text = "ZCTA: " + this.zcta;
				this.tt_empty.text = "";
				this.tt_pop.text = "Population (2000'): " + this.pop.toString();
				this.tt_ph.text = "MD: " + this.ph + " (" + abs_change_ph + " from 1998)";
				this.tt_panp.text = "PA+NP: " + this.panp + " (" + abs_change_panp + " from 1998)";
			}
			else {
				this.tt_zcta.text = "";
				this.tt_empty.text = "Mouse over";
				this.tt_pop.text = "area for physicians";
				this.tt_ph.text = "data.";
				this.tt_panp.text = "";
			}
		}
		
		public function readTooltipDataFromShpMap(shpMap:ShpMap, 
												  event:MouseEvent, 
												  dictData:Dictionary):void
		{
			this.zcta = trim(event.currentTarget.values["ZCTA"]);
			
			if (dictData.hasOwnProperty(zcta) && parseInt(zcta) > 0) {
				pop = dictData[zcta].pop.toString();
				ph = dictData[zcta].ph.toString();
				panp = dictData[zcta].panp.toString();
				change_ph = dictData[zcta].change_ph.toString();
				change_panp = dictData[zcta].change_panp.toString();
				
				if (zcta != prevZcta) {
					shpMap.dispatchEvent(new Event(Event.CHANGE));
				}
				
				prevZcta = zcta;
			}
		}
		
		public function removeTooltipDataFromShpMap(shpMap:ShpMap, 
													event:MouseEvent, 
													dictData:Dictionary):void
		{
			zcta = "";
			pop = "";
			ph = "";
			panp = "";
			change_ph = "";
			change_panp = "";
			
			shpMap.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function getDataByFieldName(field:String):String
		{
			var result:String = "";
			
			switch (field) {
				case "zcta":
					result = this.zcta;
					break;
				case "pop":
					result = this.pop;
					break;
				case "panp":
					result = this.panp;
					break;
				case "ph":
					result = this.ph;
					break;
				case "change_ph":
					result = this.change_ph;
					break;
				case "change_panp":
					result = this.change_panp;
					break;
				default:
					result = "default";
			}
			
			return result;
		}
		
		public function getDefaultMapIndex():int
		{
			return this.years.length - 1;
		}
		
		private function trim(str:String) : String {
			return str.replace(/^\s+|\s+$/g, '');
		}
		
		public function getInitialZoom():Number {
			//return 0.0015;  // for the projected one
			return 100;  // for the original one
		}
		
		public function getMaxZoom():Number {
			return 50;
		}
		
		public function getMinZoom():Number {
			return 200;
		}
		
		public function getImageLeft():int {
			return 55;
		}
		
		public function getImageTop():int {
			return 70;
		}
		
		public function getDebugString():String {
			return this.debugString;
		}
	}
}