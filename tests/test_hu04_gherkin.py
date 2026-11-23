from app.dominio.reporte import listar_cambios_estado, obtener_reporte_por_numero


def test_cierre_exitoso_de_un_reporte_con_justificacion(
    client, elegir_usuario, conexion
):
    elegir_usuario(rol="administrador")
    nota = "Microbasural retirado y verificado"

    respuesta = client.post(
        "/administracion/reportes/BC-2026-000102/completar",
        data={"nota": f"  {nota}  "},
    )

    assert respuesta.status_code == 200
    assert "Completado" in respuesta.text
    assert "aviso aceptado" in respuesta.text
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")
    assert reporte["estado"] == "Completado"
    cambios = listar_cambios_estado(conexion, reporte["id"])
    assert len(cambios) == 2
    assert cambios[-1]["nota"] == nota

    elegir_usuario(rol="vecino")
    detalle = client.get("/reportes/BC-2026-000102")

    assert detalle.status_code == 200
    assert "Completado" in detalle.text
    assert nota in detalle.text


def test_intento_de_cierre_de_reporte_sin_nota_de_resolucion(
    client, elegir_usuario, conexion
):
    elegir_usuario(rol="administrador")
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")
    cantidad_inicial = len(listar_cambios_estado(conexion, reporte["id"]))

    respuesta = client.post(
        "/administracion/reportes/BC-2026-000102/completar",
        data={"nota": "   "},
    )

    assert respuesta.status_code == 400
    assert "La nota de resolución es obligatoria" in respuesta.text
    assert (
        obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"]
        == "En revisión"
    )
    assert len(listar_cambios_estado(conexion, reporte["id"])) == cantidad_inicial


def test_estado_invalido_intento_de_cierre_de_un_reporte_que_no_esta_en_revision(
    client, elegir_usuario, conexion
):
    elegir_usuario(rol="administrador")
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000101")

    respuesta = client.post(
        "/administracion/reportes/BC-2026-000101/completar",
        data={"nota": "Intento sobre reporte recibido"},
    )

    assert respuesta.status_code == 400
    assert "El reporte no está En revisión" in respuesta.text
    assert obtener_reporte_por_numero(conexion, "BC-2026-000101")["estado"] == "Recibido"
    assert listar_cambios_estado(conexion, reporte["id"]) == []


def test_servicio_no_disponible_cierre_con_servicio_de_notificaciones_no_disponible(
    client, elegir_usuario, conexion, monkeypatch
):
    monkeypatch.setenv("CIN324_NOTIFICACIONES_DISPONIBLES", "0")
    elegir_usuario(rol="administrador")
    reporte = obtener_reporte_por_numero(conexion, "BC-2026-000102")

    respuesta = client.post(
        "/administracion/reportes/BC-2026-000102/completar",
        data={"nota": "Cierre registrado sin aviso"},
    )

    assert respuesta.status_code == 200
    assert "aviso pendiente de envío" in respuesta.text
    assert obtener_reporte_por_numero(conexion, "BC-2026-000102")["estado"] == "Completado"
    assert len(listar_cambios_estado(conexion, reporte["id"])) == 2
    tabla = conexion.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'notificaciones'"
    ).fetchone()
    assert tabla is None
