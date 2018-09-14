module display::SocketConnection
import Prelude;
import util::Math;
import lang::json::IO;


// Events
public str click  = "click";
public str change = "change";
public str tick = "tick";

data Msg = init();

int width0 = 800;
int height0 = 800;

alias Bounds = tuple[num x, num y, num width, num height];
alias BoundsC = tuple[num cx, num cy, num width, num height];

BoundsC center(Bounds b) = <b.x+b.width/2, b.y+b.height/2,b.width, b.height>;
Bounds  bounds(BoundsC c) = <c.cx-c.width/2, c.cy-c.height/2, c.width, c.height>;

map[int, lrel[set[tuple[str id , str eventName]], void()]] events = ();

/*
alias Widget = tuple[int process, str id, str eventName, str val
    ,value(str) class, value(str) style
    ,value(str, str) attr, value(int) width,  value(int) height
    ,value(int) x, value(int) y
    ,value(int) cx, value(int) cy
    ,value(int) r
    ,value(str) innerHTML
    ,value(str ,  void(value)) event
    ,value(str , Msg , void(value, Msg)) eventm
    ,value(str , Msg(str) , void(value, Msg)) eventf
    ];
 */
 data Widget
     = widget(int process = -1, str id = "", str eventName="main", str val = "none"
     ,Widget() div = widgetVoid
     ,Widget() span = widgetVoid
     ,Widget() h1 = widgetVoid
     ,Widget() h2 = widgetVoid
     ,Widget() h3 = widgetVoid
     ,Widget() h4 = widgetVoid
     ,Widget() table = widgetVoid
     ,Widget() tr = widgetVoid
     ,Widget() td = widgetVoid
     ,Widget() button = widgetVoid
     ,Widget() input = widgetVoid
     ,Widget() svg = widgetVoid
     ,Widget() rect = widgetVoid
     ,Widget() circle = widgetVoid
     ,Widget() path = widgetVoid
     ,Widget(str) class = widgetStr
     ,Widget(str) style = widgetStr
     ,Widget(str, str) attr = widgetStrStr
     ,Widget(num) width  = widgetNum
     ,Widget(num) height  = widgetNum
     ,Widget(num) x = widgetNum
     ,Widget(num) y = widgetNum
     ,Widget(num) cx = widgetNum
     ,Widget(num) cy = widgetNum
     ,Widget(num) r = widgetNum
     ,Widget(str) innerHTML = widgetStr
     ,Widget(str ,  void(value)) event  = widgetStrFun
     ,Widget(str , Msg , void(Msg)) eventm = widgetEvent1
     ,Widget(str , Msg(str) , void(Msg)) eventf = widgetEvent2
     );
      
 private Widget newWidget(Widget p,  str id) {
    return newWidget(p, id, p.eventName);
    }
    
private Widget newWidget(Widget p,  str id, str eventName) {
    Widget _r =  widget(process=p.process, id=id, eventName=eventName);
     _r.div = Widget() {return xml(_r, "div");};
    _r.span = Widget() {return xml(-r, "span");};
    _r.h1 = Widget() {return xml(_r, "h1");};
    _r.h2 = Widget() {return xml(_r, "h2");};
    _r.h3 = Widget() {return xml(-r, "h3");};
    _r.h4 = Widget() {return xml(_r, "h4");};
    _r.table = Widget() {return xml(_r, "table");};
    _r.tr = Widget() {return xml(_r, "tr");};
    _r.td = Widget() {return xml(_r, "td");};
    _r.button = Widget() {return xml(_r, "button");};
    _r.input = Widget() {return xml(_r, "input");};
    _r.svg = Widget() {return xml(_r, "svg");};
    _r.rect = Widget() {return xml(_r, "rect");};
    _r.circle = Widget() {return xml(_r, "circle");};
    _r.path = Widget() {return xml(_r, "path");};
    _r.class = class(_r);
    _r.style = style(_r);
    _r.attr = attr(_r);
    _r.width = width(_r);
    _r.height = height(_r);
    _r.x = x(_r);
    _r.y = y(_r);
    _r.cx = cx(_r);
    _r.cy = cy(_r);
    _r.r = r(_r);
    _r.innerHTML = innerHTML(_r);
    _r.event = event(_r);
    _r.eventm = eventm(_r);
    _r.eventf = eventf(_r);
    return _r;
    }

private Widget(str, str) attr(Widget p) {
   return Widget(str key, str val) {
        return attribute(p, key, val); 
        };
    }
    
