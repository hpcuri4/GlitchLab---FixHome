<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso administrador | FixHome</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/ESTILOS-CSS/estilo-principal.css">
    </head>

    <body>
        <header class="encabezado">
            <a href="${pageContext.request.contextPath}/index.html" class="logo">
                <img src="${pageContext.request.contextPath}/Imagenes/logo.png"
                     alt="">
                FixHome
            </a>

            <a href="${pageContext.request.contextPath}/index.html"
               class="volver-sitio">
                <span aria-hidden="true">←</span>
                Volver a la página principal
            </a>
        </header>

        <main class="pagina-login">

            <section class="presentacion-login"
                     aria-labelledby="titulo-login">

                <h1 id="titulo-login">
                    <span>Panel</span><br>
                    administrativo
                </h1>

                <p>Inicia sesión para gestionar la plataforma FixHome.</p>

                <div class="imagen-login">
                    <img
                        src="${pageContext.request.contextPath}/Imagenes/admin-principal.png"
                        alt="Persona trabajando con una computadora portátil">
                </div>
            </section>

            <section class="tarjeta-login"
                     aria-labelledby="titulo-formulario">

                <h2 id="titulo-formulario">
                    <span>Iniciar</span> sesión
                </h2>

                <p class="descripcion-login">
                    Acceso exclusivo para administradores.
                </p>

                <form action="${pageContext.request.contextPath}/LoginServlet"
                      method="post"
                      class="formulario-login">
                    <p class="error-login" role="alert">${errorLogin}</p>

                    <div class="campo-login">
                        <label for="correo">Correo electrónico</label>

                        <input
                            type="email"
                            id="correo"
                            name="correo"
                            placeholder="Escribe tu correo"
                            autocomplete="username"
                            maxlength="254"
                            required>
                    </div>

                    <div class="campo-login">
                        <label for="contrasena">Contraseña</label>

                        <div class="contenedor-contrasena">
                            <input
                                type="password"
                                id="contrasena"
                                name="contrasena"
                                placeholder="Ingresa tu contraseña"
                                autocomplete="current-password"
                                required>

                            <button
                                type="button"
                                class="mostrar-contrasena"
                                id="mostrar-contrasena"
                                aria-controls="contrasena"
                                aria-pressed="false">
                                Mostrar
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="boton-principal boton-login">
                        Iniciar sesión
                        <span class="flecha" aria-hidden="true">›</span>
                    </button>

                </form>
            </section>

        </main>

        <script>
            const campoContrasena = document.getElementById("contrasena");
            const botonMostrar = document.getElementById("mostrar-contrasena");

            botonMostrar.addEventListener("click", function () {
                const mostrar = campoContrasena.type === "password";

                campoContrasena.type = mostrar ? "text" : "password";
                botonMostrar.textContent = mostrar ? "Ocultar" : "Mostrar";
                botonMostrar.setAttribute("aria-pressed", String(mostrar));
            });
        </script>
    </body>
</html>