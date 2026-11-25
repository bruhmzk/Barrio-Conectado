from app.db.seed import sembrar


def test_migracion_aplicada(conexion):
    tablas = {
        fila["name"]
        for fila in conexion.execute("SELECT name FROM sqlite_master WHERE type = 'table'")
    }
    esperadas = {
        "departamentos",
        "categorias",
        "usuarios",
        "reportes",
        "ubicaciones",
        "fotografias",
        "asignaciones",
        "schema_migrations",
    }
    assert esperadas <= tablas


def test_migracion_registrada(conexion):
    fila = conexion.execute("SELECT nombre FROM schema_migrations").fetchone()
    assert fila["nombre"] == "001_esquema_inicial.sql"


def test_datos_de_ejemplo_idempotentes(conexion):
    antes = conexion.execute("SELECT COUNT(*) AS n FROM categorias").fetchone()["n"]
    sembrar(conexion)
    despues = conexion.execute("SELECT COUNT(*) AS n FROM categorias").fetchone()["n"]
    emergencias = conexion.execute(
        "SELECT COUNT(*) AS n FROM categorias WHERE es_emergencia = 1"
    ).fetchone()["n"]
    assert antes == despues
    assert emergencias == 3
