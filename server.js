const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors()); // Permite peticiones desde el HTML frontend

// Conexión a la BD
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: 'CEMR.rul07',
    database: 'Abarrotes'
};

// 1. Ruta para obtener la lista de productos
app.get('/api/productos', async (req, res) => {
    try {
        const connection = await mysql.createConnection(dbConfig);
        const [rows] = await connection.execute('SELECT id_producto, nombre, precio, stock FROM producto WHERE stock > 0');
        await connection.end();
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2. Ruta para procesar la venta al presionar "Pagar/Finalizar"
app.post('/api/ventas', async (req, res) => {
    const { items, total } = req.body; // items es un arreglo [{ id_producto, cantidad, precio_unitario }, ...]
    
    try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.beginTransaction();

        // Registrar la venta principal
        const [resultVenta] = await connection.execute(
            'INSERT INTO venta (total, fecha_hora, fecha_creacion, estatus) VALUES (?, NOW(), NOW(), 1)',
            [total]
        );
        const idVenta = resultVenta.insertId;

        // Registrar cada detalle de la venta y actualizar stock
        for (const item of items) {
            await connection.execute(
                'INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, fecha_creacion, estatus) VALUES (?, ?, ?, ?, NOW(), 1)',
                [idVenta, item.id_producto, item.cantidad, item.precio_unitario]
            );

            // Restar stock
            await connection.execute(
                'UPDATE producto SET stock = stock - ? WHERE id_producto = ?',
                [item.cantidad, item.id_producto]
            );
        }

        await connection.commit();
        await connection.end();
        res.json({ success: true, message: 'Venta registrada con éxito', id_venta: idVenta });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => {
    console.log('Servidor backend corriendo en http://localhost:3000');
});