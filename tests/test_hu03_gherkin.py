MENSAJE_SIN_RESULTADOS = "No hay resultados. Cambia los criterios de búsqueda"


def id_categoria(conexion, nombre):
    fila = conexion.execute(
        "SELECT id FROM categorias WHERE nombre = ?", (nombre,)
    ).fetchone()
    return fila["id"]


def test_hu03_filtrado_por_categoria_y_alta_prioridad(
    client, conexion, elegir_usuario
):
    elegir_usuario(rol="administrador")
    microbasural = id_categoria(conexion, "Microbasural")

    respuesta = client.get(
        "/administracion/reportes",
        params={"categoria_id": str(microbasural), "prioridad": "Alta"},
    )

    assert respuesta.status_code == 200
    assert "BC-2026-000102" in respuesta.text
    assert "BC-2026-000101" not in respuesta.text
    assert "BC-2026-000103" not in respuesta.text


def test_hu03_filtrado_sin_resultados(client, conexion, elegir_usuario):
    elegir_usuario(rol="administrador")
    luminaria = id_categoria(conexion, "Luminaria")

    respuesta = client.get(
        "/administracion/reportes",
        params={
            "categoria_id": str(luminaria),
            "prioridad": "Alta",
            "estado": "Completado",
        },
    )

    assert respuesta.status_code == 200
    assert MENSAJE_SIN_RESULTADOS in respuesta.text
    assert 'name="categoria_id"' in respuesta.text
    assert 'name="prioridad"' in respuesta.text
    assert 'name="estado"' in respuesta.text
    assert f'value="{luminaria}" selected' in respuesta.text
    assert 'value="Alta" selected' in respuesta.text
    assert 'value="Completado" selected' in respuesta.text


def test_hu03_consulta_combinada(client, conexion, elegir_usuario):
    elegir_usuario(rol="administrador")
    bache = id_categoria(conexion, "Bache")

    respuesta = client.get(
        "/administracion/reportes",
        params={
            "categoria_id": str(bache),
            "prioridad": "Alta",
            "estado": "Recibido",
        },
    )

    assert respuesta.status_code == 200
    assert "BC-2026-000103" in respuesta.text
    assert "BC-2026-000101" not in respuesta.text
    assert "BC-2026-000102" not in respuesta.text
    assert f'value="{bache}" selected' in respuesta.text
    assert 'value="Alta" selected' in respuesta.text
    assert 'value="Recibido" selected' in respuesta.text


def test_hu03_visualizacion_del_departamento_y_del_estado(client, elegir_usuario):
    elegir_usuario(rol="administrador")

    respuesta = client.get("/administracion/reportes")

    assert respuesta.status_code == 200
    for texto in ("Alumbrado", "Aseo", "Obras", "En revisión"):
        assert texto in respuesta.text
    orden = ["BC-2026-000103", "BC-2026-000102", "BC-2026-000101"]
    posiciones = [respuesta.text.index(folio) for folio in orden]
    assert posiciones == sorted(posiciones)
