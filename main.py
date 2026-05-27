import os

import oracledb
import pandas as pd
import streamlit as st


# streamlit run main.py


def cargar_env_local():
    if not os.path.exists(".env"):
        return

    with open(".env", "r", encoding="utf-8") as archivo:
        for linea in archivo:
            linea = linea.strip()
            if not linea or linea.startswith("#") or "=" not in linea:
                continue

            clave, valor = linea.split("=", 1)
            os.environ.setdefault(clave.strip(), valor.strip())


def iniciar_cliente_oracle():
    cargar_env_local()

    lib_dir = os.getenv("ORACLE_CLIENT_LIB_DIR")
    config_dir = os.getenv("ORACLE_CLIENT_CONFIG_DIR")

    if not lib_dir:
        return

    try:
        if config_dir:
            oracledb.init_oracle_client(lib_dir=lib_dir, config_dir=config_dir)
        else:
            oracledb.init_oracle_client(lib_dir=lib_dir)
    except oracledb.ProgrammingError:
        pass


def conexion_configurada():
    cargar_env_local()
    return (
        os.getenv("ORACLE_USER")
        and os.getenv("ORACLE_PASSWORD")
        and os.getenv("ORACLE_DSN")
    )


def conectar():
    iniciar_cliente_oracle()

    return oracledb.connect(
        user=os.getenv("ORACLE_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN")
    )


def consultar(sql, params=None):
    try:
        conn = conectar()
        df = pd.read_sql(sql, conn, params=params)
        df.columns = df.columns.str.lower()
        conn.close()
        return df
    except Exception as e:
        st.error(f"Error de conexion o consulta: {e}")
        return pd.DataFrame()


def registrar_cliente(tipo_documento, num_documento, nombre, email):
    conn = conectar()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
            VALUES (:tipo_documento, :num_documento, :nombre, :email, 'ACTIVO')
        """, tipo_documento=tipo_documento,
             num_documento=num_documento,
             nombre=nombre,
             email=email)

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()


def registrar_producto(proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo):
    conn = conectar()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO bd_productos (
                proveedor_id, codigo_producto, nombre, categoria,
                precio_unitario, stock_actual, stock_minimo, estado
            )
            VALUES (
                :proveedor_id, :codigo_producto, :nombre, :categoria,
                :precio_unitario, :stock_actual, :stock_minimo, 'ACTIVO'
            )
        """, proveedor_id=int(proveedor_id),
             codigo_producto=codigo_producto,
             nombre=nombre,
             categoria=categoria,
             precio_unitario=float(precio_unitario),
             stock_actual=int(stock_actual),
             stock_minimo=int(stock_minimo))

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()


# ---------- TITULOS Y DESCRIPCION-----------
st.set_page_config(page_title="Bodega BI", layout="wide")
st.title("Bodega Inventarios y Pedidos")
st.caption("Sistema BI para consultar inventario, pedidos y alertas de stock")

if not conexion_configurada():
    st.warning("Configure las variables de conexion antes de usar la aplicacion.")
    st.code(
        "ORACLE_USER=tu_usuario\n"
        "ORACLE_PASSWORD=tu_contrasena\n"
        "ORACLE_DSN=tu_dsn\n"
        "ORACLE_CLIENT_LIB_DIR=C:\\oracle\\instantclient_23_26\n"
        "ORACLE_CLIENT_CONFIG_DIR=C:\\oracle\\instantclient_23_26\\network\\admin",
        language="text"
    )
    st.stop()

# ------------MENU LATERAL--------------
st.sidebar.header("Menu")

pagina = st.sidebar.radio("Seleccione una opcion", [
    "Inventario general",
    "Consultar clientes",
    "Productos bajo stock",
    "Pedidos",
    "Registrar cliente",
    "Registrar producto"
])

# ------------METRICAS GENERALES--------------
metricas = consultar("""
    SELECT
        (SELECT COUNT(*) FROM bd_productos WHERE estado = 'ACTIVO') AS productos_activos,
        (SELECT COUNT(*) FROM bd_productos WHERE stock_actual < stock_minimo) AS productos_bajo_stock,
        (SELECT COUNT(*) FROM bd_pedidos WHERE estado = 'PENDIENTE') AS pedidos_pendientes
    FROM dual
""")

