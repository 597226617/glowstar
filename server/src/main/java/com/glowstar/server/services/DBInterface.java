package com.glowstar.server.services;

import java.sql.*;
import java.util.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DBInterface {
    private static final Logger logger = LoggerFactory.getLogger(DBInterface.class);
    private static DBInterface instance;
    private Connection connection;

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
        try {
            Class.forName("org.sqlite.JDBC");
            connection = DriverManager.getConnection("jdbc:sqlite:glowstar.db");
            connection.setAutoCommit(false);
            logger.info("SQLite initialized: glowstar.db");
        } catch (Exception e) {
            logger.error("Failed to initialize SQLite", e);
        }
    }

    public Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection("jdbc:sqlite:glowstar.db");
            connection.setAutoCommit(false);
        }
        return connection;
    }

    public void commit() throws SQLException {
        if (connection != null && !connection.isClosed()) {
            connection.commit();
        }
    }

    public void rollback() throws SQLException {
        if (connection != null && !connection.isClosed()) {
            connection.rollback();
        }
    }

    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            logger.error("Error closing connection", e);
        }
    }
}
