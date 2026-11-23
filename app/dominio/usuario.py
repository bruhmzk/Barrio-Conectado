def listar_usuarios(conn):
    return conn.execute(
        "SELECT id, nombre, medio_contacto, rol FROM usuarios ORDER BY rol, nombre"
    ).fetchall()


def obtener_usuario(conn, usuario_id):
    return conn.execute(
        "SELECT id, nombre, medio_contacto, rol FROM usuarios WHERE id = ?",
        (usuario_id,),
    ).fetchone()


def obtener_vecino_demo(conn):
    return conn.execute(
        "SELECT id, nombre, medio_contacto, rol FROM usuarios "
        "WHERE rol = 'vecino' ORDER BY id LIMIT 1"
    ).fetchone()