private Widget(str) style(Widget p) {
   return Widget(str val) {
        return attribute(p, "style", val); 
        };
    }
    
private Widget(str, void(Widget)) event(Widget p) {
    return Widget(str eventName, void(Widget) val) {
         void() q = () {val(p);};
         if (!(events[p.process]?)) events[p.process] = [];
         events[p.process]+=<{<p.id, eventName>} , q>;
         Widget r = newWidget(p, p.id);
         return r;
         };
    }
    
private Widget(str, Msg, void(Msg)) eventm(Widget p) {
    return Widget(str eventName, Msg m, void(Msg) val) {
         void() q = () {val(m);};
         if (!(events[p.process]?)) events[p.process] = [];
         events[p.process]+=<{<p.id, eventName>} , q>;
         Widget r = newWidget(p, p.id);
         return r;
         };
    }
    
private Widget(str, Msg(str), void(Msg)) eventf(Widget p) {
    return Widget(str eventName, Msg(str) m, void(Msg) val) {
         void() q = () {str s = property(p, "value");val(m(s));};
         if (!(events[p.process]?)) events[p.process] = [];
         events[p.process]+=<{<p.id, eventName>} , q>;
         Widget r = newWidget(p, p.id);
         return r;
         };
    }
/*   
private Widget() divf(Widget p) {
   return Widget() {
        return div(p); 
        };
    }
*/
   
private Widget(str) class(Widget p) {
   return Widget(str c) {
        return attribute(p, "class",c); 
        };
    }

    
private Widget(num) width(Widget p) {
   return Widget(num w) {
        return attribute(p, "width","<w>"); 
        };
    }
    
private Widget(num) height(Widget p) {
   return Widget(num h) {
        return attribute(p, "height","<h>"); 
        };
    }
    
private Widget(num) x(Widget p) {
   return Widget(num d) {
        return attribute(p, "x","<d>"); 
        };
    }
    
private Widget(num) y(Widget p) {
   return Widget(num d) {
        return attribute(p, "y","<d>"); 
        };
    }
    
private Widget(num) cx(Widget p) {
   return Widget(num d) {
        return attribute(p, "cx","<d>"); 
        };
    }
    
private Widget(num) cy(Widget p) {
   return Widget(num d) {
        return attribute(p, "cy","<d>"); 
        };
    }
    
private Widget(num) r(Widget p) {
   return Widget(num d) {
        return attribute(p, "r","<d>"); 
        };
    }
    
private Widget(str) innerHTML(Widget p) =
   Widget(str s) {
        return innerHTML(p, s); 
        };



public Widget defaultWidget = widget();

Widget createRootWidget(int p, str result) {
   return newWidget(widget(process=p, id=""), result);
}

Widget widgetVoid() {return defaultWidget;}

Widget widgetStr(str x) {return defaultWidget;}

Widget widgetInt(int x) {return defaultWidget;}

Widget widgetNum(num x) {return defaultWidget;}

Widget widgetStrStr(str x, str y) {return defaultWidget;}

Widget widgetStrFun(str x, void(value) y) {return defaultWidget;}

Widget widgetStrValVal(str x, value y, value z) {return defaultWidget;}

Widget widgetEvent1(str x, Msg y, void(Msg) z) {return defaultWidget;}

Widget widgetEvent2(str x, Msg(str) y, void(Msg) z) {return defaultWidget;}

public Widget createPanel(str initPage="MainPanel", int portNumber= 8001
                         ,int width = 800, int height = 800) {
    int p = openSocketConnection("display.MainPanel", initPage = initPage, portNumber = portNumber
    ,width = width, height = height); 
    setPrecision(3);
    str result = exchange(p, "root", [],sep);
    Widget r =  createRootWidget(p, result);
    width0 = width; height0 = height;
    return r;
    }
    
public Widget createSvgPanel() {
    Widget w = createPanel();
    Widget s =   svg(w).width(width0).height(height0);
    return w;
    }
    
public Widget select(Widget p, str id) {
    }
str sep = ";:";
    
private Widget xml(Widget p, str tg) = newWidget(p, exchange(p.process, tg, [p.id], sep));
    
public Widget h1(Widget p) = newWidget(p, exchange(p.process, "h1", [p.id], sep));

public Widget h2(Widget p) = newWidget(p, exchange(p.process, "h2", [p.id], sep));

public Widget h3(Widget p) = newWidget(p, exchange(p.process, "h3", [p.id], sep));

public Widget h4(Widget p) = newWidget(p, exchange(p.process, "h4", [p.id], sep));
  
