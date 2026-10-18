package com.fixhome.controlador;

import com.fixhome.conexion.Conexion;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
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

@WebServlet("/ConfiguracionServlet")
public class ConfiguracionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        response.sendRedirect(
            request.getContextPath() + "/admin/configuracion.jsp"
        );
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession sesion = request.getSession(false);

        if (sesion == null
                || !(sesion.getAttribute("idAdministrador") instanceof Integer)) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        String tokenGuardado =
            (String) sesion.getAttribute("tokenConfiguracion");

        String tokenRecibido = request.getParameter("token");

        if (tokenGuardado == null
                || tokenRecibido == null
                || !MessageDigest.isEqual(
                    tokenGuardado.getBytes(StandardCharsets.UTF_8),
                    tokenRecibido.getBytes(StandardCharsets.UTF_8))) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Solicitud no válida. Recarga la página."
            );
            return;
        }

        int idAdministrador =
            (Integer) sesion.getAttribute("idAdministrador");

        String accion = request.getParameter("accion");

        try (Connection conexion = Conexion.conectar()) {

            // Verificar que la cuenta siga activa y sea administradora.
            String sqlAdministrador =
                "SELECT u.contrasena_hash " +
                "FROM usuarios u " +
                "INNER JOIN administradores a " +
                "ON a.id_administrador = u.id_usuario " +
                "WHERE u.id_usuario = ? AND u.activo = TRUE";

            String hashActual;

            try (PreparedStatement consulta =
                    conexion.prepareStatement(sqlAdministrador)) {

                consulta.setInt(1, idAdministrador);

                try (ResultSet resultado = consulta.executeQuery()) {
                    if (!resultado.next()) {
                        sesion.invalidate();

                        response.sendRedirect(
                            request.getContextPath() + "/login.jsp"
                        );
                        return;
                    }

                    hashActual = resultado.getString("contrasena_hash");
                }
            }

            if ("datos".equals(accion)) {

                String nombre = texto(request, "nombre");
                String apellidos = texto(request, "apellidos");
                String correo = texto(request, "correo");
                String telefono = texto(request, "telefono");

                if (nombre.isEmpty() || nombre.length() > 100
                        || apellidos.isEmpty() || apellidos.length() > 100) {

                    terminar(request, response, sesion,
                        "error",
                        "Escribe nombre y apellidos de hasta 100 caracteres.");
                    return;
                }

                if (correo.length() > 150
                        || !correo.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {

                    terminar(request, response, sesion,
                        "error",
                        "Escribe un correo electrónico válido.");
                    return;
                }

                if (telefono.length() > 20) {
                    terminar(request, response, sesion,
                        "error",
                        "El teléfono debe tener como máximo 20 caracteres.");
                    return;
                }

                String sql =
                    "UPDATE usuarios " +
                    "SET nombre = ?, apellidos = ?, correo = ?, telefono = ? " +
                    "WHERE id_usuario = ? AND activo = TRUE";

                try (PreparedStatement consulta =
                        conexion.prepareStatement(sql)) {

                    consulta.setString(1, nombre);
                    consulta.setString(2, apellidos);
                    consulta.setString(3, correo);
                    consulta.setString(4, telefono.isEmpty() ? null : telefono);
                    consulta.setInt(5, idAdministrador);

                    consulta.executeUpdate();
                }

                terminar(request, response, sesion,
                    "exito",
                    "Los datos de tu cuenta se guardaron correctamente.");

            } else if ("contrasena".equals(accion)) {

                String actual = request.getParameter("contrasenaActual");
                String nueva = request.getParameter("contrasenaNueva");
                String confirmar = request.getParameter("confirmarContrasena");

                if (actual == null || nueva == null || confirmar == null) {
                    terminar(request, response, sesion,
                        "error",
                        "Completa los tres campos de contraseña.");
                    return;
                }

                if (!nueva.equals(confirmar)) {
                    terminar(request, response, sesion,
                        "error",
                        "La nueva contraseña y su confirmación no coinciden.");
                    return;
                }

                if (nueva.length() < 8
                        || nueva.getBytes(StandardCharsets.UTF_8).length > 72) {

                    terminar(request, response, sesion,
                        "error",
                        "La nueva contraseña debe tener al menos 8 caracteres "
                        + "y no superar 72 bytes.");
                    return;
                }

                if (actual.getBytes(StandardCharsets.UTF_8).length > 72
                        || !BCrypt.checkpw(actual, hashActual)) {

                    terminar(request, response, sesion,
                        "error",
                        "La contraseña actual es incorrecta.");
                    return;
                }

                if (BCrypt.checkpw(nueva, hashActual)) {
                    terminar(request, response, sesion,
                        "error",
                        "Elige una contraseña diferente de la actual.");
                    return;
                }

                String hashNuevo =
                    BCrypt.hashpw(nueva, BCrypt.gensalt(12));

                String sql =
                    "UPDATE usuarios SET contrasena_hash = ? " +
                    "WHERE id_usuario = ? AND contrasena_hash = ? " +
                    "AND activo = TRUE";

                int actualizados;

                try (PreparedStatement consulta =
                        conexion.prepareStatement(sql)) {

                    consulta.setString(1, hashNuevo);
                    consulta.setInt(2, idAdministrador);
                    consulta.setString(3, hashActual);

                    actualizados = consulta.executeUpdate();
                }

                if (actualizados != 1) {
                    terminar(request, response, sesion,
                        "error",
                        "La cuenta cambió mientras guardabas. Intenta nuevamente.");
                    return;
                }

                request.changeSessionId();

                terminar(request, response, sesion,
                    "exito",
                    "Tu contraseña se actualizó correctamente.");

            } else if ("notificaciones".equals(accion)) {

                boolean registros =
                    "on".equals(request.getParameter("notificarRegistros"));

                boolean avisos =
                    "on".equals(request.getParameter("notificarAvisos"));

                String sql =
                    "UPDATE administradores " +
                    "SET notificar_registros = ?, notificar_avisos = ? " +
                    "WHERE id_administrador = ?";

                try (PreparedStatement consulta =
                        conexion.prepareStatement(sql)) {

                    consulta.setBoolean(1, registros);
                    consulta.setBoolean(2, avisos);
                    consulta.setInt(3, idAdministrador);

                    consulta.executeUpdate();
                }

                terminar(request, response, sesion,
                    "exito",
                    "Tus preferencias de notificaciones se guardaron.");

            } else {

                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Acción no válida."
                );
            }

        } catch (SQLException e) {

            getServletContext().log(
                "Error al guardar la configuración de FixHome.",
                e
            );

            String mensaje = e.getErrorCode() == 1062
                ? "Ese correo electrónico ya pertenece a otra cuenta."
                : "No se pudieron guardar los cambios. Intenta nuevamente.";

            terminar(request, response, sesion, "error", mensaje);

        } catch (IllegalArgumentException e) {

            getServletContext().log(
                "Error en el formato de la contraseña almacenada.",
                e
            );

            terminar(request, response, sesion,
                "error",
                "No se pudo comprobar la contraseña de la cuenta.");
        }
    }

    private String texto(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private void terminar(HttpServletRequest request,
                          HttpServletResponse response,
                          HttpSession sesion,
                          String tipo,
                          String mensaje)
            throws IOException {

        sesion.setAttribute("tipoMensajeConfiguracion", tipo);
        sesion.setAttribute("mensajeConfiguracion", mensaje);

        response.sendRedirect(
            request.getContextPath() + "/admin/configuracion.jsp"
        );
    }
}
