module display::demo::basic::Counter
import display::SocketConnection;
import Prelude;

data Msg = inc()
         | dec();
         
alias Model = tuple[int count];
Model model = <0>;
Widget view = defaultWidget;

void updateModel(Msg msg) {
  switch (msg) {
    case inc(): model.count += 1;
    case dec(): model.count -= 1;
  }
}

void updateView(Msg msg) {
  view.innerHTML("<model.count>");
  }
  
void update(Widget w, Msg msg) {
   updateModel(msg);
   updateView(msg);
}

public void main() {
    Widget z=createPanel();
    Widget d = div(z);
    Widget h = h2(d).innerHTML("My first counter app in Rascal");  
    Widget up = button(d).innerHTML("+").eventm(click, inc(), update);  
    Widget down = button(d).innerHTML("-").eventm(click,dec(), update);
    view = div(d).innerHTML("<model.count>");
    updateView(inc());
    eventLoop(z, []); 
    }