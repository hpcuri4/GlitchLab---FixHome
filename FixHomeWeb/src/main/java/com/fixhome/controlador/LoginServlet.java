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
import javax.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");

        if (correo == null || contrasena == null
                || correo.trim().isEmpty() || contrasena.isEmpty()) {

            mostrarError(request, response,
                    "Ingresa tu correo y contraseña.");
            return;
        }

        String sql =
                "SELECT u.id_usuario, u.contrasena_hash "
                + "FROM usuarios AS u "
                + "INNER JOIN administradores AS a "
                + "ON a.id_administrador = u.id_usuario "
                + "WHERE u.correo = ? AND u.activo = TRUE";

        try (Connection conexion = Conexion.conectar();
             PreparedStatement consulta = conexion.prepareStatement(sql)) {

            consulta.setString(1, correo.trim());

            try (ResultSet resultado = consulta.executeQuery()) {
                if (resultado.next()) {
                    String hash = resultado.getString("contrasena_hash");
                    boolean correcta = false;

                    try {
                        correcta = BCrypt.checkpw(contrasena, hash);
                    } catch (IllegalArgumentException e) {
                        getServletContext().log(
                                "El hash guardado no tiene un formato BCrypt válido.",
                                e
                        );
                    }

                    if (correcta) {
                        int idAdministrador =
                                resultado.getInt("id_usuario");

                        // Sustituye cualquier sesión anterior.
                        HttpSession anterior = request.getSession(false);

                        if (anterior != null) {
                            anterior.invalidate();
                        }

                        HttpSession sesion = request.getSession(true);
                        sesion.setAttribute(
                                "idAdministrador",
                                idAdministrador
                        );
                        sesion.setMaxInactiveInterval(30 * 60);

                        response.sendRedirect(
                                request.getContextPath() + "/admin/index.jsp"
                        );
                        return;
                    }
                }
            }

            mostrarError(request, response,
                    "Correo o contraseña incorrectos.");

        } catch (SQLException e) {
            getServletContext().log(
                    "Error al consultar el acceso del administrador.",
                    e
            );

            mostrarError(request, response,
                    "No se pudo completar el acceso. Intenta nuevamente.");
        }
    }

    private void mostrarError(HttpServletRequest request,
                              HttpServletResponse response,
                              String mensaje)
            throws ServletException, IOException {

        request.setAttribute("errorLogin", mensaje);
        request.getRequestDispatcher("/login.jsp")
                .forward(request, response);
    }
}