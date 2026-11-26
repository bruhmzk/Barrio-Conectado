import pytest

from app.servicios.registrar_reporte import ErrorValidacion, registrar_reporte


def test_rechaza_campos_faltantes(conexion, datos):
    usuario, _ = datos()
    with pytest.raises(ErrorValidacion) as exc:
        registrar_reporte(conexion, usuario, "", "", "", "")
    mensajes = " ".join(exc.value.errores)
    assert "categoría" in mensajes
    assert "descripción" in mensajes
    assert "fotografía" in mensajes
    assert "dirección" in mensajes


def test_asigna_prioridad_y_departamento(conexion, datos):
    usuario, categoria = datos(categoria="Bache")
    resultado = registrar_reporte(
        conexion, usuario, categoria, "Bache grande", "foto.jpg", "Av. Central 123"
    )
    reporte = conexion.execute(
        "SELECT * FROM reportes WHERE id = ?", (resultado.reporte_id,)
    ).fetchone()
    asignacion = conexion.execute(
        "SELECT * FROM asignaciones WHERE reporte_id = ?", (resultado.reporte_id,)
    ).fetchone()
    departamento = conexion.execute(
        "SELECT nombre FROM departamentos WHERE id = ?",
        (asignacion["departamento_id"],),
    ).fetchone()

    assert reporte["estado"] == "Recibido"
    assert reporte["prioridad"] == "Alta"
    assert departamento["nombre"] == "Obras"
    assert asignacion["usuario_id"] is None