public Widget div(Widget p) = newWidget(p, exchange(p.process, "div", [p.id], sep));

public Widget p(Widget p) = newWidget(p, exchange(p.process, "p", [p.id], sep));

public Widget ul(Widget p) = newWidget(p, exchange(p.process, "ul", [p.id], sep));

public Widget ol(Widget p) = newWidget(p, exchange(p.process, "ol", [p.id], sep));

public Widget li(Widget p) = newWidget(p, exchange(p.process, "li", [p.id], sep));

public Widget span(Widget p) = newWidget(p, exchange(p.process, "span", [p.id], sep));
    
public Widget svg(Widget p) {
    str result = exchange(p.process, "svg", [p.id], sep);
    Widget r = newWidget(p, result);
    return r;
    }
    
public Widget button(Widget p) {
    str result = exchange(p.process, "button", [p.id], sep);
    Widget r = newWidget(p, result);
    return r;
    }
    
public Widget setInterval(Widget p, int interval) = newWidget(p, exchange(p.process, "setInterval", [p.id, "<interval>"], sep)); 

public Widget clearInterval(Widget p) = newWidget(p, exchange(p.process, "clearInterval", [p.id], sep)); 
    
public Widget input(Widget p) = newWidget(p, exchange(p.process, "input", [p.id], sep)); 
    
public Widget rect(Widget p) = newWidget(p, exchange(p.process, "rect", [p.id], sep));

public Widget line(Widget p) = newWidget(p, exchange(p.process, "line", [p.id], sep));

public Widget ellipse(Widget p) = newWidget(p, exchange(p.process, "ellipse", [p.id], sep));

public Widget circle(Widget p) = newWidget(p, exchange(p.process, "circle", [p.id], sep));

public Widget polygon(Widget p) = newWidget(p, exchange(p.process, "polygon", [p.id], sep));

public Widget use(Widget p, Widget g) = newWidget(p, exchange(p.process, "use", [p.id,g.id], sep));

public Widget path(Widget p, Widget markerStart = defaultWidget, Widget markerMid = defaultWidget
     , Widget markerEnd = defaultWidget ) {
     Widget w = newWidget(p, exchange(p.process, "path", [p.id], sep));
     str style = "";
     if (markerStart != defaultWidget) {
          style += "marker-start: url(#<markerStart.id>);";
          }
     if (markerMid != defaultWidget) {
          style += "marker-mid: url(#<markerMid.id>);";
          }
     if (markerEnd != defaultWidget) {
          style += "marker-end: url(#<markerEnd.id>);";
          }
     if (!isEmpty(style)) w.style(style);
     return w;
     }

public Widget text(Widget p) = newWidget(p, exchange(p.process, "text", [p.id], sep));

public Widget g(Widget p) = newWidget(p, exchange(p.process, "g", [p.id], sep));

public Widget defs(Widget p) = newWidget(p, exchange(p.process, "defs", [p.id], sep));

public Widget marker(Widget p) = newWidget(p, exchange(p.process, "marker", [p.id], sep));

public Widget removechilds(Widget p) = newWidget(p, exchange(p.process, "removechilds", [p.id], sep));
    
public Widget attribute(Widget p, str key, str val) { 
    exchange(p.process, "attribute", [p.id, key, val], sep);
    //  WHY ????
    Widget r = newWidget(p, p.id);
    return r;
    // return p;
    }
    
public str attribute(Widget p, str attr) {
    // println("attribute:<p.id> <attr>");
    return exchange(p.process, "attribute", [p.id, attr], sep);
    }
    
public str style(Widget p, str attr) {
    // println("attribute:<p.id> <attr>");
    return exchange(p.process, "style", [p.id, attr], sep);
    }
    
 public Widget property(Widget p, str key, str val) { 
    exchange(p.process, "property", [p.id, key, val], sep);
    //  WHY ????
    Widget r = newWidget(p, p.id);
    return r;
    // return p;
    }
    
