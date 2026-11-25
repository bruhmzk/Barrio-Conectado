import sqlite3
from pathlib import Path

DIR_MIGRACIONES = Path(__file__).resolve().parents[1] / "app" / "db" / "migrations"


def _base_anterior(ruta: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(ruta)
    conn.row_factory = sqlite3.Row
    conn.executescript((DIR_MIGRACIONES / "001_esquema_inicial.sql").read_text("utf-8"))
    conn.executescript((DIR_MIGRACIONES / "002_cambios_estado.sql").read_text("utf-8"))
    with conn:
        conn.execute("INSERT INTO departamentos (nombre) VALUES ('Obras')")
        conn.execute(
            "INSERT INTO categorias (nombre, urgencia_base, departamento_id) "
            "VALUES ('Bache', 'alta', 1)"
        )
        conn.execute(
            "INSERT INTO usuarios (nombre, medio_contacto, rol) "
            "VALUES ('Vecino Demo', 'vecino@demo.cl', 'vecino')"
        )
        conn.execute(
            "INSERT INTO usuarios (nombre, medio_contacto, rol) "
            "VALUES ('Administrador Demo', 'admin@demo.cl', 'administrador')"
        )
        conn.execute(
            "INSERT INTO reportes (numero_seguimiento, descripcion, fecha_hora_registro, "
            "estado, prioridad, usuario_id, categoria_id) "
            "VALUES ('BC-2026-000001', 'Bache previo', '2026-11-01T10:00:00', "
            "'Recibido', 'Alta', 1, 1)"
        )
        conn.execute(
            "INSERT INTO ubicaciones (reporte_id, latitud, longitud, referencia) "
            "VALUES (1, -33.45, -70.66, 'Av. Central')"
        )
        conn.execute(
            "INSERT INTO asignaciones (reporte_id, departamento_id, usuario_id, fecha_hora) "
            "VALUES (1, 1, NULL, '2026-11-01T10:00:00')"
        )
        conn.execute(
            "INSERT INTO cambios_estado (reporte_id, fecha_hora, estado_anterior, "
            "estado_nuevo, nota, usuario_id) "
            "VALUES (1, '2026-11-02T09:00:00', 'Recibido', 'En revisión', '', 2)"
        )
    return conn


def test_migracion_emergencias_conserva_los_datos_previos(tmp_path):
    conn = _base_anterior(tmp_path / "anterior.db")
    try:
        conn.execute("PRAGMA foreign_keys = ON")
        conn.executescript((DIR_MIGRACIONES / "003_emergencias.sql").read_text("utf-8"))

        assert conn.execute("SELECT COUNT(*) FROM reportes").fetchone()[0] == 1
        assert conn.execute("SELECT COUNT(*) FROM ubicaciones").fetchone()[0] == 1
        assert conn.execute("SELECT COUNT(*) FROM asignaciones").fetchone()[0] == 1
        assert conn.execute("SELECT COUNT(*) FROM cambios_estado").fetchone()[0] == 1
        assert conn.execute("SELECT COUNT(*) FROM usuarios").fetchone()[0] == 2

        reporte = conn.execute("SELECT * FROM reportes").fetchone()
        assert reporte["numero_seguimiento"] == "BC-2026-000001"
        assert reporte["es_emergencia"] == 0
        assert reporte["aviso_pendiente"] == 0

        assert conn.execute("PRAGMA foreign_key_check").fetchall() == []
    finally:
        conn.close()


def test_migracion_emergencias_acepta_estados_prioridad_y_rol_nuevos(tmp_path):
    conn = _base_anterior(tmp_path / "nuevo.db")
    try:
        conn.execute("PRAGMA foreign_keys = ON")
        conn.executescript((DIR_MIGRACIONES / "003_emergencias.sql").read_text("utf-8"))

        with conn:
            conn.execute(
                "INSERT INTO departamentos (nombre) VALUES ('Gestor de emergencias')"
            )
            conn.execute(
                "INSERT INTO categorias (nombre, urgencia_base, departamento_id, es_emergencia) "
                "VALUES ('Incendio', 'alta', 2, 1)"
            )
            conn.execute(
                "INSERT INTO usuarios (nombre, medio_contacto, rol) "
                "VALUES ('Gestor Demo', 'emergencias@demo.cl', 'gestor_emergencias')"
            )
            conn.execute(
                "INSERT INTO reportes (numero_seguimiento, descripcion, fecha_hora_registro, "
                "estado, prioridad, es_emergencia, aviso_pendiente, usuario_id, categoria_id) "
                "VALUES ('BC-2026-000002', 'Incendio', '2026-11-05T10:00:00', "
                "'En atención por Gestor', 'Máxima', 1, 1, 1, 2)"
            )

        fila = conn.execute(
            "SELECT r.estado, r.prioridad, r.es_emergencia, r.aviso_pendiente, "
            "c.urgencia_base FROM reportes r JOIN categorias c ON c.id = r.categoria_id "
            "WHERE r.numero_seguimiento = 'BC-2026-000002'"
        ).fetchone()
        assert fila["estado"] == "En atención por Gestor"
        assert fila["prioridad"] == "Máxima"
        assert fila["es_emergencia"] == 1
        assert fila["aviso_pendiente"] == 1
        assert fila["urgencia_base"] == "alta"

        indice = conn.execute(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name = 'idx_cambios_estado_reporte_fecha'"
        ).fetchone()
        assert indice is not None
    finally:
        conn.close()
