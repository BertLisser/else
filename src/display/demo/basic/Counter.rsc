module display::demo::basic::Counter
import display::SocketConnection;
import Prelude;

data Msg = inc()
         | dec();
         
alias Model = tuple[int count];
Model model = <0>;
Widget display = defaultWidget;
Widget mainWindow = defaultWidget;

void updateModel(Msg msg) {
  switch (msg) {
    case inc(): model.count += 1;
    case dec(): model.count -= 1;
  }
}

void view(Msg msg) {
  if (msg==init()) {
    mainWindow = createPanel();
    Widget d = div(mainWindow);
    Widget h = h2(d).innerHTML("My first counter app in Rascal");  
    Widget up = button(d).innerHTML("+").eventm(click, inc(), update);  
    Widget down = button(d).innerHTML("-").eventm(click,dec(), update);
    display = div(d);
    } 
  display.innerHTML("<model.count>");
  }
  
void update(Widget w, Msg msg) {
   updateModel(msg);
   view(msg);
}

public void main() {
    view(init());
    eventLoop(mainWindow , []); 
    }