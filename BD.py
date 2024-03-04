from mysql import connector
TABLE="hosts"
HOST="172.24.20.100"
USER="root"
PASSWORD="Patata1234"
DATABASE="equips"
def connect():
    try:
        connexio = connector.connect(
            host=HOST,
            user=USER,
            password=PASSWORD,
        )

        cursor = connexio.cursor()
        
        # Crear la base de dades si no existeix
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DATABASE}")
        cursor.execute(f"USE {DATABASE}")

        # Crear la taula si no existeix
        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS {TABLE} (
                id INT AUTO_INCREMENT PRIMARY KEY,
                data_id INT,
                mac VARCHAR(255),
                ram INT,
                cpu INT,
                Estat BOOL,
                UNIQUE(data_id, mac)
            )
        """)

        return connexio

    except connector.Error as err:
        return err



def insertRow(connexio, valors):
    try:
        cursor = connexio.cursor()
        sql=f"INSERT INTO {TABLE} (hostname, ip) VALUES ({valors[0], valors[1]}), valors)"
        cursor.execute(sql)
        cursor.commit()
        return cursor.rowcount
    except connector.error as err:
        return err

def selectALL(connexio):
    cursor = connexio.cursor()
    cursor.execute(f"SELECT * FROM {TABLE}")
    result=cursor.fletchall
    return result

def updateRow(connexio, ip, hostname):
    cursor=connexio.cursor()
    sql=(f"UPDATE {TABLE} SET hostname = {hostname} WHERE ip = {ip}")
    try:
        cursor.execute(sql)
        connexio.commit()
        return cursor.rowcount
    except connector.error as err:
        return err

def deleteRow(connexio, ip):
    cursor=connexio.cursor()
    sql=f"DELETE FROM {TABLE} WHERE ip = {ip}"
    try:    
        cursor.execute(sql)
        connexio.commit()
        return cursor.rowcount
    except connector.error as err:
        return err

def close(connexio):
    try:
        connexio.close()
    except connector.error as err:
        return err

connexio=connect()
close(connexio)