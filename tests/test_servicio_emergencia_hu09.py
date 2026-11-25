import pytest

from app.integraciones.notificaciones import (
    NotificacionesSimuladas,
    SolicitudAvisoUrgente,
)
from app.servicios.registrar_emergencia import (
    ErrorValidacionEmergencia,
    registrar_emergencia,
)


def _ids(conexion):
    categoria = conexion.execute(
        "SELECT id FROM categorias WHERE nombre = 'Incendio'"
    ).fetchone()["id"]
    vecino = conexion.execute(
        "SELECT id FROM usuarios WHERE nombre = 'Vecina Emergencias'"
    ).fetchone()["id"]
    normal = conexion.execute(
        "SELECT id FROM categorias WHERE nombre = 'Bache'"
    ).fetchone()["id"]
    return categoria, vecino, normal


def _total_reportes(conexion):
    return conexion.execute("SELECT COUNT(*) AS n FROM reportes").fetchone()["n"]


def test_registro_exitoso_con_datos_minimos(conexion):
    categoria, vecino, _ = _ids(conexion)
    antes = _total_reportes(conexion)

    resultado = registrar_emergencia(
        conexion, vecino, categoria, "", "-33.4500", "-70.6600"
    )

    assert _total_reportes(conexion) == antes + 1
    fila = conexion.execute(
        "SELECT r.*, d.nombre AS departamento FROM reportes r "
        "JOIN asignaciones a ON a.reporte_id = r.id "
        "JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.numero_seguimiento = ?",
        (resultado.numero_seguimiento,),
    ).fetchone()
    assert fila["estado"] == "Recibido"
    assert fila["prioridad"] == "Máxima"
    assert fila["es_emergencia"] == 1
    assert fila["aviso_pendiente"] == 0
    assert fila["departamento"] == "Gestor de emergencias"
    assert not resultado.aviso_pendiente
    ubicacion = conexion.execute(
        "SELECT * FROM ubicaciones WHERE reporte_id = ?", (fila["id"],)
    ).fetchone()
    assert ubicacion["latitud"] == -33.45


def test_rechaza_datos_minimos_incompletos(conexion):
    categoria, vecino, _ = _ids(conexion)
    antes = _total_reportes(conexion)

    with pytest.raises(ErrorValidacionEmergencia) as exc:
        registrar_emergencia(conexion, vecino, "", "", "", "")

    assert "Falta el tipo de emergencia." in exc.value.errores
    assert "Falta la ubicación." in exc.value.errores
    assert _total_reportes(conexion) == antes


def test_rechaza_una_categoria_que_no_es_emergencia(conexion):
    _, vecino, normal = _ids(conexion)
    antes = _total_reportes(conexion)

    with pytest.raises(ErrorValidacionEmergencia) as exc:
        registrar_emergencia(conexion, vecino, normal, "", "-33.45", "-70.66")

    assert "El tipo de emergencia no es válido." in exc.value.errores
    assert _total_reportes(conexion) == antes


def test_rechaza_una_ubicacion_no_valida(conexion):
    categoria, vecino, _ = _ids(conexion)
    antes = _total_reportes(conexion)

    with pytest.raises(ErrorValidacionEmergencia) as exc:
        registrar_emergencia(conexion, vecino, categoria, "", "999", "-70.66")

    assert "La ubicación no es válida. Ingresa una nueva ubicación." in exc.value.errores
    assert _total_reportes(conexion) == antes


def test_notificacion_no_disponible_deja_el_aviso_pendiente(conexion):
    categoria, vecino, _ = _ids(conexion)

    resultado = registrar_emergencia(
        conexion,
        vecino,
        categoria,
        "",
        "-33.45",
        "-70.66",
        notificador=NotificacionesSimuladas(disponible=False),
    )

    assert resultado.aviso_pendiente
    fila = conexion.execute(
        "SELECT aviso_pendiente FROM reportes WHERE numero_seguimiento = ?",
        (resultado.numero_seguimiento,),
    ).fetchone()
    assert fila["aviso_pendiente"] == 1


def test_adaptador_de_aviso_urgente():
    solicitud = SolicitudAvisoUrgente(
        numero_seguimiento="BC-2026-999999",
        tipo="Incendio",
        ubicacion="Pasaje Los Aromos",
        destinatario="Gestor de emergencias",
    )

    aceptado = NotificacionesSimuladas(disponible=True).solicitar_aviso_urgente(
        solicitud
    )
    caido = NotificacionesSimuladas(disponible=False).solicitar_aviso_urgente(solicitud)

    assert aceptado.aceptado
    assert aceptado.mensaje == "aviso urgente aceptado"
    assert not caido.aceptado
    assert caido.mensaje == "aviso urgente pendiente de envío"
