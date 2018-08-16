# else an alternative for salix
A variant of salix which displays figures with help of java fx. In the beginning Rascal behaves as a client, and graphical user interface, 
which runs Jave Fx, is the server. Entered graphical rascal commands will be directly displayed. In the second phase, in the rascal waitEventLoop, 
the roles of the processes will be reversed.
We will use the Msg, Model, View idea of Salix. The view has,opposed to Salix, consits of a stable part and a part which will be updated that 
depends on the Msg argument. 

An advantage of this is, that the implementation can be much simpler, because there is no need to detect the changes in the dom tree on 
the rascal side. In fact it is more like an advising frame work, then a forcing system.
```
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
```
