-- Crear base de datos
CREATE DATABASE IF NOT EXISTS paquexpress_db;
USE paquexpress_db;

-- Tabla de agentes/repartidores
CREATE TABLE agentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de paquetes asignados
CREATE TABLE paquetes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_unico VARCHAR(50) UNIQUE NOT NULL,
    direccion TEXT NOT NULL,
    destinatario VARCHAR(100) NOT NULL,
    estado ENUM('pendiente', 'entregado', 'cancelado') DEFAULT 'pendiente',
    id_agente INT,
    asignado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agente) REFERENCES agentes(id)
);

-- Tabla de entregas realizadas
CREATE TABLE entregas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_agente INT NOT NULL,
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paquete) REFERENCES paquetes(id),
    FOREIGN KEY (id_agente) REFERENCES agentes(id)
);

-- Tabla de evidencias (fotos + GPS)
CREATE TABLE evidencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL,
    foto LONGBLOB,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_entrega) REFERENCES entregas(id)
);

-- datos de prueba
INSERT INTO agentes (usuario, password, nombre) VALUES 
('repartidor1', MD5('password123'), 'Juan Pérez'),
('repartidor2', MD5('password456'), 'María García');

INSERT INTO paquetes (id_unico, direccion, destinatario, id_agente) VALUES 
('PKG001', 'Av. Reforma 123, CDMX', 'Carlos López', 1),
('PKG002', 'Calle Hidalgo 456, Guadalajara', 'Ana Martínez', 1),
('PKG003', 'Blvd. Universidad 789, Monterrey', 'Pedro Sánchez', 2);