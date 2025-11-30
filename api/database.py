import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",  # o tu usuario de XAMPP
        password="",  # usualmente vacío en XAMPP
        database="Paquexpress_db"
    )
