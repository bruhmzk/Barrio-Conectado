from app.db.conexion import aplicar_migraciones, obtener_conexion

DEPARTAMENTOS = ["Alumbrado", "Aseo", "Obras"]

CATEGORIAS = [
    ("Luminaria", "media", "Alumbrado"),
    ("Microbasural", "alta", "Aseo"),
    ("Bache", "alta", "Obras"),
]

USUARIOS = [
    ("Vecino Demo", "vecino@demo.cl", "vecino"),
    ("Administrador Demo", "admin@demo.cl", "administrador"),
]


def sembrar(conn) -> None:
    with conn:
        for nombre in DEPARTAMENTOS:
            conn.execute(
                "INSERT OR IGNORE INTO departamentos (nombre) VALUES (?)", (nombre,)
            )
        for nombre, urgencia, departamento in CATEGORIAS:
            fila = conn.execute(
                "SELECT id FROM departamentos WHERE nombre = ?", (departamento,)
            ).fetchone()
            conn.execute(
                "INSERT OR IGNORE INTO categorias (nombre, urgencia_base, departamento_id) "
                "VALUES (?, ?, ?)",
                (nombre, urgencia, fila["id"]),
            )
        for nombre, contacto, rol in USUARIOS:
            conn.execute(
                "INSERT OR IGNORE INTO usuarios (nombre, medio_contacto, rol) "
                "VALUES (?, ?, ?)",
                (nombre, contacto, rol),
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
