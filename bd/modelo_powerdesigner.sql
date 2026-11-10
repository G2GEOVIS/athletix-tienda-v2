/*==============================================================*/
/* ATHLETIX - Modelo físico para PowerDesigner (DBMS PostgreSQL) */
/* PowerDesigner: File > Reverse Engineer > Database...          */
/*   DBMS: PostgreSQL · Using script files: este archivo         */
/* Generado desde la base actual (15 tablas). Tablas en singular */
/* y columnas con prefijo de 3 letras, como en la clase.         */
/*==============================================================*/

/*==============================================================*/
/* Table: CATEGORIA                                            */
/* Categorías del catálogo (Calzado, Tecnología e implementos,  */
/* Entrenamiento)                                               */
/*==============================================================*/
create table CATEGORIA (
   CAT_CODIGO            INT2            not null,
   CAT_NOMBRE            VARCHAR(40)     not null,
   constraint PK_CATEGORIA PRIMARY KEY (cat_codigo),
   constraint AK_CATEGORIA_NOMBRE UNIQUE (cat_nombre)
);

/*==============================================================*/
/* Table: PRODUCTO                                             */
/* Productos de la tienda. El género solo aplica al calzado (Ho */
/* mbre/Mujer); el resto es Unisex                              */
/*==============================================================*/
create table PRODUCTO (
   PRD_CODIGO            VARCHAR(10)     not null,
   CAT_CODIGO            INT2            not null,
   PRD_NOMBRE            VARCHAR(80)     not null,
   PRD_DESCRIPCION       TEXT            not null,
   PRD_GENERO            VARCHAR(6)      not null,
   PRD_PRECIO            NUMERIC(10,2)   not null,
   PRD_TIENE_TALLA       BOOL            not null,
   PRD_VISIBLE           BOOL            not null,
   PRD_ETIQUETA          VARCHAR(20)     null,
   PRD_CARACTERISTICAS   TEXT            null,
   PRD_FICHA             TEXT            null,
   constraint CKC_PRD_CODIGO CHECK (((prd_codigo) ~ '^[a-z0-9]{2,10}$')),
   constraint CKC_PRD_DESCRIPCION CHECK (((length(trim(prd_descripcion)) >= 20) AND (length(trim(prd_descripcion)) <= 600))),
   constraint CKC_PRD_GENERO CHECK ((prd_genero in ('Hombre', 'Mujer', 'Unisex'))),
   constraint CKC_PRD_GENERO_CATEGORIA CHECK (((cat_codigo = 1) = ((prd_genero) <> 'Unisex'))),
   constraint CKC_PRD_NOMBRE CHECK ((length(trim(prd_nombre)) >= 3)),
   constraint CKC_PRD_PRECIO CHECK ((prd_precio > (0))),
   constraint CKC_PRD_PRECIO_MAX CHECK ((prd_precio < (100000))),
   constraint PK_PRODUCTO PRIMARY KEY (prd_codigo)
);

/*==============================================================*/
/* Table: PRODUCTO_TALLA                                       */
/* Stock por talla. Los productos sin talla usan la talla U (ún */
/* ica)                                                         */
/*==============================================================*/
create table PRODUCTO_TALLA (
   PRD_CODIGO            VARCHAR(10)     not null,
   PTA_TALLA             VARCHAR(5)      not null,
   PTA_CANTIDAD          INT4            not null,
   constraint CKC_PTA_CANTIDAD CHECK ((pta_cantidad >= 0)),
   constraint CKC_PTA_CANTIDAD_MAX CHECK ((pta_cantidad <= 100000)),
   constraint PK_PRODUCTO_TALLA PRIMARY KEY (prd_codigo, pta_talla)
);

