import sys
from pathlib import Path

import pytest

RAIZ = Path(__file__).resolve().parents[1]
if str(RAIZ) not in sys.path:
    sys.path.insert(0, str(RAIZ))

from app.db.conexion import aplicar_migraciones, obtener_conexion
from app.db.seed import sembrar


@pytest.fixture()
def db_temporal(tmp_path, monkeypatch):
    ruta = tmp_path / "prueba.db"
    monkeypatch.setenv("CIN324_DB", str(ruta))
    conn = obtener_conexion()
    try:
        aplicar_migraciones(conn)
        sembrar(conn)
    finally:
        conn.close()
    yield ruta


@pytest.fixture()
def conexion(db_temporal):
    conn = obtener_conexion()
    yield conn
    conn.close()


@pytest.fixture()
def client(db_temporal):
    from fastapi.testclient import TestClient

    from app.main import app

    with TestClient(app) as cliente:
        yield cliente


@pytest.fixture()
def datos(conexion):
    def _datos(rol="vecino", categoria="Bache"):
        usuario = conexion.execute(
            "SELECT id FROM usuarios WHERE rol = ? ORDER BY id LIMIT 1", (rol,)
        ).fetchone()
        cat = conexion.execute(
            "SELECT id FROM categorias WHERE nombre = ?", (categoria,)
        ).fetchone()
        return usuario["id"], cat["id"]

    return _datos


@pytest.fixture()
def elegir_usuario(client, datos):
    def _elegir(rol="vecino"):
        uid, _ = datos(rol=rol)
        client.post("/demo/usuario", data={"usuario_id": uid})
        return uid

    return _elegir
