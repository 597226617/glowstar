package com.glowstar.server;

import com.glowstar.server.ws.ConversationWebSocket;
import com.glowstar.server.ws.MessagesWebSocket;
import org.glassfish.grizzly.http.server.HttpHandler;
import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.grizzly.http.server.NetworkListener;
import org.glassfish.grizzly.websockets.WebSocketAddOn;
import org.glassfish.grizzly.websockets.WebSocketEngine;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpContainerProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.glowstar.server.services.DBInterface;
import com.glowstar.server.services.BlobInterface;
import com.glowstar.server.services.DatabaseInitializer;

import com.glowstar.server.config.HoodConfig;

public class GlowstarServer
{
	private static final int DEFAULT_PORT = 8080;
	
	private static final Logger logger = LoggerFactory.getLogger(GlowstarServer.class);
	
	private static boolean initializeServices()
	{
		if (HoodConfig.get() == null)
		{
			return false;
		}
		
		// Initialize PostgreSQL database
		DatabaseInitializer.initialize(DBInterface.get());
		
		if (!BlobInterface.get().initialize())
		{
			return false;
		}
		
		return true;
	}
	
	public static void main(String[] args) throws Exception
	{
		if (!initializeServices())
		{
			return;
		}
		
		
		HttpServer server = HttpServer.createSimpleServer("/", HoodConfig.get().serverPort());
		
		// api
		HttpHandler apiHandler = new GrizzlyHttpContainerProvider()
				.createContainer(HttpHandler.class, JaxRsApiResourceConfig.create());
		server.getServerConfiguration().addHttpHandler(apiHandler, "/api");
		
		// message websocket
		WebSocketAddOn addOn = new WebSocketAddOn();
		addOn.setTimeoutInSeconds(60);
		for (NetworkListener listener : server.getListeners()) {
			listener.registerAddOn(addOn);
		}
		
		WebSocketEngine.getEngine().register("", "/conversations", new ConversationWebSocket());
		WebSocketEngine.getEngine().register("", "/messages", new MessagesWebSocket());
		
		// shutdown hook
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			@Override
			public void run() {
				server.shutdownNow();
			}
		}));
		
		server.start();
	}
}
