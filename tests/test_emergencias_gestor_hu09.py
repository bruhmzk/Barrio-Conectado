from app.dominio.emergencia import obtener_emergencia


def test_bandeja_lista_solo_las_emergencias_derivadas(client, elegir_usuario):
    elegir_usuario(rol="gestor_emergencias")

    respuesta = client.get("/emergencias")

    assert respuesta.status_code == 200
    assert "BC-2026-000104" in respuesta.text
    assert "BC-2026-000105" in respuesta.text
    assert "BC-2026-000101" not in respuesta.text
    assert "Incendio" in respuesta.text
    assert "Máxima" in respuesta.text


def test_bandeja_no_esta_disponible_para_otros_roles(client, elegir_usuario):
    elegir_usuario(rol="vecino")

    respuesta = client.get("/emergencias")

    assert respuesta.status_code == 200
    assert "Selecciona un gestor de emergencias de demostración" in respuesta.text
    assert "BC-2026-000104" not in respuesta.text


def test_detalle_muestra_ubicacion_e_historial(client, elegir_usuario):
    elegir_usuario(rol="gestor_emergencias")

    respuesta = client.get("/emergencias/BC-2026-000104")

    assert respuesta.status_code == 200
    assert "Pasaje Los Aromos" in respuesta.text
    assert "Dirección:" in respuesta.text
    assert "Incendio" in respuesta.text
    assert "Recibido" in respuesta.text
    assert "Tomar conocimiento" in respuesta.text


def test_toma_de_conocimiento_exitosa(client, elegir_usuario, conexion):
    gestor = elegir_usuario(rol="gestor_emergencias")

    respuesta = client.post("/emergencias/BC-2026-000104/tomar-conocimiento")

    assert respuesta.status_code == 200
    assert "En atención por Gestor" in respuesta.text
    reporte = obtener_emergencia(conexion, "BC-2026-000104")
    assert reporte["estado"] == "En atención por Gestor"
    cambio = conexion.execute(
        "SELECT * FROM cambios_estado WHERE reporte_id = ?", (reporte["id"],)
    ).fetchone()
    assert cambio["estado_anterior"] == "Recibido"
    assert cambio["estado_nuevo"] == "En atención por Gestor"
    assert cambio["usuario_id"] == gestor


def test_toma_de_conocimiento_rechazada_por_estado_invalido(
    client, elegir_usuario, conexion
):
    elegir_usuario(rol="gestor_emergencias")
    reporte = obtener_emergencia(conexion, "BC-2026-000105")
    cambios_antes = conexion.execute(
        "SELECT COUNT(*) AS n FROM cambios_estado WHERE reporte_id = ?",
        (reporte["id"],),
    ).fetchone()["n"]

    respuesta = client.post("/emergencias/BC-2026-000105/tomar-conocimiento")

    assert respuesta.status_code == 400
    assert "no está en estado Recibido" in respuesta.text
    assert obtener_emergencia(conexion, "BC-2026-000105")["estado"] == (
        "En atención por Gestor"
    )
    cambios_despues = conexion.execute(
        "SELECT COUNT(*) AS n FROM cambios_estado WHERE reporte_id = ?",
        (reporte["id"],),
    ).fetchone()["n"]
    assert cambios_despues == cambios_antes


def test_sin_gestor_seleccionado_no_se_puede_tomar_conocimiento(client, conexion):
    client.cookies.clear()

    respuesta = client.post("/emergencias/BC-2026-000104/tomar-conocimiento")

    assert respuesta.status_code == 200
    assert "Selecciona un gestor de emergencias de demostración" in respuesta.text
    assert obtener_emergencia(conexion, "BC-2026-000104")["estado"] == "Recibido"
