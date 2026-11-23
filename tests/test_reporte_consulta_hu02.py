from app.dominio.reporte import (
    listar_cambios_estado,
    listar_reportes_de_usuario,
    obtener_reporte_para_usuario,
)


def _id_usuario(conexion, nombre):
    return conexion.execute(
        "SELECT id FROM usuarios WHERE nombre = ?", (nombre,)
    ).fetchone()["id"]


def test_lista_solo_contiene_reportes_del_autor(conexion):
    vecino = _id_usuario(conexion, "Vecino Demo")
    otro = _id_usuario(conexion, "Vecino Demo 2")

    propios = listar_reportes_de_usuario(conexion, vecino)
    assert [fila["numero_seguimiento"] for fila in propios] == [
        "BC-2026-000102",
        "BC-2026-000101",
    ]
    assert all(
        fila["categoria"] and fila["estado"] and fila["fecha_hora_registro"]
        for fila in propios
    )
    assert [
        fila["numero_seguimiento"]
        for fila in listar_reportes_de_usuario(conexion, otro)
    ] == ["BC-2026-000103"]


def test_lista_muestra_solo_reportes_del_vecino(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes")
    assert respuesta.status_code == 200
    assert "BC-2026-000101" in respuesta.text
    assert "BC-2026-000102" in respuesta.text
    assert "BC-2026-000103" not in respuesta.text
    assert "Luminaria" in respuesta.text
    assert "En revisión" in respuesta.text


def test_lista_vacia_para_vecino_sin_reportes(client, conexion):
    with conexion:
        usuario_id = conexion.execute(
            "INSERT INTO usuarios (nombre, medio_contacto, rol) VALUES (?, ?, ?)",
            ("Vecino Sin Reportes", "sinreportes@demo.cl", "vecino"),
        ).lastrowid
    client.post("/demo/usuario", data={"usuario_id": usuario_id})
    respuesta = client.get("/reportes")
    assert respuesta.status_code == 200
    assert "No existen reportes asociados a tu cuenta" in respuesta.text


def test_lista_pide_usuario_cuando_no_hay_seleccion(client):
    client.cookies.clear()
    respuesta = client.get("/reportes")
    assert respuesta.status_code == 200
    assert "Selecciona un vecino de demostración" in respuesta.text


def test_enlace_mis_reportes_en_inicio_y_registro(client, elegir_usuario):
    elegir_usuario()
    for ruta in ("/", "/reportes/nuevo"):
        assert "Mis reportes" in client.get(ruta).text


def test_detalle_filtra_por_autor_y_lee_historial(conexion):
    vecino = _id_usuario(conexion, "Vecino Demo")
    propio = obtener_reporte_para_usuario(conexion, "BC-2026-000102", vecino)
    assert propio is not None
    assert propio["estado"] == "En revisión"

    cambios = listar_cambios_estado(conexion, propio["id"])
    assert [cambio["estado_nuevo"] for cambio in cambios] == ["En revisión"]
    assert cambios[0]["fecha_hora"] == "2026-11-20T10:15:00"

    ajeno = obtener_reporte_para_usuario(conexion, "BC-2026-000103", vecino)
    assert ajeno is None


def test_detalle_muestra_estado_e_historial(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes/BC-2026-000102")
    assert respuesta.status_code == 200
    assert "Microbasural frente a la plaza" in respuesta.text
    assert "Estado actual:" in respuesta.text
    assert "En revisión" in respuesta.text
    assert "2026-11-20T10:15:00" in respuesta.text
    assert "Recibido" in respuesta.text
    assert "Historial de cambios de estado" in respuesta.text


def test_detalle_rechaza_reporte_de_otro_vecino(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes/BC-2026-000103")
    assert respuesta.status_code == 404
    assert "BC-2026-000103" not in respuesta.text
    assert "Reporte no encontrado" in respuesta.text


def test_detalle_sin_cambios_de_estado(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes/BC-2026-000101")
    assert respuesta.status_code == 200
    assert "Recibido" in respuesta.text
    assert "Sin cambios de estado registrados" in respuesta.text


def test_detalle_pide_usuario_cuando_no_hay_seleccion(client):
    client.cookies.clear()
    respuesta = client.get("/reportes/BC-2026-000102")
    assert respuesta.status_code == 200
    assert "Selecciona un vecino de demostración" in respuesta.text
