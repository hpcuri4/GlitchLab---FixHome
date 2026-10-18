package com.fixhome.utilidades;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import javax.swing.JOptionPane;
import javax.swing.JPasswordField;
import org.mindrot.jbcrypt.BCrypt;

public class GenerarHash {

    public static void main(String[] args) {
        JPasswordField campo = new JPasswordField();

        int opcion = JOptionPane.showConfirmDialog(
                null,
                campo,
                "Escribe la contraseña del administrador de FixHome",
                JOptionPane.OK_CANCEL_OPTION,
                JOptionPane.PLAIN_MESSAGE
        );

        if (opcion != JOptionPane.OK_OPTION) {
            return;
        }

        char[] caracteres = campo.getPassword();
        String contrasena = new String(caracteres);
        Arrays.fill(caracteres, '\0');

        if (contrasena.length() < 8
                || contrasena.getBytes(StandardCharsets.UTF_8).length > 72) {
            JOptionPane.showMessageDialog(
                    null,
                    "Usa al menos 8 caracteres y como máximo 72 bytes."
            );
            return;
        }

        String hash = BCrypt.hashpw(contrasena, BCrypt.gensalt(12));

        System.out.println("Copia este hash para el registro del administrador:");
        System.out.println(hash);
    }
}