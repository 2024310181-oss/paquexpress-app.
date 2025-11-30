from database import get_connection
from models import LoginModel
import hashlib

def md5_hash(password: str) -> str:
    """Genera MD5 de forma confiable"""
    return hashlib.md5(password.encode('utf-8')).hexdigest().lower()

def verificar_usuario(login: LoginModel):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Hash MD5 de la contraseña
        password_hash = md5_hash(login.password)
        
        print(f"Buscando usuario: {login.usuario}")
        print(f"Password hash generado: {password_hash}")
        print(f"Longitud del hash: {len(password_hash)}")
        
        # Query simple sin la columna active
        query = "SELECT id, nombre FROM agentes WHERE usuario = %s AND password = %s"
        cursor.execute(query, (login.usuario, password_hash))
        user = cursor.fetchone()
        
        print(f"Usuario encontrado: {user}")
        
        cursor.close()
        conn.close()
        
        if user:
            print("✓ Login exitoso")
            return (user[0], user[1])  # id, nombre
        else:
            print("✗ Usuario no encontrado o credenciales incorrectas")
            return None
            
    except Exception as e:
        print(f"Error en autenticación: {e}")
        return None