/*==============================================================*/
/* Table: PRODUCTO_IMAGEN                                      */
/* Hasta 6 fotos por producto, en orden                         */
/*==============================================================*/
create table PRODUCTO_IMAGEN (
   PRD_CODIGO            VARCHAR(10)     not null,
   PIM_ORDEN             INT2            not null,
   PIM_URL               VARCHAR(300)    not null,
   PIM_DESCRIPCION       VARCHAR(80)     not null,
   constraint CKC_PIM_ORDEN CHECK (((pim_orden >= 1) AND (pim_orden <= 6))),
   constraint CKC_PIM_URL CHECK ((length(trim(pim_url)) > 0)),
   constraint PK_PRODUCTO_IMAGEN PRIMARY KEY (prd_codigo, pim_orden)
);

/*==============================================================*/
/* Table: TIENDA                                               */
/* Tiendas físicas donde el cliente retira su pedido            */
/*==============================================================*/
create table TIENDA (
   TIE_CODIGO            INT2            not null,
   TIE_NOMBRE            VARCHAR(60)     not null,
   TIE_DIRECCION         VARCHAR(120)    not null,
   TIE_CIUDAD            VARCHAR(40)     not null,
   TIE_HORARIO           VARCHAR(60)     not null,
   constraint PK_TIENDA PRIMARY KEY (tie_codigo),
   constraint AK_TIENDA_NOMBRE UNIQUE (tie_nombre)
);

