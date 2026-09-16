USE for_you;

-- =========================================================
-- 1. USUARIOS Y ROLES
-- =========================================================

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    usuario VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (rol_id) REFERENCES roles(id)
);


-- =========================================================
-- 2. CATEGORIAS
-- =========================================================

CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    estado BOOLEAN NOT NULL DEFAULT TRUE
);


-- =========================================================
-- 3. UNIDADES DE MEDIDA
-- =========================================================

CREATE TABLE unidades_medida (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    abreviatura VARCHAR(10) NOT NULL UNIQUE,
    tipo ENUM(
        'UNIDAD',
        'PESO',
        'VOLUMEN',
        'LONGITUD'
    ) NOT NULL
);


-- =========================================================
-- 4. PROVEEDORES
-- =========================================================

CREATE TABLE proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(30),
    correo VARCHAR(150),
    direccion VARCHAR(255),
    observaciones TEXT,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- 5. INSUMOS
-- =========================================================

CREATE TABLE insumos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255),

    categoria_id INT NOT NULL,
    unidad_base_id INT NOT NULL,

    stock_actual DECIMAL(14,3) NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(14,3) NOT NULL DEFAULT 0,

    costo_promedio DECIMAL(14,6) NOT NULL DEFAULT 0,

    estado BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (categoria_id)
        REFERENCES categorias(id),

    FOREIGN KEY (unidad_base_id)
        REFERENCES unidades_medida(id)
);


-- =========================================================
-- 6. CONVERSIONES DE UNIDADES
-- =========================================================

CREATE TABLE conversiones_unidad (
    id INT AUTO_INCREMENT PRIMARY KEY,

    unidad_origen_id INT NOT NULL,
    unidad_destino_id INT NOT NULL,

    factor DECIMAL(14,6) NOT NULL,

    FOREIGN KEY (unidad_origen_id)
        REFERENCES unidades_medida(id),

    FOREIGN KEY (unidad_destino_id)
        REFERENCES unidades_medida(id),

    UNIQUE (
        unidad_origen_id,
        unidad_destino_id
    )
);


-- =========================================================
-- 7. COMPRAS
-- =========================================================

CREATE TABLE compras (
    id INT AUTO_INCREMENT PRIMARY KEY,

    proveedor_id INT NOT NULL,

    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    numero_factura VARCHAR(100),

    subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
    impuestos DECIMAL(14,2) NOT NULL DEFAULT 0,
    total DECIMAL(14,2) NOT NULL DEFAULT 0,

    observacion TEXT,

    usuario_id INT,

    FOREIGN KEY (proveedor_id)
        REFERENCES proveedores(id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);


-- =========================================================
-- 8. DETALLE DE COMPRAS
-- =========================================================

CREATE TABLE detalle_compras (
    id INT AUTO_INCREMENT PRIMARY KEY,

    compra_id INT NOT NULL,
    insumo_id INT NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL,

    unidad_compra_id INT NOT NULL,

    precio_total DECIMAL(14,2) NOT NULL,

    cantidad_base DECIMAL(14,3) NOT NULL,

    costo_unitario_base DECIMAL(14,6) NOT NULL,

    FOREIGN KEY (compra_id)
        REFERENCES compras(id)
        ON DELETE CASCADE,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id),

    FOREIGN KEY (unidad_compra_id)
        REFERENCES unidades_medida(id)
);


-- =========================================================
-- 9. HISTORIAL DE COSTOS
-- =========================================================

CREATE TABLE historial_costos_insumo (
    id INT AUTO_INCREMENT PRIMARY KEY,

    insumo_id INT NOT NULL,

    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    costo_unitario DECIMAL(14,6) NOT NULL,

    cantidad_base DECIMAL(14,3) NOT NULL,

    precio_total DECIMAL(14,2) NOT NULL,

    proveedor_id INT,

    compra_id INT,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id),

    FOREIGN KEY (proveedor_id)
        REFERENCES proveedores(id),

    FOREIGN KEY (compra_id)
        REFERENCES compras(id)
);


-- =========================================================
-- 10. MOVIMIENTOS DE INVENTARIO
-- =========================================================

CREATE TABLE movimientos_inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,

    insumo_id INT NOT NULL,

    tipo ENUM(
        'ENTRADA_COMPRA',
        'SALIDA_PRODUCCION',
        'SALIDA_MERMA',
        'SALIDA_VENTA',
        'ENTRADA_AJUSTE',
        'SALIDA_AJUSTE'
    ) NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL,

    costo_unitario DECIMAL(14,6),

    referencia VARCHAR(100),

    observacion TEXT,

    usuario_id INT,

    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);


-- =========================================================
-- 11. PRODUCTOS DEL CATALOGO
-- =========================================================

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,

    nombre VARCHAR(150) NOT NULL,

    descripcion TEXT,

    categoria_id INT NOT NULL,

    precio_venta DECIMAL(14,2),

    margen_sugerido DECIMAL(7,2),

    estado BOOLEAN NOT NULL DEFAULT TRUE,

    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
);


-- =========================================================
-- 12. RECETAS
-- =========================================================

CREATE TABLE recetas (
    id INT AUTO_INCREMENT PRIMARY KEY,

    producto_id INT NOT NULL,

    nombre VARCHAR(150) NOT NULL,

    rendimiento DECIMAL(14,3) NOT NULL DEFAULT 1,

    estado BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE
);


-- =========================================================
-- 13. DETALLE DE RECETAS
-- =========================================================

