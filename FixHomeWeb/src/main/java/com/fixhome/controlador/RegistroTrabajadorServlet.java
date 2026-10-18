package com.fixhome.controlador;

import com.fixhome.conexion.Conexion;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/RegistroTrabajadorServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB por archivo
    maxRequestSize = 1024 * 1024 * 50     // 50MB en total para la solicitud
)
public class RegistroTrabajadorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Recibir datos del Paso 1 (Datos personales)
        String nombreCompleto = request.getParameter("nombreCompleto");
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        // Separar nombre y apellidos
        String nombre = nombreCompleto;
        String apellidos = "";
        if (nombreCompleto != null && nombreCompleto.contains(" ")) {
            int ultimoEspacio = nombreCompleto.lastIndexOf(" ");
            nombre = nombreCompleto.substring(0, ultimoEspacio);
            apellidos = nombreCompleto.substring(ultimoEspacio + 1);
        }

        // 2. Recibir datos del Paso 2 (Experiencia y servicios)
        String especialidad = request.getParameter("especialidad");
        String aniosExpStr = request.getParameter("aniosExperiencia");
        String descripcionExperiencia = request.getParameter("descripcionExperiencia");
        String[] serviciosSeleccionados = request.getParameterValues("servicios");

        // 3. Validar que los documentos obligatorios estén presentes en el servidor
        Part inePart = request.getPart("ine");
        Part curpPart = request.getPart("curp_doc");
        Part domicilioPart = request.getPart("domicilio_doc");

        if (inePart == null || inePart.getSize() == 0 ||
            curpPart == null || curpPart.getSize() == 0 ||
            domicilioPart == null || domicilioPart.getSize() == 0) {
            
            // Redirige de vuelta al paso 3 indicando el error de documentos incompletos
            response.sendRedirect(request.getContextPath() + "/trabajador/registro-trabajador.jsp?error=documentos_incompletos");
            return;
        }

        // Generar un identificador único temporal para la CURP del registro
        String curpGenerada = "CURP" + System.currentTimeMillis(); 

        Connection conn = null;

        try {
            conn = Conexion.conectar();
            conn.setAutoCommit(false); // Iniciar transacción

            // A. Verificar si el correo ya existe
            String sqlCheck = "SELECT id_usuario FROM usuarios WHERE correo = ?";
            try (PreparedStatement pstCheck = conn.prepareStatement(sqlCheck)) {
                pstCheck.setString(1, correo);
                try (ResultSet rs = pstCheck.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/trabajador/registro-trabajador.jsp?error=correo_registrado");
                        return;
                    }
                }
            }

            // B. Insertar en tabla 'usuarios'
            String sqlUsuario = "INSERT INTO usuarios (nombre, apellidos, correo, contrasena_hash, telefono, activo) VALUES (?, ?, ?, ?, ?, TRUE)";
            int idUsuarioGenerado = -1;
            try (PreparedStatement pstUsr = conn.prepareStatement(sqlUsuario, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstUsr.setString(1, nombre);
                pstUsr.setString(2, apellidos);
                pstUsr.setString(3, correo);
                pstUsr.setString(4, password); // Puedes aplicar hash aquí si usas BCrypt
                pstUsr.setString(5, telefono);
                pstUsr.executeUpdate();

                try (ResultSet keys = pstUsr.getGeneratedKeys()) {
                    if (keys.next()) {
                        idUsuarioGenerado = keys.getInt(1);
                    }
                }
            }

            // C. Insertar en tabla 'trabajadores'
            String sqlTrabajador = "INSERT INTO trabajadores (id_trabajador, curp, domicilio, descripcion_experiencia, estado_registro) VALUES (?, ?, ?, ?, 'pendiente')";
            try (PreparedStatement pstTrab = conn.prepareStatement(sqlTrabajador)) {
                pstTrab.setInt(1, idUsuarioGenerado);
                pstTrab.setString(2, curpGenerada);
                pstTrab.setString(3, direccion);
                pstTrab.setString(4, "Especialidad: " + especialidad + " (" + aniosExpStr + " años). " + descripcionExperiencia);
                pstTrab.executeUpdate();
            }

            // D. Vincular servicios en 'trabajador_servicios'
            if (serviciosSeleccionados != null) {
                String sqlFindServicio = "SELECT id_servicio FROM servicios WHERE nombre = ?";
                String sqlInsertRelacion = "INSERT INTO trabajador_servicios (id_trabajador, id_servicio) VALUES (?, ?)";
                
                try (PreparedStatement pstFind = conn.prepareStatement(sqlFindServicio);
                     PreparedStatement pstRel = conn.prepareStatement(sqlInsertRelacion)) {
                    
                    for (String servNombre : serviciosSeleccionados) {
                        pstFind.setString(1, servNombre);
                        try (ResultSet rsServ = pstFind.executeQuery()) {
                            if (rsServ.next()) {
                                int idServicio = rsServ.getInt("id_servicio");
                                pstRel.setInt(1, idUsuarioGenerado);
                                pstRel.setInt(2, idServicio);
                                pstRel.executeUpdate();
                            }
                        }
                    }
                }
            }

            // E. Guardar documentos oficiales en la carpeta de subida del servidor
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            procesarYGuardarArchivo(inePart, idUsuarioGenerado, "comprobante_domicilio", uploadPath, conn);
            procesarYGuardarArchivo(curpPart, idUsuarioGenerado, "curp", uploadPath, conn);
            procesarYGuardarArchivo(domicilioPart, idUsuarioGenerado, "comprobante_domicilio", uploadPath, conn);

            // Confirmar transacción completa con éxito
            conn.commit();
            
            // Redirigir al inicio de sesión de trabajador con aviso de éxito
            response.sendRedirect(request.getContextPath() + "/login-trabajador.jsp?exito=registro_exitoso");

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/trabajador/registro-trabajador.jsp?error=1");
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // Método auxiliar para guardar archivos físicos y registrar la ruta en la base de datos
    private void procesarYGuardarArchivo(Part filePart, int idTrabajador, String tipoDoc, String uploadPath, Connection conn) throws IOException, SQLException {
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = new File(filePart.getSubmittedFileName()).getName();
            String filePath = uploadPath + File.separator + idTrabajador + "_" + fileName;
            filePart.write(filePath);

            String sqlDoc = "INSERT INTO documentos_trabajador (id_trabajador, tipo, ruta_archivo, estado) VALUES (?, ?, ?, 'pendiente')";
            try (PreparedStatement pstDoc = conn.prepareStatement(sqlDoc)) {
                pstDoc.setInt(1, idTrabajador);
                pstDoc.setString(2, tipoDoc);
                pstDoc.setString(3, "uploads/" + idTrabajador + "_" + fileName);
                pstDoc.executeUpdate();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}