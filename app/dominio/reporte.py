import random
from dataclasses import dataclass
from datetime import datetime

from app.integraciones.notificaciones import (
    NotificacionesSimuladas,
    ResultadoAviso,
    SolicitudAviso,
)

ESTADO_INICIAL = "Recibido"
ESTADOS = ("Recibido", "En revisión", "Completado", "Descartado")
PRIORIDADES = ("Alta", "Media", "Baja")


@dataclass
class ResultadoCierre:
    exito: bool
    mensaje: str
    aviso: str = ""


PRIORIDAD_POR_URGENCIA = {
    "alta": "Alta",
    "media": "Media",
    "baja": "Baja",
}


def prioridad_desde_urgencia(urgencia_base: str) -> str:
    return PRIORIDAD_POR_URGENCIA[urgencia_base]


def generar_numero_seguimiento(conn) -> str:
    anio = datetime.now().year
    for _ in range(20):
        numero = f"BC-{anio}-{random.randint(0, 999999):06d}"
        existe = conn.execute(
            "SELECT 1 FROM reportes WHERE numero_seguimiento = ?", (numero,)
        ).fetchone()
        if existe is None:
            return numero
    raise RuntimeError("No se pudo generar un número de seguimiento único")


def obtener_reporte_por_numero(conn, numero_seguimiento: str):
    return conn.execute(
        "SELECT r.*, c.nombre AS categoria, d.nombre AS departamento "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "LEFT JOIN asignaciones a ON a.reporte_id = r.id "
        "LEFT JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.numero_seguimiento = ? "
        "ORDER BY a.id LIMIT 1",
        (numero_seguimiento,),
    ).fetchone()


def listar_reportes_de_usuario(conn, usuario_id):
    return conn.execute(
        "SELECT r.numero_seguimiento, r.fecha_hora_registro, r.estado, "
        "c.nombre AS categoria "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "WHERE r.usuario_id = ? "
        "ORDER BY r.fecha_hora_registro DESC",
        (usuario_id,),
    ).fetchall()


def obtener_reporte_para_usuario(conn, numero_seguimiento: str, usuario_id):
    return conn.execute(
        "SELECT r.*, c.nombre AS categoria, d.nombre AS departamento "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "LEFT JOIN asignaciones a ON a.reporte_id = r.id "
        "LEFT JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.numero_seguimiento = ? AND r.usuario_id = ? "
        "ORDER BY a.id LIMIT 1",
        (numero_seguimiento, usuario_id),
    ).fetchone()


def listar_cambios_estado(conn, reporte_id):
    return conn.execute(
        "SELECT fecha_hora, estado_anterior, estado_nuevo, nota "
        "FROM cambios_estado WHERE reporte_id = ? ORDER BY fecha_hora",
        (reporte_id,),
    ).fetchall()


def listar_reportes_para_administracion(
    conn, categoria_id=None, prioridad=None, estado=None
):
    sql = (
        "SELECT r.numero_seguimiento, r.descripcion, r.fecha_hora_registro, "
        "r.estado, r.prioridad, c.nombre AS categoria, d.nombre AS departamento "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "LEFT JOIN asignaciones a ON a.id = ("
        "SELECT MIN(id) FROM asignaciones WHERE reporte_id = r.id"
        ") "
        "LEFT JOIN departamentos d ON d.id = a.departamento_id"
    )
    condiciones = []
    valores = []
    if categoria_id:
        condiciones.append("r.categoria_id = ?")
        valores.append(categoria_id)
    if prioridad:
        condiciones.append("r.prioridad = ?")
        valores.append(prioridad)
    if estado:
        condiciones.append("r.estado = ?")
        valores.append(estado)
    if condiciones:
        sql += " WHERE " + " AND ".join(condiciones)
    sql += (
        " ORDER BY CASE r.prioridad "
        "WHEN 'Alta' THEN 1 WHEN 'Media' THEN 2 WHEN 'Baja' THEN 3 ELSE 4 END, "
        "r.fecha_hora_registro DESC"
    )
    return conn.execute(sql, valores).fetchall()


def completar_reporte(conn, numero_seguimiento, nota, usuario_id, notificador=None):
    fila = conn.execute(
        "SELECT r.id, r.estado, u.nombre AS destinatario "
        "FROM reportes r JOIN usuarios u ON u.id = r.usuario_id "
        "WHERE r.numero_seguimiento = ?",
        (numero_seguimiento,),
    ).fetchone()
    if fila is None:
        return ResultadoCierre(False, "No existe un reporte con ese número de seguimiento")
    if fila["estado"] != "En revisión":
        return ResultadoCierre(False, "El reporte no está En revisión")

    nota_limpia = nota.strip() if nota else ""
    if not nota_limpia:
        return ResultadoCierre(False, "La nota de resolución es obligatoria")

    fecha_hora = datetime.now().isoformat(timespec="seconds")
    with conn:
        actualizado = conn.execute(
            "UPDATE reportes SET estado = ? WHERE id = ? AND estado = ?",
            ("Completado", fila["id"], "En revisión"),
        )
        if actualizado.rowcount != 1:
            return ResultadoCierre(False, "El reporte no está En revisión")
        conn.execute(
            "INSERT INTO cambios_estado "
            "(reporte_id, fecha_hora, estado_anterior, estado_nuevo, nota, usuario_id) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (
                fila["id"],
                fecha_hora,
                "En revisión",
                "Completado",
                nota_limpia,
                usuario_id,
            ),
        )

    if notificador is None:
        notificador = NotificacionesSimuladas()
    try:
        resultado_aviso = notificador.solicitar_aviso(
            SolicitudAviso(
                numero_seguimiento=numero_seguimiento,
                destinatario=fila["destinatario"],
                estado_nuevo="Completado",
                nota=nota_limpia,
            )
        )
    except Exception:
        resultado_aviso = ResultadoAviso(False, "aviso pendiente de envío")

    return ResultadoCierre(
        True, "Reporte completado correctamente", resultado_aviso.mensaje
    )
