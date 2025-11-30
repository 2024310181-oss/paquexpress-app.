from sqlalchemy import create_engine, MetaData
import pymysql

# Configuración de la base de datos
DATABASE_URL = "mysql+pymysql://root:@localhost/paquexpress_db"

engine = create_engine(DATABASE_URL)
metadata = MetaData()

# Función para conectar
def get_connection():
    return engine.connect()