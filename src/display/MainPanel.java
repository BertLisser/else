/** 
 * Copyright (c) 2018, BertLisser, Centrum Wiskunde & Informatica (CWI) 
 * All rights reserved. 
 *  
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: 
 *  
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
 *  
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
 *  
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */ 
package display;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.Border;
import javafx.scene.layout.BorderStroke;
import javafx.scene.layout.BorderStrokeStyle;
import javafx.scene.layout.BorderWidths;
import javafx.scene.layout.CornerRadii;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;

public class MainPanel extends Application{
    static int width = 800;
    static int height = 800;
    static int portNumber;
    static String initPage = "";
    
    @Override
    public void start(Stage primaryStage) {
        final WebView webView = new WebView();
        final WebEngine webEngine = webView.getEngine();
        final Label label = new Label();
        
        VBox box = new VBox();
        Border border = new Border(new BorderStroke(Color.DARKBLUE,
            BorderStrokeStyle.SOLID, CornerRadii.EMPTY,
            new BorderWidths(6)));
        final Scene scene = new Scene(box, width, height);
        label.setPrefHeight(30);
        label.setPrefWidth(width);
        webView.setPrefHeight(1000);
        // label.setBorder(border);
        box.setBorder(border);
        VBox.setVgrow(webView, Priority.ALWAYS);
        box.getChildren().add(webView);
        box.getChildren().add(label);   
        webEngine.getLoadWorker().stateProperty().addListener((obs, oldState, newState) -> {
            if (newState == Worker.State.SUCCEEDED) {
                label.setText("" + portNumber);
            }
        });
        if (!initPage.isEmpty())
        webEngine.load(this.getClass().getResource(initPage+".html").toString());
        primaryStage.setScene(scene);
        primaryStage.show();
        Task<Integer> task = new Task<Integer>() {
            void eMsg(String msg) {
                Platform.runLater(() -> {
                    label.setText(msg);
                });
            }
            @Override
            protected Integer call() throws Exception {
                try {
                    final ServerSocket serverSocket = new ServerSocket(portNumber);
                    final Socket clientSocket = serverSocket.accept();
                    serverSocket.close();
                    int oldsize = clientSocket.getSendBufferSize();
                    clientSocket.setSendBufferSize(oldsize * 4);
                    final PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
                    final DomUpdate root = new DomUpdate("root", webEngine, out);
                    Platform.runLater(()->{
                        root.addSendMessageHandler(out);
                        });
                    Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
                        public void run() {
                            try {
                                if (out!=null) out.println("");
                                if (clientSocket!=null) clientSocket.close();
                            }
                            catch (IOException e) {
                                eMsg(e.getMessage());
                            }
                        }
                    }));
                    BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                    String inputLine;   
                    while ((inputLine = in.readLine()) != null) {
                        final String[] input = inputLine.split(";:");
                        eMsg(input[0]);
                        Platform.runLater(() -> {                    
                            switch (input[0]) {
                                case "root": {
                                    out.println(root.getId());
                                    break;
                                }
                                case "innerHTML": {
                                    root.select(input[1]).innerHTML(input[2]);
                                    out.println("ok");
                                    break;
                                }
                                case "attribute": {
                                    // eMsg(""+input.length);
                                    if (input.length==4) {
                                       root.select(input[1]).attribute(input[2], input[3]);
                                       out.println("ok");
                                    }
                                    else if (input.length==3) {
                                        eMsg(""+input.length);
                                         String s = root.select(input[1]).attribute(input[2]);
                                       eMsg(s);
                                      out.println(s);
                                   }
                                    break;           
                                } 
                                case "property": {
                                    // eMsg(""+input.length);
                                    if (input.length==4) {
                                       root.select(input[1]).property(input[2], input[3]);
                                       out.println("ok");
                                    }
                                    else if (input.length==3) {
                                        eMsg(""+input.length);
                                         String s = root.select(input[1]).property(input[2]);
                                       eMsg(s);
                                      out.println(s);
                                   }
                                    break;           
                                } 
                                case "getBBox" : {
                                    eMsg(""+input.length);
                                    String s = root.select(input[1]).getBBox();
                                    eMsg(s);
                                    out.println(s);
                                }
                                case "getBoundingClientRec" : {
                                    eMsg(""+input.length);
                                    String s = root.select(input[1]).getBoundingCientRect();
                                    eMsg(s);
                                    out.println(s);
                                }
                                case "style" : {
                                    eMsg(""+input.length);
                                    String s = root.select(input[1]).style(input[2]);
                                    eMsg(s);
                                    out.println(s);
                                }
                                case "wait": {
                                    break;
                                }
                                case "exit": {          
                                    return;
                                }
                                case "use": {
                                     DomUpdate.use(webEngine, input[1], input[2]);
                                     eMsg(input[2]);
                                     out.println("ok");
                                     break;
                                }
                                case "setInterval": {
                                     String r = DomUpdate.setInterval(webEngine, input[1], input[2]); 
                                     eMsg("setInterval:"+r);
                                     out.println(r);
                                     break;  
                                     }
                                case "clearInterval": {
                                    eMsg("clearInterval:"+input[1]);
                                    String r = DomUpdate.clearInterval(webEngine, input[1]);
                                    out.println(r);
                                    break;  
                                    }
                                default: {
                                    String g = input[0].toUpperCase();
                                    String r = DomUpdate.Op.valueOf(g).build(webEngine, input[1]);
                                    out.println(r);
                                    break;
                                }
                            }
                        });
                    }
                    return 0;
                }
                catch (IOException e) {
                    eMsg("Exception caught when trying to listen on port " + portNumber
                        + " or listening for a connection");
                    eMsg(e.getMessage());
                }
                return 0;
            }
        };
        // System.err.println("Finished");
        Thread th = new Thread(task);
        th.setDaemon(true);
        th.start();
    }
    
    public static void main(String[] args) {
        System.err.println("Start:");
        if (args.length > 0)
            portNumber = Integer.parseInt(args[0]);
        else
            portNumber = 6005;
        if (args.length>1)
        initPage = args[1];
        if (args.length>2) {
           width = Integer.parseInt(args[2]);
           height = Integer.parseInt(args[3]);
        }
        System.err.println("Start:" + portNumber+" "+width+" "+height);
        launch();
    }

}
