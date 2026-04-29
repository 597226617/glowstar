package com.glowstar.server.config;

import java.io.File;
import java.lang.Iterable;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.commons.lang3.StringUtils;

import org.cfg4j.source.context.filesprovider.ConfigFilesProvider;

public class GlowstarConfigFilesProvider implements ConfigFilesProvider
{
	private static final Logger logger = LoggerFactory.getLogger(GlowstarConfigFilesProvider.class);

	private String getConfigFilePath()
	{
		File confDirectory = new File(System.getProperty("user.dir"), "conf");

		if (!confDirectory.isDirectory())
		{
			logger.error("Unable to find the `conf` directory under the current working directory",
				System.getProperty("user.dir"));
			return null;
		}


		String glowstarEnvironment = System.getenv("GLOWSTAR_ENVIRONMENT");

		if (StringUtils.isEmpty(glowstarEnvironment))
		{
			return new File(confDirectory, "dev.glowstar.properties").toString();
		}

		return new File(confDirectory, glowstarEnvironment + ".glowstar.properties").toString();
	}
	
	@Override
	public Iterable<Path> getConfigFiles()
	{
		return Collections.singleton(Paths.get(getConfigFilePath()));
	}
	
	@Override
	public String toString()
	{
		return getConfigFilePath();
	}
}
