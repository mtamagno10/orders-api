# Orders API & Customers API - Microservicios

## Descripción General

Esta aplkicación está compuesta por dos microservicios principales:

- **Orders API:** Gestiona la creación y consulta de órdenes. Publica eventos de órdenes creadas en RabbitMQ.
- **Customers API:** Gestiona los clientes y escucha eventos desde RabbitMQ para actualizar datos relacionados.

La comunicación entre servicios se realiza mediante HTTP y eventos asíncronos usando RabbitMQ.

---

## Configuración y ejecución de los servicios

### Requisitos previos

- Ruby (utilizada: versión 3.2.2)
- Rails (utilizada: versión 8.0.2.1)
- RabbitMQ corriendo localmente (`localhost:5672`)
- Bundler (`gem install bundler`)
- Cada microservicio debe estar clonado en su propia carpeta (por ejemplo `orders-api` y `customers-api`)

---

### 1. Instalar dependencias y preparar la base de datos

**Ejecuta estos comandos en la carpeta de cada microservicio:**

```bash
cd <carpeta-del-api>
bundle install
rails db:create
rails db:migrate
rails db:seed (sólo aplica a customer-api)
```

> Repite estos pasos tanto en `orders-api` como en `customers-api`.

---

### 2. Configurar las variables de entorno

El microservicio orders-api requiere configurar la URL de customers-api en variablesde entorno.  
Puedes definirlas en archivos `.env` (usando la gema dotenv) o exportarlas en la terminal.

```
CUSTOMERS_API_URL=http://localhost:3001

```

---

### 3. Levantar los microservicios

En terminales separadas:

#### Orders API

```bash
cd orders-api
rails s -p 3000
```

#### Customers API

```bash
cd customers-api
rails s -p 3001
```

---

### 4. Iniciar el listener de eventos de Customers API

En la **Customers API**, inicia el proceso que escucha los eventos publicados en RabbitMQ por Orders API:

```bash
cd customers-api
rails runner 'OrderEventsListener.run'
```

> Este comando ejecuta el listener que procesa los eventos de órdenes recibidos desde RabbitMQ y actualiza los datos de clientes según corresponda.

---

## Recursos y documentación relacionada

- [Repositorio Customers API](https://github.com/mtamagno10/customer-api)
- [Repositorio Orders API](https://github.com/mtamagno10/orders-api) <!-- Este README -->

---

## Notas adicionales
git add .
- Las APIs deben estar corriendo en los puertos configurados (3000 para orders y 3001 para customers) para que la integración funcione correctamente.

---