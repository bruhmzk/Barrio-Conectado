import random
from datetime import datetime

ESTADO_INICIAL = "Recibido"
ESTADOS = ("Recibido", "En revisión", "Completado", "Descartado")

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
