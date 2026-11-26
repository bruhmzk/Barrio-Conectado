from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse

from app.db.conexion import obtener_db
from app.dominio.emergencia import (
    ESTADO_RECIBIDO,
    listar_categorias_emergencia,
    listar_emergencias_gestor,
    obtener_emergencia,
    tomar_conocimiento,
)
from app.dominio.reporte import listar_cambios_estado
from app.dominio.usuario import listar_usuarios
from app.rutas.comun import render
from app.rutas.demo import usuario_actual
from app.servicios.registrar_emergencia import (
    ErrorValidacionEmergencia,
    registrar_emergencia,
)

router = APIRouter(prefix="/emergencias")

MENSAJE_SIN_GESTOR = (
    "Selecciona un gestor de emergencias de demostración para ver la bandeja"
)
MENSAJE_SIN_USUARIO = (
    "Selecciona un usuario de demostración antes de registrar la emergencia"
)


def _es_gestor(usuario):
    return usuario is not None and usuario["rol"] == "gestor_emergencias"


def _contexto_formulario(conn, usuario, errores, valores):
    return {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "categorias": listar_categorias_emergencia(conn),
        "errores": errores,
        "valores": valores,
    }


@router.get("")
def bandeja(
    request: Request, conn=Depends(obtener_db), usuario=Depends(usuario_actual)
):
    sin_gestor = not _es_gestor(usuario)
    emergencias = [] if sin_gestor else listar_emergencias_gestor(conn)
    return render(
        request,
        "emergencias_bandeja.html",
        {
            "usuarios": listar_usuarios(conn),
            "usuario": usuario,
            "emergencias": emergencias,
            "sin_gestor": sin_gestor,
            "mensaje_sin_gestor": MENSAJE_SIN_GESTOR,
        },
    )


@router.get("/nueva")
def formulario(
    request: Request, conn=Depends(obtener_db), usuario=Depends(usuario_actual)
):
    valores = {}
    return render(
        request,
        "emergencia_nueva.html",
        _contexto_formulario(conn, usuario, [], valores),
    )


@router.post("")
def crear(
    request: Request,
    categoria_id: str = Form(""),
    descripcion: str = Form(""),
    direccion: str = Form(""),
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    valores = {
        "categoria_id": categoria_id,
        "descripcion": descripcion,
        "direccion": direccion,
    }

    if usuario is None:
        return render(
            request,
            "emergencia_nueva.html",
            _contexto_formulario(conn, usuario, [MENSAJE_SIN_USUARIO], valores),
            status_code=400,
        )

    try:
        resultado = registrar_emergencia(
            conn, usuario["id"], categoria_id, descripcion, direccion
        )
    except ErrorValidacionEmergencia as exc:
        return render(
            request,
            "emergencia_nueva.html",
            _contexto_formulario(conn, usuario, exc.errores, valores),
            status_code=400,
        )

    return RedirectResponse(
        f"/emergencias/{resultado.numero_seguimiento}/confirmacion", status_code=303
    )


@router.get("/{numero_seguimiento}/confirmacion")
def confirmacion(
    numero_seguimiento: str,
    request: Request,
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    reporte = obtener_emergencia(conn, numero_seguimiento)
    estado = 200 if reporte is not None else 404
    return render(
        request,
        "emergencia_confirmacion.html",
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
    contexto = {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "reporte": None,
        "cambios": [],
        "resultado": None,
        "sin_gestor": not _es_gestor(usuario),
        "mensaje_sin_gestor": MENSAJE_SIN_GESTOR,
    }
    if contexto["sin_gestor"]:
        return render(request, "emergencia_detalle.html", contexto)

    reporte = obtener_emergencia(conn, numero_seguimiento)
    if reporte is None:
        return render(request, "emergencia_detalle.html", contexto, status_code=404)

    contexto["reporte"] = reporte
    contexto["cambios"] = listar_cambios_estado(conn, reporte["id"])
    return render(request, "emergencia_detalle.html", contexto)


@router.post("/{numero_seguimiento}/tomar-conocimiento")
def tomar(
    numero_seguimiento: str,
    request: Request,
    conn=Depends(obtener_db),
    usuario=Depends(usuario_actual),
):
    contexto = {
        "usuarios": listar_usuarios(conn),
        "usuario": usuario,
        "reporte": None,
        "cambios": [],
        "resultado": None,
        "sin_gestor": not _es_gestor(usuario),
        "mensaje_sin_gestor": MENSAJE_SIN_GESTOR,
    }
    if contexto["sin_gestor"]:
        return render(request, "emergencia_detalle.html", contexto)

    reporte = obtener_emergencia(conn, numero_seguimiento)
    if reporte is None:
        return render(request, "emergencia_detalle.html", contexto, status_code=404)

    resultado = tomar_conocimiento(conn, numero_seguimiento, usuario["id"])
    reporte = obtener_emergencia(conn, numero_seguimiento)
    contexto["reporte"] = reporte
    contexto["cambios"] = listar_cambios_estado(conn, reporte["id"])
    contexto["resultado"] = resultado
    return render(
        request,
        "emergencia_detalle.html",
        contexto,
        status_code=200 if resultado.exito else 400,
    )
