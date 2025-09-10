# Orders API & Customers API - Microservicios

## Descripción

Este sistema está compuesto por dos microservicios principales:

- **Orders API:** Gestiona la creación y consulta de órdenes. Publica eventos de órdenes creadas en RabbitMQ.
- **Customers API:** Gestiona los clientes y escucha eventos desde RabbitMQ para actualizar datos relacionados.

Ambos servicios se comunican por HTTP y mediante eventos asincrónicos a través de RabbitMQ.

---

## Configuración y ejecución de los servicios (sin Docker Compose)

### Requisitos previos

- Ruby (recomendado: versión 3.x)
- Rails (recomendado: versión 7.x)
- RabbitMQ levantado localmente (`localhost:5672`)
- Bundler (`gem install bundler`)
- Cada microservicio debe estar clonado en su propia carpeta.

### 1. Instalar dependencias y preparar la base de datos

**Para cada microservicio (Orders API y Customers API):**

```bash
cd <carpeta-del-api>
bundle install
rails db:create
rails db:migrate
rails db:seed
```

> Repite estos pasos tanto en la carpeta de `orders-api` como en la de `customers-api`.

### 2. Configurar las variables de entorno

Asegúrate que cada API tenga configuradas las variables necesarias para conectarse a RabbitMQ y al otro microservicio (puedes usar `.env` o las variables de Rails).

Ejemplo mínimo de variables:

```
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
CUSTOMERS_API_URL=http://localhost:3001
ORDERS_API_URL=http://localhost:3000
```

### 3. Levantar las APIs

En una terminal, levanta la Orders API:

```bash
cd orders-api
rails s -p 3000
```

En otra terminal, levanta la Customers API:

```bash
cd customers-api
rails s -p 3001
```

### 4. Iniciar el listener de eventos

En la **Customers API**, inicia el listener para eventos de RabbitMQ.  
Esto puede ser un script, un job de Rails o un runner personalizado. Ejemplo:

```bash
cd customers-api