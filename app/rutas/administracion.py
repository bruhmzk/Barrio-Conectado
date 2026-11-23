from fastapi import APIRouter, Depends, Request

from app.db.conexion import obtener_db
from app.dominio.categoria import listar_categorias
from app.dominio.reporte import (
    ESTADOS,
    PRIORIDADES,
    listar_reportes_para_administracion,
)
from app.dominio.usuario import listar_usuarios
from app.rutas.comun import render
from app.rutas.demo import usuario_actual

router = APIRouter(prefix="/administracion")

MENSAJE_SIN_ADMINISTRADOR = (
    "Selecciona un administrador de demostración para ver el panel"
)
MENSAJE_SIN_RESULTADOS = "No hay resultados. Cambia los criterios de búsqueda"


def _contexto(conn, usuario, reportes, categorias, filtros, sin_administrador=False):
    return {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "reportes": reportes,
        "categorias": categorias,
        "estados": ESTADOS,
        "prioridades": PRIORIDADES,
        "filtros": filtros,
        "sin_administrador": sin_administrador,
        "mensaje_sin_resultados": MENSAJE_SIN_RESULTADOS,
        "mensaje_sin_administrador": MENSAJE_SIN_ADMINISTRADOR,
    }


@router.get("/reportes")
def panel_reportes(
    request: Request,
    categoria_id: str = "",
    prioridad: str = "",
    estado: str = "",
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    filtros = {
        "categoria_id": categoria_id,
        "prioridad": prioridad,
        "estado": estado,
    }

    if usuario is None or usuario["rol"] != "administrador":
        return render(
            request,
            "administracion_reportes.html",
            _contexto(conn, usuario, [], [], filtros, sin_administrador=True),
        )

    categoria_filtro = (
        int(categoria_id) if categoria_id and categoria_id.isdigit() else None
    )
    reportes = listar_reportes_para_administracion(
        conn,
        categoria_id=categoria_filtro or (categoria_id or None),
        prioridad=prioridad or None,
        estado=estado or None,
    )
    return render(
        request,
        "administracion_reportes.html",
        _contexto(conn, usuario, reportes, listar_categorias(conn), filtros),
    )
