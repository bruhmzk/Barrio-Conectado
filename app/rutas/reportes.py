from fastapi import APIRouter, Depends, File, Form, Request, UploadFile
from fastapi.responses import RedirectResponse

from app.db.conexion import obtener_db
from app.dominio.categoria import listar_categorias
from app.dominio.reporte import (
    listar_cambios_estado,
    listar_reportes_de_usuario,
    obtener_reporte_por_numero,
    obtener_reporte_para_usuario,
)
from app.dominio.usuario import listar_usuarios
from app.rutas.comun import render
from app.rutas.demo import usuario_actual
from app.servicios.registrar_reporte import ErrorValidacion, registrar_reporte

router = APIRouter(prefix="/reportes")


def _contexto(conn, usuario, errores, valores):
    return {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "categorias": listar_categorias(conn),
        "errores": errores,
        "valores": valores,
    }


@router.get("")
def mis_reportes(
    request: Request, conn=Depends(obtener_db), usuario=Depends(usuario_actual)
):
    reportes = (
        listar_reportes_de_usuario(conn, usuario["id"]) if usuario is not None else []
    )
    return render(
        request,
        "mis_reportes.html",
        {
            "usuarios": listar_usuarios(conn),
            "usuario": usuario,
            "reportes": reportes,
        },
    )


@router.get("/nuevo")
def formulario(
    request: Request, conn=Depends(obtener_db), usuario=Depends(usuario_actual)
):
    return render(request, "nuevo_reporte.html", _contexto(conn, usuario, [], {}))


@router.post("")
def crear(
    request: Request,
    categoria_id: str = Form(""),
    descripcion: str = Form(""),
    latitud: str = Form(""),
    longitud: str = Form(""),
    foto: UploadFile | None = File(None),
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    valores = {
        "categoria_id": categoria_id,
        "descripcion": descripcion,
        "latitud": latitud,
        "longitud": longitud,
    }

    if usuario is None:
        errores = ["Selecciona un usuario de demostración antes de registrar el reporte."]
        return render(
            request,
            "nuevo_reporte.html",
            _contexto(conn, usuario, errores, valores),
            status_code=400,
        )

    archivo = foto.filename if foto is not None else ""
    try:
        resultado = registrar_reporte(
            conn, usuario["id"], categoria_id, descripcion, archivo, latitud, longitud
        )
    except ErrorValidacion as exc:
        return render(
            request,
            "nuevo_reporte.html",
            _contexto(conn, usuario, exc.errores, valores),
            status_code=400,
        )

    return RedirectResponse(
        f"/reportes/{resultado.numero_seguimiento}/confirmacion", status_code=303
    )


@router.get("/{numero_seguimiento}/confirmacion")
def confirmacion(
    numero_seguimiento: str,
    request: Request,
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    reporte = obtener_reporte_por_numero(conn, numero_seguimiento)
    estado = 200 if reporte is not None else 404
    return render(
        request,
        "confirmacion.html",
        {
            "usuarios": listar_usuarios(conn),
            "usuario": usuario,
            "reporte": reporte,
        },
        status_code=estado,
    )


@router.get("/{numero_seguimiento}")
def detalle(
    numero_seguimiento: str,
    request: Request,
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    if usuario is None:
        return render(
            request,
            "detalle_reporte.html",
            {
                "usuarios": listar_usuarios(conn),
                "usuario": usuario,
                "reporte": None,
                "cambios": [],
                "sin_usuario": True,
            },
        )

    reporte = obtener_reporte_para_usuario(conn, numero_seguimiento, usuario["id"])
    estado = 200 if reporte is not None else 404
    cambios = listar_cambios_estado(conn, reporte["id"]) if reporte is not None else []
    return render(
        request,
        "detalle_reporte.html",
        {
            "usuarios": listar_usuarios(conn),
            "usuario": usuario,
            "reporte": reporte,
            "cambios": cambios,
            "sin_usuario": False,
        },
        status_code=estado,
    )