if not metricas.empty:
    col_1, col_2, col_3 = st.columns(3)
    with col_1:
        st.metric("Productos activos", int(metricas["productos_activos"].iloc[0]))
    with col_2:
        st.metric("Productos bajo stock", int(metricas["productos_bajo_stock"].iloc[0]))
    with col_3:
        st.metric("Pedidos pendientes", int(metricas["pedidos_pendientes"].iloc[0]))

st.divider()

# ----------------INVENTARIO GENERAL-------------------
if pagina == "Inventario general":
    st.subheader("Inventario general")

    categoria = st.text_input("Filtrar por categoria")

    inventario = consultar("""
        SELECT
            p.producto_id,
            p.codigo_producto,
            p.nombre AS producto,
            p.categoria,
            pr.nombre AS proveedor,
            p.precio_unitario,
            p.stock_actual,
            p.stock_minimo,
            p.estado
        FROM bd_productos p
        JOIN bd_proveedores pr ON pr.proveedor_id = p.proveedor_id
        WHERE (:categoria IS NULL OR UPPER(p.categoria) LIKE '%' || UPPER(:categoria) || '%')
        ORDER BY p.categoria, p.nombre
    """, params={"categoria": categoria.strip() if categoria.strip() else None})

    st.dataframe(
        inventario.rename(columns={
            "producto_id": "ID",
            "codigo_producto": "Codigo",
            "producto": "Producto",
            "categoria": "Categoria",
            "proveedor": "Proveedor",
            "precio_unitario": "Precio",
            "stock_actual": "Stock actual",
            "stock_minimo": "Stock minimo",
            "estado": "Estado"
        }),
        use_container_width=True,
        hide_index=True
    )

# ----------------CONSULTAR CLIENTES-------------------
elif pagina == "Consultar clientes":
    st.subheader("Clientes registrados")

    buscar = st.text_input("Buscar por nombre o documento")

    clientes = consultar("""
        SELECT
            cliente_id,
            tipo_documento,
            num_documento,
            nombre,
            email,
            estado
        FROM bd_clientes
        WHERE (
            :buscar IS NULL
            OR UPPER(nombre) LIKE '%' || UPPER(:buscar) || '%'
            OR UPPER(num_documento) LIKE '%' || UPPER(:buscar) || '%'
        )
        ORDER BY cliente_id DESC
    """, params={"buscar": buscar.strip() if buscar.strip() else None})

    st.write(f"Clientes encontrados: **{len(clientes)}**")
    st.dataframe(
        clientes.rename(columns={
            "cliente_id": "ID",
            "tipo_documento": "Tipo doc",
            "num_documento": "Documento",
            "nombre": "Nombre",
            "email": "Email",
            "estado": "Estado"
        }),
        use_container_width=True,
        hide_index=True
    )

# ----------------PRODUCTOS BAJO STOCK-------------------
elif pagina == "Productos bajo stock":
    st.subheader("Productos bajo stock")

    bajo_stock = consultar("""
        SELECT
            p.codigo_producto,
            p.nombre AS producto,
            p.categoria,
            p.stock_actual,
            p.stock_minimo,
            (p.stock_minimo - p.stock_actual) AS unidades_faltantes
        FROM bd_productos p
        WHERE p.stock_actual < p.stock_minimo
        ORDER BY unidades_faltantes DESC
    """)

    if bajo_stock.empty:
        st.info("No hay productos bajo stock.")
    else:
        st.dataframe(
            bajo_stock.rename(columns={
                "codigo_producto": "Codigo",
                "producto": "Producto",
                "categoria": "Categoria",
                "stock_actual": "Stock actual",
                "stock_minimo": "Stock minimo",
                "unidades_faltantes": "Unidades faltantes"
            }),
            use_container_width=True,
            hide_index=True
        )

