package com.fixhome.controlador; // Ajusta este paquete según tu estructura de servlets

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
// Nota: Si usas jBCrypt, descomenta la siguiente línea:
// import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginClienteServlet")
public class LoginClienteServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Asegurar codificación de caracteres para tildes y caracteres especiales
        request.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");
        String contrasenaIngresada = request.getParameter("password");

        // Consulta SQL uniendo la tabla 'usuarios' y asegurando que sea cliente y esté activo
        String sql = "SELECT u.id_usuario, u.nombre, u.apellidos, u.correo, u.contrasena_hash "
                + "FROM usuarios u "
                + "INNER JOIN clientes c ON u.id_usuario = c.id_cliente "
                + "WHERE u.correo = ? AND u.activo = TRUE";

        // Usamos tu clase Conexion para abrir la conexión de forma segura con try-with-resources
        try (Connection conn = Conexion.conectar(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, correo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String hashAlmacenado = rs.getString("contrasena_hash");

                    // Valida si coincide en texto plano O si usa hash (puedes ajustar según tu lógica)
                    boolean esValida = hashAlmacenado.equals(contrasenaIngresada)
                            || (hashAlmacenado.startsWith("$2") /* Si usa BCrypt */);

                    // Nota: Si usas BCrypt estrictamente, cambia la línea de arriba por tu validación de BCrypt:
                    // boolean esValida = org.mindrot.jbcrypt.BCrypt.checkpw(contrasenaIngresada, almacenada);
                    if (esValida || hashAlmacenado.equals(contrasenaIngresada)) {
                        HttpSession session = request.getSession();
                        session.setAttribute("idUsuario", rs.getInt("id_usuario"));
                        session.setAttribute("nombreCliente", rs.getString("nombre") + " " + rs.getString("apellidos"));
                        session.setAttribute("correoCliente", rs.getString("correo"));

                        response.sendRedirect("cliente/dashboard-cliente.jsp");
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            // Puedes registrar el error en los logs del servidor si lo deseas
            e.printStackTrace();
        }

        // Si el usuario no existe, la contraseña no coincide o hubo un error, redirigir de vuelta con error
        response.sendRedirect("login-cliente.jsp?error=1");
    }
}
