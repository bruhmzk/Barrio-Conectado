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
    assert 'name="direccion"' in formulario.text
    assert 'name="latitud"' not in formulario.text
    assert 'name="longitud"' not in formulario.text
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
            "direccion": "Av. Central 123",
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
        data={"categoria_id": "", "descripcion": "", "direccion": ""},
    )

    assert respuesta.status_code == 400
    assert "Falta el tipo de emergencia." in respuesta.text
    assert "Falta la dirección." in respuesta.text
    assert _total_reportes(conexion) == antes


def test_registro_de_emergencia_con_direccion_vacia(client, elegir_usuario, conexion):
    elegir_usuario()
    categoria = _categoria_emergencia(conexion)
    antes = _total_reportes(conexion)

    respuesta = client.post(
        "/emergencias",
        data={
            "categoria_id": str(categoria),
            "descripcion": "",
            "direccion": "   ",
        },
    )

    assert respuesta.status_code == 400
    assert "Falta la dirección." in respuesta.text
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
            "direccion": "Esquina Av. Central con Los Aromos",
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


def test_boton_emergencia_visible_desde_el_inicio(client):
    client.cookies.clear()
    respuesta = client.get("/")
    assert respuesta.status_code == 200
    assert 'class="boton boton-emergencia"' in respuesta.text
    assert 'href="/emergencias/nueva"' in respuesta.text
