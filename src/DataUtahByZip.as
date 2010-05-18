package
{
	import flare.display.TextSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class DataUtahByZip implements DataInterface
	{
		private var years:Array = new Array(1998, 2003);
		
		// tooltip text sprites
		private var tt_zip:TextSprite;
		private var tt_panp:TextSprite;
		private var tt_ph:TextSprite;
		private var tt_pop:TextSprite;
		
		// attribute strings for tooltip
		private var zip:String;
		private var pop:String;
		private var ph:String;
		private var panp:String;
		private var change_ph:String;
		private var change_panp:String;
		private var prevZip:String;
		
		private var debugString:String = "$DataUtahByZip$";
		
		public function DataUtahByZip()
		{
			// do nothing right now, all hard coded...
		}
		
		public function getYears():Array
		{
			return this.years;
		}
		
		public function getXmlFileName(year:String):String
		{
			return "../dat/utah_by_zip_" + year + ".xml";
		}
		
		public function getShpFileName(year:String):String
		{
			return "../shp/utzip.shp";
		}
		
		public function getDbfFileName(year:String):String
		{
			return "../shp/utzip.dbf";
		}
		
		public function getDataAttributes():Array
		{
			return new Array("zip", "year", "np", "pa", "ph",
				"panp", "pop", "change_ph", "change_panp", "change_pop");
		}
		
		public function getKeyAttribute():String
		{
			return "zip";
		}
		
		public function keyAttributeNameInDbfFile():String
		{
			return "ZIP";
		}
		
		public function updateMapColor(dictData:Dictionary, features:Array, highlightBorder:Boolean, highlightUrban:Boolean):void
		{
			for (var i:int = 0; i < features.length; i++) {
				if (!features[i].values) {
					continue;
				}
				
				zip = trim(features[i].values["ZIP"]);
				var color:uint = 0xCCCCCC;
				if (zip.length > 0 && dictData.hasOwnProperty(zip)) {
					//features[i].draw(color, color * parseInt(dictData[zip].ph));
					
					var change_ph:Number = dictData[zip].change_ph;
					var change_panp:Number = dictData[zip].change_panp;
					
					if (change_ph == 0 && change_panp == 0) {
						color = 0xcccccc;
					}
					else {
						if (change_ph > 0 && change_panp > 0) {
							if (change_ph > change_panp) {
								color = 0x489100;
							}
							else {
								color = 0x9FDB64;
							}
						}
						else if (change_ph < 0 && change_panp < 0) {
							if (change_ph < change_panp) {
								color = 0xD9958A;
							}
							else {
								color = 0xcc0000;
							}
						}
						else {
							if (change_ph > change_panp) {
								color = 0x489100;
							}
							else {
								color = 0xD9958A;
							}
						}
					}
				}
				else {
					color = 0xAAAAAA;
				}
				
				features[i].draw(color, color);
			}
		}
		
		public function drawLegendForLegendBar(ox:int, oy:int, segLength:int, legendSprite:Sprite, textContainer:Sprite):void
		{
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
			
			tt_zip = new TextSprite("zip area");
			tt_zip.color = 0xffffff;
			tt_zip.alpha = 0.8;
			tt_zip.size = tt_text_size;
			tt_zip.font = "Calibri";
			tt_zip.x = tt_ox;
			tt_zip.y = tt_oy;
			tt_zip.visible = true;
			root.addChild(tt_zip);
			
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
			var zipArea:String = this.getDataByFieldName("zip");
			if (zipArea.length > 0) {
				var abs_change_ph:String = this.change_ph;
				if (parseInt(abs_change_ph) >= 0) {
					abs_change_ph = "+" + abs_change_ph;
				}
				var abs_change_panp:String = this.change_panp;
				if (parseInt(abs_change_panp) >= 0) {
					abs_change_panp = "+" + abs_change_panp;
				}
				
				
				this.tt_zip.text = "ZIP: " + this.zip;
				this.tt_pop.text = "Population: " + this.pop.toString();
				this.tt_ph.text = "MD: " + this.ph + " (" + abs_change_ph + " from 1998)";
				this.tt_panp.text = "PA+NP: " + this.panp + " (" + abs_change_panp + " from 1998)";
			}
			else {
				this.tt_zip.text = "";
				this.tt_pop.text = "area for physicians";
				this.tt_ph.text = "data.";
				this.tt_panp.text = "";
			}
		}
		
		public function readTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void
		{
			this.zip = trim(event.currentTarget.values["ZIP"]);
			
			if (dictData.hasOwnProperty(zip) && parseInt(zip) > 0) {
				pop = dictData[zip].pop.toString();
				if (parseInt(pop) > 0) {
					pop = dictData[zip].pop.toString();
					ph = dictData[zip].ph.toString();
					panp = dictData[zip].panp.toString();
					change_ph = dictData[zip].change_ph.toString();
					change_panp = dictData[zip].change_panp.toString();
				}
				else {
					pop = "N/A";
					ph = "N/A";
					panp = "N/A";
					change_ph = "N/A";
					change_panp = "N/A";
				}
				
				if (zip != prevZip) {
					shpMap.dispatchEvent(new Event(Event.CHANGE));
				}
				
				prevZip = zip;
			}
		}
		
		public function removeTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void
		{
			zip = "";
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
				case "zip":
					result = this.zip;
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
			return 100;
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