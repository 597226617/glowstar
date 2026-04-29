package com.glowstar.server.services;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DatabaseInitializer {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);

    public static void initialize(DBInterface db) {
        try (Connection conn = db.getConnection()) {
            try {
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
                        // Skip pure comments
                        if (line.trim().startsWith("--")) continue;
                        sql.append(line).append("\n");
                    }
                }

                // PostgreSQL: split by semicolon, execute each statement
                String[] statements = sql.toString().split(";");
                try (Statement stmt = conn.createStatement()) {
                    for (String statement : statements) {
                        String trimmed = statement.trim();
                        if (!trimmed.isEmpty()) {
                            stmt.execute(trimmed);
                        }
                    }
                }

                conn.commit();
                logger.info("PostgreSQL database initialized: 20 tables");
            } catch (Exception e) {
                db.rollback(conn);
                logger.error("Failed to initialize database", e);
                throw new RuntimeException("Database initialization failed", e);
            } finally {
                db.closeConnection(conn);
            }
        } catch (SQLException e) {
            logger.error("Failed to get database connection", e);
        }
    }
}
