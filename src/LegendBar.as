// ActionScript file
package
{
	
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class LegendBar extends Sprite
	{
		private var ox:int;
		private var oy:int;
		private var segmentLength:int;
		
		private var legendSprite:Sprite = new Sprite();
		private var textContainer:Sprite = new Sprite();
		
		private var dataInterface:DataInterface;
		
		public function LegendBar(orgx:int, orgy:int, segLength:int, numSegs:int, dataInterface:DataInterface){
			ox = orgx;
			oy = orgy;
			segmentLength = segLength;
			
			this.dataInterface = dataInterface;
			
			drawLegend();
			
			addChild(legendSprite);
			addChild(textContainer);
		}
		
		public function drawLegend():void{
			dataInterface.drawLegendForLegendBar(ox, oy, segmentLength, legendSprite, textContainer);
		}
		
		public function update():void {
			drawLegend();
		}
		
	}
}