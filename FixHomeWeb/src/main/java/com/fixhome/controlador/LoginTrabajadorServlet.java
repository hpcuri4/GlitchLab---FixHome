package com.fixhome.controlador;

import com.fixhome.conexion.Conexion;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginTrabajadorServlet", urlPatterns = {"/LoginTrabajadorServlet"})
public class LoginTrabajadorServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        try (Connection conn = Conexion.conectar()) {
            
            // 1. Validamos en la base de datos usando 'contrasena_hash' y un JOIN con 'trabajadores'
            String sql = "SELECT u.id_usuario, u.nombre FROM usuarios u " +
                         "INNER JOIN trabajadores t ON u.id_usuario = t.id_trabajador " +
                         "WHERE u.correo = ? AND u.contrasena_hash = ?";
            
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, correo);
                pst.setString(2, password);
                
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        int idUsuario = rs.getInt("id_usuario");
                        
                        // ¡Credenciales correctas y es trabajador! Guardamos la sesión
                        HttpSession session = request.getSession();
                        session.setAttribute("idUsuario", idUsuario);
                        
                        // Redirigimos al dashboard del trabajador
                        response.sendRedirect(request.getContextPath() + "/trabajador/dashboard-trabajador.jsp");
                    } else {
                        // Si no coincide, verificamos si al menos existe en usuarios para saber si es un cliente intentando entrar aquí
                        String sqlCheckUser = "SELECT id_usuario FROM usuarios WHERE correo = ?";
                        try (PreparedStatement pstCheck = conn.prepareStatement(sqlCheckUser)) {
                            pstCheck.setString(1, correo);
                            try (ResultSet rsCheck = pstCheck.executeQuery()) {
                                if (rsCheck.next()) {
                                    // El usuario existe pero no está en la tabla trabajadores
                                    response.sendRedirect(request.getContextPath() + "/login-trabajador.jsp?error=no_autorizado");
                                } else {
                                    // Correo o contraseña completamente incorrectos
                                    response.sendRedirect(request.getContextPath() + "/login-trabajador.jsp?error=credenciales_invalidas");
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // Revisa la consola de Tomcat si ocurre algún otro fallo
            response.sendRedirect(request.getContextPath() + "/login-trabajador.jsp?error=1");
        }
    }
}