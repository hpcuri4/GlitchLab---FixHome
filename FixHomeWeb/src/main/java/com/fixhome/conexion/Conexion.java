package com.fixhome.conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    private static final String URL =
            "jdbc:mysql://localhost:3306/fixhome";

    // Cambia estos datos por los de tu conexión local a MySQL.
    private static final String USUARIO = "root";
    private static final String CONTRASENA = "root";

    public static Connection conectar() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el conector de MySQL.", e);
        }

        return DriverManager.getConnection(URL, USUARIO, CONTRASENA);
    }
}