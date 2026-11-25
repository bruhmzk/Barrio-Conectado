from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db.conexion import aplicar_migraciones
from app.rutas import administracion, demo, emergencias, reportes


@asynccontextmanager
async def lifespan(app: FastAPI):
    aplicar_migraciones()
    yield


app = FastAPI(title="Barrio Conectado", lifespan=lifespan)
app.include_router(demo.router)
app.include_router(reportes.router)
app.include_router(administracion.router)
app.include_router(emergencias.router)
