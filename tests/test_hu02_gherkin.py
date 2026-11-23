from app.dominio.reporte import obtener_reporte_por_numero


def _id_usuario(conexion, nombre):
    return conexion.execute(
        "SELECT id FROM usuarios WHERE nombre = ?", (nombre,)
    ).fetchone()["id"]


def test_visualizacion_exitosa_del_historial_de_reportes_propios(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes")
    assert respuesta.status_code == 200
    assert "BC-2026-000101" in respuesta.text
    assert "BC-2026-000102" in respuesta.text
    assert "Luminaria" in respuesta.text
    assert "Microbasural" in respuesta.text
    assert "Recibido" in respuesta.text
    assert "En revisión" in respuesta.text
    assert "BC-2026-000103" not in respuesta.text


def test_consulta_de_historial_por_vecino_sin_reportes_previos(client, conexion):
    with conexion:
        usuario_id = conexion.execute(
            "INSERT INTO usuarios (nombre, medio_contacto, rol) VALUES (?, ?, ?)",
            ("Vecino Nuevo", "nuevo@demo.cl", "vecino"),
        ).lastrowid
    client.post("/demo/usuario", data={"usuario_id": usuario_id})

    respuesta = client.get("/reportes")
    assert respuesta.status_code == 200
    assert "No existen reportes asociados a tu cuenta" in respuesta.text
    assert "BC-2026-000101" not in respuesta.text
    assert "BC-2026-000102" not in respuesta.text
    assert "BC-2026-000103" not in respuesta.text


def test_consulta_del_historial_de_cambios_de_estado_de_un_reporte(
    client, conexion, elegir_usuario
):
    elegir_usuario()
    antes = obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"]

    with conexion:
        reporte = conexion.execute(
            "SELECT id FROM reportes WHERE numero_seguimiento = ?",
            ("BC-2026-000102",),
        ).fetchone()
        administrador = _id_usuario(conexion, "Administrador Demo")
        conexion.execute(
            "INSERT INTO cambios_estado (reporte_id, fecha_hora, estado_anterior, "
            "estado_nuevo, nota, usuario_id) VALUES (?, ?, ?, ?, ?, ?)",
            (
                reporte["id"],
                "2026-11-21T08:00:00",
                "En revisión",
                "Completado",
                "Derivado a Alumbrado",
                administrador,
            ),
        )

    respuesta = client.get("/reportes/BC-2026-000102")
    assert respuesta.status_code == 200
    assert "Estado actual:" in respuesta.text
    assert "En revisión" in respuesta.text
    assert "Historial de cambios de estado" in respuesta.text
    assert "2026-11-20T10:15:00" in respuesta.text
    assert "2026-11-21T08:00:00" in respuesta.text
    assert "Recibido" in respuesta.text
    assert "Completado" in respuesta.text
    assert "Derivado a Alumbrado" in respuesta.text
    assert respuesta.text.index("2026-11-20T10:15:00") < respuesta.text.index(
        "2026-11-21T08:00:00"
    )

    despues = obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"]
    assert despues == antes == "En revisión"


def test_variante_reporte_ajeno_no_accesible(client, elegir_usuario):
    elegir_usuario()
    lista = client.get("/reportes")
    assert 'href="/reportes/BC-2026-000103"' not in lista.text

    respuesta = client.get("/reportes/BC-2026-000103")
    assert respuesta.status_code == 404
    assert "Reporte no encontrado" in respuesta.text


def test_variante_reporte_sin_cambios_de_estado(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes/BC-2026-000101")
    assert respuesta.status_code == 200
    assert "Recibido" in respuesta.text
    assert "Sin cambios de estado registrados" in respuesta.text


def test_variante_sin_usuario_seleccionado(client):
    client.cookies.clear()
    for ruta in ("/reportes", "/reportes/BC-2026-000102"):
        respuesta = client.get(ruta)
        assert respuesta.status_code == 200
        assert "Selecciona un vecino de demostración" in respuesta.text
