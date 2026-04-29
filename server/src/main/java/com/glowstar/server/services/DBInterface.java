package com.glowstar.server.services;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;

public class DBInterface {
    private static final Logger logger = LoggerFactory.getLogger(DBInterface.class);
    private static DBInterface instance;
    private HikariDataSource dataSource;

    public static DBInterface get() {
        if (instance == null) {
            synchronized (DBInterface.class) {
                if (instance == null) {
                    instance = new DBInterface();
                }
            }
        }
        return instance;
    }

    private DBInterface() {
        String jdbcUrl = System.getenv().getOrDefault("DB_URL",
                "jdbc:postgresql://localhost:5432/glowstar");
        String username = System.getenv().getOrDefault("DB_USER", "glowstar");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "glowstar");

        try {
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName("org.postgresql.Driver");
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setIdleTimeout(300000);
            config.setConnectionTimeout(10000);
            config.setMaxLifetime(600000);
            config.setAutoCommit(false);

            dataSource = new HikariDataSource(config);
            logger.info("PostgreSQL connected: {}", jdbcUrl);
        } catch (Exception e) {
            logger.error("Failed to initialize PostgreSQL connection pool", e);
            throw new RuntimeException("Database connection failed", e);
        }
    }

    public Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public void commit(Connection conn) throws SQLException {
        if (conn != null) {
            conn.commit();
        }
    }

    public void rollback(Connection conn) {
        try {
            if (conn != null) {
                conn.rollback();
            }
        } catch (SQLException e) {
            logger.error("Error rolling back transaction", e);
        }
    }

    public void closeConnection(Connection conn) {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            logger.error("Error closing connection", e);
        }
    }

    public void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            logger.info("PostgreSQL connection pool closed");
        }
    }
}
