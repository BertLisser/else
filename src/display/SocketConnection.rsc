module display::SocketConnection
import Prelude;
import util::Math;


// Events
public str click  = "click";
public str change = "change";
public str tick = "tick";

data Msg = empty();

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
     ,Widget(str) class = widgetStr
     ,Widget(str) style = widgetStr
     ,Widget(str, str) attr = widgetStrStr
     ,Widget(int) width  = widgetInt
     ,Widget(int) height  = widgetInt
     ,Widget(int) x = widgetInt
     ,Widget(int) y = widgetInt
     ,Widget(int) cx = widgetInt
     ,Widget(int) cy = widgetInt
     ,Widget(int) r = widgetInt
     ,Widget(str) innerHTML = widgetStr
     ,Widget(str ,  void(value)) event  = widgetStrFun
     ,Widget(str , Msg , void(value, Msg)) eventm = widgetEvent1
     ,Widget(str , Msg(str) , void(value, Msg)) eventf = widgetEvent2
     );
      
 private Widget newWidget(Widget p,  str id) {
    return newWidget(p, id, p.eventName);
    }
    
private Widget newWidget(Widget p,  str id, str eventName) {
    Widget _r =  widget(process=p.process, id=id, eventName=eventName);
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
    
private Widget(str, Msg, void(Widget, Msg)) eventm(Widget p) {
    return Widget(str eventName, Msg m, void(Widget, Msg) val) {
         void() q = () {val(p, m);};
         if (!(events[p.process]?)) events[p.process] = [];
         events[p.process]+=<{<p.id, eventName>} , q>;
         Widget r = newWidget(p, p.id);
         return r;
         };
    }
    
private Widget(str, Msg(str), void(Widget, Msg)) eventf(Widget p) {
    return Widget(str eventName, Msg(str) m, void(Widget, Msg) val) {
         void() q = () {str s = property(p, "value");val(p, m(s));};
         if (!(events[p.process]?)) events[p.process] = [];
         events[p.process]+=<{<p.id, eventName>} , q>;
         Widget r = newWidget(p, p.id);
         return r;
         };
    }
   
private Widget(str) class(Widget p) {
   return Widget(str c) {
        return attribute(p, "class",c); 
        };
    }

    
private Widget(int) width(Widget p) {
   return Widget(int w) {
        return attribute(p, "width","<w>"); 
        };
    }
    
private Widget(int) height(Widget p) {
   return Widget(int h) {
        return attribute(p, "height","<h>"); 
        };
    }
    
private Widget(int) x(Widget p) {
   return Widget(int d) {
        return attribute(p, "x","<d>"); 
        };
    }
    
private Widget(int) y(Widget p) {
   return Widget(int d) {
        return attribute(p, "y","<d>"); 
        };
    }
    
private Widget(int) cx(Widget p) {
   return Widget(int d) {
        return attribute(p, "cx","<d>"); 
        };
    }
    
private Widget(int) cy(Widget p) {
   return Widget(int d) {
        return attribute(p, "cy","<d>"); 
        };
    }
    
private Widget(int) r(Widget p) {
   return Widget(int d) {
        return attribute(p, "r","<d>"); 
        };
    }
    
private Widget(str) innerHTML(Widget p) =
   Widget(str s) {
        return innerHTML(p, s); 
        };

str sep = ";:";

public Widget defaultWidget = widget();

Widget createRootWidget(int p, str result) {
   return widget(process=p, id = result);
}

Widget widgetStr(str x) {return defaultWidget;}

Widget widgetInt(int x) {return defaultWidget;}

Widget widgetStrStr(str x, str y) {return defaultWidget;}

Widget widgetStrFun(str x, void(value) y) {return defaultWidget;}

Widget widgetStrValVal(str x, value y, value z) {return defaultWidget;}

Widget widgetEvent1(str x, Msg y, void(value, Msg) z) {return defaultWidget;}

Widget widgetEvent2(str x, Msg(str) y, void(value, Msg) z) {return defaultWidget;}

public Widget createPanel(str initPage="MainPanel", int portNumber= 8000) {
    int p = openSocketConnection("display.MainPanel", initPage = initPage, portNumber = portNumber); 
    str result = exchange(p, "root", [],sep);
    Widget r =  createRootWidget(p, result);
    return r;
    }
    
public Widget createSvgPanel() {
    Widget w = createPanel();
    Widget s =   svg(w).width(800).height(800);
    return w;
    }
    
public Widget select(Widget p, str id) {
    }
    
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
    
 public int bounds(Widget p, str attr) {
   // println("attribute:<p.id> <attr>");
    str r = exchange(p.process, "bounds", [p.id, attr], sep);
    return round(toReal(r));
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
, int portNumber=8000, str initPage="mainPage");

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


