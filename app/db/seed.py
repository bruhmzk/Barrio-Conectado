from app.db.conexion import aplicar_migraciones, obtener_conexion

DEPARTAMENTOS = ["Alumbrado", "Aseo", "Obras", "Gestor de emergencias"]

CATEGORIAS = [
    ("Luminaria", "media", "Alumbrado", 0),
    ("Microbasural", "alta", "Aseo", 0),
    ("Bache", "alta", "Obras", 0),
    ("Incendio", "alta", "Gestor de emergencias", 1),
    ("Emergencia médica", "alta", "Gestor de emergencias", 1),
    ("Accidente", "alta", "Gestor de emergencias", 1),
]

USUARIOS = [
    ("Vecino Demo", "vecino@demo.cl", "vecino"),
    ("Administrador Demo", "admin@demo.cl", "administrador"),
    ("Vecino Demo 2", "vecino2@demo.cl", "vecino"),
    ("Gestor Emergencias Demo", "emergencias@demo.cl", "gestor_emergencias"),
    ("Vecina Emergencias", "vecina.emergencias@demo.cl", "vecino"),
]

REPORTES_EJEMPLO = [
    {
        "numero": "BC-2026-000101",
        "descripcion": "Luminaria apagada en la esquina",
        "estado": "Recibido",
        "prioridad": "Media",
        "autor": "Vecino Demo",
        "categoria": "Luminaria",
        "fecha": "2026-11-18T09:30:00",
        "foto": "luminaria.jpg",
        "direccion": "Esquina Av. Central",
    },
    {
        "numero": "BC-2026-000102",
        "descripcion": "Microbasural frente a la plaza",
        "estado": "En revisión",
        "prioridad": "Alta",
        "autor": "Vecino Demo",
        "categoria": "Microbasural",
        "fecha": "2026-11-19T14:10:00",
        "foto": "microbasural.jpg",
        "direccion": "Plaza central",
    },
    {
        "numero": "BC-2026-000103",
        "descripcion": "Bache profundo en la avenida",
        "estado": "Recibido",
        "prioridad": "Alta",
        "autor": "Vecino Demo 2",
        "categoria": "Bache",
        "fecha": "2026-11-20T11:00:00",
        "foto": "bache.jpg",
        "direccion": "Av. Principal",
    },
    {
        "numero": "BC-2026-000104",
        "descripcion": "",
        "estado": "Recibido",
        "prioridad": "Máxima",
        "autor": "Vecina Emergencias",
        "categoria": "Incendio",
        "fecha": "2026-11-21T08:05:00",
        "foto": None,
        "direccion": "Pasaje Los Aromos",
        "es_emergencia": 1,
        "aviso_pendiente": 0,
    },
    {
        "numero": "BC-2026-000105",
        "descripcion": "Colisión menor en la esquina",
        "estado": "En atención por Gestor",
        "prioridad": "Máxima",
        "autor": "Vecina Emergencias",
        "categoria": "Accidente",
        "fecha": "2026-11-20T18:40:00",
        "foto": None,
        "direccion": "Esquina Av. Central con Los Aromos",
        "es_emergencia": 1,
        "aviso_pendiente": 0,
    },
]

CAMBIOS_EJEMPLO = [
    {
        "numero": "BC-2026-000102",
        "fecha": "2026-11-20T10:15:00",
        "estado_anterior": "Recibido",
        "estado_nuevo": "En revisión",
        "nota": "",
        "usuario": "Administrador Demo",
    },
    {
        "numero": "BC-2026-000105",
        "fecha": "2026-11-20T19:10:00",
        "estado_anterior": "Recibido",
        "estado_nuevo": "En atención por Gestor",
        "nota": "",
        "usuario": "Gestor Emergencias Demo",
    },
]


def _id_usuario(conn, nombre):
    return conn.execute(
        "SELECT id FROM usuarios WHERE nombre = ?", (nombre,)
    ).fetchone()["id"]


