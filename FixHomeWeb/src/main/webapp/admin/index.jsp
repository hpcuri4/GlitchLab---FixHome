<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fixhome.conexion.Conexion"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.DayOfWeek"%>
<%@page import="java.time.temporal.TemporalAdjusters"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.UUID"%>

<%!
    private String puntosGrafica(int[] valores, int maximo) {
        StringBuilder puntos = new StringBuilder();

        for (int i = 0; i < valores.length; i++) {
            int x = 60 + i * 100;
            double y = 220 - (valores[i] * 180.0 / maximo);

            puntos.append(x).append(",")
                  .append(String.format(java.util.Locale.US, "%.2f", y))
                  .append(" ");
        }

        return puntos.toString().trim();
    }
%>

<%
    if (session.getAttribute("idAdministrador") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    response.setHeader("Cache-Control", "no-store");

    if (session.getAttribute("tokenCerrarSesion") == null) {
        session.setAttribute(
            "tokenCerrarSesion",
            UUID.randomUUID().toString()
        );
    }

    String ruta = request.getContextPath();

    int totalUsuarios = 0;
    int totalTrabajadores = 0;
    int solicitudesPendientes = 0;
    int trabajadoresPendientes = 0;

    int[] recibidas = new int[5];
    int[] finalizadas = new int[5];
    String[] fechas = new String[5];

    boolean errorDatos = false;

    LocalDate semanaActual = LocalDate.now()
        .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

    DateTimeFormatter formatoFecha =
        DateTimeFormatter.ofPattern("dd/MM");

    for (int i = 0; i < 5; i++) {
        fechas[i] = semanaActual.minusWeeks(4 - i)
                                .format(formatoFecha);
    }

    String sqlResumen =
        "SELECT "
        + "(SELECT COUNT(*) FROM usuarios) AS usuarios, "
        + "(SELECT COUNT(*) FROM trabajadores t "
        + " INNER JOIN usuarios u ON u.id_usuario = t.id_trabajador "
        + " WHERE t.estado_registro = 'aceptado' AND u.activo = TRUE) "
        + " AS trabajadores, "
        + "(SELECT COUNT(*) FROM solicitudes "
        + " WHERE estado = 'pendiente') AS solicitudes_pendientes, "
        + "(SELECT COUNT(*) FROM trabajadores t "
        + " INNER JOIN usuarios u ON u.id_usuario = t.id_trabajador "
        + " WHERE t.estado_registro = 'pendiente' AND u.activo = TRUE) "
        + " AS trabajadores_pendientes";

    String sqlGrafica =
        "SELECT "
        + "(SELECT COUNT(*) FROM solicitudes "
        + " WHERE fecha_solicitud >= ? AND fecha_solicitud < ?) "
        + " AS recibidas, "
        + "(SELECT COUNT(*) FROM solicitudes "
        + " WHERE estado = 'finalizada' "
        + " AND fecha_finalizacion >= ? AND fecha_finalizacion < ?) "
        + " AS finalizadas";

    try (Connection conexion = Conexion.conectar()) {

        try (PreparedStatement consulta =
                conexion.prepareStatement(sqlResumen);
             ResultSet resultado = consulta.executeQuery()) {

            if (resultado.next()) {
                totalUsuarios = resultado.getInt("usuarios");
                totalTrabajadores = resultado.getInt("trabajadores");
                solicitudesPendientes =
                    resultado.getInt("solicitudes_pendientes");
                trabajadoresPendientes =
                    resultado.getInt("trabajadores_pendientes");
            }
        }

        try (PreparedStatement consulta =
                conexion.prepareStatement(sqlGrafica)) {

            for (int i = 0; i < 5; i++) {
                LocalDate inicio = semanaActual.minusWeeks(4 - i);
                LocalDate fin = inicio.plusWeeks(1);

                Timestamp desde = Timestamp.valueOf(inicio.atStartOfDay());
                Timestamp hasta = Timestamp.valueOf(fin.atStartOfDay());

                consulta.setTimestamp(1, desde);
                consulta.setTimestamp(2, hasta);
                consulta.setTimestamp(3, desde);
                consulta.setTimestamp(4, hasta);

                try (ResultSet resultado = consulta.executeQuery()) {
                    if (resultado.next()) {
                        recibidas[i] = resultado.getInt("recibidas");
                        finalizadas[i] = resultado.getInt("finalizadas");
                    }
                }
            }
        }

    } catch (SQLException e) {
        errorDatos = true;
        application.log("No se pudo cargar el resumen administrativo.", e);
    }

    int mayorValor = 0;

    for (int i = 0; i < 5; i++) {
        mayorValor = Math.max(mayorValor, recibidas[i]);
        mayorValor = Math.max(mayorValor, finalizadas[i]);
    }

    int maximoGrafica = Math.max(5, ((mayorValor + 4) / 5) * 5);

    String puntosRecibidas = puntosGrafica(recibidas, maximoGrafica);
    String puntosFinalizadas = puntosGrafica(finalizadas, maximoGrafica);
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio administrador | FixHome</title>

    <link rel="stylesheet"
          href="<%= ruta %>/ESTILOS-CSS/estilo-principal.css">
</head>

<body class="pagina-admin">

    <!-- Iconos utilizados en el panel -->
    <svg class="iconos-admin" xmlns="http://www.w3.org/2000/svg"
         aria-hidden="true">
        <symbol id="icono-inicio" viewBox="0 0 24 24">
            <path d="M3 11 12 3l9 8M5 10v11h5v-7h4v7h5V10"/>
        </symbol>

        <symbol id="icono-usuarios" viewBox="0 0 24 24">
            <circle cx="9" cy="7" r="3"/>
            <path d="M3 21v-3a6 6 0 0 1 12 0v3M17 4a3 3 0 0 1 0 6M21 21v-3a6 6 0 0 0-4-5"/>
        </symbol>

        <symbol id="icono-trabajadores" viewBox="0 0 24 24">
            <path d="M14 6a5 5 0 0 0-6 6L3 17a3 3 0 0 0 4 4l5-5a5 5 0 0 0 6-6l-4 4-4-4 4-4Z"/>
        </symbol>

        <symbol id="icono-solicitudes" viewBox="0 0 24 24">
            <rect x="5" y="3" width="14" height="18" rx="2"/>
            <path d="M9 8h6M9 12h6M9 16h4"/>
        </symbol>

        <symbol id="icono-configuracion" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="3"/>
            <path d="m9 3-1 3-3 1 1 3-2 2 2 2-1 3 3 1 1 3h6l1-3 3-1-1-3 2-2-2-2 1-3-3-1-1-3Z"/>
        </symbol>

        <symbol id="icono-campana" viewBox="0 0 24 24">
            <path d="M6 9a6 6 0 0 1 12 0v6l2 3H4l2-3V9M10 21h4"/>
        </symbol>
    </svg>

    <!-- Barra lateral -->
    <aside class="barra-admin">
        <a href="<%= ruta %>/admin/index.jsp" class="logo">
            <img src="<%= ruta %>/Imagenes/logo.png" alt="">
            FixHome
        </a>

        <nav class="menu-admin" aria-label="Navegación administrativa">
            <a href="<%= ruta %>/admin/index.jsp"
               class="activo" aria-current="page">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-inicio"/>
                </svg>
                Inicio
            </a>

            <a href="<%= ruta %>/admin/usuarios.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-usuarios"/>
                </svg>
                Usuarios
            </a>

            <a href="<%= ruta %>/admin/trabajadores.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-trabajadores"/>
                </svg>
                Trabajadores
            </a>

            <a href="<%= ruta %>/admin/solicitudes.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-solicitudes"/>
                </svg>
                Solicitudes
            </a>

            <a href="<%= ruta %>/admin/configuracion.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-configuracion"/>
                </svg>
                Configuración
            </a>
        </nav>
    </aside>

    <div class="contenido-admin">

        <!-- Encabezado superior -->
        <jsp:include page="encabezado-admin.jsp"/>

        <main class="principal-admin">

            <section class="titulo-admin">
                <h1>Panel de administración</h1>
                <p>Resumen de actividad en FixHome.</p>
            </section>

            <% if (errorDatos) { %>

                <p class="error-admin" role="alert">
                    No se pudieron cargar los datos.
                    Intenta actualizar la página.
                </p>

            <% } else { %>

                <!-- Contadores -->
                <section class="resumen-admin"
                         aria-label="Resumen de la plataforma">

                    <article class="tarjeta-resumen">
                        <div class="imagen-resumen">
                            <svg class="icono-admin" aria-hidden="true">
                                <use href="#icono-usuarios"/>
                            </svg>
                        </div>

                        <div>
                            <h2>Usuarios registrados</h2>
                            <p class="numero-resumen"><%= totalUsuarios %></p>
                        </div>
                    </article>

                    <article class="tarjeta-resumen">
                        <div class="imagen-resumen imagen-resumen-naranja">
                            <svg class="icono-admin" aria-hidden="true">
                                <use href="#icono-trabajadores"/>
                            </svg>
                        </div>

                        <div>
                            <h2>Trabajadores activos</h2>
                            <p class="numero-resumen"><%= totalTrabajadores %></p>
                        </div>
                    </article>

                    <article class="tarjeta-resumen">
                        <div class="imagen-resumen">
                            <svg class="icono-admin" aria-hidden="true">
                                <use href="#icono-solicitudes"/>
                            </svg>
                        </div>

                        <div>
                            <h2>Solicitudes pendientes</h2>
                            <p class="numero-resumen"><%= solicitudesPendientes %></p>
                        </div>
                    </article>

                </section>

                <section class="actividad-admin">

                    <!-- Gráfica -->
                    <article class="tarjeta-grafica">
                        <div class="encabezado-grafica">
                            <div>
                                <h2>Actividad de solicitudes</h2>
                                <p>Últimas cinco semanas</p>
                            </div>

                            <div class="leyenda-grafica">
                                <span>
                                    <i class="punto-recibidas"></i>
                                    Recibidas
                                </span>
                                <span>
                                    <i class="punto-finalizadas"></i>
                                    Finalizadas
                                </span>
                            </div>
                        </div>

                        <svg class="grafica-admin"
                             viewBox="0 0 520 260"
                             role="img"
                             aria-labelledby="titulo-grafica descripcion-grafica">

                            <title id="titulo-grafica">
                                Actividad semanal de solicitudes
                            </title>

                            <desc id="descripcion-grafica">
                                Solicitudes recibidas y finalizadas
                                durante las últimas cinco semanas.
                            </desc>

                            <% for (int i = 0; i <= 5; i++) {
                                int y = 220 - i * 36;
                                int valor = maximoGrafica * i / 5;
                            %>
                                <line x1="60" y1="<%= y %>"
                                      x2="460" y2="<%= y %>"
                                      class="linea-grafica"/>

                                <text x="45" y="<%= y + 4 %>"
                                      text-anchor="end"
                                      class="texto-grafica">
                                    <%= valor %>
                                </text>
                            <% } %>

                            <% for (int i = 0; i < 5; i++) {
                                int x = 60 + i * 100;
                            %>
                                <line x1="<%= x %>" y1="40"
                                      x2="<%= x %>" y2="220"
                                      class="linea-grafica"/>

                                <text x="<%= x %>" y="245"
                                      text-anchor="middle"
                                      class="texto-grafica">
                                    <%= fechas[i] %>
                                </text>
                            <% } %>

                            <polygon
                                points="60,220 <%= puntosRecibidas %> 460,220"
                                class="area-recibidas"/>

                            <polyline points="<%= puntosRecibidas %>"
                                      class="linea-recibidas"/>

                            <polyline points="<%= puntosFinalizadas %>"
                                      class="linea-finalizadas"/>

                            <% for (int i = 0; i < 5; i++) {
                                int x = 60 + i * 100;
                                double yRecibida =
                                    220 - recibidas[i] * 180.0 / maximoGrafica;
                                double yFinalizada =
                                    220 - finalizadas[i] * 180.0 / maximoGrafica;
                            %>
                                <circle cx="<%= x %>"
                                        cy="<%= yRecibida %>"
                                        r="4" class="marca-recibidas">
                                    <title>
                                        <%= fechas[i] %>:
                                        <%= recibidas[i] %> recibidas
                                    </title>
                                </circle>

                                <circle cx="<%= x %>"
                                        cy="<%= yFinalizada %>"
                                        r="4" class="marca-finalizadas">
                                    <title>
                                        <%= fechas[i] %>:
                                        <%= finalizadas[i] %> finalizadas
                                    </title>
                                </circle>
                            <% } %>
                        </svg>
                    </article>

                    <!-- Registros pendientes -->
                    <article class="aviso-admin">
                        <div class="imagen-resumen imagen-resumen-naranja">
                            <svg class="icono-admin" aria-hidden="true">
                                <use href="#icono-trabajadores"/>
                            </svg>
                        </div>

                        <h2>
                            <%= trabajadoresPendientes %>
                            <%= trabajadoresPendientes == 1
                                ? "trabajador espera validación"
                                : "trabajadores esperan validación" %>
                        </h2>

                        <p>
                            Revisa los datos y documentos enviados
                            para aceptar o rechazar los registros.
                        </p>

                        <a href="<%= ruta %>/admin/solicitudes.jsp?tipo=registros"
                           class="boton-revisar">
                            Revisar registros
                            <span aria-hidden="true">›</span>
                        </a>
                    </article>

                </section>

            <% } %>
        </main>
    </div>

</body>
</html>