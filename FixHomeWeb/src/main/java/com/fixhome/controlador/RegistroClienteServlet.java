/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fixhome.controlador;

import com.fixhome.conexion.Conexion;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
// Si usas jBCrypt para hashing de contraseñas, descomenta la siguiente línea:
// import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/RegistroClienteServlet")
public class RegistroClienteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("nombre");
        String apellidos = request.getParameter("apellidos");
        String correo = request.getParameter("correo");
        String telefono = request.getParameter("telefono");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Validar que las contraseñas coincidan
        if (password == null || !password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/cliente/registro-cliente.jsp?error=contrasenas_no_coinciden");
            return;
        }

        // Consultas SQL
        String sqlExisteCorreo = "SELECT id_usuario FROM usuarios WHERE correo = ?";
        String sqlInsertUsuario = "INSERT INTO usuarios (nombre, apellidos, correo, contrasena_hash, telefono, activo) VALUES (?, ?, ?, ?, ?, TRUE)";
        String sqlInsertCliente = "INSERT INTO clientes (id_cliente) VALUES (?)";

        Connection conn = null;

        try {
            conn = Conexion.conectar();
            
            // Iniciar transacción explícita
            conn.setAutoCommit(false);

            // 2. Comprobar si el correo ya existe en la base de datos
            try (PreparedStatement pstmtExiste = conn.prepareStatement(sqlExisteCorreo)) {
                pstmtExiste.setString(1, correo);
                try (ResultSet rs = pstmtExiste.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/cliente/registro-cliente.jsp?error=correo_registrado");
                        return;
                    }
                }
            }

            // 3. Generar hash de la contraseña (o guardar en texto plano si estás en etapa de pruebas)
            String passwordHash = password; 
            // Si usas jBCrypt, descomenta la siguiente línea:
            // String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

            // 4. Insertar en la tabla 'usuarios'
            int idUsuarioGenerado = -1;
            try (PreparedStatement pstmtUsuario = conn.prepareStatement(sqlInsertUsuario, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstmtUsuario.setString(1, nombre);
                pstmtUsuario.setString(2, apellidos);
                pstmtUsuario.setString(3, correo);
                pstmtUsuario.setString(4, passwordHash);
                pstmtUsuario.setString(5, telefono);

                int filasAfectadas = pstmtUsuario.executeUpdate();

                if (filasAfectadas > 0) {
                    try (ResultSet generatedKeys = pstmtUsuario.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            idUsuarioGenerado = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            // 5. Insertar en la tabla 'clientes' vinculando el id_usuario
            if (idUsuarioGenerado != -1) {
                try (PreparedStatement pstmtCliente = conn.prepareStatement(sqlInsertCliente)) {
                    pstmtCliente.setInt(1, idUsuarioGenerado);
                    pstmtCliente.executeUpdate();
                }

                // Confirmar cambios en la base de datos (Commit)
                conn.commit();

                // Registro exitoso: redirigir a la página de login
                response.sendRedirect(request.getContextPath() + "/login-cliente.jsp?exito=registro_exitoso");
            } else {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/cliente/registro-cliente.jsp?error=1");
            }

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Revertir transacción si ocurre un error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cliente/registro-cliente.jsp?error=1");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close(); // Cerrar la conexión
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}