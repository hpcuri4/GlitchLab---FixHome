<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FixHome | Registro de Trabajador</title>

        <!-- Enlaces a tus hojas de estilos CSS -->
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-logincliente.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-principal.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/ESTILOS-CSS/estilo-registrotrabajador.css">
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
            <!-- Columna Izquierda: Presentación / Branding -->
            <section class="presentacion-cliente">
                <span class="etiqueta-bienvenida" id="etiquetaBrand">Trabajador</span>
                <h1 id="tituloBrand">Crea tu cuenta</h1>
                <p id="descBrand">Ofrece tus servicios y conecta con nuevos clientes de manera segura y directa.</p>

                <div class="imagen-login-cliente">
                    <img src="<%= request.getContextPath()%>/Imagenes/registro-trabajador.png" alt="Caja de herramientas FixHome">
                </div>

                <div class="tarjeta-confianza">
                    <div class="icono-confianza">✓</div>
                    <div>
                        <strong>Red de especialistas</strong>
                        <p>Amplía tu cartera de trabajos y gestiona tu propio tiempo.</p>
                    </div>
                </div>
            </section>

            <!-- Columna Derecha: Contenedor del Formulario Multipasos -->
            <section class="tarjeta-login-cliente">

                <!-- CONTENEDOR GLOBAL DE ALERTAS VISIBLES EN CUALQUIER PASO -->
                <div id="alertaFormulario" style="display: none; background: #fdf2f2; border: 1.5px solid #f8d7da; color: #842029; padding: 12px 16px; border-radius: 10px; font-size: 13px; margin-bottom: 20px; align-items: center; gap: 10px;">
                    <span style="font-size: 16px;">⚠️</span>
                    <span id="textoAlerta" style="flex: 1; font-weight: 500;"></span>
                </div>

                <div class="encabezado-formulario">
                    <h2 id="tituloPaso">Datos <span>personales</span></h2>
                    <p class="descripcion-login" id="subtituloPaso">Paso 1 de 3: Información básica de tu cuenta.</p>
                </div>

                <!-- Barra de Progreso de 3 Pasos -->
                <div class="pasos-wizard">
                    <div class="paso-item activo" id="pasoIndicator1">
                        <div class="paso-numero" id="pasoNum1">1</div>
                        <span class="paso-label">Datos personales</span>
                    </div>
                    <div class="linea-paso"></div>
                    <div class="paso-item" id="pasoIndicator2">
                        <div class="paso-numero" id="pasoNum2">2</div>
                        <span class="paso-label">Experiencia</span>
                    </div>
                    <div class="linea-paso"></div>
                    <div class="paso-item" id="pasoIndicator3">
                        <div class="paso-numero" id="pasoNum3">3</div>
                        <span class="paso-label">Documentos</span>
                    </div>
                </div>

                <!-- Formulario Principal -->
                <form id="formRegistroTrabajador" class="formulario-login" action="<%= request.getContextPath()%>/RegistroTrabajadorServlet" method="POST" enctype="multipart/form-data">

                    <!-- ================= PASO 1: DATOS PERSONALES ================= -->
                    <div class="seccion-paso activa" id="paso1">
                        <div class="campo-login">
                            <label for="nombreCompleto">Nombre completo</label>
                            <div class="contenedor-input-icono">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                <input type="text" id="nombreCompleto" name="nombreCompleto" placeholder="Escribe tu nombre">
                            </div>
                        </div>

                        <div class="campo-login">
                            <label for="correo">Correo electrónico</label>
                            <div class="contenedor-input-icono">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                <input type="email" id="correo" name="correo" placeholder="nombre@correo.com">
                            </div>
                        </div>

                        <div class="campo-login">
                            <label for="password">Contraseña</label>
                            <div class="contenedor-input-icono contenedor-contrasena">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                                <input type="password" id="password" name="password" placeholder="••••••••">
                                <button type="button" class="mostrar-contrasena" id="btnMostrar" onclick="togglePass()">Mostrar</button>
                            </div>
                        </div>

                        <div class="campo-login">
                            <label for="telefono">Número de teléfono</label>
                            <div class="contenedor-input-icono">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                                <input type="tel" id="telefono" name="telefono" placeholder="10 dígitos" maxlength="10">
                            </div>
                        </div>

                        <div class="campo-login">
                            <label for="direccion">Dirección</label>
                            <div class="contenedor-input-icono">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                <input type="text" id="direccion" name="direccion" placeholder="Calle, número y colonia">
                            </div>
                        </div>

                        <div style="background: #f4f6f4; border: 1px solid #d0ded4; border-radius: 8px; padding: 12px; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; font-size: 13px; color: #2c4c3e;">
                            <span style="font-size: 16px;">🛡️</span>
                            <span>Para aceptar solicitudes, tu documentación debe ser aprobada.</span>
                        </div>

                        <button type="button" class="boton-login-cliente" onclick="siguientePaso(2)">
                            Continuar <span class="flecha">›</span>
                        </button>
                    </div>

                    <!-- ================= PASO 2: EXPERIENCIA Y SERVICIOS ================= -->
                    <div class="seccion-paso" id="paso2">
                        <!-- Especialidad principal -->
                        <div class="campo-login">
                            <label for="especialidad">Especialidad principal</label>
                            <div class="contenedor-input-icono" style="position: relative; display: flex; align-items: center;">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; pointer-events: none; width: 20px; height: 20px; color: #666;"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"></path></svg>
                                <select id="especialidad" name="especialidad" style="width: 100%; border: none; background: transparent; font-size: 14px; outline: none; padding: 12px 12px 12px 45px; cursor: pointer; appearance: none; -webkit-appearance: none; -moz-appearance: none;">
                                    <option value="" disabled selected>Selecciona una especialidad</option>
                                    <option value="Plomería">Plomería</option>
                                    <option value="Electricidad">Electricidad</option>
                                    <option value="Carpintería">Carpintería</option>
                                    <option value="Pintura">Pintura</option>
                                    <option value="Jardinería">Jardinería</option>
                                    <option value="Limpieza">Limpieza</option>
                                </select>
                                <span style="position: absolute; right: 15px; pointer-events: none; color: #666; font-size: 12px;">▼</span>
                            </div>
                        </div>

                        <!-- Años de experiencia -->
                        <div class="campo-login">
                            <label for="aniosExperiencia">Años de experiencia</label>
                            <div class="contenedor-input-icono">
                                <svg class="icono-input" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                <input type="number" id="aniosExperiencia" name="aniosExperiencia" placeholder="Ej. 3" min="0" max="50">
                            </div>
                        </div>

                        <!-- Describe tu experiencia -->
                        <div class="campo-login">
                            <label for="descripcionExperiencia">Describe tu experiencia</label>
                            <div style="border: 1px solid #dcdcdc; border-radius: 8px; padding: 10px; background: #fafafa;">
                                <textarea id="descripcionExperiencia" name="descripcionExperiencia" rows="3" placeholder="Cuéntanos sobre tu trabajo y experiencia..." maxlength="500" oninput="actualizarContador(this)" style="width: 100%; border: none; background: transparent; resize: none; outline: none; font-family: inherit; font-size: 14px;"></textarea>
                                <div class="contador-caracteres" id="txtContador">0/500</div>
                            </div>
                        </div>

                        <!-- Servicios que realizas -->
                        <div class="campo-login">
                            <label>Servicios que realizas</label>
                            <div class="grid-servicios">
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Plomería" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">🪠 Plomería</span>
                                    <span class="radio-custom"></span>
                                </label>
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Electricidad" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">⚡ Electricidad</span>
                                    <span class="radio-custom"></span>
                                </label>
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Carpintería" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">🔨 Carpintería</span>
                                    <span class="radio-custom"></span>
                                </label>
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Pintura" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">🎨 Pintura</span>
                                    <span class="radio-custom"></span>
                                </label>
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Jardinería" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">🌱 Jardinería</span>
                                    <span class="radio-custom"></span>
                                </label>
                                <label class="tarjeta-servicio">
                                    <input type="checkbox" name="servicios" value="Limpieza" onchange="toggleTarjeta(this)">
                                    <span class="info-servicio">🧹 Limpieza</span>
                                    <span class="radio-custom"></span>
                                </label>
                            </div>
                        </div>

                        <div style="background: #f4f6f4; border: 1px solid #d0ded4; border-radius: 8px; padding: 12px; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; font-size: 13px; color: #2c4c3e;">
                            <span style="font-size: 16px;">ℹ️</span>
                            <span>Podrás editar esta información más adelante.</span>
                        </div>

                        <!-- Botones Atrás / Continuar -->
                        <div class="acciones-formulario">
                            <button type="button" class="btn-atras" onclick="siguientePaso(1)">Atrás</button>
                            <button type="button" class="boton-login-cliente btn-continuar" onclick="siguientePaso(3)">
                                Continuar <span class="flecha" aria-hidden="true">›</span>
                            </button>
                        </div>
                    </div>

                    <!-- ================= PASO 3: DOCUMENTOS ================= -->
                    <div class="seccion-paso" id="paso3">
                        
                        <!-- Identificación oficial -->
                        <div class="campo-login" style="margin-bottom: 16px;">
                            <div style="display: flex; align-items: flex-start; justify-content: space-between; border: 1.5px solid #e0e0e0; border-radius: 12px; padding: 14px; background: #ffffff;">
                                <div style="display: flex; gap: 12px; align-items: flex-start; flex: 1; overflow: hidden;">
                                    <div style="color: #0c3b2e; font-size: 24px; margin-top: 2px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="16" rx="2"></rect><circle cx="9" cy="10" r="2"></circle><path d="M15 8h2"></path><path d="M15 12h2"></path><path d="M7 16h10"></path></svg>
                                    </div>
                                    <div style="flex: 1; overflow: hidden;">
                                        <strong style="display: block; font-size: 14px; color: #0c3b2e; margin-bottom: 2px;">Identificación oficial</strong>
                                        <span style="font-size: 12px; color: #666; display: block; margin-bottom: 6px;">INE o pasaporte.</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span id="label-ine" style="font-size: 11px; color: #888; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">Ningún archivo seleccionado</span>
                                            <button type="button" id="btn-quitar-ine" onclick="quitarArchivo('ine', 'label-ine', 'btn-quitar-ine')" style="display: none; background: none; border: none; color: #c62828; font-size: 11px; font-weight: bold; cursor: pointer; padding: 0;">Quitar</button>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label for="ine" style="background: #ffffff; color: #0c3b2e; border: 1.5px solid #0c3b2e; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; display: inline-block; white-space: nowrap; transition: background 0.2s;">
                                        + Adjuntar archivo
                                    </label>
                                    <input type="file" id="ine" name="ine" accept=".pdf,.jpg,.jpeg,.png" style="display: none;" onchange="actualizarNombreArchivo(this, 'label-ine', 'btn-quitar-ine')">
                                </div>
                            </div>
                        </div>

                        <!-- CURP -->
                        <div class="campo-login" style="margin-bottom: 16px;">
                            <div style="display: flex; align-items: flex-start; justify-content: space-between; border: 1.5px solid #e0e0e0; border-radius: 12px; padding: 14px; background: #ffffff;">
                                <div style="display: flex; gap: 12px; align-items: flex-start; flex: 1; overflow: hidden;">
                                    <div style="color: #0c3b2e; font-size: 24px; margin-top: 2px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                    </div>
                                    <div style="flex: 1; overflow: hidden;">
                                        <strong style="display: block; font-size: 14px; color: #0c3b2e; margin-bottom: 2px;">CURP</strong>
                                        <span style="font-size: 12px; color: #666; display: block; margin-bottom: 6px;">Adjunta tu constancia o documento.</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span id="label-curp" style="font-size: 11px; color: #888; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">Ningún archivo seleccionado</span>
                                            <button type="button" id="btn-quitar-curp" onclick="quitarArchivo('curp_doc', 'label-curp', 'btn-quitar-curp')" style="display: none; background: none; border: none; color: #c62828; font-size: 11px; font-weight: bold; cursor: pointer; padding: 0;">Quitar</button>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label for="curp_doc" style="background: #ffffff; color: #0c3b2e; border: 1.5px solid #0c3b2e; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; display: inline-block; white-space: nowrap;">
                                        + Adjuntar archivo
                                    </label>
                                    <input type="file" id="curp_doc" name="curp_doc" accept=".pdf,.jpg,.jpeg,.png" style="display: none;" onchange="actualizarNombreArchivo(this, 'label-curp', 'btn-quitar-curp')">
                                </div>
                            </div>
                        </div>

                        <!-- Comprobante de domicilio -->
                        <div class="campo-login" style="margin-bottom: 16px;">
                            <div style="display: flex; align-items: flex-start; justify-content: space-between; border: 1.5px solid #e0e0e0; border-radius: 12px; padding: 14px; background: #ffffff;">
                                <div style="display: flex; gap: 12px; align-items: flex-start; flex: 1; overflow: hidden;">
                                    <div style="color: #0c3b2e; font-size: 24px; margin-top: 2px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                                    </div>
                                    <div style="flex: 1; overflow: hidden;">
                                        <strong style="display: block; font-size: 14px; color: #0c3b2e; margin-bottom: 2px;">Comprobante de domicilio</strong>
                                        <span style="font-size: 12px; color: #666; display: block; margin-bottom: 6px;">Documento reciente a tu nombre.</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span id="label-domicilio" style="font-size: 11px; color: #888; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">Ningún archivo seleccionado</span>
                                            <button type="button" id="btn-quitar-domicilio" onclick="quitarArchivo('domicilio_doc', 'label-domicilio', 'btn-quitar-domicilio')" style="display: none; background: none; border: none; color: #c62828; font-size: 11px; font-weight: bold; cursor: pointer; padding: 0;">Quitar</button>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label for="domicilio_doc" style="background: #ffffff; color: #0c3b2e; border: 1.5px solid #0c3b2e; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; display: inline-block; white-space: nowrap;">
                                        + Adjuntar archivo
                                    </label>
                                    <input type="file" id="domicilio_doc" name="domicilio_doc" accept=".pdf,.jpg,.jpeg,.png" style="display: none;" onchange="actualizarNombreArchivo(this, 'label-domicilio', 'btn-quitar-domicilio')">
                                </div>
                            </div>
                        </div>

                        <!-- Fotos de trabajos realizados (Opcional) -->
                        <div class="campo-login" style="margin-bottom: 16px;">
                            <div style="display: flex; align-items: flex-start; justify-content: space-between; border: 1.5px solid #e0e0e0; border-radius: 12px; padding: 14px; background: #ffffff;">
                                <div style="display: flex; gap: 12px; align-items: flex-start; flex: 1; overflow: hidden;">
                                    <div style="color: #0c3b2e; font-size: 24px; margin-top: 2px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                                    </div>
                                    <div style="flex: 1; overflow: hidden;">
                                        <strong style="display: block; font-size: 14px; color: #0c3b2e; margin-bottom: 2px;">Fotos de trabajos realizados</strong>
                                        <span style="font-size: 12px; color: #666; display: block; margin-bottom: 6px;">Opcional: muestra algunos de tus trabajos.</span>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span id="label-fotos" style="font-size: 11px; color: #888; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">Ningún archivo seleccionado</span>
                                            <button type="button" id="btn-quitar-fotos" onclick="quitarArchivo('fotos_trabajo', 'label-fotos', 'btn-quitar-fotos')" style="display: none; background: none; border: none; color: #c62828; font-size: 11px; font-weight: bold; cursor: pointer; padding: 0;">Quitar</button>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label for="fotos_trabajo" style="background: #ffffff; color: #0c3b2e; border: 1.5px solid #0c3b2e; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; cursor: pointer; display: inline-block; white-space: nowrap;">
                                        + Adjuntar imágenes
                                    </label>
                                    <input type="file" id="fotos_trabajo" name="fotos_trabajo" accept=".jpg,.jpeg,.png" multiple style="display: none;" onchange="actualizarNombreArchivo(this, 'label-fotos', 'btn-quitar-fotos')">
                                </div>
                            </div>
                        </div>

                        <!-- Alerta informativa -->
                        <div style="background: #f4f6f4; border: 1px solid #d0ded4; border-radius: 8px; padding: 12px; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; font-size: 13px; color: #2c4c3e;">
                            <span style="font-size: 16px;">🛡️</span>
                            <span>Solo el administrador podrá revisar tus documentos.</span>
                        </div>

                        <!-- Botones de Navegación -->
                        <div class="acciones-formulario">
                            <button type="button" class="btn-atras" onclick="siguientePaso(2)">Atrás</button>
                            <button type="submit" class="boton-login-cliente btn-continuar" onclick="return validarDocumentos(event);">
                                Enviar registro <span class="flecha" aria-hidden="true">›</span>
                            </button>
                        </div>

                        <p style="text-align: center; font-size: 11px; color: #888; margin-top: 15px;">Tu registro quedará pendiente de revisión.</p>
                    </div>

                </form>

                <div class="pie-tarjeta-login">
                    <p>¿Ya tienes cuenta? <a href="<%= request.getContextPath()%>/login-trabajador.jsp">Inicia sesión</a></p>
                </div>
            </section>
        </main>

        <!-- Scripts de Navegación y Validaciones -->
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

            function actualizarContador(textarea) {
                document.getElementById('txtContador').textContent = textarea.value.length + "/500";
            }

            function toggleTarjeta(checkbox) {
                const tarjeta = checkbox.closest('.tarjeta-servicio');
                if (checkbox.checked) {
                    tarjeta.classList.add('seleccionada');
                } else {
                    tarjeta.classList.remove('seleccionada');
                }
            }

            // Función para mostrar la alerta estilizada
            function mostrarAlerta(mensaje) {
                const contenedorAlerta = document.getElementById('alertaFormulario');
                const textoAlerta = document.getElementById('textoAlerta');

                if (contenedorAlerta && textoAlerta) {
                    textoAlerta.textContent = mensaje;
                    contenedorAlerta.style.display = 'flex';
                    contenedorAlerta.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                } else {
                    alert(mensaje);
                }
            }

            function ocultarAlerta() {
                const contenedorAlerta = document.getElementById('alertaFormulario');
                if (contenedorAlerta) {
                    contenedorAlerta.style.display = 'none';
                }
            }

            // Validación del Paso 1
            function validarPaso1() {
                ocultarAlerta();
                const nombre = document.getElementById('nombreCompleto').value.trim();
                const correo = document.getElementById('correo').value.trim();
                const password = document.getElementById('password').value.trim();
                const telefono = document.getElementById('telefono').value.trim();
                const direccion = document.getElementById('direccion').value.trim();

                if (nombre === "" || correo === "" || password === "" || telefono === "" || direccion === "") {
                    mostrarAlerta("Por favor, completa todos los campos obligatorios del Paso 1.");
                    return false;
                }

                const regexCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!regexCorreo.test(correo)) {
                    mostrarAlerta("Por favor, ingresa un correo electrónico válido.");
                    return false;
                }

                if (password.length < 6) {
                    mostrarAlerta("La contraseña debe tener al menos 6 caracteres.");
                    return false;
                }

                if (telefono.length !== 10 || isNaN(telefono)) {
                    mostrarAlerta("Por favor, ingresa un número de teléfono válido de 10 dígitos.");
                    return false;
                }

                return true;
            }

            // Validación del Paso 2
            function validarPaso2() {
                ocultarAlerta();
                const especialidad = document.getElementById('especialidad').value;
                const aniosExp = document.getElementById('aniosExperiencia').value;
                const descripcion = document.getElementById('descripcionExperiencia').value.trim();
                const servicios = document.querySelectorAll('input[name="servicios"]:checked');

                if (!especialidad || especialidad === "") {
                    mostrarAlerta("Por favor, selecciona tu especialidad principal.");
                    return false;
                }

                if (aniosExp === "" || isNaN(aniosExp) || parseInt(aniosExp) < 0) {
                    mostrarAlerta("Por favor, indica tus años de experiencia válidos.");
                    return false;
                }

                if (descripcion === "") {
                    mostrarAlerta("Por favor, escribe una breve descripción de tu experiencia.");
                    return false;
                }

                if (servicios.length === 0) {
                    mostrarAlerta("Por favor, selecciona al menos un servicio que realizas.");
                    return false;
                }

                return true;
            }

            // Validación del Paso 3 (Documentos Obligatorios)
            function validarDocumentos(event) {
                ocultarAlerta();
                const ine = document.getElementById('ine').files.length;
                const curp = document.getElementById('curp_doc').files.length;
                const domicilio = document.getElementById('domicilio_doc').files.length;

                if (ine === 0 || curp === 0 || domicilio === 0) {
                    if (event) event.preventDefault();
                    mostrarAlerta("⚠️ Debes adjuntar todos los documentos obligatorios (INE, CURP y Comprobante de domicilio) para enviar tu registro.");
                    siguientePaso(3);
                    return false;
                }
                return true;
            }

            // Navegación del Wizard
            function siguientePaso(pasoDestino) {
                ocultarAlerta();

                if (pasoDestino === 2) {
                    if (!validarPaso1()) return;
                }

                if (pasoDestino === 3) {
                    if (!validarPaso1()) {
                        cambiarVistaPaso(1);
                        return;
                    }
                    if (!validarPaso2()) return;
                }

                cambiarVistaPaso(pasoDestino);
            }

            // Cambiar vista de los pasos
            function cambiarVistaPaso(paso) {
                document.querySelectorAll('.seccion-paso').forEach(sec => sec.classList.remove('activa'));

                for (let i = 1; i <= 3; i++) {
                    const item = document.getElementById('pasoIndicator' + i);
                    const num = document.getElementById('pasoNum' + i);
                    if (item && num) {
                        item.classList.remove('activo', 'completado');

                        if (i < paso) {
                            item.classList.add('completado');
                            num.textContent = '✓';
                        } else if (i === paso) {
                            item.classList.add('activo');
                            num.textContent = i;
                        } else {
                            num.textContent = i;
                        }
                    }
                }

                const seccionActual = document.getElementById('paso' + paso);
                if (seccionActual) {
                    seccionActual.classList.add('activa');
                }

                const tituloPaso = document.getElementById('tituloPaso');
                const subtituloPaso = document.getElementById('subtituloPaso');
                const tituloBrand = document.getElementById('tituloBrand');
                const descBrand = document.getElementById('descBrand');

                if (paso === 1) {
                    if (tituloPaso) tituloPaso.innerHTML = 'Datos <span>personales</span>';
                    if (subtituloPaso) subtituloPaso.textContent = 'Paso 1 de 3: Información básica de tu cuenta.';
                    if (tituloBrand) tituloBrand.textContent = 'Crea tu cuenta';
                    if (descBrand) descBrand.textContent = 'Ofrece tus servicios y conecta con nuevos clientes de manera segura y directa.';
                } else if (paso === 2) {
                    if (tituloPaso) tituloPaso.innerHTML = 'Tu <span>experiencia</span>';
                    if (subtituloPaso) subtituloPaso.textContent = 'Paso 2 de 3: Cuéntales a tus clientes qué servicios puedes realizar.';
                    if (tituloBrand) tituloBrand.textContent = 'Tu experiencia';
                    if (descBrand) descBrand.textContent = 'Destaca tus habilidades para recibir las mejores solicitudes de trabajo.';
                } else if (paso === 3) {
                    if (tituloPaso) tituloPaso.innerHTML = 'Verifica <span>tu perfil</span>';
                    if (subtituloPaso) subtituloPaso.textContent = 'Paso 3 de 3: Envía tus documentos para validación.';
                    if (tituloBrand) tituloBrand.textContent = 'Verifica tu perfil';
                    if (descBrand) descBrand.textContent = 'Envía tus documentos para que el administrador revise tu registro.';
                }

                window.scrollTo({ top: 0, behavior: 'smooth' });
            }

            // Actualizar nombre de archivo seleccionado
            function actualizarNombreArchivo(input, labelId, btnQuitarId) {
                const label = document.getElementById(labelId);
                const btnQuitar = document.getElementById(btnQuitarId);

                if (input.files && input.files.length > 0) {
                    if (input.files.length === 1) {
                        label.textContent = input.files[0].name;
                    } else {
                        label.textContent = input.files.length + " archivos seleccionados";
                    }
                    label.style.color = "#2e7d32";
                    label.style.fontWeight = "bold";
                    if (btnQuitar) btnQuitar.style.display = 'inline-block';
                } else {
                    resetearArchivoUI(input, label, btnQuitar);
                }
            }

            // Quitar archivo seleccionado
            function quitarArchivo(inputId, labelId, btnQuitarId) {
                const input = document.getElementById(inputId);
                const label = document.getElementById(labelId);
                const btnQuitar = document.getElementById(btnQuitarId);

                input.value = ""; // Limpiar input file
                resetearArchivoUI(input, label, btnQuitar);
            }

            function resetearArchivoUI(input, label, btnQuitar) {
                label.textContent = "Ningún archivo seleccionado";
                label.style.color = "#888";
                label.style.fontWeight = "normal";
                if (btnQuitar) btnQuitar.style.display = 'none';
            }

            // Al cargar la página, detectar parámetros de error en la URL
            window.addEventListener('DOMContentLoaded', (event) => {
                const urlParams = new URLSearchParams(window.location.search);
                const error = urlParams.get('error');

                if (error === 'correo_registrado') {
                    siguientePaso(1);
                    mostrarAlerta("⚠️ El correo electrónico ya se encuentra registrado. Intenta con otro o inicia sesión.");
                } else if (error === 'documentos_incompletos') {
                    siguientePaso(3);
                    mostrarAlerta("⚠️ Debes adjuntar todos los documentos obligatorios (INE, CURP y Comprobante de domicilio).");
                } else if (error === '1') {
                    mostrarAlerta("Ocurrió un error inesperado al procesar tu registro. Por favor, intenta de nuevo.");
                }
            });
        </script>
    </body>
</html>