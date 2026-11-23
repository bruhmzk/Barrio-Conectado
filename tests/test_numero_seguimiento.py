import re
from datetime import datetime

from app.dominio.reporte import generar_numero_seguimiento


def test_formato_del_numero(conexion):
    numero = generar_numero_seguimiento(conexion)
    assert re.fullmatch(r"BC-\d{4}-\d{6}", numero)


def test_reintenta_si_el_numero_ya_existe(conexion, monkeypatch):
    usuario = conexion.execute("SELECT id FROM usuarios LIMIT 1").fetchone()["id"]
    categoria = conexion.execute("SELECT id FROM categorias LIMIT 1").fetchone()["id"]
    anio = datetime.now().year
    with conexion:
        conexion.execute(
            "INSERT INTO reportes (numero_seguimiento, descripcion, fecha_hora_registro, "
            "estado, prioridad, usuario_id, categoria_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                f"BC-{anio}-000001",
                "Reporte previo",
                "2026-01-01T00:00:00",
                "Recibido",
                "Alta",
                usuario,
                categoria,
            ),
        )
    valores = iter([1, 1, 2])
    monkeypatch.setattr(
        "app.dominio.reporte.random.randint", lambda a, b: next(valores)
    )
    assert generar_numero_seguimiento(conexion) == f"BC-{anio}-000002"
