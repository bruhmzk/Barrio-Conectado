from dataclasses import dataclass

PRIORIDAD_MAXIMA = "Máxima"
ESTADO_RECIBIDO = "Recibido"
ESTADO_EN_ATENCION = "En atención por Gestor"
DEPARTAMENTO_EMERGENCIAS = "Gestor de emergencias"


@dataclass
class ResultadoToma:
    exito: bool
    mensaje: str


def listar_categorias_emergencia(conn):
    return conn.execute(
        "SELECT id, nombre FROM categorias WHERE es_emergencia = 1 ORDER BY nombre"
    ).fetchall()


def obtener_departamento_emergencias(conn):
    return conn.execute(
        "SELECT id, nombre FROM departamentos WHERE nombre = ?",
        (DEPARTAMENTO_EMERGENCIAS,),
    ).fetchone()


def listar_emergencias_gestor(conn):
    return conn.execute(
        "SELECT r.numero_seguimiento, r.descripcion, r.fecha_hora_registro, "
        "r.estado, r.prioridad, r.aviso_pendiente, c.nombre AS categoria, "
        "u.nombre AS autor, d.nombre AS departamento "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "JOIN usuarios u ON u.id = r.usuario_id "
        "LEFT JOIN asignaciones a ON a.id = ("
        "SELECT MIN(id) FROM asignaciones WHERE reporte_id = r.id"
        ") "
        "LEFT JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.es_emergencia = 1 AND d.nombre = ? "
        "ORDER BY CASE r.estado WHEN 'Recibido' THEN 0 ELSE 1 END, "
        "r.fecha_hora_registro DESC",
        (DEPARTAMENTO_EMERGENCIAS,),
    ).fetchall()


def obtener_emergencia(conn, numero_seguimiento):
    return conn.execute(
        "SELECT r.*, c.nombre AS categoria, u.nombre AS autor, "
        "u.medio_contacto AS contacto_autor, "
        "ub.latitud, ub.longitud, ub.referencia, d.nombre AS departamento "
        "FROM reportes r "
        "JOIN categorias c ON c.id = r.categoria_id "
        "JOIN usuarios u ON u.id = r.usuario_id "
        "LEFT JOIN ubicaciones ub ON ub.reporte_id = r.id "
        "LEFT JOIN asignaciones a ON a.id = ("
        "SELECT MIN(id) FROM asignaciones WHERE reporte_id = r.id"
        ") "
        "LEFT JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.numero_seguimiento = ? AND r.es_emergencia = 1",
        (numero_seguimiento,),
    ).fetchone()


def tomar_conocimiento(conn, numero_seguimiento, usuario_id):
    fila = conn.execute(
        "SELECT id, estado FROM reportes "
        "WHERE numero_seguimiento = ? AND es_emergencia = 1",
        (numero_seguimiento,),
    ).fetchone()
    if fila is None:
        return ResultadoToma(False, "No existe una emergencia con ese número de seguimiento")
    if fila["estado"] != ESTADO_RECIBIDO:
        return ResultadoToma(False, "La emergencia no está en estado Recibido")

    with conn:
        actualizado = conn.execute(
            "UPDATE reportes SET estado = ? WHERE id = ? AND estado = ?",
            (ESTADO_EN_ATENCION, fila["id"], ESTADO_RECIBIDO),
        )
        if actualizado.rowcount != 1:
            return ResultadoToma(False, "La emergencia no está en estado Recibido")
        conn.execute(
            "INSERT INTO cambios_estado "
            "(reporte_id, fecha_hora, estado_anterior, estado_nuevo, nota, usuario_id) "
            "VALUES (?, datetime('now', 'localtime'), ?, ?, ?, ?)",
            (fila["id"], ESTADO_RECIBIDO, ESTADO_EN_ATENCION, "", usuario_id),
        )

    return ResultadoToma(True, "La emergencia quedó En atención por Gestor")
