from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db.conexion import aplicar_migraciones, obtener_conexion
from app.db.seed import sembrar
from app.rutas import administracion, demo, emergencias, reportes


@asynccontextmanager
async def lifespan(app: FastAPI):
    aplicar_migraciones()
    conn = obtener_conexion()
    try:
        sembrar(conn)
    finally:
        conn.close()
    yield


app = FastAPI(title="Barrio Conectado", lifespan=lifespan)
app.include_router(demo.router)
app.include_router(reportes.router)
app.include_router(administracion.router)
app.include_router(emergencias.router)
