# IzyLite - Backend API

This is the backend service for the IzyLite application. It provides the RESTful API for managing authentication, product inventory, and sales transactions.

---

## English

### Features
- Authentication: JWT-based secure login and registration.
- Product Management: Endpoints to handle the product catalog and stock.
- Sales Processing: Logic for recording transactions and generating reports.
- Data Persistence: Uses MongoDB with Mongoose for reliable data storage.

### Tech Stack
- Runtime: Node.js
- Framework: Express.js
- Language: TypeScript
- Database: MongoDB
- ORM: Mongoose

### Docker Deployment
1.  **Environment Setup**: Create a `.env` file from the example:
    ```bash
    cp .env.example .env
    ```
2.  **Run with Docker Compose**:
    ```bash
    docker-compose up --build
    ```
    The API will be available at `http://localhost:3000`.

### Installation & Setup (Local)
1. cd izy-back
2. npm install
3. Create .env file
4. npm run dev

---
Este es el servicio de backend para la aplicacion de IzyLite. Esto contiene una API que se encarga de gestionar la autenticacion, inventario y las transacciones de ventas

## Español

### Características
- Autenticación: Inicio de sesión y registro seguro basado en JWT.
- Gestión de Productos: Endpoints para manejar el catálogo de productos y el stock.
- Procesamiento de Ventas: Lógica para registrar transacciones y generar reportes.
- Persistencia de Datos: Utiliza MongoDB con Mongoose para un almacenamiento de datos confiable.

### Stack Tecnológico
- Entorno: Node.js
- Framework: Express.js
- Lenguaje: TypeScript
- Base de Datos: MongoDB

### Despliegue con Docker
1.  **Configuración de Entorno**: Crea un archivo `.env` basado en el ejemplo:
    ```bash
    cp .env.example .env
    ```
2.  **Ejecutar con Docker Compose**:
    ```bash
    docker-compose up --build
    ```
    La API estará disponible en `http://localhost:3000`.

### Instalación y Configuración (Local)
1. cd izy-back
2. npm install
3. Crear archivo .env
4. npm run dev
