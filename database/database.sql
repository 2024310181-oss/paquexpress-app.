-- Crear base de datos
-- Script de creación de base de datos
CREATE DATABASE Paquexpress_db;
USE Paquexpress_db;

-- Tabla de agentes/repartidores
CREATE TABLE agentes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    active TINYINT(1) DEFAULT 1,
    creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de paquetes
CREATE TABLE paquetes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_unico VARCHAR(20) UNIQUE NOT NULL,
    direccion TEXT NOT NULL,
    destinatario VARCHAR(100) NOT NULL,
    estado ENUM('pendiente', 'entregado') DEFAULT 'pendiente',
    id_agente INT,
    creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agente) REFERENCES agentes(id)
);

-- Tabla de entregas
CREATE TABLE entregas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_paquete INT NOT NULL,
    id_agente INT NOT NULL,
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paquete) REFERENCES paquetes(id),
    FOREIGN KEY (id_agente) REFERENCES agentes(id)
);

-- Tabla de evidencias (fotos y GPS)
CREATE TABLE evidencias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_entrega INT NOT NULL,
    foto LONGBLOB,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    FOREIGN KEY (id_entrega) REFERENCES entregas(id)
);

-- datos de prueba
INSERT INTO agentes (usuario, password, nombre) VALUES 
('repartidor1', MD5('password123'), 'Juan Pérez'),
('repartidor2', MD5('password456'), 'Leo valencia');

INSERT INTO paquetes (id_unico, direccion, destinatario, id_agente) VALUES 
('PKG001', 'Av. Reforma 123, CDMX', 'Carlos López', 1),
('PKG002', 'Calle Hidalgo 456, Guadalajara', 'Ana Martínez', 1),
('PKG003', 'Blvd. Universidad 789, Monterrey', 'Pedro Sánchez', 2);
