/**
 * Copyright (c) 2018, BertLisser, Centrum Wiskunde & Informatica (CWI) All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions
 * and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided with
 * the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package display;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;

import io.usethesource.vallang.IBool;
import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IList;
import io.usethesource.vallang.IMap;
import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class SocketConnection {
    private final IValueFactory vf;
    private static HashMap<IInteger, Process> runningProcesses = new HashMap<IInteger, Process>();
    private static HashMap<IInteger, Socket> sockets = new HashMap<IInteger, Socket>();
    private static IInteger processCounter = null;
    private final int sleep = 2000;

    public SocketConnection(IValueFactory vf) {
        this.vf = vf;
    }

    public synchronized IInteger openSocketConnection(IString javaClass, ISourceLocation workingDir, IList arguments,
        IMap envVars, IInteger portNumber, IString initPage, IInteger width, IInteger height, IEvaluatorContext eval) {
        PrintWriter out = eval.getStdOut();
        // String path = this.getClass().getResource(javaClass.getValue()).getPath();
        String path = eval.getConfiguration().getRascalJavaClassPathProperty();
        // out.println(path);
        try {
            // Build the arg array using the command and the command arguments passed in the arguments list
            List<String> args = new ArrayList<String>();
            args.add("/usr/bin/java");
            args.add("-cp");
            args.add(path);
            args.add(javaClass.getValue());
            args.add("" + portNumber.intValue());
            args.add(initPage.getValue());
            args.add(""+width.intValue());
            args.add(""+height.intValue());
            if (arguments != null) {
                for (int n = 0; n < arguments.length(); ++n) {
                    if (arguments.get(n) instanceof IString)
                        args.add(((IString) arguments.get(n)).getValue());
                    else
                        throw RuntimeExceptionFactory.illegalArgument(arguments.get(n), null, null);
                }
            }
            ProcessBuilder pb = new ProcessBuilder(args);

            // Built the environment var map using the envVars map
            Map<String, String> vars = new HashMap<String, String>();
            if (envVars != null && envVars.size() > 0) {
                for (IValue varKey : envVars) {
                    if (varKey instanceof IString) {
                        IString strKey = (IString) varKey;
                        IValue varVal = envVars.get(varKey);
                        if (varVal instanceof IString) {
                            IString strVal = (IString) varVal;
                            vars.put(strKey.getValue(), strVal.getValue());
                        }
                        else {
                            throw RuntimeExceptionFactory.illegalArgument(varVal, null, null);
                        }
                    }
                    else {
                        throw RuntimeExceptionFactory.illegalArgument(varKey, null, null);
                    }
                }
            }
            Map<String, String> currentEnv = pb.environment();
            try {
                for (String strKey : vars.keySet()) {
                    currentEnv.put(strKey, vars.get(strKey));
                }
            }
            catch (UnsupportedOperationException uoe) {
                throw RuntimeExceptionFactory.permissionDenied(
                    vf.string("Modifying environment variables is not allowed on this machine."), null, null);
            }
            catch (IllegalArgumentException iae) {
                throw RuntimeExceptionFactory.permissionDenied(
                    vf.string("Modifying environment variables is not allowed on this machine."), null, null);
            }

            File cwd = null;
            if (workingDir != null && workingDir.getScheme().equals("file")) {
                cwd = new File(workingDir.getPath());
                pb.directory(cwd);
            }

            Process newProcess = pb.start();

            if (processCounter == null) {
                processCounter = vf.integer(0);
            }
            processCounter = processCounter.add(vf.integer(1));
            runningProcesses.put(processCounter, newProcess);
            try {
                Thread.sleep(sleep);
                String hostName = "localhost";
                Socket socket = new Socket(hostName, portNumber.intValue());
                int oldsize = socket.getReceiveBufferSize();
                socket.setReceiveBufferSize(oldsize * 4);
                sockets.put(processCounter, socket);
                Thread.sleep(sleep);
                return processCounter;
            }
            catch (IOException | InterruptedException e) {
                out.println(e.getMessage());
            }       
            return vf.integer(-1);
        }
        catch (IOException e) {
            throw RuntimeExceptionFactory.javaException(e, null, null);
        }
    }

    public synchronized void closeSocketConnection(IInteger processId, IBool force) {
        if (!runningProcesses.containsKey(processId))
            throw RuntimeExceptionFactory.illegalArgument(processId, null, null);

        if (sockets.containsKey(processId)) {
            try {
                sockets.get(processId).close();
            }
            catch (IOException e) {
                // eat it, we are just throwing it away anyway
            }
            finally {
                sockets.remove(processId);
            }
        }

        Process runningProcess = runningProcesses.get(processId);

        if (runningProcess.isAlive()) {
            if (force.getValue()) {
                runningProcess.destroyForcibly();
            }
            else {
                runningProcess.destroy();
            }
        }

        new Thread("zombie process clean up") {
            public void run() {
                try {
                    Thread.sleep(sleep);
                    if (!runningProcess.isAlive()) {
                        runningProcesses.remove(processId);
                    }
                }
                catch (InterruptedException e) {
                    // may happen occasionally
                }
            };
        }.start();


        return;
    }

    public IString exchange(IInteger processId, IString toServer, IEvaluatorContext eval) {
        PrintWriter out = eval.getStdOut();
        Socket clientSocket;
        // out.println(toServer.getValue());
        if (sockets.containsKey(processId)) {
            clientSocket = sockets.get(processId);
        }
        else {
            return vf.string("Unkown processId");
        }
        try {
            PrintWriter output = new PrintWriter(clientSocket.getOutputStream(), true);
            output.println(toServer.getValue());
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            String result = in.readLine();
            return vf.string(result);
        }
        catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return vf.string(e.getMessage());
        }
    }
    
    public IString getResource(IString className, IEvaluatorContext eval) {
        // return vf.string(this.getClass().getClassLoader().toString());
        // PrintWriter out=eval.getStdOut();
        // String[] path = eval.getConfiguration().getRascalJavaClassPathProperty().split(":");
        // return vf.string(path[0] + "/" + className.getValue());
        return vf.string(this.getClass().getResource(className.getValue()).getPath());
    }
    
    public static void main(String[] args) {
		System.out.println("Hello world");
	}
}
