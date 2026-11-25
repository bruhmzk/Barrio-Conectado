from app.dominio.emergencia import (
    ESTADO_EN_ATENCION,
    listar_categorias_emergencia,
    listar_emergencias_gestor,
    obtener_emergencia,
    tomar_conocimiento,
)


def test_bandeja_solo_lista_emergencias_del_gestor(conexion):
    filas = listar_emergencias_gestor(conexion)

    numeros = [fila["numero_seguimiento"] for fila in filas]
    assert numeros == ["BC-2026-000104", "BC-2026-000105"]
    assert all(fila["departamento"] == "Gestor de emergencias" for fila in filas)
    assert all(fila["prioridad"] == "Máxima" for fila in filas)
    assert "BC-2026-000101" not in numeros


def test_detalle_solo_encuentra_emergencias(conexion):
    assert obtener_emergencia(conexion, "BC-2026-000104")["categoria"] == "Incendio"
    assert obtener_emergencia(conexion, "BC-2026-000105")["estado"] == (
        "En atención por Gestor"
    )
    assert obtener_emergencia(conexion, "BC-2026-000101") is None


def test_categorias_de_emergencia(conexion):
    nombres = [fila["nombre"] for fila in listar_categorias_emergencia(conexion)]
    assert nombres == ["Accidente", "Emergencia médica", "Incendio"]


def test_tomar_conocimiento_cambia_el_estado(conexion):
    gestor = conexion.execute(
        "SELECT id FROM usuarios WHERE rol = 'gestor_emergencias'"
    ).fetchone()["id"]

    resultado = tomar_conocimiento(conexion, "BC-2026-000104", gestor)

    assert resultado.exito
    assert (
        obtener_emergencia(conexion, "BC-2026-000104")["estado"] == ESTADO_EN_ATENCION
    )
    cambio = conexion.execute(
        "SELECT * FROM cambios_estado WHERE reporte_id = "
        "(SELECT id FROM reportes WHERE numero_seguimiento = 'BC-2026-000104')"
    ).fetchone()
    assert cambio["estado_anterior"] == "Recibido"
    assert cambio["estado_nuevo"] == ESTADO_EN_ATENCION
    assert cambio["usuario_id"] == gestor


def test_tomar_conocimiento_rechaza_un_estado_invalido(conexion):
    gestor = conexion.execute(
        "SELECT id FROM usuarios WHERE rol = 'gestor_emergencias'"
    ).fetchone()["id"]

    resultado = tomar_conocimiento(conexion, "BC-2026-000105", gestor)

    assert not resultado.exito
    assert "no está en estado Recibido" in resultado.mensaje
    assert (
        obtener_emergencia(conexion, "BC-2026-000105")["estado"] == ESTADO_EN_ATENCION
    )
