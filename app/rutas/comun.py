from pathlib import Path

from fastapi import Request
from fastapi.templating import Jinja2Templates

DIR_TEMPLATES = Path(__file__).resolve().parent.parent / "templates"
templates = Jinja2Templates(directory=str(DIR_TEMPLATES))


def render(request: Request, nombre: str, contexto: dict, status_code: int = 200):
    return templates.TemplateResponse(
        request=request, name=nombre, context=contexto, status_code=status_code
    )
