from pydantic import BaseModel
from typing import Optional

# Modelos para request/response
class LoginModel(BaseModel):
    usuario: str
    password: str

class PaqueteModel(BaseModel):
    id_unico: str
    direccion: str
    destinatario: str

class EntregaModel(BaseModel):
    id_paquete: int
    id_agente: int
    foto: str  # Base64
    latitud: float
    longitud: float