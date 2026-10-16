const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));


const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'abarrotes',
    waitForConnections: true,
    connectionLimit: 10
});
const MAX = 9999999999; 
function fallo(mensaje, estado = 400) {
    const e = new Error(mensaje);
    e.status = estado;
    throw e;
}
function entero(valor, minimo = 1) {
    return Number.isInteger(valor) && valor >= minimo && valor <= 2147483647;
}
function centavos(valor) {
    const texto = String(valor);
    if (!/^\d+(\.\d{1,2})?$/.test(texto)) fallo('El precio debe tener como máximo dos decimales.');
    const n = Math.round(Number(texto) * 100);
    if (!Number.isSafeInteger(n) || n <= 0 || n > MAX) fallo('Precio fuera de rango.');
    return n;
}
function dinero(n) { return (n / 100).toFixed(2); }

app.get('/api/productos', async (req, res) => {
    const [rows] = await pool.execute(
        'SELECT id_producto, nombre, precio, stock FROM producto WHERE estatus = 1 ORDER BY nombre'
    );
    res.json(rows);
});

app.post('/api/productos', async (req, res) => {
    const { nombre, precio, stock } = req.body || {};
    if (typeof nombre !== 'string' || !nombre.trim() || nombre.trim().length > 100)
        fallo('Escribe un nombre de 1 a 100 caracteres.');
    if (!entero(stock, 0)) fallo('El stock debe ser un número entero mayor o igual a cero.');
    const precioFinal = dinero(centavos(precio));
    const [result] = await pool.execute(
        'INSERT INTO producto (nombre, precio, stock, fecha_creacion, estatus) VALUES (?, ?, ?, NOW(), 1)',
        [nombre.trim(), precioFinal, stock]
    );
    res.status(201).json({ success: true, id_producto: result.insertId });
});

app.post('/api/productos/:id/stock', async (req, res) => {
    const id = Number(req.params.id);
    const { cantidad } = req.body || {};
    if (!entero(id) || !entero(cantidad)) fallo('Selecciona un producto y una cantidad entera positiva.');
    
    const [result] = await pool.execute(
        'UPDATE producto SET stock = stock + ? WHERE id_producto = ? AND estatus = 1 AND stock <= ?',
        [cantidad, id, 2147483647 - cantidad]
    );
    if (!result.affectedRows) fallo('Producto no disponible o stock fuera de rango.', 409);
    res.json({ success: true });
});

app.post('/api/ventas', async (req, res) => {
    const { items } = req.body || {};
    if (!Array.isArray(items) || !items.length || items.length > 500) fallo('Selecciona entre 1 y 500 productos.');
    const cantidades = new Map();
    for (const item of items) {
        if (!item || !entero(item.id_producto) || !entero(item.cantidad)) fallo('Producto o cantidad inválidos.');
        const cantidad = (cantidades.get(item.id_producto) || 0) + item.cantidad;
        if (!entero(cantidad)) fallo('Cantidad fuera de rango.');
        cantidades.set(item.id_producto, cantidad);
    }
    const connection = await pool.getConnection();
    let ticket;
    try {
        await connection.beginTransaction();
        const detalle = [];
        let total = 0;
        
        for (const [id, cantidad] of [...cantidades].sort((a, b) => a[0] - b[0])) {
            const [[p]] = await connection.execute(
                'SELECT id_producto, nombre, precio, stock FROM producto WHERE id_producto = ? AND estatus = 1 FOR UPDATE', [id]
            );
            if (!p) fallo('Un producto ya no está disponible.', 409);
            if (p.stock < cantidad) fallo('Stock insuficiente para ' + p.nombre + '.', 409);
            const precio = centavos(p.precio);
            const subtotal = precio * cantidad;
            total += subtotal;
            if (!Number.isSafeInteger(total) || total > MAX) fallo('El total supera el máximo permitido.');
            detalle.push({ id_producto: id, nombre: p.nombre, cantidad, precio_unitario: dinero(precio), subtotal: dinero(subtotal) });
        }
        const [venta] = await connection.execute(
            'INSERT INTO venta (total, fecha_hora, fecha_creacion, estatus) VALUES (?, NOW(), NOW(), 1)', [dinero(total)]
        );
        for (const item of detalle) {
            await connection.execute(
                'INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, fecha_creacion, estatus) VALUES (?, ?, ?, ?, NOW(), 1)',
                [venta.insertId, item.id_producto, item.cantidad, item.precio_unitario]
            );
            await connection.execute('UPDATE producto SET stock = stock - ? WHERE id_producto = ?', [item.cantidad, item.id_producto]);
        }
        const [[fecha]] = await connection.execute(
            "SELECT DATE_FORMAT(fecha_hora, '%d/%m/%Y %H:%i:%s') AS fecha FROM venta WHERE id_venta = ?", [venta.insertId]
        );
        ticket = { id_venta: venta.insertId, fecha: fecha.fecha, items: detalle, total: dinero(total) };
        await connection.commit();
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
    res.status(201).json({ success: true, ticket });
});

app.use((error, req, res, next) => {
    console.error(error.message);
    const status = error.status || 500;
    res.status(status).json({ error: status < 500 ? error.message : 'No se pudo completar la operación. Revisa la conexión a MySQL y la consola del servidor.' });
});
if (require.main === module) {
    app.listen(3000, () => console.log('Abre http://localhost:3000 en tu navegador'));
}
module.exports = { app, pool };