def sembrar(conn) -> None:
    with conn:
        for nombre in DEPARTAMENTOS:
            conn.execute(
                "INSERT OR IGNORE INTO departamentos (nombre) VALUES (?)", (nombre,)
            )
        for nombre, urgencia, departamento, es_emergencia in CATEGORIAS:
            fila = conn.execute(
                "SELECT id FROM departamentos WHERE nombre = ?", (departamento,)
            ).fetchone()
            conn.execute(
                "INSERT OR IGNORE INTO categorias "
                "(nombre, urgencia_base, departamento_id, es_emergencia) "
                "VALUES (?, ?, ?, ?)",
                (nombre, urgencia, fila["id"], es_emergencia),
            )
        for nombre, contacto, rol in USUARIOS:
            conn.execute(
                "INSERT OR IGNORE INTO usuarios (nombre, medio_contacto, rol) "
                "VALUES (?, ?, ?)",
                (nombre, contacto, rol),
            )

        for datos in REPORTES_EJEMPLO:
            usuario_id = _id_usuario(conn, datos["autor"])
            categoria = conn.execute(
                "SELECT id, departamento_id FROM categorias WHERE nombre = ?",
                (datos["categoria"],),
            ).fetchone()
            conn.execute(
                "INSERT OR IGNORE INTO reportes (numero_seguimiento, descripcion, "
                "fecha_hora_registro, estado, prioridad, es_emergencia, aviso_pendiente, "
                "usuario_id, categoria_id) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    datos["numero"],
                    datos["descripcion"],
                    datos["fecha"],
                    datos["estado"],
                    datos["prioridad"],
                    datos.get("es_emergencia", 0),
                    datos.get("aviso_pendiente", 0),
                    usuario_id,
                    categoria["id"],
                ),
            )
            reporte_id = conn.execute(
                "SELECT id FROM reportes WHERE numero_seguimiento = ?",
                (datos["numero"],),
            ).fetchone()["id"]
            conn.execute(
                "INSERT OR IGNORE INTO ubicaciones (reporte_id, direccion, referencia) "
                "VALUES (?, ?, ?)",
                (reporte_id, datos["direccion"], datos["direccion"]),
            )
            if datos.get("foto"):
                conn.execute(
                    "INSERT INTO fotografias (reporte_id, archivo_imagen) "
                    "SELECT ?, ? WHERE NOT EXISTS "
                    "(SELECT 1 FROM fotografias WHERE reporte_id = ? AND archivo_imagen = ?)",
                    (reporte_id, datos["foto"], reporte_id, datos["foto"]),
                )
            conn.execute(
                "INSERT INTO asignaciones (reporte_id, departamento_id, usuario_id, fecha_hora) "
                "SELECT ?, ?, NULL, ? WHERE NOT EXISTS "
                "(SELECT 1 FROM asignaciones WHERE reporte_id = ? AND departamento_id = ? "
                "AND fecha_hora = ?)",
                (
                    reporte_id,
                    categoria["departamento_id"],
                    datos["fecha"],
                    reporte_id,
                    categoria["departamento_id"],
                    datos["fecha"],
                ),
            )

        for cambio in CAMBIOS_EJEMPLO:
            reporte_id = conn.execute(
                "SELECT id FROM reportes WHERE numero_seguimiento = ?",
                (cambio["numero"],),
            ).fetchone()["id"]
            usuario_id = _id_usuario(conn, cambio["usuario"])
            conn.execute(
                "INSERT INTO cambios_estado (reporte_id, fecha_hora, estado_anterior, "
                "estado_nuevo, nota, usuario_id) "
                "SELECT ?, ?, ?, ?, ?, ? WHERE NOT EXISTS "
                "(SELECT 1 FROM cambios_estado WHERE reporte_id = ? AND fecha_hora = ? "
                "AND estado_anterior = ? AND estado_nuevo = ?)",
                (
                    reporte_id,
                    cambio["fecha"],
                    cambio["estado_anterior"],
                    cambio["estado_nuevo"],
                    cambio["nota"],
                    usuario_id,
                    reporte_id,
                    cambio["fecha"],
                    cambio["estado_anterior"],
                    cambio["estado_nuevo"],
                ),
            )


def main() -> None:
    conn = obtener_conexion()
    try:
        aplicar_migraciones(conn)
        sembrar(conn)
    finally:
        conn.close()
    print("Base de datos lista con datos de ejemplo.")


if __name__ == "__main__":
    main()
