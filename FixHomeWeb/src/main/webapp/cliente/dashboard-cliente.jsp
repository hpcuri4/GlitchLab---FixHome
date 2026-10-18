<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Validar si hay una sesión activa de cliente
    String nombreCliente = (String) session.getAttribute("nombreCliente");
    if (nombreCliente == null) {
        response.sendRedirect("login-cliente.jsp");
        return;
    }
%>
<%@ page import="java.sql.*" %>
<%@ page import="com.fixhome.conexion.Conexion" %>
<%
    // Variables para las notificaciones
    int totalNotificaciones = 0;
    String htmlNotificaciones = "";

    Integer idClienteLogueado = (Integer) session.getAttribute("idUsuario");

    if (idClienteLogueado != null) {
        String sqlNotis = "SELECT s.id_solicitud, s.tipo_trabajo, s.estado, s.fecha_actualizacion, serv.nombre AS servicio "
                + "FROM solicitudes s "
                + "INNER JOIN servicios serv ON s.id_servicio = serv.id_servicio "
                + "WHERE s.id_cliente = ? AND s.estado IN ('aceptada', 'finalizada') "
                + "ORDER BY s.id_solicitud DESC LIMIT 5";

        try (Connection conn = Conexion.conectar(); PreparedStatement pstmt = conn.prepareStatement(sqlNotis)) {

            pstmt.setInt(1, idClienteLogueado);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    totalNotificaciones++;
                    String servicio = rs.getString("servicio");
                    String estado = rs.getString("estado");
                    int idSol = rs.getInt("id_solicitud");

                    String mensajeEstado = estado.equals("aceptada") ? "¡Un trabajador ha aceptado tu solicitud!" : "Tu servicio ha finalizado.";

                    htmlNotificaciones += "<div class='aviso-notificacion'>"
                            + "<strong>" + servicio + " (" + estado.toUpperCase() + ")</strong>"
                            + "<p>" + mensajeEstado + "</p>"
                            + "<a href='detalles-solicitud.jsp?id=" + idSol + "'>Ver detalles</a>"
                            + "</div>";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (htmlNotificaciones.equals("")) {
        htmlNotificaciones = "<p style='text-align:center; color:var(--texto-secundario); padding: 10px 0;'>No tienes nuevas notificaciones.</p>";
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>FixHome | Panel de Cliente</title>
                <link rel="stylesheet" href="../ESTILOS-CSS/estilo-principal.css">
                    <link rel="stylesheet" href="../ESTILOS-CSS/dashboard-cliente.css">
                        </head>

                        <body class="pagina-admin pagina-cliente-dashboard">

                            <!-- Barra lateral de navegación web -->
                            <aside class="barra-admin">
                                <a href="dashboard-cliente.jsp" class="logo">
                                    <img src="../Imagenes/logo.png" alt="Logo FixHome">
                                        FixHome
                                </a>

                                <nav class="menu-admin">
                                    <a href="dashboard-cliente.jsp" class="activo">
                                        <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                                        Inicio
                                    </a>
                                    <a href="mis-solicitudes.jsp">
                                        <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                                        Solicitudes
                                    </a>
                                    <a href="historial-servicios.jsp">
                                        <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                        Historial
                                    </a>
                                    <a href="perfil-cliente.jsp">
                                        <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                        Perfil
                                    </a>
                                </nav>
                            </aside>

                            <!-- Contenido Principal -->
                            <div class="contenido-admin">

                                <!-- Encabezado superior -->
                                <header class="encabezado-admin">
                                    <!-- Componente dinámico de Notificaciones (Campanita) -->
                                    <details class="notificaciones-admin">
                                        <summary aria-label="Notificaciones">
                                            <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                                                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                                <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                                            </svg>
                                            <% if (totalNotificaciones > 0) {%>
                                            <span class="contador-notificaciones"><%= totalNotificaciones%></span>
                                            <% }%>
                                        </summary>

                                        <div class="panel-notificaciones">
                                            <h2>Notificaciones</h2>
                                            <div class="lista-avisos-noti">
                                                <%= htmlNotificaciones%>
                                            </div>
                                        </div>
                                    </details>

                                    <!-- Menú de Usuario -->
                                    <details class="cuenta-admin">
                                        <summary>
                                            <div class="avatar-admin">
                                                <svg class="icono-admin" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                            </div>
                                            <span><%= nombreCliente%></span>
                                        </summary>
                                        <div class="opciones-admin">
                                            <form action="<%= request.getContextPath()%>/CerrarSesionServlet" method="POST">
                                                <button type="submit">Cerrar sesión</button>
                                            </form>
                                        </div>
                                    </details>
                                </header>

                                <!-- Dashboard de Cliente -->
                                <main class="principal-admin dashboard-cliente-web">

                                    <!-- Saludo principal -->
                                    <div class="titulo-admin saludo-dashboard">
                                        <h1>¡Hola, <span><%= nombreCliente%></span>!</h1>
                                        <p>¿Qué necesita tu hogar hoy?</p>
                                    </div>

                                    <!-- Banner principal de llamada a la acción -->
                                    <section class="banner-cliente-web">
                                        <div class="banner-texto">
                                            <h2>Tu hogar, en buenas manos.</h2>
                                            <p>Solicita un servicio profesional y deja el resto en nuestras manos expertas.</p>
                                            <a href="nueva-solicitud.jsp" class="boton-banner-cliente">
                                                Solicitar un servicio
                                                <span aria-hidden="true">›</span>
                                            </a>
                                        </div>
                                        <div class="banner-ilustracion">
                                            <img src="../Imagenes/dashboard-cliente.png" alt="Sala de hogar acogedora">
                                        </div>
                                    </section>

                                    <!-- Sección de Servicios -->
                                    <section class="seccion-dashboard-web">
                                        <div class="encabezado-seccion-web">
                                            <h2>Servicios</h2>
                                            <a href="servicios.html" class="enlace-ver-todos">Ver todos ›</a>
                                        </div>

                                        <div class="grid-servicios-web">

                                            <div class="icono-servicio-web">🚰</div>
                                            <h3>Plomería</h3>


                                            <div class="icono-servicio-web">💡</div>
                                            <h3>Electricidad</h3>


                                            <div class="icono-servicio-web">🔒</div>
                                            <h3>Cerrajería</h3>

                                            <div class="icono-servicio-web">🔨</div>
                                            <h3>Carpintería</h3>


                                            <div class="icono-servicio-web">🧴</div>
                                            <h3>Limpieza</h3>


                                            <div class="icono-servicio-web">🌿</div>
                                            <h3>Jardinería</h3>

                                        </div>
                                    </section>

                                    <!-- Sección: Mis Solicitudes -->
                                    <section class="seccion-dashboard-web">
                                        <div class="encabezado-seccion-web">
                                            <h2>Mis solicitudes</h2>
                                            <a href="mis-solicitudes.jsp" class="enlace-ver-todos">Ver todas ›</a>
                                        </div>

                                        <div class="tarjeta-vacia-solicitudes">
                                            <div class="icono-vacio">📄</div>
                                            <div>
                                                <h3>Aún no tienes solicitudes</h3>
                                                <p>Cuando solicites un servicio, podrás consultar aquí su estado en tiempo real.</p>
                                            </div>
                                        </div>
                                    </section>

                                </main>
                            </div>

                        </body>
                        </html>