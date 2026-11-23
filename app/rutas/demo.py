from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse

from app.db.conexion import obtener_db
from app.dominio.usuario import listar_usuarios, obtener_usuario
from app.rutas.comun import render

router = APIRouter()


def usuario_actual(request: Request, conn=Depends(obtener_db)):
    valor = request.cookies.get("usuario_demo")
    if not valor or not valor.isdigit():
        return None
    return obtener_usuario(conn, int(valor))


@router.get("/")
def inicio(request: Request, conn=Depends(obtener_db), usuario=Depends(usuario_actual)):
    return render(
        request,
        "inicio.html",
        {"usuarios": listar_usuarios(conn), "usuario": usuario},
    )


@router.post("/demo/usuario")
def elegir_usuario(usuario_id: int = Form(...)):
    respuesta = RedirectResponse("/", status_code=303)
    respuesta.set_cookie("usuario_demo", str(usuario_id), httponly=True)
    return respuesta
