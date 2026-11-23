import sqlite3

import pytest


def test_migracion_002_registrada(conexion):
    fila = conexion.execute(
        "SELECT nombre FROM schema_migrations WHERE nombre = ?",
        ("002_cambios_estado.sql",),
    ).fetchone()
    assert fila is not None


def test_tabla_cambios_estado_tiene_columnas_del_modelo(conexion):
    columnas = {
        fila["name"] for fila in conexion.execute("PRAGMA table_info(cambios_estado)")
    }
    assert {
        "id",
        "reporte_id",
        "fecha_hora",
        "estado_anterior",
        "estado_nuevo",
        "nota",
        "usuario_id",
    } <= columnas


def test_estado_nuevo_debe_pertenecer_a_est01(conexion):
    usuario = conexion.execute("SELECT id FROM usuarios LIMIT 1").fetchone()["id"]
    categoria = conexion.execute("SELECT id FROM categorias LIMIT 1").fetchone()["id"]
    with conexion:
        cursor = conexion.execute(
            "INSERT INTO reportes (numero_seguimiento, descripcion, fecha_hora_registro, "
            "estado, prioridad, usuario_id, categoria_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                "BC-2026-990001",
                "Reporte de prueba",
                "2026-11-21T09:00:00",
                "Recibido",
                "Media",
                usuario,
                categoria,
            ),
        )
        reporte_id = cursor.lastrowid

    with pytest.raises(sqlite3.IntegrityError):
        with conexion:
            conexion.execute(
                "INSERT INTO cambios_estado (reporte_id, fecha_hora, estado_anterior, "
                "estado_nuevo, nota, usuario_id) VALUES (?, ?, ?, ?, ?, ?)",
                (
                    reporte_id,
                    "2026-11-21T09:30:00",
                    "Recibido",
                    "Aprobada",
                    "",
                    usuario,
                ),
            )
