import pytest

from app.dominio.reporte import (
    completar_reporte,
    listar_cambios_estado,
    obtener_reporte_por_numero,
)
from app.integraciones.notificaciones import NotificacionesSimuladas


class NotificadorQueFalla:
    def solicitar_aviso(self, solicitud):
        raise RuntimeError("servicio no disponible")


def _admin_id(conexion):
    return conexion.execute(
        "SELECT id FROM usuarios WHERE rol = 'administrador' ORDER BY id LIMIT 1"
    ).fetchone()["id"]


def test_cierre_exitoso_escribe_estado_y_cambio(conexion):
    admin_id = _admin_id(conexion)
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")

    resultado = completar_reporte(
        conexion,
        "BC-2026-000102",
        "  Microbasural retirado  ",
        admin_id,
        NotificacionesSimuladas(disponible=True),
    )

    assert resultado.exito is True
    assert resultado.aviso == "aviso aceptado"
    actualizado = obtener_reporte_por_numero(conexion, "BC-2026-000102")
    assert actualizado["estado"] == "Completado"
    cambios = listar_cambios_estado(conexion, reporte["id"])
    assert len(cambios) == 2
    ultimo = cambios[-1]
    assert ultimo["estado_anterior"] == "En revisión"
    assert ultimo["estado_nuevo"] == "Completado"
    assert ultimo["nota"] == "Microbasural retirado"
    assert (
        conexion.execute("SELECT usuario_id FROM cambios_estado ORDER BY id DESC LIMIT 1").fetchone()[
            "usuario_id"
        ]
        == admin_id
    )


@pytest.mark.parametrize("nota", ["", "   "])
def test_nota_vacia_o_con_espacios_no_escribe(conexion, nota):
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")
    cantidad_inicial = len(listar_cambios_estado(conexion, reporte["id"]))

    resultado = completar_reporte(
        conexion, "BC-2026-000102", nota, _admin_id(conexion)
    )

    assert resultado.exito is False
    assert resultado.mensaje == "La nota de resolución es obligatoria"
    assert obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"] == "En revisión"
    assert len(listar_cambios_estado(conexion, reporte["id"])) == cantidad_inicial


@pytest.mark.parametrize("numero", ["BC-2026-000101", "BC-2026-000102"])
def test_estado_no_en_revision_no_escribe(conexion, numero):
    admin_id = _admin_id(conexion)
    if numero == "BC-2026-000102":
        completar_reporte(conexion, numero, "Cierre previo", admin_id)
    reporte = obtener_reporte_por_numero(conexion, numero)
    cantidad_inicial = len(listar_cambios_estado(conexion, reporte["id"]))

    resultado = completar_reporte(conexion, numero, "Otra nota", admin_id)

    assert resultado.exito is False
    assert resultado.mensaje == "El reporte no está En revisión"
    estado_esperado = "Completado" if numero == "BC-2026-000102" else "Recibido"
    assert obtener_reporte_por_numero(conexion, numero)["estado"] == estado_esperado
    assert len(listar_cambios_estado(conexion, reporte["id"])) == cantidad_inicial


def test_seed_deja_bc_2026_000102_en_revision(conexion):
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")

    assert reporte["estado"] == "En revisión"
    assert len(listar_cambios_estado(conexion, reporte["id"])) == 1


def test_fallo_del_notificador_no_deshlace_el_cierre(conexion):
    admin_id = _admin_id(conexion)
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")

    resultado = completar_reporte(
        conexion, "BC-2026-000102", "Nota con aviso caído", admin_id, NotificadorQueFalla()
    )

    assert resultado.exito is True
    assert resultado.aviso == "aviso pendiente de envío"
    assert obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"] == "Completado"
    assert len(listar_cambios_estado(conexion, reporte["id"])) == 2
