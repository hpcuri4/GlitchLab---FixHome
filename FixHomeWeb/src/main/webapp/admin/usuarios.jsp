<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fixhome.conexion.Conexion"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.UUID"%>

<%!
    private static class UsuarioFila {

        int id;
        String nombre;
        String correo;
        String telefono;
        boolean activo;
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

    String buscar = request.getParameter("buscar");
    String estado = request.getParameter("estado");

    if (buscar == null) {
        buscar = "";
    }

    buscar = buscar.trim();

    if (!"activo".equals(estado) && !"inactivo".equals(estado)) {
        estado = "";
    }

    List<UsuarioFila> usuarios = new ArrayList<>();
    boolean errorDatos = false;
    int totalClientes = 0;

    String sql
            = "SELECT u.id_usuario, "
            + "CONCAT(u.nombre, ' ', u.apellidos) AS nombre_completo, "
            + "u.correo, u.telefono, u.activo "
            + "FROM usuarios AS u "
            + "INNER JOIN clientes AS c ON c.id_cliente = u.id_usuario "
            + "WHERE (CONCAT(u.nombre, ' ', u.apellidos) LIKE ? "
            + "OR u.correo LIKE ? OR u.telefono LIKE ?) ";

    if ("activo".equals(estado)) {
        sql += "AND u.activo = TRUE ";
    } else if ("inactivo".equals(estado)) {
        sql += "AND u.activo = FALSE ";
    }

    sql += "ORDER BY u.id_usuario DESC";

    try (Connection conexion = Conexion.conectar(); PreparedStatement consulta = conexion.prepareStatement(sql)) {
        try (PreparedStatement consultaTotal = conexion.prepareStatement(
                "SELECT COUNT(*) AS total FROM clientes"); ResultSet resultadoTotal = consultaTotal.executeQuery()) {

            if (resultadoTotal.next()) {
                totalClientes = resultadoTotal.getInt("total");
            }
        }
        String coincidencia = "%" + buscar + "%";

        consulta.setString(1, coincidencia);
        consulta.setString(2, coincidencia);
        consulta.setString(3, coincidencia);

        try (ResultSet resultado = consulta.executeQuery()) {
            while (resultado.next()) {
                UsuarioFila usuario = new UsuarioFila();

                usuario.id = resultado.getInt("id_usuario");
                usuario.nombre = resultado.getString("nombre_completo");
                usuario.correo = resultado.getString("correo");
                usuario.telefono = resultado.getString("telefono");
                usuario.activo = resultado.getBoolean("activo");

                usuarios.add(usuario);
            }
        }

    } catch (SQLException e) {
        errorDatos = true;
        application.log("No se pudo consultar el listado de clientes.", e);
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Usuarios | FixHome</title>

        <link rel="stylesheet"
              href="<%= ruta%>/ESTILOS-CSS/estilo-principal.css">
    </head>

    <body class="pagina-admin">

        <!-- Iconos del panel -->
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
        <a href="<%= ruta%>/admin/index.jsp" class="logo">
            <img src="<%= ruta%>/Imagenes/logo.png" alt="">
            FixHome
        </a>

        <nav class="menu-admin" aria-label="Navegación administrativa">

            <a href="<%= ruta%>/admin/index.jsp">
                <svg class="icono-admin" aria-hidden="true">
                <use href="#icono-inicio"/>
                </svg>
                Inicio
            </a>

            <a href="<%= ruta%>/admin/usuarios.jsp"
               class="activo" aria-current="page">
                <svg class="icono-admin" aria-hidden="true">
                <use href="#icono-usuarios"/>
                </svg>
                Usuarios
            </a>

            <a href="<%= ruta%>/admin/trabajadores.jsp">
                <svg class="icono-admin" aria-hidden="true">
                <use href="#icono-trabajadores"/>
                </svg>
                Trabajadores
            </a>

            <a href="<%= ruta%>/admin/solicitudes.jsp">
                <svg class="icono-admin" aria-hidden="true">
                <use href="#icono-solicitudes"/>
                </svg>
                Solicitudes
            </a>

            <a href="<%= ruta%>/admin/configuracion.jsp">
                <svg class="icono-admin" aria-hidden="true">
                <use href="#icono-configuracion"/>
                </svg>
                Configuración
            </a>

        </nav>
    </aside>

    <div class="contenido-admin">

        <jsp:include page="encabezado-admin.jsp"/>

        <main class="principal-admin">

            <section class="titulo-admin">
                <h1>Usuarios</h1>
            </section>
            <% if (!errorDatos) {%>
            <section class="resumen-clientes"
                     aria-label="Total de clientes registrados">

                <article class="tarjeta-resumen">
                    <div class="imagen-resumen">
                        <svg class="icono-admin" aria-hidden="true">
                        <use href="#icono-usuarios"/>
                        </svg>
                    </div>

                    <div>
                        <p class="numero-resumen"><%= totalClientes%></p>
                        <h2>Clientes registrados</h2>
                    </div>
                </article>

            </section>
            <% }%>

            <!-- Búsqueda y filtro -->
            <form action="<%= ruta%>/admin/usuarios.jsp"
                  method="get"
                  class="filtros-usuarios">

                <div class="campo-busqueda-usuarios">
                    <label for="buscar-usuario">Buscar cliente</label>

                    <input type="search"
                           id="buscar-usuario"
                           name="buscar"
                           value="<%= escapar(buscar)%>"
                           placeholder="Nombre, correo o teléfono">
                </div>

                <div class="campo-estado-usuarios">
                    <label for="estado-usuario">Estado de la cuenta</label>

                    <select id="estado-usuario" name="estado">
                        <option value=""
                                <%= estado.isEmpty() ? "selected" : ""%>>
                            Todos
                        </option>

                        <option value="activo"
                                <%= "activo".equals(estado) ? "selected" : ""%>>
                            Activos
                        </option>

                        <option value="inactivo"
                                <%= "inactivo".equals(estado) ? "selected" : ""%>>
                            Inactivos
                        </option>
                    </select>
                </div>

                <button type="submit" class="boton-buscar-usuarios">
                    Buscar
                </button>

                <a href="<%= ruta%>/admin/usuarios.jsp"
                   class="limpiar-filtros-usuarios">
                    Limpiar
                </a>
            </form>

            <% if (errorDatos) { %>

            <p class="error-admin" role="alert">
                No se pudieron cargar los usuarios.
                Intenta actualizar la página.
            </p>

            <% } else {%>

            <section class="listado-usuarios"
                     aria-labelledby="titulo-listado-usuarios">

                <div class="encabezado-listado-usuarios">
                    <h2 id="titulo-listado-usuarios">
                        Clientes registrados
                    </h2>

                    <span class="total-usuarios">
                        <%= usuarios.size()%>
                        <%= usuarios.size() == 1
                                ? "resultado" : "resultados"%>
                    </span>
                </div>

                <% if (usuarios.isEmpty()) { %>

                <div class="sin-usuarios">
                    <h3>No se encontraron clientes</h3>
                    <p>
                        Si ya tienes registros, prueba otra búsqueda
                        o selecciona un estado diferente.
                    </p>
                </div>

                <% } else { %>

                <div class="contenedor-tabla-usuarios">
                    <table class="tabla-usuarios">
                        <thead>
                            <tr>
                                <th scope="col">Nombre</th>
                                <th scope="col">Correo electrónico</th>
                                <th scope="col">Teléfono</th>
                                <th scope="col">Estado</th>
                                <th scope="col">Acciones</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% for (UsuarioFila usuario : usuarios) {%>
                            <tr>
                                <td class="nombre-usuario">
                                    <%= escapar(usuario.nombre)%>
                                </td>

                                <td>
                                    <%= escapar(usuario.correo)%>
                                </td>

                                <td>
                                    <%= usuario.telefono == null
                                            || usuario.telefono.trim().isEmpty()
                                            ? "Sin registrar"
                                            : escapar(usuario.telefono)%>
                                </td>

                                <td>
                                    <span class="estado-usuario
                                          <%= usuario.activo
                                                  ? "usuario-activo"
                                                  : "usuario-inactivo"%>">

                                        <%= usuario.activo
                                                ? "Activo" : "Inactivo"%>
                                    </span>
                                </td>

                                <td>
                                    <a href="<%= ruta%>/admin/perfil-usuario.jsp?id=<%= usuario.id%>"
                                       class="boton-perfil-usuario"
                                       aria-label="Ver perfil de <%= escapar(usuario.nombre)%>">
                                        Ver perfil
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <% } %>
            </section>

            <% }%>

        </main>
    </div>

</body>
</html>