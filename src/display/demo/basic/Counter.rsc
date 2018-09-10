module display::demo::basic::Counter
import display::SocketConnection;
import Prelude;

data Msg = inc()
         | dec();
         
alias Model = tuple[int count];
Model model = <0>;


Widget display = defaultWidget;

void updateModel(Msg msg) {
  switch (msg) {
    case inc(): model.count += 1;
    case dec(): model.count -= 1;
  }
}

Widget view(Msg msg) {
  if (msg==init()) {
    Widget mainWindow = createPanel();
    Widget d = mainWindow.div();
    Widget h = d.h2().innerHTML("My first counter app in Rascal");  
    Widget up = d.button().innerHTML("+").eventm(click, inc(), update).style("background-color:green");  
    Widget down = d.button().innerHTML("-").eventm(click,dec(), update);
    display = d.div();
    } 
  display.innerHTML("<model.count>");
  return display;
  }
  
void update(Msg msg) {
   updateModel(msg);
   view(msg);
}

public void main() {
    eventLoop(view(init()) , []); 
    }