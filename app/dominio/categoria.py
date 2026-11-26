def asegurar_categorias(conn):
    if conn.execute("SELECT 1 FROM categorias LIMIT 1").fetchone() is None:
        from app.db.seed import sembrar

        sembrar(conn)


def listar_categorias(conn):
    asegurar_categorias(conn)
    return conn.execute(
        "SELECT id, nombre, urgencia_base, departamento_id, es_emergencia "
        "FROM categorias ORDER BY nombre"
    ).fetchall()


def obtener_categoria(conn, categoria_id):
    return conn.execute(
        "SELECT id, nombre, urgencia_base, departamento_id, es_emergencia "
        "FROM categorias WHERE id = ?",
        (categoria_id,),
    ).fetchone()
