module display::demo::basic::Circle
import display::SocketConnection;
import Prelude;
import util::Math;

public void main() {
 Widget z=createPanel().div();
 Widget p = z.svg().width(200).height(200).class("b").attr("viewBox","0 0 200 200");
   //p.rect().width(100).height(100).style("fill:yellow");
   //num r = shrink*(100-10)/2;
   //num cx = 100/2;
   //num cy = 100/2;
   num r = 50;
   num cx = 100;
   num cy = 100;
   num f = 1.2;
   Widget q=p.circle().attr("r", "<r>").attr("cx", "<cx>").attr("cy","<cy>").
   style("stroke:red;stroke-width:8;fill:blue");
   Bounds b = getBBox(q);
   BoundsC c = center(b);
   c.width *= f; c.height *= f;
   Bounds b1 = bounds(c);
   p.rect().width(b.width).height(b.height).x(b.x).y(b.y).style("fill:blue;fill-opacity:0.5");
   println(b1);
   p.rect().width(b1.width).height(b1.height).x(b1.x).y(b1.y).style("fill:yellow;fill-opacity:0.5;stroke:red;stroke-width:4");
   }