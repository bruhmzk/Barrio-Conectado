import os
from dataclasses import dataclass
from typing import Protocol


@dataclass
class SolicitudAviso:
    numero_seguimiento: str
    destinatario: str
    estado_nuevo: str
    nota: str


@dataclass
class ResultadoAviso:
    aceptado: bool
    mensaje: str


class Notificador(Protocol):
    def solicitar_aviso(self, solicitud: SolicitudAviso) -> ResultadoAviso:
        ...


class NotificacionesSimuladas:
    def __init__(self, disponible: bool | None = None):
        if disponible is None:
            disponible = os.getenv("CIN324_NOTIFICACIONES_DISPONIBLES", "1") != "0"
        self.disponible = disponible

    def solicitar_aviso(self, solicitud: SolicitudAviso) -> ResultadoAviso:
        if not self.disponible:
            print(
                "[NotificacionesSimuladas] Aviso pendiente para "
                f"{solicitud.destinatario} ({solicitud.numero_seguimiento})"
            )
            return ResultadoAviso(False, "aviso pendiente de envío")
        print(
            "[NotificacionesSimuladas] Aviso aceptado para "
            f"{solicitud.destinatario} ({solicitud.numero_seguimiento}): "
            f"{solicitud.estado_nuevo}"
        )
        return ResultadoAviso(True, "aviso aceptado")
