<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FixHome | Acceso de Trabajadores</title>

        <!-- Enlaces a los estilos CSS -->
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-logincliente.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-principal.css">
    </head>

    <body class="pagina-login-cliente">
        <!-- Encabezado superior -->
        <header class="encabezado-login">
            <a href="<%= request.getContextPath()%>/index.html" class="logo">
                <img src="<%= request.getContextPath()%>/Imagenes/logo.png" alt="Logo FixHome">
                FixHome
            </a>

            <a href="<%= request.getContextPath()%>/index.html" class="volver-sitio">
                <span aria-hidden="true">←</span> Volver a la página principal
            </a>
        </header>

        <main class="contenedor-login-cliente">
            <!-- Columna izquierda: Presentación para el trabajador -->
            <section class="presentacion-cliente">
                <span class="etiqueta-bienvenida">Portal de Especialistas</span>
                <h1>Gestiona tus servicios en <span>FixHome</span></h1>
                <p>Accede a tu cuenta para revisar solicitudes asignadas, actualizar el estado de tus trabajos y comunicarte con los clientes.</p>

                <div class="imagen-login-cliente">
                    <img src="<%= request.getContextPath()%>/Imagenes/login-trabajador.png" alt="Especialista trabajando">
                </div>
            </section>

            <!-- Columna derecha: Formulario de Inicio de Sesión de Trabajadores -->
            <section class="tarjeta-login-cliente">
                <div class="encabezado-formulario">
                    <h2>Iniciar <span>Sesión</span></h2>
                </div>

                <%-- Mensaje dinámico en caso de error o éxito --%>
                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                <div class="error-login" style="margin-bottom: 20px;">
                    <% if ("credenciales_invalidas".equals(error)) { %>
                    Correo o contraseña incorrectos. Por favor, verifica tus datos.
                    <% } else if ("no_autorizado".equals(error)) { %>
                    Esta cuenta no cuenta con permisos de trabajador.
                    <% } else { %>
                    Ocurrió un error al iniciar sesión. Intenta de nuevo.
                    <% } %>
                </div>
                <% } %>

                <%
                    String exito = request.getParameter("exito");
                    if ("registro_exitoso".equals(exito)) {
                %>
                <div class="exito-login" style="margin-bottom: 20px; color: #2e7d32; background: #e8f5e9; padding: 12px; border-radius: 8px; font-size: 14px;">
                    ¡Registro exitoso! Ya puedes iniciar sesión con tus datos.
                </div>
                <% } %>

                <!-- Apunta al servlet LoginTrabajadorServlet -->
                <form action="<%= request.getContextPath()%>/LoginTrabajadorServlet" method="POST" class="formulario-login">

                    <!-- Correo electrónico -->
                    <div class="campo-login">
                        <label for="correo">Correo electrónico</label>
                        <div class="contenedor-input-icono">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                            <polyline points="22,6 12,13 2,6"></polyline>
                            </svg>
                            <input 
                                type="email" 
                                id="correo" 
                                name="correo" 
                                placeholder="trabajador@fixhome.com" 
                                required 
                                autocomplete="email">
                        </div>
                    </div>

                    <!-- Contraseña -->
                    <div class="campo-login">
                        <label for="password">Contraseña</label>
                        <div class="contenedor-input-icono contenedor-contrasena">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input 
                                type="password" 
                                id="password" 
                                name="password" 
                                placeholder="Introduce tu contraseña" 
                                required 
                                autocomplete="current-password">
                            <button type="button" class="mostrar-contrasena" id="btnMostrar" onclick="togglePass()">
                                Mostrar
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="boton-login-cliente">
                        Entrar a mi cuenta
                        <span class="flecha" aria-hidden="true">›</span>
                    </button>
                </form>

                <div class="pie-tarjeta-login">
                    <p>¿No tienes una cuenta? <a href="<%= request.getContextPath()%>/trabajador/registro-trabajador.jsp">Regístrate aquí</a></p>
                </div>
            </section>
        </main>

        <!-- Script para mostrar/ocultar contraseña -->
        <script>
            function togglePass() {
                const input = document.getElementById('password');
                const btn = document.getElementById('btnMostrar');
                if (input.type === 'password') {
                    input.type = 'text';
                    btn.textContent = 'Ocultar';
                } else {
                    input.type = 'password';
                    btn.textContent = 'Mostrar';
                }
            }
        </script>
    </body>
</html>