from database import get_connection
import base64

def registrar_entrega(id_paquete: int, id_agente: int, foto: str, latitud: float, longitud: float):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Validar que el paquete existe y pertenece al agente
        validar_query = """
        SELECT id FROM paquetes 
        WHERE id = %s AND id_agente = %s AND estado = 'pendiente'
        """
        cursor.execute(validar_query, (id_paquete, id_agente))
        paquete_valido = cursor.fetchone()
        
        if not paquete_valido:
            cursor.close()
            conn.close()
            return {"success": False, "error": "Paquete no válido o ya entregado"}
        
        # 1. Registrar la entrega
        query_entrega = "INSERT INTO entregas (id_paquete, id_agente) VALUES (%s, %s)"
        cursor.execute(query_entrega, (id_paquete, id_agente))
        id_entrega = cursor.lastrowid
        
        # 2. Guardar evidencia (foto + GPS)
        foto_bytes = base64.b64decode(foto) if foto else None
        
        query_evidencia = """
        INSERT INTO evidencias (id_entrega, foto, latitud, longitud) 
        VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query_evidencia, (id_entrega, foto_bytes, latitud, longitud))
        
        # 3. Actualizar estado del paquete
        update_query = "UPDATE paquetes SET estado = 'entregado' WHERE id = %s"
        cursor.execute(update_query, (id_paquete,))
        
        conn.commit()  # ← IMPORTANTE: hacer commit de todas las operaciones
        cursor.close()
        conn.close()
        
        return {"success": True, "id_entrega": id_entrega}
        
    except Exception as e:
        print(f"Error registrando entrega: {e}")
        return {"success": False, "error": str(e)}