CREATE TABLE detalle_recetas (
    id INT AUTO_INCREMENT PRIMARY KEY,

    receta_id INT NOT NULL,

    insumo_id INT NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL,

    FOREIGN KEY (receta_id)
        REFERENCES recetas(id)
        ON DELETE CASCADE,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
);


-- =========================================================
-- 14. COTIZACIONES
-- =========================================================

CREATE TABLE cotizaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,

    cliente VARCHAR(150),

    telefono_cliente VARCHAR(30),

    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    descripcion TEXT,

    producto_base_id INT NULL,

    costo_total DECIMAL(14,2) NOT NULL DEFAULT 0,

    precio_venta DECIMAL(14,2) NOT NULL DEFAULT 0,

    ganancia DECIMAL(14,2) NOT NULL DEFAULT 0,

    margen DECIMAL(7,2) NOT NULL DEFAULT 0,

    estado ENUM(
        'BORRADOR',
        'COTIZADA',
        'APROBADA',
        'RECHAZADA',
        'CANCELADA'
    ) NOT NULL DEFAULT 'BORRADOR',

    usuario_id INT,

    FOREIGN KEY (producto_base_id)
        REFERENCES productos(id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);


-- =========================================================
-- 15. DETALLE DE COTIZACIONES
-- =========================================================

CREATE TABLE detalle_cotizacion (
    id INT AUTO_INCREMENT PRIMARY KEY,

    cotizacion_id INT NOT NULL,

    insumo_id INT NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL,

    unidad_id INT NOT NULL,

    costo_unitario DECIMAL(14,6) NOT NULL,

    costo_total DECIMAL(14,2) NOT NULL,

    FOREIGN KEY (cotizacion_id)
        REFERENCES cotizaciones(id)
        ON DELETE CASCADE,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id),

    FOREIGN KEY (unidad_id)
        REFERENCES unidades_medida(id)
);


-- =========================================================
-- 16. PEDIDOS
-- =========================================================

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,

    cotizacion_id INT,

    cliente VARCHAR(150) NOT NULL,

    telefono VARCHAR(30),

    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fecha_entrega DATETIME,

    estado ENUM(
        'PENDIENTE',
        'CONFIRMADO',
        'EN_PRODUCCION',
        'LISTO',
        'ENTREGADO',
        'CANCELADO'
    ) NOT NULL DEFAULT 'PENDIENTE',

    observaciones TEXT,

    usuario_id INT,

    FOREIGN KEY (cotizacion_id)
        REFERENCES cotizaciones(id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);


-- =========================================================
-- 17. DETALLE DE PEDIDOS
-- =========================================================

CREATE TABLE detalle_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,

    pedido_id INT NOT NULL,

    producto_id INT,

    descripcion VARCHAR(255) NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL DEFAULT 1,

    precio_unitario DECIMAL(14,2) NOT NULL DEFAULT 0,

    subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,

    FOREIGN KEY (pedido_id)
        REFERENCES pedidos(id)
        ON DELETE CASCADE,

    FOREIGN KEY (producto_id)
        REFERENCES productos(id)
);


-- =========================================================
-- 18. PRODUCCION
-- =========================================================

CREATE TABLE producciones (
    id INT AUTO_INCREMENT PRIMARY KEY,

    pedido_id INT,

    cotizacion_id INT,

    fecha_inicio DATETIME,

    fecha_fin DATETIME,

    estado ENUM(
        'PENDIENTE',
        'EN_PROCESO',
        'FINALIZADA',
        'CANCELADA'
    ) NOT NULL DEFAULT 'PENDIENTE',

    observaciones TEXT,

    usuario_id INT,

    FOREIGN KEY (pedido_id)
        REFERENCES pedidos(id),

    FOREIGN KEY (cotizacion_id)
        REFERENCES cotizaciones(id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);


-- =========================================================
-- 19. DETALLE DE PRODUCCION
-- =========================================================

CREATE TABLE detalle_produccion (
    id INT AUTO_INCREMENT PRIMARY KEY,

    produccion_id INT NOT NULL,

    insumo_id INT NOT NULL,

    cantidad DECIMAL(14,3) NOT NULL,

    costo_unitario DECIMAL(14,6) NOT NULL,

    costo_total DECIMAL(14,2) NOT NULL,

    FOREIGN KEY (produccion_id)
        REFERENCES producciones(id)
        ON DELETE CASCADE,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
);


-- =========================================================
-- 20. DATOS INICIALES
-- =========================================================

INSERT INTO roles (nombre, descripcion)
VALUES
('ADMINISTRADOR', 'Acceso completo al sistema'),
('OPERADOR', 'Operaciones de inventario y cotizaciones');


INSERT INTO unidades_medida (nombre, abreviatura, tipo)
VALUES
('Unidad', 'und', 'UNIDAD'),
('Gramo', 'g', 'PESO'),
('Kilogramo', 'kg', 'PESO'),
('Mililitro', 'ml', 'VOLUMEN'),
('Litro', 'L', 'VOLUMEN'),
('Centímetro', 'cm', 'LONGITUD'),
('Metro', 'm', 'LONGITUD');


-- =========================================================
-- 21. COMPROBACION
-- =========================================================

SHOW TABLES;

USE for_you;

SELECT COUNT(*) AS cantidad_tablas
FROM information_schema.tables
WHERE table_schema = 'for_you';
wc -l src/main/resources/db/schema.sql

