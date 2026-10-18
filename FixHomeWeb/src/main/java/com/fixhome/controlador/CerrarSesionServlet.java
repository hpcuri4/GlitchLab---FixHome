package com.fixhome.controlador;

import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CerrarSesionServlet")
public class CerrarSesionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws IOException {

        // Obtiene la sesión actual sin crear una nueva
        HttpSession sesion = request.getSession(false);

        if (sesion != null) {
            sesion.invalidate(); // Destruye todos los datos de la sesión (cierra sesión)
        }

        // Redirige al usuario a la página de inicio o al login de clientes
        response.sendRedirect(request.getContextPath() + "/index.html");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {
        // Permite manejar peticiones GET por si algún enlace directo llama al servlet
        doPost(request, response);
    }
}