<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FixHome | Crear cuenta de Cliente</title>
        
        <!-- Enlaces a los estilos CSS -->
        <link rel="stylesheet" href="<%= request.getContextPath() %>/ESTILOS-CSS/estilo-logincliente.css">
        <link rel="stylesheet" href="<%= request.getContextPath() %>/ESTILOS-CSS/estilo-principal.css">
    </head>

    <body class="pagina-login-cliente">
        <!-- Encabezado superior -->
        <header class="encabezado-login">
            <a href="<%= request.getContextPath() %>/index.html" class="logo">
                <img src="<%= request.getContextPath() %>/Imagenes/logo.png" alt="Logo FixHome">
                FixHome
            </a>

            <a href="<%= request.getContextPath() %>/index.html" class="volver-sitio">
                <span aria-hidden="true">←</span> Volver a la página principal
            </a>
        </header>

        <main class="contenedor-login-cliente">
            <!-- Columna izquierda: Presentación de beneficios para el cliente -->
            <section class="presentacion-cliente">
                <span class="etiqueta-bienvenida">Registro de Clientes</span>
                <h1>Únete a <span>FixHome</span> hoy mismo</h1>
                <p>Crea tu cuenta en pocos minutos para solicitar servicios de reparación, mantenimiento e instalación para tu hogar.</p>

                <div class="imagen-login-cliente">
                    <img src="<%= request.getContextPath() %>/Imagenes/registro-cliente.png" alt="Técnico profesional listo para ayudar">
                </div>

            
            </section>

            <!-- Columna derecha: Formulario de Registro -->
            <section class="tarjeta-login-cliente">
                <div class="encabezado-formulario">
                    <h2><span>Crea</span> tu cuenta</h2>
                </div>

                <%-- Mensaje dinámico en caso de error o advertencia --%>
                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                    <div class="error-login" style="margin-bottom: 20px;">
                        <% if ("correo_registrado".equals(error)) { %>
                            El correo electrónico ya está registrado. Intenta con otro o inicia sesión.
                        <% } else if ("contrasenas_no_coinciden".equals(error)) { %>
                            Las contraseñas no coinciden. Por favor, verifícalas.
                        <% } else { %>
                            Ocurrió un error al registrar tu cuenta. Por favor, intenta de nuevo.
                        <% } %>
                    </div>
                <%  } %>

                <!-- Apunta al servlet RegistroClienteServlet -->
                <form action="<%= request.getContextPath() %>/RegistroClienteServlet" method="POST" class="formulario-login" onsubmit="return validarRegistro();">
                    
                    <!-- Nombre y Apellidos -->
                    <div class="campo-login">
                        <label for="nombre">Nombre(s)</label>
                        <div class="contenedor-input-icono">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input 
                                type="text" 
                                id="nombre" 
                                name="nombre" 
                                placeholder="Carlos" 
                                required 
                                autocomplete="given-name">
                        </div>
                    </div>

                    <div class="campo-login">
                        <label for="apellidos">Apellidos</label>
                        <div class="contenedor-input-icono">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input 
                                type="text" 
                                id="apellidos" 
                                name="apellidos" 
                                placeholder="Pérez Gómez" 
                                required 
                                autocomplete="family-name">
                        </div>
                    </div>

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
                                placeholder="ejemplo@correo.com" 
                                required 
                                autocomplete="email">
                        </div>
                    </div>

                    <!-- Teléfono -->
                    <div class="campo-login">
                        <label for="telefono">Teléfono de contacto</label>
                        <div class="contenedor-input-icono">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                            </svg>
                            <input 
                                type="tel" 
                                id="telefono" 
                                name="telefono" 
                                placeholder="5512345678" 
                                required 
                                autocomplete="tel">
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
                                placeholder="Mínimo 6 caracteres" 
                                required 
                                autocomplete="new-password">
                            <button type="button" class="mostrar-contrasena" id="btnMostrar1" onclick="togglePass('password', 'btnMostrar1')">
                                Mostrar
                            </button>
                        </div>
                    </div>

                    <!-- Confirmar Contraseña -->
                    <div class="campo-login">
                        <label for="confirmPassword">Confirmar contraseña</label>
                        <div class="contenedor-input-icono contenedor-contrasena">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input 
                                type="password" 
                                id="confirmPassword" 
                                name="confirmPassword" 
                                placeholder="Repite tu contraseña" 
                                required 
                                autocomplete="new-password">
                            <button type="button" class="mostrar-contrasena" id="btnMostrar2" onclick="togglePass('confirmPassword', 'btnMostrar2')">
                                Mostrar
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="boton-login-cliente">
                        Registrarme
                        <span class="flecha" aria-hidden="true">›</span>
                    </button>
                </form>

                <div class="pie-tarjeta-login">
                    <p>¿Ya tienes una cuenta? <a href="<%= request.getContextPath() %>/login-cliente.jsp">Inicia sesión</a></p>
                </div>
            </section>
        </main>

        <!-- Scripts de validación en el cliente -->
        <script>
            function togglePass(inputId, btnId) {
                const input = document.getElementById(inputId);
                const btn = document.getElementById(btnId);
                if (input.type === 'password') {
                    input.type = 'text';
                    btn.textContent = 'Ocultar';
                } else {
                    input.type = 'password';
                    btn.textContent = 'Mostrar';
                }
            }

            function validarRegistro() {
                const pass = document.getElementById('password').value;
                const confirmPass = document.getElementById('confirmPassword').value;

                if (pass !== confirmPass) {
                    alert("Las contraseñas no coinciden. Por favor verifícalas.");
                    return false;
                }
                if (pass.length < 6) {
                    alert("La contraseña debe tener al menos 6 caracteres.");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>