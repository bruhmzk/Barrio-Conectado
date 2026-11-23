from app.dominio.reporte import listar_cambios_estado, obtener_reporte_por_numero


def test_sin_administrador_seleccionado(client, conexion):
    respuesta = client.get(
        "/administracion/reportes/BC-2026-000102/completar"
    )

    assert respuesta.status_code == 200
    assert (
        "Selecciona un administrador de demostración para completar el reporte"
        in respuesta.text
    )
    assert (
        obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"]
        == "En revisión"
    )


def test_vecino_no_puede_abrir_el_formulario(client, elegir_usuario, conexion):
    elegir_usuario(rol="vecino")

    respuesta = client.get(
        "/administracion/reportes/BC-2026-000102/completar"
    )

    assert respuesta.status_code == 200
    assert (
        "Selecciona un administrador de demostración para completar el reporte"
        in respuesta.text
    )
    assert (
        obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"]
        == "En revisión"
    )


def test_administrador_ve_el_formulario(client, elegir_usuario):
    elegir_usuario(rol="administrador")

    respuesta = client.get(
        "/administracion/reportes/BC-2026-000102/completar"
    )

    assert respuesta.status_code == 200
    assert "BC-2026-000102" in respuesta.text
    assert 'name="nota"' in respuesta.text
    assert "Completar reporte" in respuesta.text


def test_post_directo_sobre_reporte_recibido_es_rechazado(
    client, elegir_usuario, conexion
):
    elegir_usuario(rol="administrador")
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000101")

    respuesta = client.post(
        "/administracion/reportes/BC-2026-000101/completar",
        data={"nota": "Intento inválido"},
    )

    assert respuesta.status_code == 400
    assert "El reporte no está En revisión" in respuesta.text
    assert obtener_reporte_por_numero(conexion, "BC-2026-000101")["estado"] == "Recibido"
    assert listar_cambios_estado(conexion, reporte["id"]) == []


def test_panel_muestra_completar_solo_para_en_revision(client, elegir_usuario):
    elegir_usuario(rol="administrador")

    respuesta = client.get("/administracion/reportes")

    assert respuesta.status_code == 200
    assert (
        "/administracion/reportes/BC-2026-000102/completar" in respuesta.text
    )
    assert (
        "/administracion/reportes/BC-2026-000101/completar" not in respuesta.text
    )
