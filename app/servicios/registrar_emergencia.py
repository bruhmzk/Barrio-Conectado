from dataclasses import dataclass
from datetime import datetime

from app.dominio.categoria import obtener_categoria
from app.dominio.emergencia import (
    DEPARTAMENTO_EMERGENCIAS,
    ESTADO_RECIBIDO,
    PRIORIDAD_MAXIMA,
    obtener_departamento_emergencias,
)
from app.dominio.reporte import generar_numero_seguimiento
from app.integraciones.mapas import MapasSimulados, ValidadorUbicacion
from app.integraciones.notificaciones import (
    NotificacionesSimuladas,
    NotificadorUrgente,
    ResultadoAviso,
    SolicitudAvisoUrgente,
)


class ErrorValidacionEmergencia(Exception):
    def __init__(self, errores: list[str]):
        self.errores = errores
        super().__init__("; ".join(errores))


@dataclass
class ResultadoRegistroEmergencia:
    reporte_id: int
    numero_seguimiento: str
    aviso_pendiente: bool
    mensaje_aviso: str


def validar_datos(categoria_id, latitud, longitud) -> list[str]:
    errores = []
    if not categoria_id:
        errores.append("Falta el tipo de emergencia.")
    if latitud in (None, "") or longitud in (None, ""):
        errores.append("Falta la ubicación.")
    return errores


def _a_float(valor):
    try:
        return float(valor)
    except (TypeError, ValueError):
        return None


def registrar_emergencia(
    conn,
    usuario_id: int,
    categoria_id,
    descripcion: str,
    latitud,
    longitud,
    validador: ValidadorUbicacion | None = None,
    notificador: NotificadorUrgente | None = None,
) -> ResultadoRegistroEmergencia:
    errores = validar_datos(categoria_id, latitud, longitud)
    if errores:
        raise ErrorValidacionEmergencia(errores)

    try:
        cat_id = int(categoria_id)
    except (TypeError, ValueError):
        raise ErrorValidacionEmergencia(["El tipo de emergencia no es válido."])

    categoria = obtener_categoria(conn, cat_id)
    if categoria is None or not categoria["es_emergencia"]:
        raise ErrorValidacionEmergencia(["El tipo de emergencia no es válido."])

    lat = _a_float(latitud)
    lon = _a_float(longitud)
    if lat is None or lon is None:
        raise ErrorValidacionEmergencia(
            ["La ubicación no es válida. Ingresa una nueva ubicación."]
        )

    validador = validador or MapasSimulados()
    ubicacion = validador.validar(lat, lon)
    if not ubicacion.valida:
        raise ErrorValidacionEmergencia(
            ["La ubicación no es válida. Ingresa una nueva ubicación."]
        )

    departamento = obtener_departamento_emergencias(conn)
    departamento_id = (
        departamento["id"] if departamento is not None else categoria["departamento_id"]
    )

    numero = generar_numero_seguimiento(conn)
    fecha = datetime.now().isoformat(timespec="seconds")

    with conn:
        cursor = conn.execute(
            "INSERT INTO reportes (numero_seguimiento, descripcion, "
            "fecha_hora_registro, estado, prioridad, es_emergencia, "
            "aviso_pendiente, usuario_id, categoria_id) "
            "VALUES (?, ?, ?, ?, ?, 1, 0, ?, ?)",
            (
                numero,
                (descripcion or "").strip(),
                fecha,
                ESTADO_RECIBIDO,
                PRIORIDAD_MAXIMA,
                usuario_id,
                cat_id,
            ),
        )
        reporte_id = cursor.lastrowid
        conn.execute(
            "INSERT INTO ubicaciones (reporte_id, latitud, longitud, referencia) "
            "VALUES (?, ?, ?, ?)",
            (reporte_id, lat, lon, ubicacion.referencia),
        )
        conn.execute(
            "INSERT INTO asignaciones (reporte_id, departamento_id, usuario_id, "
            "fecha_hora) VALUES (?, ?, NULL, ?)",
            (reporte_id, departamento_id, fecha),
        )

    if notificador is None:
        notificador = NotificacionesSimuladas()
    try:
        resultado_aviso = notificador.solicitar_aviso_urgente(
            SolicitudAvisoUrgente(
                numero_seguimiento=numero,
                tipo=categoria["nombre"],
                ubicacion=ubicacion.referencia,
                destinatario=DEPARTAMENTO_EMERGENCIAS,
            )
        )
    except Exception:
        resultado_aviso = ResultadoAviso(False, "aviso urgente pendiente de envío")

    if not resultado_aviso.aceptado:
        with conn:
            conn.execute(
                "UPDATE reportes SET aviso_pendiente = 1 WHERE id = ?", (reporte_id,)
            )

    return ResultadoRegistroEmergencia(
        reporte_id=reporte_id,
        numero_seguimiento=numero,
        aviso_pendiente=not resultado_aviso.aceptado,
        mensaje_aviso=resultado_aviso.mensaje,
    )
