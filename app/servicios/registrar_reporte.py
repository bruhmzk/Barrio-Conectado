from dataclasses import dataclass
from datetime import datetime

from app.dominio.categoria import obtener_categoria
from app.dominio.reporte import (
    ESTADO_INICIAL,
    generar_numero_seguimiento,
    prioridad_desde_urgencia,
)


class ErrorValidacion(Exception):
    def __init__(self, errores: list[str]):
        self.errores = errores
        super().__init__("; ".join(errores))


@dataclass
class ResultadoRegistro:
    reporte_id: int
    numero_seguimiento: str


def validar_datos(
    categoria_id,
    descripcion: str,
    archivo_foto: str,
    direccion: str,
) -> list[str]:
    errores = []
    if not categoria_id:
        errores.append("Falta la categoría.")
    if not (descripcion or "").strip():
        errores.append("Falta la descripción.")
    if not (archivo_foto or "").strip():
        errores.append("Falta la fotografía.")
    if not (direccion or "").strip():
        errores.append("Falta la dirección.")
    return errores


def registrar_reporte(
    conn,
    usuario_id: int,
    categoria_id,
    descripcion: str,
    archivo_foto: str,
    direccion: str,
) -> ResultadoRegistro:
    errores = validar_datos(categoria_id, descripcion, archivo_foto, direccion)
    if errores:
        raise ErrorValidacion(errores)

    try:
        cat_id = int(categoria_id)
    except (TypeError, ValueError):
        raise ErrorValidacion(["La categoría seleccionada no existe."])

    categoria = obtener_categoria(conn, cat_id)
    if categoria is None:
        raise ErrorValidacion(["La categoría seleccionada no existe."])

    direccion_limpia = direccion.strip()
    numero = generar_numero_seguimiento(conn)
    prioridad = prioridad_desde_urgencia(categoria["urgencia_base"])
    fecha = datetime.now().isoformat(timespec="seconds")

    with conn:
        cursor = conn.execute(
            "INSERT INTO reportes (numero_seguimiento, descripcion, fecha_hora_registro, "
            "estado, prioridad, usuario_id, categoria_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                numero,
                descripcion.strip(),
                fecha,
                ESTADO_INICIAL,
                prioridad,
                usuario_id,
                cat_id,
            ),
        )
        reporte_id = cursor.lastrowid
        conn.execute(
            "INSERT INTO ubicaciones (reporte_id, direccion, referencia) "
            "VALUES (?, ?, ?)",
            (reporte_id, direccion_limpia, direccion_limpia),
        )
        conn.execute(
            "INSERT INTO fotografias (reporte_id, archivo_imagen) VALUES (?, ?)",
            (reporte_id, archivo_foto),
        )
        conn.execute(
            "INSERT INTO asignaciones (reporte_id, departamento_id, usuario_id, fecha_hora) "
            "VALUES (?, ?, ?, ?)",
            (reporte_id, categoria["departamento_id"], None, fecha),
        )

    return ResultadoRegistro(reporte_id=reporte_id, numero_seguimiento=numero)
