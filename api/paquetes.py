from database import get_connection

def obtener_paquetes_agente(id_agente: int):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)  # ← Para obtener resultados como diccionarios
        
        query = """
        SELECT id, id_unico, direccion, destinatario, estado 
        FROM paquetes 
        WHERE id_agente = %s AND estado = 'pendiente'
        """
        cursor.execute(query, (id_agente,))
        paquetes = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return paquetes
    except Exception as e:
        print(f"Error obteniendo paquetes: {e}")
        return []

def actualizar_estado_paquete(id_paquete: int, estado: str):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        query = "UPDATE paquetes SET estado = %s WHERE id = %s"
        cursor.execute(query, (estado, id_paquete))
        conn.commit()  # ← IMPORTANTE: hacer commit en MySQL
        
        cursor.close()
        conn.close()
        
        return True
    except Exception as e:
        print(f"Error actualizando estado: {e}")
        return False
