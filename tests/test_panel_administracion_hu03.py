MENSAJE_SIN_ADMINISTRADOR = (
    "Selecciona un administrador de demostración para ver el panel"
)


def test_sin_usuario_seleccionado_no_muestra_el_panel(client):
    respuesta = client.get("/administracion/reportes")

    assert respuesta.status_code == 200
    assert MENSAJE_SIN_ADMINISTRADOR in respuesta.text
    assert "BC-2026-000101" not in respuesta.text


def test_vecino_no_muestra_el_panel(client, elegir_usuario):
    elegir_usuario(rol="vecino")

    respuesta = client.get("/administracion/reportes")

    assert respuesta.status_code == 200
    assert MENSAJE_SIN_ADMINISTRADOR in respuesta.text
    assert "BC-2026-000101" not in respuesta.text


def test_administrador_sin_filtros_ve_los_tres_reportes(client, elegir_usuario):
    elegir_usuario(rol="administrador")

    respuesta = client.get("/administracion/reportes")

    assert respuesta.status_code == 200
    assert MENSAJE_SIN_ADMINISTRADOR not in respuesta.text
    for folio in ("BC-2026-000103", "BC-2026-000102", "BC-2026-000101"):
        assert folio in respuesta.text


def test_enlace_del_panel_aparece_en_inicio_y_nuevo_reporte(client):
    for ruta in ("/", "/reportes/nuevo"):
        respuesta = client.get(ruta)
        assert "Panel de administración" in respuesta.text
