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
