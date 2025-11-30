from database import get_connection

def obtener_paquetes_agente(id_agente: int):
    conn = get_connection()
    
    query = """
    SELECT id, id_unico, direccion, destinatario, estado 
    FROM paquetes 
    WHERE id_agente = %s AND estado = 'pendiente'
    """
    result = conn.execute(query, (id_agente,))
    paquetes = result.fetchall()
    conn.close()
    
    return paquetes

def actualizar_estado_paquete(id_paquete: int, estado: str):
    conn = get_connection()
    
    query = "UPDATE paquetes SET estado = %s WHERE id = %s"
    conn.execute(query, (estado, id_paquete))
    conn.close()