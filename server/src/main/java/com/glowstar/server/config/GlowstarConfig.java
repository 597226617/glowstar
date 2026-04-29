package com.glowstar.server.config;

import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.cfg4j.source.ConfigurationSource;
import org.cfg4j.source.files.FilesConfigurationSource;
import org.cfg4j.source.context.filesprovider.ConfigFilesProvider;
import org.cfg4j.provider.ConfigurationProvider;
import org.cfg4j.provider.ConfigurationProviderBuilder;
import org.cfg4j.source.reload.strategy.PeriodicalReloadStrategy;

public class GlowstarConfig
{
	private static final Logger logger = LoggerFactory.getLogger(GlowstarConfig.class);

	private static GlowstarConfigParameters instance;

	public static GlowstarConfigParameters get()
	{
		if (instance != null)
		{
			return instance;
		}

		synchronized (GlowstarConfigParameters.class)
		{
			if (instance != null)
			{
				return instance;
			}

			instance = GlowstarConfig.create();
			return instance;
		}
	}

	private static GlowstarConfigParameters create()
	{
		try
		{
			ConfigFilesProvider configFilesProvider = new GlowstarConfigFilesProvider();
			ConfigurationSource source = new FilesConfigurationSource(configFilesProvider);

			logger.info("Loading config from: {}", configFilesProvider);

			ConfigurationProvider provider = new ConfigurationProviderBuilder()
				.withConfigurationSource(source)
				.withReloadStrategy(new PeriodicalReloadStrategy(5, TimeUnit.SECONDS))
				.build();

			return provider.bind("", GlowstarConfigParameters.class);
		}
		catch (Exception e)
		{
			logger.error("Error loading configuration", e);
			return null;
		}
	}
}