public str property(Widget p, str attr) {
    // println("attribute:<p.id> <attr>");
    return exchange(p.process, "property", [p.id, attr], sep);
    }
    
 public Bounds getBBox(Widget p) {
   // println("attribute:<p.id> <attr>");
    str r = exchange(p.process, "getBBox", [p.id], sep);
    // return round(toReal(r));
    map[str, num] z = parseJSON(#map[str, num], r);
    return <z["x"], z["y"], z["width"], z["height"]>;
    }
    
 public Bounds getBoundingClientRec(Widget p) {
   // println("attribute:<p.id> <attr>");
    str r = exchange(p.process, "getBoundingClientRec", [p.id], sep);
    // return round(toReal(r));
    map[str, num] z = parseJSON(#map[str, num], r);
    return <z["left"], z["top"], z["width"], z["height"]>;
    }
    
public Widget innerHTML(Widget p, str text) {
    exchange(p.process, "innerHTML", [p.id, text], sep);
    Widget r = newWidget(p, p.id);
    return r;
    }
    
 public str attribute(int p, str key, str attr, str val) {
    return exchange(p, "attribute", [key, attr, val], sep);
    }
    
public Widget waitForUser(Widget p) {
    str s = exchange(p.process, p.eventName, [p.id], sep);
    if (isEmpty(s)) return newWidget(p, "", "exit");
    list[str] r = split(":", s);
    if (size(r)<2) return defaultWidget;
    Widget z = newWidget(p, r[0], r[1]);
    if (size(r)==3) z.val = r[2];       
    return z;
    }
    
public map[str, str] style(Widget p) {
   str s = attribute(p, "style");
   list[str] styles = split(";", s);
   map[str, str] r = (styl[0]: styl[1]|str x<-styles, list[str] styl:=split(":", x));
   return r;
   }
    
@reflect{For getting IO streams}
@javaClass{display.SocketConnection}
public java int openSocketConnection(str javaClass, loc workingDir=|cwd:///|, list[str] args = [], map[str,str] envVars = ()
, int portNumber=8000, str initPage="mainPage", int width = 800, int height = 800);

@reflect{For getting IO streams}
@javaClass{display.SocketConnection}
public java str exchange(int processId, str toServer);


public str exchange(int processId, str key, list[str] toServer, str sep) {
   list[str] args  = [key]+toServer;
   // println(size(intercalate(sep, args)));
   return exchange(processId, replaceAll(intercalate(sep, args),"\n", " "));
   }

@reflect{For getting IO streams}
@javaClass{display.SocketConnection}
public java str getResource(str javaClass);


@javaClass{display.SocketConnection}
public java void closeSocketConnection(int processId, bool force);

//eventLoop(z, ({<up.id, click>}:()  {counter+=1;}
     //            ,{<down.id, click>}:() {counter-=1;}
     //             ,{<up.id, click>, <down.id, click>}:() {r.innerHTML("<counter>");}
     //         ); 
  
 public void eventLoop(lrel[set[tuple[Widget w , str eventName]], void()] eventName) { 
      if (isEmpty(eventName) || isEmpty(eventName[0][0])) return;
      lrel[set[tuple[str id , str eventName]], void()] r = 
         [<{<y[0].id, y[1]>|tuple[Widget w , str eventName] y<-x[0]}, x[1]>|tuple[set[tuple[Widget w , str eventName]], void()] x<-eventName];
      eventLoop(getOneFrom(eventName[0][0])[0], r);
      }
      
 bool procIn(tuple[str id, str eventName] t, set[tuple[Widget() w, str eventName]] key) {
      for (tuple[Widget() w, str eventName] x<-key) {
          if (t.id == x.w().id && t.eventName == x.eventName) return true;
          }
      return false;
      }
      
 public void eventLoop(lrel[set[tuple[Widget() w , str eventName]], void()] events) { 
      if (isEmpty(events) || isEmpty(events[0][0])) return;
      Widget z = getOneFrom(events[0][0])[0]();
      while (true) {
        Widget s = waitForUser(z);
        // println("eventLoop: <s.id> <s.eventName>");
        if (s.process<0) continue;
        if (s.eventName=="exit") {println("exit"); return;}
        tuple[str, str] t = <s.id, s.eventName>;
        for (tuple[set[tuple[Widget() w, str eventName]] key, void() f] ev <-  events) {
             if (procIn(t, ev.key)) ev.f();
             }
        } 
     }  
 
     
 public void eventLoop(Widget z, lrel[set[tuple[str id , str eventName]], void()] events1) {
      while (true) {
        Widget s = waitForUser(z);
        // println("eventLoop: <s.id> <s.eventName>");
        if (s.process<0) continue;
        if (s.eventName=="exit") {println("exit"); return;}
        tuple[str, str] t = <s.id, s.eventName>;
        for (tuple[set[tuple[str id, str eventName]] key, void() f] ev <-  events[z.process]) {
             if (t in ev.key) ev.f();
             }
        for (tuple[set[tuple[str id, str eventName]] key, void() f] ev <-  events1) {
             if (t in ev.key) ev.f();
             }
        } 
     }


