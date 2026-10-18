package com.fixhome.filtros;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter("/admin/*")
public class FiltroAdministrador implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest peticion = (HttpServletRequest) request;
        HttpServletResponse respuesta = (HttpServletResponse) response;

        respuesta.setHeader("Cache-Control", "no-store");

        HttpSession sesion = peticion.getSession(false);

        if (sesion == null
                || sesion.getAttribute("idAdministrador") == null) {

            respuesta.sendRedirect(
                    peticion.getContextPath() + "/login.jsp"
            );
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}