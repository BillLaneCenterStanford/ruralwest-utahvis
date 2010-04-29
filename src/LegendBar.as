// ActionScript file
// combo boxes
package
{
	
	import flare.display.TextSprite;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class LegendBar extends Sprite
	{
		private var ox:int;
		private var oy:int;
		private var segmentLength:int;
		//private var numSegments:int;
		
		private var pcpColorArray:Array;  // pcp = per capita physicians
		private var pcpArray:Array;
		
		public var showMode:String;
		
		private var legendSprite:Sprite = new Sprite();
		private var textContainer:Sprite = new Sprite();
		
		public function LegendBar(orgx:int, orgy:int, segLength:int, numSegs:int, _mode:String){
			
			ox = orgx;
			oy = orgy;
			segmentLength = segLength;
			showMode = _mode;
			
			pcpColorArray = new Array(7);
			pcpColorArray[0] = 0xFF4E37;
			pcpColorArray[1] = 0xFF8878;
			pcpColorArray[2] = 0xFFAE9A;
			pcpColorArray[3] = 0xFFDBC9;
			pcpColorArray[4] = 0xFFFAF7;
			pcpColorArray[5] = 0xcccccc;
			
			/////////////////////////////////////////////////
			
			pcpArray = new Array(7);
			pcpArray[0] = " > 0.0100";
			pcpArray[1] = " > 0.0030";
			pcpArray[2] = " > 0.0010";
			pcpArray[3] = " > 0.0005";
			pcpArray[4] = " > 0.0000";
			pcpArray[5] = " Data N/A";
			
			drawLegend();
			addChild(legendSprite);
			addChild(textContainer);
		}
		
		public function drawLegend():void{
			
			legendSprite.graphics.clear();
			while(textContainer.numChildren > 0)
				textContainer.removeChildAt(0);
			
			textContainer.graphics.clear();
			
			if(showMode == "none"){
				legendSprite.graphics.clear();
				return;
			}
			else if (showMode == "utah") {
				trace("$legend utah$");
				/*
				if (chg_ph > 0 && chg_papn > 0) {
					if (chg_ph > chg_papn) {
						color = 0x73d216;
					}
					else {
						color = 0x8ae234;
					}
				}
				else if (chg_ph < 0 && chg_papn < 0) {
					if (chg_ph < chg_papn) {
						color = 0xef2929;
					}
					else {
						color = 0xcc0000;
					}
				}
				*/
				var colorArray:Array = new Array();
				colorArray[0] = 0x73d216;
				colorArray[1] = 0x8ae234;
				colorArray[2] = 0xef2929;
				colorArray[3] = 0xcc0000;
				var textArray:Array = new Array();
				textArray[0] = "\u0394PH > \u0394PA+PN > 0";
				textArray[1] = "\u0394PA+PN > \u0394PH > 0";
				textArray[2] = "0 > \u0394PA+PN > \u0394PH";
				textArray[3] = "0 > \u0394PH > \u0394PA+PN";
				for (var i:int = 0; i < colorArray.length; i++) {
					legendSprite.graphics.beginFill(colorArray[i]);
					legendSprite.graphics.drawRect(ox, oy + i * segmentLength, 14, segmentLength);
					legendSprite.graphics.endFill();
				}
				
				for (var j:int = 0; j < textArray.length; j++) {
					var txt:TextSprite = new TextSprite(textArray[j]);

					txt.color = 0xffffff;
					txt.alpha = 0.6;
					txt.x = ox + 22;
					txt.y = oy + j * segmentLength;
					txt.font = "Calibri";
					txt.size = 12;
					textContainer.addChild(txt);
				}
			}
			else {
				for (var i:int = 0; i < 6; i++){
					if (showMode == "percapita_physicians") {
						legendSprite.graphics.beginFill(pcpColorArray[i]);
					}
					
					legendSprite.graphics.drawRect(ox , oy + i * segmentLength, 14, segmentLength);
					legendSprite.graphics.endFill();
				}
				
				for(var j:int = 0; j < 6; j++){
					var txt:TextSprite;
					if(showMode == "percapita_physicians"){
						if(j == 5)
							txt = new TextSprite(pcpArray[j]);
						else
							txt = new TextSprite(pcpArray[j] + " per capita");
					}
					
					txt.color = 0xffffff;
					txt.alpha = 0.6;
					txt.x = ox + 14;
					txt.y = oy + j * segmentLength;
					txt.font = "Calibri";
					txt.size = 12;
					textContainer.addChild(txt);
				}
			}      
		}
		
		public function update():void {
			drawLegend();
		}
		
	}
}