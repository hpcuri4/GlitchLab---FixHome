<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fixhome.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>

<%!
    private static class TrabajadorFila {
        int id;
        String nombre;
        String correo;
        String especialidades;
        String fechaAceptacion;
    }

    private String escapar(String texto) {
        if (texto == null) {
            return "";
        }

        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (!(session.getAttribute("idAdministrador") instanceof Integer)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    response.setHeader("Cache-Control", "no-store");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String ruta = request.getContextPath();

    String buscar = request.getParameter("buscar");

    if (buscar == null) {
        buscar = "";
    }

    buscar = buscar.trim();

    int paginaActual = 1;
    int registrosPorPagina = 10;

    try {
        paginaActual = Integer.parseInt(request.getParameter("pagina"));
    } catch (NumberFormatException e) {
        paginaActual = 1;
    }

    if (paginaActual < 1) {
        paginaActual = 1;
    }

    int totalTrabajadores = 0;
    int totalResultados = 0;
    int totalPaginas = 1;

    boolean errorDatos = false;

    List<TrabajadorFila> trabajadores = new ArrayList<>();

    String condicion =
        " FROM trabajadores t " +
        " INNER JOIN usuarios u " +
        " ON u.id_usuario = t.id_trabajador " +
        " WHERE t.estado_registro = 'aceptado' " +
        " AND u.activo = TRUE ";

    String filtro =
        " AND (" +
        " CONCAT(u.nombre, ' ', u.apellidos) LIKE ? " +
        " OR u.correo LIKE ? " +
        " OR EXISTS (" +
        "     SELECT 1 " +
        "     FROM trabajador_servicios ts " +
        "     INNER JOIN servicios s " +
        "     ON s.id_servicio = ts.id_servicio " +
        "     WHERE ts.id_trabajador = t.id_trabajador " +
        "     AND s.nombre LIKE ?" +
        " )) ";

    String coincidencia = "%" + buscar + "%";

    try (Connection conexion = Conexion.conectar()) {

        // Total de trabajadores aceptados y activos.
        try (PreparedStatement consulta = conexion.prepareStatement(
                "SELECT COUNT(*) AS total " + condicion);
             ResultSet resultado = consulta.executeQuery()) {

            if (resultado.next()) {
                totalTrabajadores = resultado.getInt("total");
            }
        }

        // Total de coincidencias de la búsqueda.
        try (PreparedStatement consulta = conexion.prepareStatement(
                "SELECT COUNT(*) AS total " + condicion + filtro)) {

            consulta.setString(1, coincidencia);
            consulta.setString(2, coincidencia);
            consulta.setString(3, coincidencia);

            try (ResultSet resultado = consulta.executeQuery()) {
                if (resultado.next()) {
                    totalResultados = resultado.getInt("total");
                }
            }
        }

        totalPaginas = Math.max(
            1,
            (int) Math.ceil(
                (double) totalResultados / registrosPorPagina
            )
        );

        if (paginaActual > totalPaginas) {
            paginaActual = totalPaginas;
        }

        int desplazamiento =
            (paginaActual - 1) * registrosPorPagina;

        String sql =
            "SELECT t.id_trabajador, " +
            " CONCAT(u.nombre, ' ', u.apellidos) AS nombre_completo, " +
            " u.correo, t.fecha_revision, " +
            " (" +
            "     SELECT GROUP_CONCAT(" +
            "         DISTINCT s.nombre " +
            "         ORDER BY s.nombre SEPARATOR ', '" +
            "     ) " +
            "     FROM trabajador_servicios ts " +
            "     INNER JOIN servicios s " +
            "     ON s.id_servicio = ts.id_servicio " +
            "     WHERE ts.id_trabajador = t.id_trabajador " +
            " ) AS especialidades " +
            condicion + filtro +
            " ORDER BY t.fecha_revision DESC, t.id_trabajador DESC " +
            " LIMIT ? OFFSET ?";

        try (PreparedStatement consulta = conexion.prepareStatement(sql)) {

            consulta.setString(1, coincidencia);
            consulta.setString(2, coincidencia);
            consulta.setString(3, coincidencia);
            consulta.setInt(4, registrosPorPagina);
            consulta.setInt(5, desplazamiento);

            try (ResultSet resultado = consulta.executeQuery()) {

                SimpleDateFormat formato =
                    new SimpleDateFormat("dd/MM/yyyy");

                while (resultado.next()) {

                    TrabajadorFila trabajador = new TrabajadorFila();

                    trabajador.id =
                        resultado.getInt("id_trabajador");

                    trabajador.nombre =
                        resultado.getString("nombre_completo");

                    trabajador.correo =
                        resultado.getString("correo");

                    trabajador.especialidades =
                        resultado.getString("especialidades");

                    if (trabajador.especialidades == null
                            || trabajador.especialidades.trim().isEmpty()) {
                        trabajador.especialidades = "Sin asignar";
                    }

                    java.sql.Timestamp fecha =
                        resultado.getTimestamp("fecha_revision");

                    trabajador.fechaAceptacion = fecha == null
                        ? "Sin registrar"
                        : formato.format(fecha);

                    trabajadores.add(trabajador);
                }
            }
        }

    } catch (SQLException e) {
        errorDatos = true;

        application.log(
            "Error al consultar los trabajadores de FixHome.",
            e
        );
    }

    int primerResultado = totalResultados == 0
        ? 0
        : (paginaActual - 1) * registrosPorPagina + 1;

    int ultimoResultado = Math.min(
        paginaActual * registrosPorPagina,
        totalResultados
    );
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Trabajadores | FixHome</title>

    <link rel="stylesheet"
          href="<%= ruta %>/ESTILOS-CSS/estilo-principal.css">
</head>

<body class="pagina-admin pagina-trabajadores">

    <!-- Definiciones de los iconos del menú -->
    <svg class="iconos-admin"
         xmlns="http://www.w3.org/2000/svg"
         aria-hidden="true"
         style="position:absolute;width:0;height:0;overflow:hidden">

        <symbol id="icono-inicio" viewBox="0 0 24 24">
            <g fill="none"
               stroke="currentColor"
               stroke-width="1.8"
               stroke-linecap="round"
               stroke-linejoin="round">
                <path d="M3 10 12 3l9 7"></path>
                <path d="M5 9v12h5v-7h4v7h5V9"></path>
            </g>
        </symbol>

        <symbol id="icono-usuarios" viewBox="0 0 24 24">
            <g fill="none"
               stroke="currentColor"
               stroke-width="1.8"
               stroke-linecap="round"
               stroke-linejoin="round">
                <circle cx="9" cy="7" r="3.5"></circle>
                <path d="M2 21v-3a7 7 0 0 1 14 0v3"></path>
                <path d="M17 3.5a3.5 3.5 0 0 1 0 7"></path>
                <path d="M19 14a6 6 0 0 1 3 5v2"></path>
            </g>
        </symbol>

        <symbol id="icono-trabajadores" viewBox="0 0 24 24">
            <g fill="none"
               stroke="currentColor"
               stroke-width="1.8"
               stroke-linecap="round"
               stroke-linejoin="round">
                <path d="M14.7 6.3a5.5 5.5 0 0 0-7 7L3 18
                         a2.1 2.1 0 0 0 3 3l4.7-4.7
                         a5.5 5.5 0 0 0 7-7l-3.5 3.5-3-3z">
                </path>
            </g>
        </symbol>

        <symbol id="icono-solicitudes" viewBox="0 0 24 24">
            <g fill="none"
               stroke="currentColor"
               stroke-width="1.8"
               stroke-linecap="round"
               stroke-linejoin="round">
                <rect x="5" y="2" width="14" height="20" rx="2">
                </rect>
                <path d="M9 7h6M9 11h6M9 15h4"></path>
            </g>
        </symbol>

        <symbol id="icono-configuracion" viewBox="0 0 24 24">
            <g fill="none"
               stroke="currentColor"
               stroke-width="1.8"
               stroke-linecap="round"
               stroke-linejoin="round">
                <path d="m9 3 .6-2h4.8l.6 2 2 1.2 2.1-.4
                         2.4 4.2-1.4 1.6v2.4l1.4 1.6
                         -2.4 4.2-2.1-.4-2 1.2-.6 2H9.6
                         l-.6-2-2-1.2-2.1.4-2.4-4.2
                         1.4-1.6V9.6L2.5 8l2.4-4.2 2.1.4z">
                </path>
                <circle cx="12" cy="10.8" r="3"></circle>
            </g>
        </symbol>

    </svg>

    <!-- Menú lateral -->
    <aside class="barra-admin">

        <a href="<%= ruta %>/admin/index.jsp" class="logo">
            <img src="<%= ruta %>/Imagenes/logo.png" alt="">
            FixHome
        </a>

        <nav class="menu-admin"
             aria-label="Navegación del administrador">

            <a href="<%= ruta %>/admin/index.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-inicio"></use>
                </svg>
                Inicio
            </a>

            <a href="<%= ruta %>/admin/usuarios.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-usuarios"></use>
                </svg>
                Usuarios
            </a>

            <a href="<%= ruta %>/admin/trabajadores.jsp"
               class="activo"
               aria-current="page">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-trabajadores"></use>
                </svg>
                Trabajadores
            </a>

            <a href="<%= ruta %>/admin/solicitudes.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-solicitudes"></use>
                </svg>
                Solicitudes
            </a>

            <a href="<%= ruta %>/admin/configuracion.jsp">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-configuracion"></use>
                </svg>
                Configuración
            </a>

        </nav>

    </aside>

    <div class="contenido-admin">

        <!-- Único encabezado, compartido con las demás páginas -->
        <jsp:include page="encabezado-admin.jsp"/>

        <main class="principal-admin">

            <section class="titulo-admin">
                <h1>Trabajadores</h1>
            </section>

            <% if (!errorDatos) { %>

                <section class="resumen-clientes"
                         aria-label="Total de trabajadores activos">

                    <article class="tarjeta-resumen">

                        <div class="imagen-resumen">
                            <svg class="icono-admin" aria-hidden="true">
                                <use href="#icono-usuarios"></use>
                            </svg>
                        </div>

                        <div>
                            <p class="numero-resumen">
                                <%= totalTrabajadores %>
                            </p>

                            <h2>Trabajadores activos</h2>
                        </div>

                    </article>

                </section>

            <% } %>

            <form class="filtros-usuarios"
                  action="<%= ruta %>/admin/trabajadores.jsp"
                  method="get">

                <div class="campo-busqueda-usuarios">
                    <label for="buscar-trabajador">
                        Buscar trabajador
                    </label>

                    <input type="search"
                           id="buscar-trabajador"
                           name="buscar"
                           placeholder="Nombre, correo o especialidad"
                           value="<%= escapar(buscar) %>">
                </div>

                <div class="campo-estado-usuarios">
                    <label for="estado-trabajador">
                        Estado de la cuenta
                    </label>

                    <input type="text"
                           id="estado-trabajador"
                           value="Activos"
                           readonly>
                </div>

                <button type="submit" class="boton-buscar-usuarios">
                    Buscar
                </button>

                <a href="<%= ruta %>/admin/trabajadores.jsp"
                   class="limpiar-filtros-usuarios">
                    Limpiar
                </a>

            </form>

            <% if (errorDatos) { %>

                <div class="error-admin" role="alert">
                    No se pudieron cargar los trabajadores.
                    Intenta nuevamente.
                </div>

            <% } else { %>

                <section class="listado-usuarios"
                         aria-labelledby="titulo-listado-trabajadores">

                    <div class="encabezado-listado-usuarios">

                        <h2 id="titulo-listado-trabajadores">
                            Trabajadores registrados
                        </h2>

                        <span class="total-usuarios">
                            <%= totalResultados %> resultados
                        </span>

                    </div>

                    <% if (trabajadores.isEmpty()) { %>

                        <div class="sin-usuarios">
                            <h3>No se encontraron trabajadores</h3>

                            <p>
                                Solo se muestran trabajadores aceptados
                                y activos. Si ya tienes registros,
                                prueba otra búsqueda.
                            </p>
                        </div>

                    <% } else { %>

                        <div class="contenedor-tabla-usuarios">

                            <table class="tabla-usuarios">

                                <thead>
                                    <tr>
                                        <th scope="col">Trabajador</th>
                                        <th scope="col">Especialidad</th>
                                        <th scope="col">
                                            Fecha de aceptación
                                        </th>
                                        <th scope="col">Estado</th>
                                        <th scope="col">Acciones</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <% for (TrabajadorFila trabajador
                                            : trabajadores) { %>

                                        <tr>
                                            <td>
                                                <span class="nombre-usuario">
                                                    <%= escapar(trabajador.nombre) %>
                                                </span>

                                                <span class="correo-trabajador">
                                                    <%= escapar(trabajador.correo) %>
                                                </span>
                                            </td>

                                            <td>
                                                <%= escapar(trabajador.especialidades) %>
                                            </td>

                                            <td>
                                                <%= escapar(trabajador.fechaAceptacion) %>
                                            </td>

                                            <td>
                                                <span class="estado-usuario usuario-activo">
                                                    Activo
                                                </span>
                                            </td>

                                            <td>
                                                <a class="boton-perfil-usuario"
                                                   href="<%= ruta %>/admin/perfil-trabajador.jsp?id=<%= trabajador.id %>"
                                                   aria-label="Ver perfil de <%= escapar(trabajador.nombre) %>">
                                                    Ver perfil
                                                </a>
                                            </td>
                                        </tr>

                                    <% } %>
                                </tbody>

                            </table>

                        </div>

                        <footer class="pie-listado-trabajadores">

                            <p>
                                Mostrando <%= primerResultado %>
                                a <%= ultimoResultado %>
                                de <%= totalResultados %> trabajadores
                            </p>

                            <% if (totalPaginas > 1) { %>

                                <form class="paginacion-trabajadores"
                                      action="<%= ruta %>/admin/trabajadores.jsp"
                                      method="get">

                                    <input type="hidden"
                                           name="buscar"
                                           value="<%= escapar(buscar) %>">

                                    <button type="submit"
                                            name="pagina"
                                            value="<%= paginaActual - 1 %>"
                                            aria-label="Página anterior"
                                            <%= paginaActual == 1 ? "disabled" : "" %>>
                                        ‹
                                    </button>

                                    <span>
                                        <%= paginaActual %>
                                        de <%= totalPaginas %>
                                    </span>

                                    <button type="submit"
                                            name="pagina"
                                            value="<%= paginaActual + 1 %>"
                                            aria-label="Página siguiente"
                                            <%= paginaActual == totalPaginas ? "disabled" : "" %>>
                                        ›
                                    </button>

                                </form>

                            <% } %>

                        </footer>

                    <% } %>

                </section>

            <% } %>

        </main>

    </div>

</body>
</html>