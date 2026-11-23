import os
import sqlite3
from contextlib import contextmanager
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
DIR_MIGRACIONES = Path(__file__).resolve().parent / "migrations"


def ruta_db() -> Path:
    return Path(os.environ.get("CIN324_DB", str(RAIZ / "data" / "app.db")))


def obtener_conexion() -> sqlite3.Connection:
    ruta = ruta_db()
    ruta.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(ruta)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def aplicar_migraciones(conn: sqlite3.Connection | None = None) -> None:
    propia = conn is None
    if propia:
        conn = obtener_conexion()
    try:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS schema_migrations ("
            "nombre TEXT PRIMARY KEY, aplicada_en TEXT NOT NULL)"
        )
        aplicadas = {
            fila["nombre"] for fila in conn.execute("SELECT nombre FROM schema_migrations")
        }
        for archivo in sorted(DIR_MIGRACIONES.glob("*.sql")):
            if archivo.name in aplicadas:
                continue
            conn.executescript(archivo.read_text(encoding="utf-8"))
            conn.execute(
                "INSERT INTO schema_migrations (nombre, aplicada_en) VALUES (?, datetime('now'))",
                (archivo.name,),
            )
            conn.commit()
    finally:
        if propia:
            conn.close()


def obtener_db():
    conn = obtener_conexion()
    try:
        yield conn
    finally:
        conn.close()


@contextmanager
def transaccion(conn: sqlite3.Connection):
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
