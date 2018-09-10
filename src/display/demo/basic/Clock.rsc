module display::demo::basic::Clock

import display::SocketConnection;
import Prelude;
import util::Math;

tuple[int X, int Y] time2coord(int time) {
   real angle = 2 * PI() * (toReal(time) / 60.0);
   int handX = round(50 + 40 * cos(angle));
   int handY = round(50 + 40 * sin(angle));
   return <handX, handY>;
   }
   
void clock(Widget dv) {
   int time = 1;
   tuple[int X, int Y] hand = time2coord(time);
   bool running = false;
   println(dv.id);
   Widget p = svg(dv).width(300).height(300);  //.attr("viewBox", "0 -0 100 100");
   // Widget p = svg(dv);
   println(p.id);
   Widget c = circle(p).cx(50).cy(50).r(45).attr("fill", "#0B79CE")
                       .attr("stroke", "grey").attr("stroke-width", "4");
   Widget l= line(p).attr("x1", "50").attr("y1", "50").attr("x2", "<hand.X>").attr("y2", "<hand.Y>")
   .attr("stroke","#023963"); 
   Widget b = button(dv).innerHTML("On/Off")
   .event(click, (Widget b)
         {running = !running;
           if (running) {
                setInterval(b, 1000).event(tick,  (Widget b)
                 { 
                 time+=1; hand = time2coord(time);
                 l.attr("x2", "<hand.X>").attr("y2", "<hand.Y>");  
                 })
                 .attr("style", "background-color:red");
              }
           else {
              clearInterval(b).attr("style", "background-color:blue");
              }
         });  
   }

public void main() {
   Widget z=createPanel();
   Widget dv = div(z);
   h2(dv).innerHTML("Clock using SVG");
   clock(dv);
   eventLoop(dv, []);
}