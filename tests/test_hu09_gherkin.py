from app.dominio.reporte import obtener_reporte_por_numero


def _categoria_emergencia(conexion, nombre="Incendio"):
    return conexion.execute(
        "SELECT id FROM categorias WHERE nombre = ? AND es_emergencia = 1", (nombre,)
    ).fetchone()["id"]


def _total_reportes(conexion):
    return conexion.execute("SELECT COUNT(*) AS n FROM reportes").fetchone()["n"]


def test_acceso_directo_a_reporte_de_emergencia_desde_menu_principal(
    client, elegir_usuario
):
    elegir_usuario()

    inicio = client.get("/")
    assert inicio.status_code == 200
    assert 'href="/emergencias/nueva"' in inicio.text
    assert "Emergencia" in inicio.text

    formulario = client.get("/emergencias/nueva")
    assert formulario.status_code == 200
    assert 'action="/emergencias"' in formulario.text
    assert 'name="categoria_id"' in formulario.text
    assert 'name="latitud"' in formulario.text
    assert 'name="longitud"' in formulario.text
    assert "Enviar emergencia" in formulario.text
    assert "Incendio" in formulario.text
    assert "Bache" not in formulario.text


def test_registro_exitoso_de_un_reporte_de_emergencia_con_interfaz_simplificada(
    client, elegir_usuario, conexion
):
    elegir_usuario()
    categoria = _categoria_emergencia(conexion)
    antes = _total_reportes(conexion)

    respuesta = client.post(
        "/emergencias",
        data={
            "categoria_id": str(categoria),
            "descripcion": "",
            "latitud": "-33.4500",
            "longitud": "-70.6600",
        },
        follow_redirects=False,
    )

    assert respuesta.status_code == 303
    assert "/emergencias/BC-" in respuesta.headers["location"]
    assert _total_reportes(conexion) == antes + 1

    confirmacion = client.get(respuesta.headers["location"])
    assert confirmacion.status_code == 200
    assert "BC-" in confirmacion.text
    assert "Recibido" in confirmacion.text
    assert "Máxima" in confirmacion.text
    assert "Gestor de emergencias" in confirmacion.text
    assert "notificado" in confirmacion.text

    numero = respuesta.headers["location"].split("/")[2]
    reporte = obtener_reporte_por_numero(conexion, numero)
    assert reporte["estado"] == "Recibido"
    assert reporte["prioridad"] == "Máxima"
    assert reporte["es_emergencia"] == 1
    assert reporte["aviso_pendiente"] == 0
    assert reporte["departamento"] == "Gestor de emergencias"


def test_registro_de_emergencia_con_datos_minimos_incompletos(
    client, elegir_usuario, conexion
):
    elegir_usuario()
    antes = _total_reportes(conexion)

    respuesta = client.post(
        "/emergencias",
        data={"categoria_id": "", "descripcion": "", "latitud": "", "longitud": ""},
    )

    assert respuesta.status_code == 400
    assert "Falta el tipo de emergencia." in respuesta.text
    assert "Falta la ubicación." in respuesta.text
    assert _total_reportes(conexion) == antes


def test_registro_de_emergencia_con_ubicacion_no_valida(
    client, elegir_usuario, conexion
):
    elegir_usuario()
    categoria = _categoria_emergencia(conexion)
    antes = _total_reportes(conexion)

    respuesta = client.post(
        "/emergencias",
        data={
            "categoria_id": str(categoria),
            "descripcion": "",
            "latitud": "999",
            "longitud": "-70.6600",
        },
    )

    assert respuesta.status_code == 400
    assert "La ubicación no es válida. Ingresa una nueva ubicación." in respuesta.text
    assert _total_reportes(conexion) == antes


def test_derivacion_al_gestor_cuando_la_notificacion_no_esta_disponible(
    client, elegir_usuario, conexion, monkeypatch
):
    monkeypatch.setenv("CIN324_NOTIFICACIONES_DISPONIBLES", "0")
    elegir_usuario()
    categoria = _categoria_emergencia(conexion, "Accidente")

    respuesta = client.post(
        "/emergencias",
        data={
            "categoria_id": str(categoria),
            "descripcion": "",
            "latitud": "-33.4590",
            "longitud": "-70.6620",
        },
        follow_redirects=False,
    )

    assert respuesta.status_code == 303
    confirmacion = client.get(respuesta.headers["location"])
    assert "pendiente de envío" in confirmacion.text

    numero = respuesta.headers["location"].split("/")[2]
    reporte = obtener_reporte_por_numero(conexion, numero)
    assert reporte["estado"] == "Recibido"
    assert reporte["prioridad"] == "Máxima"
    assert reporte["es_emergencia"] == 1
    assert reporte["aviso_pendiente"] == 1
    assert reporte["departamento"] == "Gestor de emergencias"
