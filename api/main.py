from fastapi import FastAPI, HTTPException
from auth import verificar_usuario, md5_hash
from paquetes import obtener_paquetes_agente, actualizar_estado_paquete
from entregas import registrar_entrega
from models import LoginModel, EntregaModel
import uvicorn
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ESTO ES ESENCIAL:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite todas las origins
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos los métodos
    allow_headers=["*"],  # Permite todos los headers
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

# Endpoint para registrar entrega - CORREGIDO
@app.post("/entregar")
def entregar_paquete(entrega: EntregaModel):
    try:
        # Registrar entrega (ahora retorna un diccionario)
        result = registrar_entrega(
            entrega.id_paquete,
            entrega.id_agente,
            entrega.foto,
            entrega.latitud,
            entrega.longitud
        )
        
        if result["success"]:
            # La actualización del estado ya se hace dentro de registrar_entrega
            return {"success": True, "id_entrega": result["id_entrega"]}
        else:
            raise HTTPException(status_code=400, detail=result["error"])
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Health check
@app.get("/")
def read_root():
    return {"message": "Paquexpress API funcionando"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