# ----------------PEDIDOS-------------------
elif pagina == "Pedidos":
    st.subheader("Pedidos")

    estado = st.selectbox("Filtrar por estado", ["TODOS", "PENDIENTE", "DESPACHADO", "CANCELADO"])
    estado_param = None if estado == "TODOS" else estado

    pedidos = consultar("""
        SELECT
            pe.pedido_id,
            pe.num_pedido,
            c.nombre AS cliente,
            pe.fecha_pedido,
            pe.estado,
            NVL(SUM(dp.cantidad * dp.precio_unitario), 0) AS valor_pedido
        FROM bd_pedidos pe
        JOIN bd_clientes c ON c.cliente_id = pe.cliente_id
        LEFT JOIN bd_detalle_pedido dp ON dp.pedido_id = pe.pedido_id
        WHERE (:estado IS NULL OR pe.estado = :estado)
        GROUP BY pe.pedido_id, pe.num_pedido, c.nombre, pe.fecha_pedido, pe.estado
        ORDER BY pe.fecha_pedido DESC
    """, params={"estado": estado_param})

    st.dataframe(
        pedidos.rename(columns={
            "pedido_id": "ID",
            "num_pedido": "Pedido",
            "cliente": "Cliente",
            "fecha_pedido": "Fecha",
            "estado": "Estado",
            "valor_pedido": "Valor pedido"
        }),
        use_container_width=True,
        hide_index=True
    )

# ----------------REGISTRAR CLIENTE-------------------
elif pagina == "Registrar cliente":
    st.subheader("Registrar cliente")

    col_4, col_5 = st.columns(2)
    with col_4:
        tipo_documento = st.selectbox("Tipo de documento", ["CC", "NIT", "CE"])
        num_documento = st.text_input("Numero de documento")
    with col_5:
        nombre = st.text_input("Nombre")
        email = st.text_input("Email")

    if st.button("Registrar cliente", type="primary"):
        if not num_documento.strip() or not nombre.strip():
            st.warning("Complete el numero de documento y el nombre.")
        else:
            try:
                registrar_cliente(tipo_documento, num_documento.strip(), nombre.strip(), email.strip())
                st.success("Cliente registrado correctamente.")
            except Exception as e:
                st.error(f"No se pudo registrar el cliente: {e}")

# ----------------REGISTRAR PRODUCTO-------------------
elif pagina == "Registrar producto":
    st.subheader("Registrar producto")

    proveedores = consultar("""
        SELECT proveedor_id, nombre
        FROM bd_proveedores
        WHERE estado = 'ACTIVO'
        ORDER BY nombre
    """)

    if proveedores.empty:
        st.info("Primero debe existir al menos un proveedor activo.")
    else:
        opciones = proveedores["proveedor_id"].astype(str) + " - " + proveedores["nombre"]

        col_6, col_7 = st.columns(2)
        with col_6:
            proveedor = st.selectbox("Proveedor", opciones.tolist())
            codigo_producto = st.text_input("Codigo del producto")
            nombre_producto = st.text_input("Nombre del producto")
            categoria = st.selectbox("Categoria", ["ALIMENTOS", "ASEO", "BEBIDAS", "EMPAQUES", "LACTEOS"])
        with col_7:
            precio_unitario = st.number_input("Precio unitario", min_value=0.0, step=1000.0)
            stock_actual = st.number_input("Stock actual", min_value=0, step=1)
            stock_minimo = st.number_input("Stock minimo", min_value=0, step=1)

        if st.button("Registrar producto", type="primary"):
            if not codigo_producto.strip() or not nombre_producto.strip():
                st.warning("Complete el codigo y el nombre del producto.")
            else:
                proveedor_id = int(proveedor.split(" - ")[0])

                try:
                    registrar_producto(
                        proveedor_id,
                        codigo_producto.strip(),
                        nombre_producto.strip(),
                        categoria,
                        precio_unitario,
                        stock_actual,
                        stock_minimo
                    )
                    st.success("Producto registrado correctamente.")
                except Exception as e:
                    st.error(f"No se pudo registrar el producto: {e}")
