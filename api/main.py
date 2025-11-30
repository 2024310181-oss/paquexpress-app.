from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from auth import verificar_usuario, md5_hash
from paquetes import obtener_paquetes_agente, actualizar_estado_paquete
from entregas import registrar_entrega
from models import LoginModel, EntregaModel
import uvicorn

app = FastAPI(title="Paquexpress API", version="1.0")

# CORS para conectar con Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Endpoint de login
@app.post("/login")
def login(login_data: LoginModel):
    user = verificar_usuario(login_data)
    if user:
        return {"success": True, "id": user[0], "nombre": user[1]}
    else:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

# Endpoint para obtener paquetes del agente
@app.get("/paquetes/{id_agente}")
def get_paquetes(id_agente: int):
    paquetes = obtener_paquetes_agente(id_agente)
    return {"paquetes": paquetes}

# Endpoint para registrar entrega
@app.post("/entregar")
def entregar_paquete(entrega: EntregaModel):
    try:
        # Registrar entrega
        id_entrega = registrar_entrega(
            entrega.id_paquete,
            entrega.id_agente,
            entrega.foto,
            entrega.latitud,
            entrega.longitud
        )
        
        # Actualizar estado del paquete
        actualizar_estado_paquete(entrega.id_paquete, "entregado")
        
        return {"success": True, "id_entrega": id_entrega}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Health check
@app.get("/")
def read_root():
    return {"message": "Paquexpress API funcionando"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)