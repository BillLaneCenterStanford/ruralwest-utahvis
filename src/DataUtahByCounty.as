package
{
	import flare.display.TextSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class DataUtahByCounty implements DataInterface
	{
		private var years:Array = new Array(1998, 2003, 2008);
		
		// tooltip text sprites
		private var tt_county:TextSprite;
		private var tt_category:TextSprite;
		private var tt_pop:TextSprite;
		private var tt_ph:TextSprite;
		private var tt_papn:TextSprite;
		
		// attribute strings for tooltip
		private var fips:String;
		private var countyname:String;
		private var category:String;
		private var pop:String;
		private var ph:String;
		private var papn:String;
		private var abs_change_ph:String;
		private var abs_change_papn:String;
		private var prevCounty:String;
		
		public function DataUtahByCounty()
		{
			// do nothing right now, all hard-coded ...
		}
		
		public function getYears():Array {
			return this.years;
		}
		
		public function getXmlFileName(year:String):String {
			return "../dat/Utah_PH_PA_" + year + ".xml";
		}
		
		public function getShpFileName(year:String):String {
			return "../shp/us.SHP";
		}
		
		public function getDbfFileName(year:String):String {
			return "../shp/us.DBF";
		}
		
		public function getDataAttributes():Array {
			var attr:Array = new Array(
				"countyname", "fips", "category",
				"ph", "papn", "pop",
				"change_ph", "change_papn",
				"abs_change_ph", "abs_change_papn");
			
			return attr;
		}
		
		public function getDefaultMapIndex():int {
			return this.years.length - 1;
		}
		
		public function getKeyAttribute():String {
			return "fips";
		}
		
		public function updateMapColor(dictData:Dictionary, features:Array, highlightBorder:Boolean, highlightUrban:Boolean):void {
			var highlight_border_features:Array = new Array();
			var highlight_color_features:Array = new Array();
			
			// Assign attribute dictionaries to features.
			for ( var i : int = 0; i < features.length; i++ ) {
				if (!features[i].values) {
					trace(i);
					continue;
				}
				var fips:String = trim(features[i].values[keyAttributeNameInDbfFile()]);
				
				var color:uint = 0xcccccc;
				if (fips.length > 0 && dictData.hasOwnProperty(fips)) {
					var chg_ph:Number = dictData[fips].change_ph;
					var chg_papn:Number = dictData[fips].change_papn;
					var cat:String = dictData[fips].category;
					if (chg_ph == 0 && chg_papn == 0) {
						color = 0xcccccc;
					}
					else {
						if (chg_ph > 0 && chg_papn > 0) {
							if (chg_ph > chg_papn) {
								color = 0x489100;
							}
							else {
								color = 0x9FDB64;
							}
						}
						else if (chg_ph < 0 && chg_papn < 0) {
							if (chg_ph < chg_papn) {
								color = 0xD9958A;
							}
							else {
								color = 0xcc0000;
							}
						}
						else {
							if (chg_ph > chg_papn) {
								color = 0x489100;
							}
							else {
								color = 0xD9958A;
							}
						}
					}
				}
				else {
					color = 0xaaaaaa; 
				}
				
				if (highlightBorder && highlightUrban){
					if(cat == "urban" && dictData.hasOwnProperty(fips) ){
						highlight_border_features.push(features[i]);
						highlight_color_features.push(color);
					}
					features[i].draw(0x444444, color);
				}
				else if(highlightBorder){
					features[i].draw(0x444444, color);
				}
				else{
					features[i].draw(color, color);
				}
			}
			
			for (var j:int = 0; j < highlight_border_features.length; j++){
				highlight_border_features[j].draw(0x0000ff, highlight_color_features[j] + 0x101010, 1.0);
			}
		}
		
		public function keyAttributeNameInDbfFile():String {
			return "ID";
		}
		
		public function drawLegendForLegendBar(ox:int, oy:int, segLength:int, legendSprite:Sprite, textContainer:Sprite):void {
			legendSprite.graphics.clear();
			while(textContainer.numChildren > 0)
				textContainer.removeChildAt(0);
			textContainer.graphics.clear();
			
			var colorArray:Array = new Array();
			colorArray[0] = 0x489100;
			colorArray[1] = 0x9FDB64;
			colorArray[2] = 0xD9958A;
			colorArray[3] = 0xcc0000;
			var textArray:Array = new Array();
			textArray[0] = "incr. in MDs > incr. \r in PAs + NPs";
			textArray[1] = "incr. in PAs + NPs > \r incr. in MDs";
			textArray[2] = "decr. in MDs > decr. \r in PAs + NPs";
			textArray[3] = "decr. in PA + NPs > \r decr. in MDs";
			for (var i:int = 0; i < colorArray.length; i++) {
				legendSprite.graphics.beginFill(colorArray[i]);
				legendSprite.graphics.drawRect(ox, oy + i * segLength, 14, segLength);
				legendSprite.graphics.endFill();
			}
			
			for (var j:int = 0; j < textArray.length; j++) {
				var txt:TextSprite = new TextSprite(textArray[j]);
				
				txt.color = 0xffffff;
				txt.alpha = 0.6;
				txt.x = ox + 22;
				txt.y = oy + j * segLength;
				txt.font = "Calibri";
				txt.size = 12;
				textContainer.addChild(txt);
			}
		}
		
		public function drawTooltip(root:Sprite):void {
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
			
			
			tt_county = new TextSprite();
			tt_county.color = 0xffffff;
			tt_county.alpha = 0.8;
			tt_county.size = tt_text_size;
			tt_county.font = "Calibri";
			tt_county.x = tt_ox;
			tt_county.y = tt_oy;
			tt_county.visible = true;
			root.addChild(tt_county);
			
			tt_category = new TextSprite("Roll over a Utah ");
			tt_category.color = 0xffffff;
			tt_category.alpha = 0.8;
			tt_category.size = tt_text_size;
			tt_category.font = "Calibri";
			tt_category.x = tt_ox;
			tt_category.y = tt_oy + tt_vert_spacing*1;
			tt_category.visible = true;
			root.addChild(tt_category);
			
			tt_pop = new TextSprite("county for physicians");
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
			
			tt_papn = new TextSprite();
			tt_papn.color = 0xffffff;
			tt_papn.alpha = 0.8;
			tt_papn.size = tt_text_size;
			tt_papn.font = "Calibri";
			tt_papn.x = tt_ox;
			tt_papn.y = tt_oy + tt_vert_spacing*4;
			tt_papn.visible = true;
			root.addChild(tt_papn);
		}
		
		public function handleTooltip(mapObj:ShpMapObject, event:Event):void {
			var cnty:String = this.getDataByFieldName("countyname");
			if(cnty.length > 0){
				tt_county.text = this.countyname.toUpperCase() + " county";
				tt_category.text = this.category;
				tt_pop.text = "Population: " + this.pop;
				
				var abs_change_ph:String = this.abs_change_ph;
				if (parseInt(abs_change_ph) >= 0) {
					abs_change_ph = "+" + abs_change_ph;
				}
				var abs_change_papn:String = this.abs_change_papn;
				if (parseInt(abs_change_papn) >= 0) {
					abs_change_papn = "+" + abs_change_papn;
				}
				tt_ph.text = "MD: " + this.ph + " (" + abs_change_ph + " from 1998)";
				tt_papn.text = "PA+NP: " + this.papn + " (" + abs_change_papn + " from 1998)";
			}
			else{
				tt_county.text = "";
				tt_category.text = "Roll over a Utah ";
				tt_pop.text = "county for physicians";
				tt_ph.text = "data.";
				tt_papn.text = "";
			}
		}
		
		public function readTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void {
			fips = trim(event.currentTarget.values["ID"]);
			
			if (dictData.hasOwnProperty(fips) && parseInt(fips) > 0) {
				pop = dictData[fips].pop.toString();
				if (parseInt(pop) > 0) {
					countyname = dictData[fips].countyname.toString();
					category = dictData[fips].category.toString();
					pop = dictData[fips].pop.toString();
					ph = dictData[fips].ph.toString();
					papn = dictData[fips].papn.toString();
					abs_change_ph = dictData[fips].abs_change_ph.toString();
					abs_change_papn = dictData[fips].abs_change_papn.toString();
				}
				else {
					countyname = "N/A";
					category = "N/A";
					pop = "N/A";
					ph = "N/A";
					papn = "N/A";
					abs_change_ph = "N/A";
					abs_change_papn = "N/A";
				}
				
				if (countyname != prevCounty) {
					shpMap.dispatchEvent(new Event(Event.CHANGE));
				}
				
				prevCounty = countyname;
			}
		}
		
		public function removeTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void {
			fips = "";
			countyname = "";
			category = "";
			pop = "";
			ph = "";
			papn = "";
			abs_change_ph = "";
			abs_change_papn = "";
			
			shpMap.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function getDataByFieldName(field:String):String {
			var result:String = "";
			
			switch (field) {
				case "countyname":
					result = this.countyname;
					break;
				case "category":
					result = this.category;
					break;
				case "pop":
					result = this.pop;
					break;
				case "ph":
					result = this.ph;
					break;
				case "papn":
					result = this.papn;
					break;
				case "abs_change_ph":
					result = this.abs_change_ph;
					break;
				case "abs_change_papn":
					result = this.abs_change_papn;
					break;
				default:
					result = "default";
			}
			
			return result;
		}
		
		public function getInitialZoom():Number {
			return 1.2;
		}
		
		public function getMaxZoom():Number {
			return 0.5;
		}
		
		public function getMinZoom():Number {
			return 10;
		}
		
		public function getImageLeft():int {
			return -460;
		}
		
		public function getImageTop():int {
			return -620;
		}

		private function trim(str:String) : String {
			return str.replace(/^\s+|\s+$/g, '');
		}
		
		public function getDebugString():String {
			return "$DataUtahByCounty Nothing$";
		}
	}
}