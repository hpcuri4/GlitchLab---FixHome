<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.fixhome.conexion.Conexion" %>
<%
    // Variables dinámicas
    String nombreTrabajador = "Especialista";
    int totalNotificaciones = 0;
    String htmlNotificaciones = "";
    
    // Obtenemos el ID de la sesión del trabajador logueado
    Integer idTrabajadorLogueado = (Integer) session.getAttribute("idUsuario");
    
    // Seguridad opcional: Si no ha iniciado sesión, redirigir al login
    if (idTrabajadorLogueado == null) {
        response.sendRedirect(request.getContextPath() + "/trabajadorlogin-trabajador.jsp");
        return;
    }

    try (Connection conn = Conexion.conectar()) {
        
        // 1. Obtener el nombre real del trabajador desde la base de datos
        String sqlNombre = "SELECT nombre FROM usuarios WHERE id_usuario = ?";
        try (PreparedStatement pstNombre = conn.prepareStatement(sqlNombre)) {
            pstNombre.setInt(1, idTrabajadorLogueado);
            try (ResultSet rsNombre = pstNombre.executeQuery()) {
                if (rsNombre.next()) {
                    nombreTrabajador = rsNombre.getString("nombre");
                }
            }
        }
        
        // 2. Consultar solicitudes pendientes acordes a los servicios del trabajador para la campanita
        String sqlNotis = "SELECT s.id_solicitud, serv.nombre AS servicio " +
                          "FROM solicitudes s " +
                          "INNER JOIN servicios serv ON s.id_servicio = serv.id_servicio " +
                          "INNER JOIN trabajador_servicios ts ON ts.id_servicio = s.id_servicio " +
                          "WHERE ts.id_trabajador = ? AND s.estado = 'pendiente' " +
                          "ORDER BY s.id_solicitud DESC LIMIT 5";
                          
        try (PreparedStatement pstNotis = conn.prepareStatement(sqlNotis)) {
            pstNotis.setInt(1, idTrabajadorLogueado);
            try (ResultSet rsNotis = pstNotis.executeQuery()) {
                while (rsNotis.next()) {
                    totalNotificaciones++;
                    String servicio = rsNotis.getString("servicio");
                    int idSol = rsNotis.getInt("id_solicitud");
                    
                    htmlNotificaciones += "<div style='padding: 10px 0; border-bottom: 1px solid #f0f0f0;'>" +
                                          "<strong style='font-size: 13px; color: #0c3b2e; display: block;'>" + servicio + "</strong>" +
                                          "<p style='margin: 3px 0 6px 0; font-size: 12px; color: #666;'>Nueva solicitud pendiente cercana.</p>" +
                                          "<a href='detalles-solicitud.jsp?id=" + idSol + "' style='font-size: 11px; color: #6d9773; font-weight: bold; text-decoration: none;'>Ver detalles ›</a>" +
                                          "</div>";
                }
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    if (htmlNotificaciones.equals("")) {
        htmlNotificaciones = "<p style='text-align:center; color:#666; padding: 10px 0; font-size: 13px;'>No tienes nuevas notificaciones.</p>";
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FixHome | Panel de Trabajador</title>

        <!-- Hojas de estilos CSS -->
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-principal.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-logincliente.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-principaltrabajador.css">
    </head>
<body>

        <!-- Barra Lateral -->
        <aside class="sidebar">
            <div>
                <a href="#" class="sidebar-logo">
                    <img src="<%= request.getContextPath() %>/Imagenes/logo.png" alt="Logo FixHome">
                    FixHome
                </a>

                <ul class="sidebar-menu">
                    <li>
                        <a href="#" class="activo">
                            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            Inicio
                        </a>
                    </li>
                    <li>
                        <a href="mis-servicios.jsp">
                            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                            Mis servicios
                        </a>
                    </li>
                    <li>
                        <a href="solicitudes-trabajador.jsp">
                            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                            Solicitudes
                        </a>
                    </li>
                    <li>
                        <a href="perfil-trabajador.jsp">
                            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            Perfil
                        </a>
                    </li>
                </ul>
            </div>

            <div>
                <form action="<%= request.getContextPath() %>/CerrarSesionServlet" method="POST">
                    <button type="submit" style="width: 100%; background: #fdf2f2; color: #c62828; border: none; padding: 12px; border-radius: 10px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;">
                        Cerrar sesión
                    </button>
                </form>
            </div>
        </aside>

        <!-- Contenido Principal -->
        <main class="main-content">
            <header class="dashboard-header">
                <div class="bienvenida-titulo">
                    <h1>¡Hola, <%= nombreTrabajador %>!</h1>
                    <p>¿Listo para atender nuevos servicios?</p>
                </div>

                <div class="header-actions">
                    <div class="encabezado-admin">
                        <!-- Notificaciones -->
                        <details class="notificaciones-admin">
                            <summary aria-label="Notificaciones">
                                <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                    <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                                </svg>
                                <% if (totalNotificaciones > 0) { %>
                                    <span class="contador-notificaciones"><%= totalNotificaciones %></span>
                                <% } %>
                            </summary>
                            <div class="panel-notificaciones">
                                <h2>Notificaciones</h2>
                                <div><%= htmlNotificaciones %></div>
                            </div>
                        </details>

                        <!-- Menú de Usuario -->
                        <details class="cuenta-admin">
                            <summary>
                                <div class="avatar-admin">
                                    <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                </div>
                                <span style="font-size: 14px; font-weight: 600; color: var(--verde-principal);"><%= nombreTrabajador %></span>
                            </summary>
                            <div class="opciones-admin">
                                <form action="<%= request.getContextPath() %>/CerrarSesionServlet" method="POST">
                                    <button type="submit" style="width: 100%; background: none; border: none; color: #c62828; font-weight: 600; cursor: pointer; text-align: left; padding: 6px 0;">Cerrar sesión</button>
                                </form>
                            </div>
                        </details>
                    </div>
                </div>
            </header>

            <!-- Tarjeta de Estado de Cuenta -->
            <section class="tarjeta-estado-cuenta">
                <div class="estado-info">
                    <div class="estado-icono">✓</div>
                    <div class="estado-texto">
                        <h3>Estado de cuenta</h3>
                        <p>Tu cuenta está verificada como trabajador</p>
                    </div>
                </div>
                <div class="badges-estado">
                    <span class="badge disponible">
                        <span class="punto-verde"></span> Disponible
                    </span>
                    <span class="badge verificado">
                        ✓ Cuenta verificada
                    </span>
                </div>
            </section>

            <!-- Estadísticas -->
            <section class="grid-stats">
                <div class="tarjeta-stat">
                    <div class="stat-icon">💼</div>
                    <h2>4</h2>
                    <p>Servicios activos</p>
                </div>

                <div class="tarjeta-stat">
                    <div class="stat-icon">🔔</div>
                    <h2><%= totalNotificaciones %></h2>
                    <p>Solicitudes nuevas</p>
                </div>

                <div class="tarjeta-stat">
                    <div class="stat-icon">📊</div>
                    <h2>27</h2>
                    <p>Servicios realizados</p>
                </div>
            </section>

            <!-- Banner de Nuevas Oportunidades -->
            <section class="banner-oportunidades">
                <div class="oportunidad-contenido-izq">
                    <div class="contenedor-imagen-oportunidad">
                        <img src="<%= request.getContextPath() %>/Imagenes/registro-trabajador.png" alt="Herramientas FixHome">
                    </div>
                    <div class="oportunidad-info">
                        <h3>Nuevas oportunidades</h3>
                        <p>Revisa las solicitudes disponibles cerca de ti.</p>
                    </div>
                </div>
                <a href="solicitudes-trabajador.jsp" class="btn-verde-custom">
                    Ver solicitudes ›
                </a>
            </section>
        </main>
    </body>
</html>