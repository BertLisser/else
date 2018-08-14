module display::demo::basic::Celsius
import display::SocketConnection;
import Prelude;
import util::Math;

@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}


alias Model = real;

data Msg
  = c(str c)
  | f(str f)
  ; 

real toF(real c) = c * 9.0/5.0 + 32.0;

real toC(real f) = (f - 32.0) * 5.0/9.0;

real toReal_(str s) {
  try {
    return toReal(s);
  }
  catch IllegalArgument():
    return 0.0;
}

void updateView(Model m, Msg msg, Widget cc, Widget ff) {
    switch (msg) {
       case c(_): {property(ff, "value", "<round(toF(m))>");}
       case f(_): {property(cc, "value", "<round(m)>");}
       }
    }

Model update(Model m , Msg msg) {
  switch (msg) {
    case c(str new): {m = toReal_(new);}
    case f(str new): {m = toC(toReal_(new));}
  }
  return m;
}

public void main() {
   Model model = 37.0;
   Widget z=createPanel();
   Widget d = div(z);
   h2(d).innerHTML("Celsius to fahrenheit converter");
   Widget pp  = p(d); span(pp).innerHTML("C:"); 
   Widget cc = input(pp).attr("value", "<round(model)>").attr("type", "text");
   pp  = p(d); span(pp).innerHTML("F:"); 
   Widget ff = input(pp).attr("value", "<round(toF(model))>").attr("type", "text");
   void(Widget) updateChange() {
      return void(Widget w) {
         Msg msg;
         if (w.id == cc.id) {msg = c(property(w, "value"));}
         if (w.id == ff.id) {msg = f(property(w, "value"));}
         model=update(model, msg);
         updateView(model, msg, cc ,ff); 
         };
      }
    cc.event(change, updateChange());
    ff.event(change, updateChange());
    eventLoop(z, []); 
   }