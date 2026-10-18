<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fixhome.conexion.Conexion"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.UUID"%>

<%!
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

    int idAdministrador =
        (Integer) session.getAttribute("idAdministrador");

    if (session.getAttribute("tokenConfiguracion") == null) {
        session.setAttribute(
            "tokenConfiguracion",
            UUID.randomUUID().toString()
        );
    }

    String tokenConfiguracion =
        (String) session.getAttribute("tokenConfiguracion");

    String mensaje =
        (String) session.getAttribute("mensajeConfiguracion");

    String tipoMensaje =
        (String) session.getAttribute("tipoMensajeConfiguracion");

    session.removeAttribute("mensajeConfiguracion");
    session.removeAttribute("tipoMensajeConfiguracion");

    String nombre = "";
    String apellidos = "";
    String correo = "";
    String telefono = "";

    boolean notificarRegistros = false;
    boolean notificarAvisos = false;
    boolean errorDatos = false;
    boolean cuentaEncontrada = false;

    String sql =
        "SELECT u.nombre, u.apellidos, u.correo, u.telefono, " +
        "a.notificar_registros, a.notificar_avisos " +
        "FROM usuarios u " +
        "INNER JOIN administradores a " +
        "ON a.id_administrador = u.id_usuario " +
        "WHERE u.id_usuario = ? AND u.activo = TRUE";

    try (Connection conexion = Conexion.conectar();
         PreparedStatement consulta = conexion.prepareStatement(sql)) {

        consulta.setInt(1, idAdministrador);

        try (ResultSet resultado = consulta.executeQuery()) {

            if (resultado.next()) {
                cuentaEncontrada = true;

                nombre = resultado.getString("nombre");
                apellidos = resultado.getString("apellidos");
                correo = resultado.getString("correo");
                telefono = resultado.getString("telefono");

                notificarRegistros =
                    resultado.getBoolean("notificar_registros");

                notificarAvisos =
                    resultado.getBoolean("notificar_avisos");
            }
        }

    } catch (SQLException e) {
        errorDatos = true;
        application.log("Error al consultar configuración.", e);
    }

    if (!errorDatos && !cuentaEncontrada) {
        session.invalidate();
        response.sendRedirect(ruta + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Configuración | FixHome</title>

    <link rel="stylesheet"
          href="<%= ruta %>/ESTILOS-CSS/estilo-principal.css">
</head>

<body class="pagina-admin pagina-configuracion">

    <svg class="iconos-admin"
         xmlns="http://www.w3.org/2000/svg"
         aria-hidden="true"
         style="position:absolute;width:0;height:0;overflow:hidden">

        <symbol id="icono-inicio" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 10 12 3l9 7"></path>
                <path d="M5 9v12h5v-7h4v7h5V9"></path>
            </g>
        </symbol>

        <symbol id="icono-usuarios" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="7" r="3.5"></circle>
                <path d="M2 21v-3a7 7 0 0 1 14 0v3"></path>
                <path d="M17 3.5a3.5 3.5 0 0 1 0 7"></path>
                <path d="M19 14a6 6 0 0 1 3 5v2"></path>
            </g>
        </symbol>

        <symbol id="icono-trabajadores" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <path d="M14.7 6.3a5.5 5.5 0 0 0-7 7L3 18
                         a2.1 2.1 0 0 0 3 3l4.7-4.7
                         a5.5 5.5 0 0 0 7-7l-3.5 3.5-3-3z">
                </path>
            </g>
        </symbol>

        <symbol id="icono-solicitudes" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <rect x="5" y="2" width="14" height="20" rx="2"></rect>
                <path d="M9 7h6M9 11h6M9 15h4"></path>
            </g>
        </symbol>

        <symbol id="icono-configuracion" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <path d="m9 3 .6-2h4.8l.6 2 2 1.2 2.1-.4
                         2.4 4.2-1.4 1.6v2.4l1.4 1.6
                         -2.4 4.2-2.1-.4-2 1.2-.6 2H9.6
                         l-.6-2-2-1.2-2.1.4-2.4-4.2
                         1.4-1.6V9.6L2.5 8l2.4-4.2 2.1.4z">
                </path>
                <circle cx="12" cy="10.8" r="3"></circle>
            </g>
        </symbol>

        <symbol id="icono-ojo" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z">
                </path>
                <circle cx="12" cy="12" r="3"></circle>
            </g>
        </symbol>

        <symbol id="icono-campana" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8a6 6 0 0 0-12 0
                         c0 7-3 7-3 9h18c0-2-3-2-3-9z"></path>
                <path d="M10 21h4"></path>
            </g>
        </symbol>

        <symbol id="icono-correo" viewBox="0 0 24 24">
            <g fill="none" stroke="currentColor" stroke-width="1.8"
               stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                <path d="m3 6 9 7 9-7"></path>
            </g>
        </symbol>

    </svg>

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

            <a href="<%= ruta %>/admin/trabajadores.jsp">
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

            <a href="<%= ruta %>/admin/configuracion.jsp"
               class="activo"
               aria-current="page">
                <svg class="icono-admin" aria-hidden="true">
                    <use href="#icono-configuracion"></use>
                </svg>
                Configuración
            </a>

        </nav>

    </aside>

    <div class="contenido-admin">

        <jsp:include page="encabezado-admin.jsp"/>

        <main class="principal-admin">

            <section class="titulo-admin">
                <h1>Configuración</h1>
                <p>Administra tu cuenta y preferencias.</p>
            </section>

            <% if (mensaje != null) { %>
                <div class="mensaje-configuracion <%= "exito".equals(tipoMensaje)
                        ? "mensaje-configuracion-exito"
                        : "mensaje-configuracion-error" %>"
                     role="status">
                    <%= escapar(mensaje) %>
                </div>
            <% } %>

            <% if (errorDatos) { %>

                <div class="error-admin" role="alert">
                    No se pudo cargar la configuración.
                    Intenta nuevamente.
                </div>

            <% } else { %>

                <!-- Datos de la cuenta -->
                <section class="tarjeta-configuracion"
                         aria-labelledby="titulo-datos-cuenta">

                    <h2 id="titulo-datos-cuenta">Datos de la cuenta</h2>

                    <form action="<%= ruta %>/ConfiguracionServlet"
                          method="post">

                        <input type="hidden" name="accion" value="datos">
                        <input type="hidden" name="token"
                               value="<%= escapar(tokenConfiguracion) %>">

                        <div class="campos-configuracion">

                            <div class="campo-configuracion">
                                <label for="nombre-admin">Nombre</label>
                                <input type="text"
                                       id="nombre-admin"
                                       name="nombre"
                                       maxlength="100"
                                       autocomplete="given-name"
                                       value="<%= escapar(nombre) %>"
                                       required>
                            </div>

                            <div class="campo-configuracion">
                                <label for="apellidos-admin">Apellidos</label>
                                <input type="text"
                                       id="apellidos-admin"
                                       name="apellidos"
                                       maxlength="100"
                                       autocomplete="family-name"
                                       value="<%= escapar(apellidos) %>"
                                       required>
                            </div>

                            <div class="campo-configuracion">
                                <label for="correo-admin">
                                    Correo electrónico
                                </label>
                                <input type="email"
                                       id="correo-admin"
                                       name="correo"
                                       maxlength="150"
                                       autocomplete="email"
                                       value="<%= escapar(correo) %>"
                                       required>
                            </div>

                            <div class="campo-configuracion">
                                <label for="telefono-admin">Teléfono</label>
                                <input type="tel"
                                       id="telefono-admin"
                                       name="telefono"
                                       maxlength="20"
                                       autocomplete="tel"
                                       value="<%= escapar(telefono) %>">
                            </div>

                            <div class="campo-configuracion">
                                <label for="rol-admin">Rol</label>
                                <input type="text"
                                       id="rol-admin"
                                       value="Administrador"
                                       readonly>
                            </div>

                        </div>

                        <div class="acciones-configuracion">
                            <button type="submit"
                                    class="boton-buscar-usuarios">
                                Guardar cambios
                            </button>
                        </div>

                    </form>
                </section>

                <!-- Seguridad -->
                <section class="tarjeta-configuracion"
                         aria-labelledby="titulo-seguridad">

                    <h2 id="titulo-seguridad">Seguridad</h2>
                    <h3>Cambiar contraseña</h3>

                    <p class="descripcion-configuracion">
                        Utiliza al menos 8 caracteres para tu nueva contraseña.
                    </p>

                    <form action="<%= ruta %>/ConfiguracionServlet"
                          method="post"
                          id="formulario-contrasena">

                        <input type="hidden"
                               name="accion"
                               value="contrasena">

                        <input type="hidden"
                               name="token"
                               value="<%= escapar(tokenConfiguracion) %>">

                        <div class="campos-contrasena">

                            <div class="campo-configuracion">
                                <label for="contrasena-actual">
                                    Contraseña actual
                                </label>

                                <div class="entrada-contrasena">
                                    <input type="password"
                                           id="contrasena-actual"
                                           name="contrasenaActual"
                                           autocomplete="current-password"
                                           required>

                                    <button type="button"
                                            class="mostrar-contrasena"
                                            data-campo="contrasena-actual"
                                            aria-label="Mostrar contraseña actual"
                                            aria-pressed="false">
                                        <svg class="icono-admin"
                                             aria-hidden="true">
                                            <use href="#icono-ojo"></use>
                                        </svg>
                                    </button>
                                </div>
                            </div>

                            <div class="campo-configuracion">
                                <label for="contrasena-nueva">
                                    Nueva contraseña
                                </label>

                                <div class="entrada-contrasena">
                                    <input type="password"
                                           id="contrasena-nueva"
                                           name="contrasenaNueva"
                                           minlength="8"
                                           autocomplete="new-password"
                                           required>

                                    <button type="button"
                                            class="mostrar-contrasena"
                                            data-campo="contrasena-nueva"
                                            aria-label="Mostrar nueva contraseña"
                                            aria-pressed="false">
                                        <svg class="icono-admin"
                                             aria-hidden="true">
                                            <use href="#icono-ojo"></use>
                                        </svg>
                                    </button>
                                </div>
                            </div>

                            <div class="campo-configuracion">
                                <label for="confirmar-contrasena">
                                    Confirmar contraseña
                                </label>

                                <div class="entrada-contrasena">
                                    <input type="password"
                                           id="confirmar-contrasena"
                                           name="confirmarContrasena"
                                           minlength="8"
                                           autocomplete="new-password"
                                           required>

                                    <button type="button"
                                            class="mostrar-contrasena"
                                            data-campo="confirmar-contrasena"
                                            aria-label="Mostrar confirmación de contraseña"
                                            aria-pressed="false">
                                        <svg class="icono-admin"
                                             aria-hidden="true">
                                            <use href="#icono-ojo"></use>
                                        </svg>
                                    </button>
                                </div>
                            </div>

                        </div>

                        <div class="acciones-configuracion">
                            <button type="submit"
                                    class="boton-secundario-configuracion">
                                Actualizar contraseña
                            </button>
                        </div>

                    </form>
                </section>

                <!-- Preferencias -->
                <section class="tarjeta-configuracion"
                         aria-labelledby="titulo-notificaciones">

                    <h2 id="titulo-notificaciones">Notificaciones</h2>

                    <form action="<%= ruta %>/ConfiguracionServlet"
                          method="post"
                          id="formulario-notificaciones">

                        <input type="hidden"
                               name="accion"
                               value="notificaciones">

                        <input type="hidden"
                               name="token"
                               value="<%= escapar(tokenConfiguracion) %>">

                        <div class="fila-notificacion">

                            <span class="icono-preferencia"
                                  aria-hidden="true">
                                <svg class="icono-admin">
                                    <use href="#icono-campana"></use>
                                </svg>
                            </span>

                            <div class="texto-notificacion">
                                <label for="notificar-registros">
                                    Nuevas solicitudes de trabajadores
                                </label>

                                <p id="descripcion-registros">
                                    Muestra un aviso cuando haya registros
                                    pendientes de revisión.
                                </p>
                            </div>

                            <div class="interruptor-configuracion">
                                <input type="checkbox"
                                       id="notificar-registros"
                                       name="notificarRegistros"
                                       aria-describedby="descripcion-registros"
                                       <%= notificarRegistros ? "checked" : "" %>>

                                <label for="notificar-registros">
                                    <span class="texto-solo-lectores">
                                        Notificaciones de trabajadores
                                    </span>
                                </label>
                            </div>

                        </div>

                        <div class="fila-notificacion">

                            <span class="icono-preferencia"
                                  aria-hidden="true">
                                <svg class="icono-admin">
                                    <use href="#icono-correo"></use>
                                </svg>
                            </span>

                            <div class="texto-notificacion">
                                <label for="notificar-avisos">
                                    Avisos de la plataforma
                                </label>

                                <p id="descripcion-avisos">
                                    Muestra avisos de solicitudes de servicio
                                    pendientes de aceptación.
                                </p>
                            </div>

                            <div class="interruptor-configuracion">
                                <input type="checkbox"
                                       id="notificar-avisos"
                                       name="notificarAvisos"
                                       aria-describedby="descripcion-avisos"
                                       <%= notificarAvisos ? "checked" : "" %>>

                                <label for="notificar-avisos">
                                    <span class="texto-solo-lectores">
                                        Avisos de la plataforma
                                    </span>
                                </label>
                            </div>

                        </div>

                        <noscript>
                            <div class="acciones-configuracion">
                                <button type="submit"
                                        class="boton-buscar-usuarios">
                                    Guardar notificaciones
                                </button>
                            </div>
                        </noscript>

                    </form>
                </section>

            <% } %>

        </main>
    </div>

    <script>
        // Mostrar u ocultar contraseñas.
        document.querySelectorAll(".mostrar-contrasena")
            .forEach(function (boton) {

                const etiquetaOriginal = boton.getAttribute("aria-label");

                boton.addEventListener("click", function () {
                    const campo = document.getElementById(
                        boton.dataset.campo
                    );

                    const mostrar = campo.type === "password";

                    campo.type = mostrar ? "text" : "password";

                    boton.setAttribute("aria-pressed", String(mostrar));

                    boton.setAttribute(
                        "aria-label",
                        mostrar
                            ? etiquetaOriginal.replace("Mostrar", "Ocultar")
                            : etiquetaOriginal
                    );
                });
            });

        // Comprobar la confirmación antes de enviar.
        const nueva = document.getElementById("contrasena-nueva");
        const confirmar = document.getElementById("confirmar-contrasena");

        function validarConfirmacion() {
            if (!nueva || !confirmar) {
                return;
            }

            confirmar.setCustomValidity(
                confirmar.value !== nueva.value
                    ? "Las contraseñas no coinciden."
                    : ""
            );
        }

        if (nueva && confirmar) {
            nueva.addEventListener("input", validarConfirmacion);
            confirmar.addEventListener("input", validarConfirmacion);
        }

        // Guardar preferencias al cambiar un interruptor.
        const formularioNotificaciones =
            document.getElementById("formulario-notificaciones");

        if (formularioNotificaciones) {
            formularioNotificaciones
                .querySelectorAll('input[type="checkbox"]')
                .forEach(function (interruptor) {

                    interruptor.addEventListener("change", function () {
                        formularioNotificaciones.requestSubmit();
                    });
                });
        }
    </script>

</body>
</html>