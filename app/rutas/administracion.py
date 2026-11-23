from fastapi import APIRouter, Depends, Form, Request

from app.db.conexion import obtener_db
from app.dominio.categoria import listar_categorias
from app.dominio.reporte import (
    ESTADOS,
    PRIORIDADES,
    completar_reporte,
    listar_reportes_para_administracion,
    obtener_reporte_por_numero,
)
from app.dominio.usuario import listar_usuarios
from app.integraciones.notificaciones import NotificacionesSimuladas
from app.rutas.comun import render
from app.rutas.demo import usuario_actual

router = APIRouter(prefix="/administracion")

MENSAJE_SIN_ADMINISTRADOR = (
    "Selecciona un administrador de demostración para ver el panel"
)
MENSAJE_SIN_RESULTADOS = "No hay resultados. Cambia los criterios de búsqueda"
MENSAJE_SIN_ADMINISTRADOR_COMPLETAR = (
    "Selecciona un administrador de demostración para completar el reporte"
)


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


def _contexto_completar(
    conn, usuario, reporte=None, nota="", resultado=None, sin_administrador=False
):
    return {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "reporte": reporte,
        "nota": nota,
        "resultado": resultado,
        "sin_administrador": sin_administrador,
        "mensaje_sin_administrador": MENSAJE_SIN_ADMINISTRADOR_COMPLETAR,
        "estado_invalido": reporte is not None and reporte["estado"] != "En revisión",
    }


@router.get("/reportes/{numero_seguimiento}/completar")
def formulario_completar(
    numero_seguimiento: str,
    request: Request,
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    if usuario is None or usuario["rol"] != "administrador":
        return render(
            request,
            "completar_reporte.html",
            _contexto_completar(conn, usuario, sin_administrador=True),
        )

    reporte = obtener_reporte_por_numero(conn, numero_seguimiento)
    estado = 200 if reporte is not None else 404
    return render(
        request,
        "completar_reporte.html",
        _contexto_completar(conn, usuario, reporte),
        status_code=estado,
    )


@router.post("/reportes/{numero_seguimiento}/completar")
def completar(
    numero_seguimiento: str,
    request: Request,
    nota: str = Form(""),
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    if usuario is None or usuario["rol"] != "administrador":
        return render(
            request,
            "completar_reporte.html",
            _contexto_completar(conn, usuario, nota=nota, sin_administrador=True),
        )

    reporte = obtener_reporte_por_numero(conn, numero_seguimiento)
    if reporte is None:
        return render(
            request,
            "completar_reporte.html",
            _contexto_completar(conn, usuario, nota=nota),
            status_code=404,
        )

    resultado = completar_reporte(
        conn,
        numero_seguimiento,
        nota,
        usuario["id"],
        NotificacionesSimuladas(),
    )
    reporte = obtener_reporte_por_numero(conn, numero_seguimiento)
    estado = 200 if resultado.exito else 400
    return render(
        request,
        "completar_reporte.html",
        _contexto_completar(conn, usuario, reporte, nota, resultado),
        status_code=estado,
    )
