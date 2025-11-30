from database import get_connection
from models import LoginModel
import hashlib

def md5_hash(password: str) -> str:
    return hashlib.md5(password.encode()).hexdigest()

def verificar_usuario(login: LoginModel):
    try:
        conn = get_connection()
        
        # Hash MD5 de la contraseña
        password_hash = md5_hash(login.password)
        
        query = "SELECT id, nombre FROM agentes WHERE usuario = %s AND password = %s AND activo = TRUE"
        result = conn.execute(query, (login.usuario, password_hash))
        user = result.fetchone()
        conn.close()
        
        return user
    except Exception as e:
        print(f"Error en autenticación: {e}")
        return None