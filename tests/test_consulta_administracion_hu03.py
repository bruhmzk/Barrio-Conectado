from app.dominio.reporte import listar_reportes_para_administracion


def id_categoria(conexion, nombre):
    fila = conexion.execute(
        "SELECT id FROM categorias WHERE nombre = ?", (nombre,)
    ).fetchone()
    return fila["id"]


def test_sin_filtros_devuelve_tres_reportes_en_orden_de_prioridad(conexion):
    filas = listar_reportes_para_administracion(conexion)

    assert len(filas) == 3
    assert [fila["numero_seguimiento"] for fila in filas] == [
        "BC-2026-000103",
        "BC-2026-000102",
        "BC-2026-000101",
    ]
    assert [fila["prioridad"] for fila in filas] == ["Alta", "Alta", "Media"]


def test_filtro_por_categoria_incluye_departamento_asignado(conexion):
    luminaria = id_categoria(conexion, "Luminaria")

    filas = listar_reportes_para_administracion(conexion, categoria_id=luminaria)

    assert len(filas) == 1
    assert filas[0]["numero_seguimiento"] == "BC-2026-000101"
    assert filas[0]["departamento"] == "Alumbrado"


def test_filtros_combinados_con_and_y_sin_duplicados(conexion):
    luminaria = id_categoria(conexion, "Luminaria")

    coincidentes = listar_reportes_para_administracion(
        conexion, categoria_id=luminaria, prioridad="Media", estado="Recibido"
    )
    assert len(coincidentes) == 1
    assert coincidentes[0]["numero_seguimiento"] == "BC-2026-000101"

    sin_resultados = listar_reportes_para_administracion(
        conexion, categoria_id=luminaria, prioridad="Alta", estado="Completado"
    )
    assert sin_resultados == []
