<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FixHome | Iniciar sesión como Cliente</title>
        <link rel="stylesheet" href="ESTILOS-CSS/estilo-logincliente.css">
        <link rel="stylesheet" href="ESTILOS-CSS/estilo-principal.css">
    </head>

    <body class="pagina-login-cliente">
        <header class="encabezado-login">
            <a href="index.html" class="logo">
                <img src="Imagenes/logo.png" alt="Logo FixHome">
                FixHome
            </a>

            <a href="index.html" class="volver-sitio">
                <span aria-hidden="true">←</span> Volver a la página principal
            </a>
        </header>

        <main class="contenedor-login-cliente">
            <!-- Columna izquierda: Presentación -->
            <section class="presentacion-cliente">
                <span class="etiqueta-bienvenida">Portal Clientes</span>
                <h1>Tu hogar en las <span>mejores manos</span></h1>
                <p>Accede a tu cuenta para solicitar servicios, dar seguimiento a tus reparaciones y calificar la atención recibida.</p>

                <div class="imagen-login-cliente">
                    <img src="Imagenes/login-cliente.png" alt="Electricista profesional ayudando en el hogar">
                </div>

          
            </section>

            <!-- Columna derecha: Formulario -->
            <section class="tarjeta-login-cliente">
                <div class="encabezado-formulario">
                    <h2><span>Inicia</span> sesión</h2>
                </div>

                <%-- Mensaje dinámico si las credenciales fallan --%>
                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                <div class="error-login" style="margin-bottom: 20px;">
                    Correo electrónico o contraseña incorrectos. Verifica tus datos.
                </div>
                <%  }%>

                <!-- Apunta directo al Servlet que conecta con la base de datos -->
                <form action="LoginClienteServlet" method="POST" class="formulario-login">
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
                                placeholder="cliente@fixhome.com" 
                                required
                                autocomplete="email">
                        </div>
                    </div>

                    <div class="campo-login">
                        <div class="encabezado-campo">
                            <label for="password">Contraseña</label>
                            <a href="#" class="enlace-olvido">¿Olvidaste tu contraseña?</a>
                        </div>
                        <div class="contenedor-input-icono contenedor-contrasena">
                            <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input 
                                type="password" 
                                id="password" 
                                name="password" 
                                placeholder="Ingresa tu contraseña" 
                                required>
                            <button type="button" class="mostrar-contrasena" id="btnMostrar" onclick="togglePassword()">
                                Mostrar
                            </button>
                        </div>
                    </div> <!-- Naited ditoy ti umiso a panangisira (>) iti div -->

                    <button type="submit" class="boton-login-cliente">
                        Iniciar sesión
                        <span class="flecha" aria-hidden="true">›</span>
                    </button>
                </form>

                <div class="pie-tarjeta-login">
                    <p>¿Aún no tienes cuenta? <a href="<%= request.getContextPath()%>/cliente/registro-cliente.jsp">Regístrate como cliente</a></p>
                </div>
            </section>
        </main>

        <script>
            function togglePassword() {
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