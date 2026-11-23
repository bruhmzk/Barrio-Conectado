from app.integraciones.notificaciones import (
    NotificacionesSimuladas,
    SolicitudAviso,
)


def _solicitud():
    return SolicitudAviso(
        numero_seguimiento="BC-2026-000102",
        destinatario="Vecino Demo",
        estado_nuevo="Completado",
        nota="Microbasural retirado",
    )


def test_solicitud_aceptada():
    resultado = NotificacionesSimuladas(disponible=True).solicitar_aviso(_solicitud())

    assert resultado.aceptado is True
    assert resultado.mensaje == "aviso aceptado"


def test_servicio_no_disponible():
    resultado = NotificacionesSimuladas(disponible=False).solicitar_aviso(_solicitud())

    assert resultado.aceptado is False
    assert resultado.mensaje == "aviso pendiente de envío"


def test_no_existe_tabla_notificaciones(conexion):
    tabla = conexion.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'notificaciones'"
    ).fetchone()

    assert tabla is None
