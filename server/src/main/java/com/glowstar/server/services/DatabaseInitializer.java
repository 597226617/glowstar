package com.glowstar.server.services;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.Statement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DatabaseInitializer {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);

    public static void initialize(DBInterface db) {
        try (Connection conn = db.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Read schema.sql from resources
            InputStream is = DatabaseInitializer.class.getClassLoader()
                .getResourceAsStream("schema.sql");
            
            if (is == null) {
                logger.error("schema.sql not found in resources");
                return;
            }
            
            StringBuilder sql = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sql.append(line).append("\n");
                }
            }
            
            // Execute each statement
            String[] statements = sql.toString().split(";");
            for (String statement : statements) {
                statement = statement.trim();
                if (!statement.isEmpty() && !statement.startsWith("--")) {
                    stmt.execute(statement);
                }
            }
            
            logger.info("Database initialized successfully");
        } catch (Exception e) {
            logger.error("Failed to initialize database", e);
        }
    }
}
