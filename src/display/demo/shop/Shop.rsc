module display::demo::shop::Shop

import display::SocketConnection;
import Prelude;

// This app is based on: https://www.mendix.com/tech-blog/making-react-reactive-pursuit-high-performing-easily-maintainable-react-apps/

data Article
  = article(str name, real price, int id, str newName = "", real newPrice = 0.0);
  
data Entry
  = entry(int id, int amount);
  
alias Cart = list[Entry];

alias Model = tuple[
  list[Article] articles, 
  Cart cart,
  str newName,
  real newPrice
];

data Msg
  = editName(int idx, str name)
  | editPrice(int idx, str price)
  | save(int idx)
  | addToCart(int idx)
  | removeFromCart(int idx)
  | newPrice(str price)
  | newName(str name)
  | newArticle()
  | updateSome() // TODO
  | createLots() // TODO
  ;
  
tuple[Widget articles, Widget cart, Widget span] view = < defaultWidget, defaultWidget, defaultWidget>;
  
int _id = -1;
int nextId() { return _id += 1; }

Msg(str) editName(int idx) = Msg(str s) { return editName(idx, s); };
Msg(str) editPrice(int idx) = Msg(str s) { return editPrice(idx, s); };

Article findArticle(int id, Model m) = [ a | Article a <- m.articles, a.id == id][0];

void updateModel(Msg msg) {
  switch (msg) {
    case editName(int idx, str name):
      model.articles[idx].newName = name;    
    case editPrice(int idx, str price):
      model.articles[idx].newPrice = toReal(price); 
    case save(int idx): {
      model.articles[idx].price = model.articles[idx].newPrice;
      model.articles[idx].name = model.articles[idx].newName;
    }  
    case addToCart(int idx): {
      Article a = model.articles[idx];
      if (int i <- [0..size(model.cart)], model.cart[i].id == a.id) {
        model.cart[i] = model.cart[i][amount = model.cart[i].amount + 1];
      }
      else {
	      model.cart += [entry(model.articles[idx].id, 1)];
	    }
    }
    case removeFromCart(int idx): {
      Entry e = model.cart[idx];
      if (e.amount == 1) {
        model.cart = delete(model.cart, idx); 
      }
      else {
        model.cart[idx] = e.amount -= 1;
      }
    }  
    case newPrice(str price):
      model.newPrice = toReal(price);
    case newName(str name): {
      model.newName = name;
      }
    case newArticle(): {
      model.articles += [Article::article(model.newName, model.newPrice, nextId())];
      }
  }
}

void updateView(Msg msg) {
        switch (msg) {
        case newArticle(): {
          removechilds(view.articles);
          for (int i <- [0..size(model.articles)]) 
             articleView(view.articles, model.articles[i], i);          
          }
        case addToCart(_): {
           removechilds(view.cart);
           for (int i <- [0..size(model.cart)]) {
             Widget l = li(view.cart);
             button(l).innerHTML("\<\<");
             span(l).innerHTML(findArticle(model.cart[i].id, model).name);
             span(l).class("price").innerHTML("<model.cart[i].amount>x"); 
           }
           real total = ( 0.0 | it + e.amount * findArticle(e.id, model).price | Entry e <- model.cart);
           view.span.innerHTML("Total: € <total>");
        }
       }
    }
   
void update(Widget p, Msg msg) {
    updateModel(msg);
    updateView(msg);
    }

void articlesView(Widget w) {
    Widget d = div(w);
    p(d).innerHTML("Article name");
    Widget i1 = input(d).attr("value", model.newName).attr("type", "text");
    p(d).innerHTML("Price (a number)");
    Widget i2 = input(d).attr("value", "<model.newPrice>").attr("type", "text");
    Widget b = button(d).innerHTML("new article").eventm("click", newArticle(), update);
    view.articles = ul(d);
    i1.eventf(change, newName, update); 
    i2.eventf(change, newPrice,  update); 
    updateView(newArticle());
}

void articleView(Widget w, Article a, int i) {
  Widget l = li(w);
  span(l).innerHTML(a.name);
  Widget b = button(l).innerHTML("\>\>").eventm(click, addToCart(i), update);
  span(l).class("price").innerHTML("€ <a.price>");
}

void cartView(Widget w) {
  cartview = div(w);
  view.cart=ul(cartview);
  view.span=span(cartview);
  updateView(addToCart(0));
}

Model model = <
    [Article::article("Funny Bunnies", 17.63, nextId()),
     Article::article("Awesome React", 23.95, nextId()),
     Article::article("Second hand Netbook", 50.00, nextId())],
     [entry(0, 1)],
     "",
     0.0
    >;
    
void shopDemoView(Widget w) {
    Widget d = div(w);
    h1(d).innerHTML("Elm-in-Rascal shopping cart demo");
    Widget table = div(d).class("rTable");
    Widget row1 =  div(table).class("rTableRow");
    Widget button1 = div(row1).class("rTableCell");
          button(button1).innerHTML("update some items");
    Widget button2 = div(row1).class("rTableCell");
          button(button2).innerHTML("create a lot of items");
    Widget row2 =  div(table).class("rTableRow");
        Widget c1 =  div(row2).class("rTableCell");
          h2(c1).innerHTML("Available items");
    articlesView(c1);
        Widget c2 =  div(row2).class("rTableCell");
          h2(c2).innerHTML("Your shopping cart");
    cartView(c2);
}

public void main() {  
   Widget z=createPanel();
   shopDemoView(z);
   eventLoop(z, []); 
   }