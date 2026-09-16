package com.foryou;

import static spark.Spark.*;

public class Main {

    public static void main(String[] args) {

        port(4567);

        get("/", (request, response) -> {
            return "FOR YOU - API funcionando correctamente";
        });

        System.out.println("=================================");
        System.out.println("FOR YOU");
        System.out.println("Servidor iniciado en puerto 4567");
        System.out.println("=================================");
    }
}
