Sistema de Entregas Móvil - Paquexpress
Descripción del Proyecto

Este proyecto es una aplicación móvil creada para Paquexpress S.A. de C.V., pensada para que los agentes puedan llevar un mejor control de sus entregas.
Con esta app se pueden registrar entregas tomando una foto como evidencia y guardando la ubicación exacta donde se hizo la entrega.

Objetivo

La idea principal es hacer que el proceso de entrega sea más seguro y confiable, guardando información como fotos y ubicación para comprobar cada entrega de manera sencilla.

Tecnología Usada
Aplicación Móvil

Está desarrollada con Flutter, y usa algunos complementos para funciones importantes como:

tomar fotos,

obtener la ubicación,

guardar datos básicos del usuario,

y conectarse con el servidor.

Backend (Servidor)

La parte del servidor está hecha con FastAPI, que es rápido y fácil de trabajar.
Toda la información se guarda en una base de datos MySQL
y el acceso de los usuarios se valida con un sistema de autenticación simple basado en MD5.

Base de Datos

Se usa MySQL y contiene las tablas principales:

agentes
paquetes
entregas
evidencias

Instalación y Configuración
Lo que necesitas antes de empezar

Python 3.8 o superior

Flutter instalado

Un servidor MySQL

Git para clonar el proyecto
git clone https://github.com/tuusuario/paquexpress-app.git
cd paquexpress-app
1. Clonar el Repositorio
git clone https://github.com/tuusuario/paquexpress-app.git
cd paquexpress-app
