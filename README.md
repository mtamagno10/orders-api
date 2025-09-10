# Orders API & Customers API - Microservicios

## Descripción General

Este sistema está compuesto por dos microservicios principales:

- **Orders API:** Gestiona la creación y consulta de órdenes. Publica eventos de órdenes creadas en RabbitMQ.
- **Customers API:** Gestiona los clientes y escucha eventos desde RabbitMQ para actualizar datos relacionados.

La comunicación entre servicios se realiza mediante HTTP y eventos asíncronos usando RabbitMQ.

---

## Configuración y ejecución de los servicios

### Requisitos previos

- Ruby (recomendado: versión 3.x)
- Rails (recomendado: versión 7.x)
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
rails db:seed
```

> Repite estos pasos tanto en `orders-api` como en `customers-api`.

---

### 2. Configurar las variables de entorno

Cada microservicio requiere ciertas variables para conectarse a RabbitMQ y al otro servicio.  
Puedes definirlas en archivos `.env` (usando la gema dotenv) o exportarlas en la terminal.

Ejemplo mínimo de variables en cada microservicio:

```
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
CUSTOMERS_API_URL=http://localhost:3001
ORDERS_API_URL=http://localhost:3000
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
- [Documentación de RabbitMQ](https://www.rabbitmq.com/documentation.html)
- [Rails Guides](https://guides.rubyonrails.org/)

---

## Notas adicionales

- Si tienes dudas sobre cómo iniciar el listener, revisa el README de `customer-api`.
- Si usas Docker Compose, la configuración difiere: consulta la documentación del proyecto.
- Las APIs deben estar corriendo en los puertos configurados (3000 para orders y 3001 para customers) para que la integración funcione correctamente.

---