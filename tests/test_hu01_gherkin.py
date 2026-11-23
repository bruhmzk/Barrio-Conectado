def _datos_formulario(datos, **extra):
    _, categoria = datos()
    valores = {
        "categoria_id": str(categoria),
        "descripcion": "Bache en la esquina",
        "latitud": "-33.45",
        "longitud": "-70.66",
    }
    valores.update(extra)
    return valores


def _foto():
    return {"foto": ("foto.jpg", b"contenido", "image/jpeg")}


def test_registro_exitoso_con_todos_los_datos(client, conexion, datos, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes",
        data=_datos_formulario(datos),
        files=_foto(),
        follow_redirects=False,
    )
    assert respuesta.status_code == 303
    numero = respuesta.headers["location"].split("/")[2]
    reporte = conexion.execute(
        "SELECT * FROM reportes WHERE numero_seguimiento = ?", (numero,)
    ).fetchone()
    assert reporte["estado"] == "Recibido"
    assert reporte["numero_seguimiento"].startswith("BC-")


def test_intento_de_registro_con_datos_incompletos(client, conexion, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes",
        data={"categoria_id": "", "descripcion": "", "latitud": "", "longitud": ""},
    )
    assert respuesta.status_code == 400
    assert "datos obligatorios" in respuesta.text.lower()
    assert conexion.execute("SELECT COUNT(*) AS n FROM reportes").fetchone()["n"] == 0


def test_ubicacion_valida(client, conexion, datos, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes",
        data=_datos_formulario(datos, latitud="-33.4", longitud="-70.6"),
        files=_foto(),
        follow_redirects=False,
    )
    assert respuesta.status_code == 303
    numero = respuesta.headers["location"].split("/")[2]
    ubicacion = conexion.execute(
        "SELECT u.referencia FROM ubicaciones u "
        "JOIN reportes r ON r.id = u.reporte_id "
        "WHERE r.numero_seguimiento = ?",
        (numero,),
    ).fetchone()
    assert ubicacion["referencia"]


def test_ubicacion_no_valida(client, conexion, datos, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes", data=_datos_formulario(datos, latitud="120"), files=_foto()
    )
    assert respuesta.status_code == 400
    assert "no es válida" in respuesta.text
    assert conexion.execute("SELECT COUNT(*) AS n FROM reportes").fetchone()["n"] == 0


def test_clasificacion_automatica(client, conexion, datos, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes",
        data=_datos_formulario(datos),
        files=_foto(),
        follow_redirects=False,
    )
    numero = respuesta.headers["location"].split("/")[2]
    fila = conexion.execute(
        "SELECT r.prioridad, d.nombre AS departamento FROM reportes r "
        "JOIN asignaciones a ON a.reporte_id = r.id "
        "JOIN departamentos d ON d.id = a.departamento_id "
        "WHERE r.numero_seguimiento = ?",
        (numero,),
    ).fetchone()
    assert fila["prioridad"] == "Alta"
    assert fila["departamento"] == "Obras"


def test_inicio_muestra_selector_de_usuario(client):
    respuesta = client.get("/")
    assert respuesta.status_code == 200
    assert "Usuario de demostración" in respuesta.text


def test_selector_guarda_usuario_de_demostracion(client, elegir_usuario):
    uid = elegir_usuario()
    assert client.cookies.get("usuario_demo") == str(uid)


def test_formulario_muestra_campos_obligatorios(client, elegir_usuario):
    elegir_usuario()
    respuesta = client.get("/reportes/nuevo")
    assert respuesta.status_code == 200
    for texto in ("Categoría", "Descripción", "Fotografía", "Latitud", "Longitud"):
        assert texto in respuesta.text


def test_confirmacion_muestra_numero_de_seguimiento(client, datos, elegir_usuario):
    elegir_usuario()
    respuesta = client.post(
        "/reportes",
        data=_datos_formulario(datos),
        files=_foto(),
        follow_redirects=False,
    )
    numero = respuesta.headers["location"].split("/")[2]
    confirmacion = client.get(f"/reportes/{numero}/confirmacion")
    assert confirmacion.status_code == 200
    assert numero in confirmacion.text
