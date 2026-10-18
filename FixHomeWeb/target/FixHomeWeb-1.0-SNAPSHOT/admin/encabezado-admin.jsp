<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fixhome.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.UUID"%>

<%
    String rutaEncabezado = request.getContextPath();

    if (session.getAttribute("tokenCerrarSesion") == null) {
        session.setAttribute(
            "tokenCerrarSesion",
            UUID.randomUUID().toString()
        );
    }

    int registrosEncabezado = 0;
    int avisosEncabezado = 0;
    boolean errorEncabezado = false;

    Object idEncabezado = session.getAttribute("idAdministrador");

    if (idEncabezado instanceof Integer) {

        String sqlEncabezado =
            "SELECT a.notificar_registros, a.notificar_avisos, " +
            "(SELECT COUNT(*) FROM trabajadores t " +
            " INNER JOIN usuarios u ON u.id_usuario = t.id_trabajador " +
            " WHERE t.estado_registro = 'pendiente' " +
            " AND u.activo = TRUE) AS registros, " +
            "(SELECT COUNT(*) FROM solicitudes " +
            " WHERE estado = 'pendiente') AS avisos " +
            "FROM administradores a " +
            "WHERE a.id_administrador = ?";

        try (Connection conexionEncabezado = Conexion.conectar();
             PreparedStatement consultaEncabezado =
                conexionEncabezado.prepareStatement(sqlEncabezado)) {

            consultaEncabezado.setInt(1, (Integer) idEncabezado);

            try (ResultSet resultadoEncabezado =
                    consultaEncabezado.executeQuery()) {

                if (resultadoEncabezado.next()) {

                    if (resultadoEncabezado.getBoolean("notificar_registros")) {
                        registrosEncabezado =
                            resultadoEncabezado.getInt("registros");
                    }

                    if (resultadoEncabezado.getBoolean("notificar_avisos")) {
                        avisosEncabezado =
                            resultadoEncabezado.getInt("avisos");
                    }
                }
            }

        } catch (SQLException e) {
            errorEncabezado = true;
            application.log("Error al consultar notificaciones.", e);
        }
    }

    int totalEncabezado = registrosEncabezado + avisosEncabezado;
%>

<header class="encabezado-admin">

    <details class="notificaciones-admin">

        <summary aria-label="Mostrar notificaciones">
            <svg class="icono-admin"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="1.8"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true">
                <path d="M18 8a6 6 0 0 0-12 0
                         c0 7-3 7-3 9h18c0-2-3-2-3-9z"></path>
                <path d="M10 21h4"></path>
            </svg>

            <% if (totalEncabezado > 0) { %>
                <span class="contador-notificaciones">
                    <%= totalEncabezado %>
                </span>
            <% } %>
        </summary>

        <div class="panel-notificaciones">
            <h2>Notificaciones</h2>

            <% if (errorEncabezado) { %>

                <p>No se pudieron consultar las notificaciones.</p>

            <% } else if (totalEncabezado == 0) { %>

                <p>No tienes avisos pendientes habilitados.</p>

            <% } else { %>

                <% if (registrosEncabezado > 0) { %>
                    <div class="aviso-notificacion">
                        <strong>Registros de trabajadores</strong>

                        <p>
                            <%= registrosEncabezado %>
                            pendientes de revisión.
                        </p>

                        <a href="<%= rutaEncabezado %>/admin/index.jsp">
                            Ir al inicio
                        </a>
                    </div>
                <% } %>

                <% if (avisosEncabezado > 0) { %>
                    <div class="aviso-notificacion">
                        <strong>Solicitudes de servicio</strong>

                        <p>
                            <%= avisosEncabezado %>
                            pendientes de aceptación.
                        </p>

                        <a href="<%= rutaEncabezado %>/admin/solicitudes.jsp?estado=pendiente">
                            Ver solicitudes
                        </a>
                    </div>
                <% } %>

            <% } %>
        </div>

    </details>

    <details class="cuenta-admin">

        <summary>
            <span class="avatar-admin" aria-hidden="true">
                <svg class="icono-admin"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="1.8"
                     stroke-linecap="round"
                     stroke-linejoin="round">
                    <circle cx="9" cy="7" r="3.5"></circle>
                    <path d="M2 21v-3a7 7 0 0 1 14 0v3"></path>
                    <path d="M17 3.5a3.5 3.5 0 0 1 0 7"></path>
                    <path d="M19 14a6 6 0 0 1 3 5v2"></path>
                </svg>
            </span>

            Administrador
            <span aria-hidden="true">⌄</span>
        </summary>

        <div class="opciones-admin">
            <form action="<%= rutaEncabezado %>/CerrarSesionServlet"
                  method="post">

                <input type="hidden"
                       name="token"
                       value="<%= session.getAttribute("tokenCerrarSesion") %>">

                <button type="submit">Cerrar sesión</button>

            </form>
        </div>

    </details>

</header>