/*==============================================================*/
/* Table: CLIENTE                                              */
/* Datos del cliente. CLI_USUARIO es el id de su cuenta en Supa */
/* base Auth                                                    */
/*==============================================================*/
create table CLIENTE (
/* CKC_CLI_CEDULA: la cédula se valida con la función cedula_valida (módulo 10) en la base real */
   CLI_CEDULA            VARCHAR(20)     not null,
   CLI_USUARIO           UUID            not null,
   CLI_NOMBRES           VARCHAR(60)     not null,
   CLI_APELLIDOS         VARCHAR(60)     not null,
   CLI_CELULAR           VARCHAR(16)     not null,
   CLI_CORREO            VARCHAR(120)    not null,
   CLI_FECHA_REGISTRO    TIMESTAMPTZ     not null,
   CLI_DIRECCION         VARCHAR(150)    null,
   CLI_PAIS              VARCHAR(40)     not null,
   CLI_TIPO_DOCUMENTO    VARCHAR(9)      not null,
   constraint CKC_CLI_APELLIDOS CHECK (((cli_apellidos) ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$')),
   constraint CKC_CLI_CELULAR CHECK (((((cli_pais) = 'Ecuador') AND ((cli_celular) ~ '^09[0-9]{8}$')) OR (((cli_pais) <> 'Ecuador') AND ((cli_celular) ~ '^\+[1-9][0-9]{6,14}$')))),
   constraint CKC_CLI_DIRECCION CHECK (((cli_direccion IS NULL) OR ((length(trim(cli_direccion)) >= 8) AND (length(trim(cli_direccion)) <= 150)))),
   constraint CKC_CLI_NOMBRES CHECK (((cli_nombres) ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$')),
   constraint CKC_CLI_PAIS CHECK (((length(trim(cli_pais)) >= 3) AND (length(trim(cli_pais)) <= 40))),
   constraint CKC_CLI_TIPO_DOCUMENTO CHECK ((cli_tipo_documento in ('Cédula', 'Pasaporte'))),
   constraint PK_CLIENTE PRIMARY KEY (cli_cedula),
   constraint AK_CLIENTE_CELULAR UNIQUE (cli_celular),
   constraint AK_CLIENTE_CORREO UNIQUE (cli_correo),
   constraint AK_CLIENTE_USUARIO UNIQUE (cli_usuario)
);

/*==============================================================*/
/* Table: ADMINISTRADOR                                        */
/* Cuentas con permiso de administrador                         */
/*==============================================================*/
create table ADMINISTRADOR (
   ADM_USUARIO           UUID            not null,
   constraint PK_ADMINISTRADOR PRIMARY KEY (adm_usuario)
);

/*==============================================================*/
/* Table: METODO_PAGO                                          */
/* Tarjetas guardadas: solo marca, últimos 4 dígitos, titular y */
/*  vencimiento                                                 */
/*==============================================================*/
create table METODO_PAGO (
   MTP_CODIGO            INT4            not null,
   CLI_CEDULA            VARCHAR(20)     not null,
   MTP_MARCA             VARCHAR(20)     not null,
   MTP_ULTIMOS4          CHAR(4)         not null,
   MTP_TITULAR           VARCHAR(60)     not null,
   MTP_MES_VENCE         INT2            not null,
   MTP_ANIO_VENCE        INT2            not null,
   constraint CKC_MTP_ANIO CHECK ((mtp_anio_vence >= 2026)),
   constraint CKC_MTP_MARCA CHECK ((mtp_marca in ('Visa', 'Mastercard', 'American Express', 'Diners Club', 'Discover', 'JCB', 'UnionPay', 'Maestro'))),
   constraint CKC_MTP_MES CHECK (((mtp_mes_vence >= 1) AND (mtp_mes_vence <= 12))),
   constraint CKC_MTP_ULTIMOS4 CHECK ((mtp_ultimos4 ~ '^[0-9]{4}$')),
   constraint PK_METODO_PAGO PRIMARY KEY (mtp_codigo),
   constraint AK_METODO_PAGO_CLIENTE UNIQUE (cli_cedula, mtp_marca, mtp_ultimos4, mtp_mes_vence, mtp_anio_vence)
);

/*==============================================================*/
/* Table: PEDIDO                                               */
/* Pedido de un cliente, con tienda de retiro, código de retiro */
/*  y estado                                                    */
/*==============================================================*/
create table PEDIDO (
   PED_NUMERO            INT4            not null,
   CLI_CEDULA            VARCHAR(20)     not null,
   TIE_CODIGO            INT2            not null,
   PED_FECHA             TIMESTAMPTZ     not null,
   PED_ESTADO            VARCHAR(12)     not null,
   PED_SUBTOTAL          NUMERIC(10,2)   not null,
   PED_IVA               NUMERIC(10,2)   not null,
   PED_TOTAL             NUMERIC(10,2)   not null,
   PED_CLAVE_PAGO        UUID            null,
   PED_CODIGO_RETIRO     CHAR(6)         null,
   PED_HORA_ESTIMADA     TIMESTAMPTZ     null,
   PED_FACTURA           INT4            null,
   constraint CKC_PED_ESTADO CHECK ((ped_estado in ('Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado'))),
   constraint CKC_PED_VALORES CHECK (((ped_subtotal >= (0)) AND (ped_iva >= (0)) AND (ped_total = (ped_subtotal + ped_iva)))),
   constraint PK_PEDIDO PRIMARY KEY (ped_numero),
   constraint AK_PEDIDO_CLAVE UNIQUE (ped_clave_pago),
   constraint AK_PEDIDO_FACTURA UNIQUE (ped_factura)
);

/*==============================================================*/
/* Table: DETALLE_PEDIDO                                       */
/* Productos de cada pedido con la talla, cantidad y precio al  */
/* momento de la compra                                         */
/*==============================================================*/
create table DETALLE_PEDIDO (
   PED_NUMERO            INT4            not null,
   PRD_CODIGO            VARCHAR(10)     not null,
   DPE_TALLA             VARCHAR(5)      not null,
   DPE_CANTIDAD          INT2            not null,
   DPE_PRECIO            NUMERIC(10,2)   not null,
   constraint CKC_DPE_CANTIDAD CHECK ((dpe_cantidad >= 1)),
   constraint CKC_DPE_PRECIO CHECK ((dpe_precio > (0))),
   constraint PK_DETALLE_PEDIDO PRIMARY KEY (ped_numero, prd_codigo, dpe_talla)
);

/*==============================================================*/
/* Table: PAGO                                                 */
/* Pago de cada pedido (tarjeta simulada o efectivo en la tiend */
/* a)                                                           */
/*==============================================================*/
create table PAGO (
   PAG_CODIGO            INT4            not null,
   PED_NUMERO            INT4            not null,
   MTP_CODIGO            INT4            null,
   PAG_MARCA             VARCHAR(20)     null,
   PAG_ULTIMOS4          CHAR(4)         null,
   PAG_MONTO             NUMERIC(10,2)   not null,
   PAG_FECHA             TIMESTAMPTZ     not null,
   PAG_ESTADO            VARCHAR(10)     not null,
   PAG_FORMA             VARCHAR(10)     not null,
   constraint CKC_PAG_ESTADO CHECK ((pag_estado in ('Aprobado', 'Pendiente', 'Anulado'))),
   constraint CKC_PAG_FORMA CHECK ((pag_forma in ('Tarjeta', 'En tienda'))),
   constraint CKC_PAG_MONTO CHECK ((pag_monto > (0))),
   constraint CKC_PAG_TARJETA CHECK ((((pag_forma) = 'En tienda') OR ((pag_marca IS NOT NULL) AND (pag_ultimos4 IS NOT NULL)))),
   constraint CKC_PAG_ULTIMOS4 CHECK ((pag_ultimos4 ~ '^[0-9]{4}$')),
   constraint PK_PAGO PRIMARY KEY (pag_codigo),
   constraint AK_PAGO_PEDIDO UNIQUE (ped_numero)
);

/*==============================================================*/
/* Table: RESENA                                               */
/* Reseñas de compra verificada: una por cliente y producto     */
/*==============================================================*/
create table RESENA (
   CLI_CEDULA            VARCHAR(20)     not null,
   PRD_CODIGO            VARCHAR(10)     not null,
   RES_ESTRELLAS         INT2            not null,
   RES_COMENTARIO        VARCHAR(500)    not null,
   RES_FECHA             TIMESTAMPTZ     not null,
   constraint CKC_RES_COMENTARIO CHECK ((length(trim(res_comentario)) >= 10)),
   constraint CKC_RES_COMENTARIO_MAX CHECK ((length((res_comentario)) <= 1000)),
   constraint CKC_RES_ESTRELLAS CHECK (((res_estrellas >= 1) AND (res_estrellas <= 5))),
   constraint PK_RESENA PRIMARY KEY (cli_cedula, prd_codigo)
);

/*==============================================================*/
/* Table: FAVORITO                                             */
/* Productos favoritos de cada cliente                          */
/*==============================================================*/
create table FAVORITO (
   CLI_CEDULA            VARCHAR(20)     not null,
   PRD_CODIGO            VARCHAR(10)     not null,
   FAV_FECHA             TIMESTAMPTZ     not null,
   constraint PK_FAVORITO PRIMARY KEY (cli_cedula, prd_codigo)
);

/*==============================================================*/
/* Table: CARRITO                                              */
/* Carrito guardado de cada cliente                             */
/*==============================================================*/
create table CARRITO (
   CLI_CEDULA            VARCHAR(20)     not null,
   PRD_CODIGO            VARCHAR(10)     not null,
   CAR_TALLA             VARCHAR(5)      not null,
   CAR_CANTIDAD          INT4            not null,
   CAR_FECHA             TIMESTAMPTZ     not null,
   constraint CKC_CAR_CANTIDAD CHECK (((car_cantidad >= 1) AND (car_cantidad <= 9999))),
   constraint PK_CARRITO PRIMARY KEY (cli_cedula, prd_codigo, car_talla)
);

/*==============================================================*/
/* Table: MOVIMIENTO_STOCK                                     */
/* Historial de cada cambio de stock (venta, cancelación, ajust */
/* e)                                                           */
/*==============================================================*/
create table MOVIMIENTO_STOCK (
   MST_CODIGO            INT4            not null,
   PRD_CODIGO            VARCHAR(10)     not null,
   PTA_TALLA             VARCHAR(5)      not null,
   MST_MOTIVO            VARCHAR(20)     not null,
   MST_CANTIDAD          INT4            not null,
   MST_STOCK_ANTERIOR    INT4            not null,
   MST_STOCK_NUEVO       INT4            not null,
   PED_NUMERO            INT4            null,
   MST_FECHA             TIMESTAMPTZ     not null,
   MST_TRANSACCION       INT8            not null,
   constraint CKC_MST_MOTIVO CHECK ((mst_motivo in ('Venta', 'Cancelación', 'Ajuste', 'Alta', 'Limpieza'))),
   constraint PK_MOVIMIENTO_STOCK PRIMARY KEY (mst_codigo)
);

/*==============================================================*/
/* Relaciones (claves foráneas)                                  */
/*==============================================================*/
alter table PRODUCTO
   add constraint FK_CATEGORIA_PRODUCTO FOREIGN KEY (CAT_CODIGO) REFERENCES CATEGORIA(CAT_CODIGO) ON DELETE RESTRICT;

alter table PRODUCTO_TALLA
   add constraint FK_PRODUCTO_PRODUCTOTALLA FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;

alter table PRODUCTO_IMAGEN
   add constraint FK_PRODUCTO_PRODUCTOIMAGEN FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;

/* CLIENTE.FK_USUARIO_CLIENTE: referencia a la tabla de cuentas de Supabase Auth (AUTH.USERS), que no es parte de este modelo */

/* ADMINISTRADOR.FK_USUARIO_ADMINISTRADOR: referencia a la tabla de cuentas de Supabase Auth (AUTH.USERS), que no es parte de este modelo */

alter table METODO_PAGO
   add constraint FK_CLIENTE_METODOPAGO FOREIGN KEY (CLI_CEDULA) REFERENCES CLIENTE(CLI_CEDULA) on delete cascade;

alter table PEDIDO
   add constraint FK_CLIENTE_PEDIDO FOREIGN KEY (CLI_CEDULA) REFERENCES CLIENTE(CLI_CEDULA) ON DELETE RESTRICT;

alter table PEDIDO
   add constraint FK_TIENDA_PEDIDO FOREIGN KEY (TIE_CODIGO) REFERENCES TIENDA(TIE_CODIGO) ON DELETE RESTRICT;

alter table DETALLE_PEDIDO
   add constraint FK_PEDIDO_DETALLEPEDIDO FOREIGN KEY (PED_NUMERO) REFERENCES PEDIDO(PED_NUMERO) on delete cascade;

alter table DETALLE_PEDIDO
   add constraint FK_PRODUCTO_DETALLEPEDIDO FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) ON DELETE RESTRICT;

alter table PAGO
   add constraint FK_METODOPAGO_PAGO FOREIGN KEY (MTP_CODIGO) REFERENCES METODO_PAGO(MTP_CODIGO) ON DELETE SET NULL;

alter table PAGO
   add constraint FK_PEDIDO_PAGO FOREIGN KEY (PED_NUMERO) REFERENCES PEDIDO(PED_NUMERO) on delete cascade;

alter table RESENA
   add constraint FK_CLIENTE_RESENA FOREIGN KEY (CLI_CEDULA) REFERENCES CLIENTE(CLI_CEDULA) on delete cascade;

alter table RESENA
   add constraint FK_PRODUCTO_RESENA FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;

alter table FAVORITO
   add constraint FK_CLIENTE_FAVORITO FOREIGN KEY (CLI_CEDULA) REFERENCES CLIENTE(CLI_CEDULA) on delete cascade;

alter table FAVORITO
   add constraint FK_PRODUCTO_FAVORITO FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;

alter table CARRITO
   add constraint FK_CLIENTE_CARRITO FOREIGN KEY (CLI_CEDULA) REFERENCES CLIENTE(CLI_CEDULA) on delete cascade;

alter table CARRITO
   add constraint FK_PRODUCTO_CARRITO FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;

alter table MOVIMIENTO_STOCK
   add constraint FK_PEDIDO_MOVIMIENTO FOREIGN KEY (PED_NUMERO) REFERENCES PEDIDO(PED_NUMERO) ON DELETE SET NULL;

alter table MOVIMIENTO_STOCK
   add constraint FK_PRODUCTO_MOVIMIENTO FOREIGN KEY (PRD_CODIGO) REFERENCES PRODUCTO(PRD_CODIGO) on delete cascade;
