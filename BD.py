from mysql import connector
TABLE="hosts"
HOST="172.24.20.4"
USER="root"
PASSWORD="Patata1234"
DATABASE="equips"
def connect():
    try:
        return connector.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        database=DATABASE
        )
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
    connexio.close()
