from dataclasses import dataclass
from typing import Protocol


@dataclass
class ResultadoUbicacion:
    valida: bool
    referencia: str = ""


class ValidadorUbicacion(Protocol):
    def validar(self, latitud: float, longitud: float) -> ResultadoUbicacion:
        ...


class MapasSimulados:
    """Versión simulada del Servicio de mapas y geolocalización."""

    def validar(self, latitud: float, longitud: float) -> ResultadoUbicacion:
        valida = -90 <= latitud <= 90 and -180 <= longitud <= 180
        referencia = f"Latitud {latitud:.4f}, longitud {longitud:.4f}"
        return ResultadoUbicacion(valida=valida, referencia=referencia)
