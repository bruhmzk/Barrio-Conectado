from app.db.seed import sembrar


def test_reportes_de_ejemplo_con_sus_relaciones(conexion):
    numeros = [
        fila["numero_seguimiento"]
        for fila in conexion.execute(
            "SELECT numero_seguimiento FROM reportes ORDER BY numero_seguimiento"
        )
    ]
    assert numeros == [
        "BC-2026-000101",
        "BC-2026-000102",
        "BC-2026-000103",
        "BC-2026-000104",
        "BC-2026-000105",
    ]

    con_foto = {"BC-2026-000101", "BC-2026-000102", "BC-2026-000103"}
    for numero in numeros:
        reporte = conexion.execute(
            "SELECT id FROM reportes WHERE numero_seguimiento = ?", (numero,)
        ).fetchone()
        for tabla in ("ubicaciones", "asignaciones"):
            fila = conexion.execute(
                f"SELECT 1 FROM {tabla} WHERE reporte_id = ?", (reporte["id"],)
            ).fetchone()
            assert fila is not None, f"{numero} sin {tabla}"
        foto = conexion.execute(
            "SELECT 1 FROM fotografias WHERE reporte_id = ?", (reporte["id"],)
        ).fetchone()
        assert (foto is not None) == (numero in con_foto), f"{numero} con foto inesperada"


def test_cambio_de_estado_de_ejemplo(conexion):
    cambios = conexion.execute(
        "SELECT c.* FROM cambios_estado c "
        "JOIN reportes r ON r.id = c.reporte_id "
        "WHERE r.numero_seguimiento = ?",
        ("BC-2026-000102",),
    ).fetchall()
    assert len(cambios) == 1
    assert cambios[0]["estado_anterior"] == "Recibido"
    assert cambios[0]["estado_nuevo"] == "En revisión"
    assert cambios[0]["fecha_hora"] == "2026-11-20T10:15:00"
    assert cambios[0]["nota"] == ""


def test_seed_idempotente(conexion):
    sembrar(conexion)
    sembrar(conexion)
    conteos = {
        tabla: conexion.execute(f"SELECT COUNT(*) AS n FROM {tabla}").fetchone()["n"]
        for tabla in ("usuarios", "reportes", "cambios_estado")
    }
    assert conteos == {"usuarios": 5, "reportes": 5, "cambios_estado": 2}
