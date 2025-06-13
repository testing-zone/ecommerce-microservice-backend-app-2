import random
import json
from locust import HttpUser, task, between

class EcommerceLoadTest(HttpUser):
    """
    Pruebas de rendimiento para el sistema e-commerce.
    Simula comportamiento de usuarios reales navegando, comprando y gestionando productos.
    """
    host = "http://localhost:30082"  # product-service NodePort
    wait_time = between(1, 3)  # Tiempo de espera entre tareas (1-3 segundos)
    
    # Configuración de servicios por NodePort
    services = {
        "user": "http://localhost:30087",
        "product": "http://localhost:30082", 
        "order": "http://localhost:30083",
        "payment": "http://localhost:30084",
        "shipping": "http://localhost:30085",
        "favourite": "http://localhost:30086"
    }
    
    def on_start(self):
        """Configuración inicial al iniciar cada usuario virtual"""
        self.user_id = None
        self.product_id = None
        self.order_id = None
        self.auth_token = None
        
        # Crear usuario para las pruebas
        self.create_test_user()
    
    def create_test_user(self):
        """Crea un usuario de prueba para usar en las tareas"""
        user_data = {
            "firstName": f"TestUser{random.randint(1000, 9999)}",
            "lastName": "LoadTest",
            "email": f"test{random.randint(1000, 9999)}@loadtest.com",
            "phone": f"555{random.randint(1000, 9999)}",
            "credentialDto": {
                "username": f"testuser{random.randint(1000, 9999)}",
                "password": "password123",
                "roleBasedAuthority": "ROLE_USER",
                "isEnabled": True,
                "isAccountNonExpired": True,
                "isAccountNonLocked": True,
                "isCredentialsNonExpired": True
            }
        }
        
        # Usar el servicio correcto para crear usuarios
        user_service_url = self.services["user"]
        with self.client.post(f"{user_service_url}/api/users", 
                            json=user_data, 
                            catch_response=True,
                            name="POST /api/users") as response:
            if response.status_code == 201:
                user_response = response.json()
                self.user_id = user_response.get('userId')
                response.success()
            else:
                response.failure(f"Failed to create user: {response.status_code}")
    
    @task(3)
    def browse_products(self):
        """Simula navegación por el catálogo de productos - Tarea más frecuente"""
        product_service_url = self.services["product"]
        with self.client.get(f"{product_service_url}/api/products", 
                           catch_response=True,
                           name="GET /api/products") as response:
            if response.status_code == 200:
                try:
                    products = response.json()
                    if products and len(products) > 0:
                        # Seleccionar un producto aleatorio para futuras tareas
                        self.product_id = random.choice(products).get('productId')
                    response.success()
                except:
                    # Si no hay productos, crear uno de prueba
                    self.create_test_product()
                    response.success()
            else:
                response.failure(f"Failed to browse products: {response.status_code}")
    
    def create_test_product(self):
        """Crea un producto de prueba si no existen productos"""
        product_data = {
            "productTitle": f"Test Product {random.randint(1000, 9999)}",
            "imageUrl": "http://example.com/product.jpg",
            "sku": f"TST-{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(10.0, 100.0), 2),
            "quantity": random.randint(10, 100),
            "categoryDto": {
                "categoryTitle": "Test Category",
                "imageUrl": "http://example.com/category.jpg"
            }
        }
        
        product_service_url = self.services["product"]
        with self.client.post(f"{product_service_url}/api/products", 
                            json=product_data, 
                            catch_response=True,
                            name="POST /api/products (test data)") as response:
            if response.status_code == 201:
                product_response = response.json()
                self.product_id = product_response.get('productId')
                response.success()
    
    @task(2)
    def view_product_details(self):
        """Simula ver detalles de un producto específico"""
        if self.product_id:
            product_service_url = self.services["product"]
            with self.client.get(f"{product_service_url}/api/products/{self.product_id}", 
                               catch_response=True,
                               name="GET /api/products/{id}") as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view product details: {response.status_code}")
    
    @task(2)
    def search_products(self):
        """Simula búsqueda de productos"""
        search_terms = ["Test", "Product", "Item", "Phone", "Laptop"]
        search_term = random.choice(search_terms)
        
        product_service_url = self.services["product"]
        with self.client.get(f"{product_service_url}/api/products/search?title={search_term}", 
                           catch_response=True,
                           name=f"GET /api/products/search") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to search products: {response.status_code}")
    
    @task(1)
    def create_order(self):
        """Simula creación de una orden"""
        if self.user_id:
            order_data = {
                "orderDate": "2024-01-15T10:00:00",
                "orderDesc": f"Load test order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(10.0, 500.0), 2)
            }
            
            order_service_url = self.services["order"]
            with self.client.post(f"{order_service_url}/api/orders?userId={self.user_id}", 
                                json=order_data, 
                                catch_response=True,
                                name="POST /api/orders") as response:
                if response.status_code == 201:
                    order_response = response.json()
                    self.order_id = order_response.get('orderId')
                    response.success()
                else:
                    response.failure(f"Failed to create order: {response.status_code}")
    
    @task(1)
    def add_to_favorites(self):
        """Simula agregar producto a favoritos"""
        if self.user_id and self.product_id:
            favourite_service_url = self.services["favourite"]
            with self.client.post(f"{favourite_service_url}/api/favourites?userId={self.user_id}&productId={self.product_id}", 
                                catch_response=True,
                                name="POST /api/favourites") as response:
                if response.status_code == 201:
                    response.success()
                else:
                    response.failure(f"Failed to add to favorites: {response.status_code}")
    
    @task(1)
    def view_user_profile(self):
        """Simula ver perfil de usuario"""
        if self.user_id:
            user_service_url = self.services["user"]
            with self.client.get(f"{user_service_url}/api/users/{self.user_id}", 
                               catch_response=True,
                               name="GET /api/users/{id}") as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view user profile: {response.status_code}")


class AdminLoadTest(HttpUser):
    """
    Pruebas de rendimiento para operaciones administrativas.
    Simula administradores gestionando productos, órdenes y usuarios.
    """
    host = "http://localhost:30082"  # product-service NodePort
    wait_time = between(2, 5)
    weight = 1  # Menos administradores que usuarios normales
    
    # Configuración de servicios por NodePort
    services = {
        "user": "http://localhost:30087",
        "product": "http://localhost:30082", 
        "order": "http://localhost:30083",
        "payment": "http://localhost:30084",
        "shipping": "http://localhost:30085",
        "favourite": "http://localhost:30086"
    }
    
    def on_start(self):
        """Configuración inicial para usuario administrador"""
        self.admin_user_id = None
        self.create_admin_user()
    
    def create_admin_user(self):
        """Crea un usuario administrador para las pruebas"""
        admin_data = {
            "firstName": f"Admin{random.randint(1000, 9999)}",
            "lastName": "LoadTest",
            "email": f"admin{random.randint(1000, 9999)}@loadtest.com",
            "phone": f"555{random.randint(1000, 9999)}",
            "credentialDto": {
                "username": f"admin{random.randint(1000, 9999)}",
                "password": "adminpassword123",
                "roleBasedAuthority": "ROLE_ADMIN",
                "isEnabled": True,
                "isAccountNonExpired": True,
                "isAccountNonLocked": True,
                "isCredentialsNonExpired": True
            }
        }
        
        user_service_url = self.services["user"]
        with self.client.post(f"{user_service_url}/api/users", 
                            json=admin_data, 
                            catch_response=True,
                            name="POST /api/users (admin)") as response:
            if response.status_code == 201:
                admin_response = response.json()
                self.admin_user_id = admin_response.get('userId')
                response.success()
            else:
                response.failure(f"Failed to create admin user: {response.status_code}")
    
    @task(2)
    def manage_products(self):
        """Simula gestión de productos por administrador"""
        # Crear nuevo producto
        product_data = {
            "productTitle": f"Admin Product {random.randint(1000, 9999)}",
            "imageUrl": "http://example.com/product.jpg",
            "sku": f"ADM-{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(10.0, 1000.0), 2),
            "quantity": random.randint(1, 100),
            "categoryDto": {
                "categoryTitle": "Admin Category",
                "imageUrl": "http://example.com/category.jpg"
            }
        }
        
        product_service_url = self.services["product"]
        with self.client.post(f"{product_service_url}/api/products", 
                            json=product_data, 
                            catch_response=True,
                            name="POST /api/products (admin)") as response:
            if response.status_code == 201:
                response.success()
            else:
                response.failure(f"Failed to create product: {response.status_code}")
    
    @task(1)
    def view_all_orders(self):
        """Simula visualización de todas las órdenes por administrador"""
        order_service_url = self.services["order"]
        with self.client.get(f"{order_service_url}/api/orders", 
                           catch_response=True,
                           name="GET /api/orders (admin)") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to view all orders: {response.status_code}")
    
    @task(1)
    def view_all_users(self):
        """Simula visualización de todos los usuarios por administrador"""
        user_service_url = self.services["user"]
        with self.client.get(f"{user_service_url}/api/users", 
                           catch_response=True,
                           name="GET /api/users (admin)") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to view all users: {response.status_code}")


# Configuración de pruebas de estrés
class StressTest(HttpUser):
    """
    Pruebas de estrés que simulan carga pesada en el sistema.
    Realiza operaciones intensivas para probar los límites del sistema.
    """
    host = "http://localhost:30082"  # product-service NodePort
    wait_time = between(0.1, 0.5)  # Tiempo de espera muy corto para estrés
    weight = 2
    
    # Configuración de servicios por NodePort
    services = {
        "user": "http://localhost:30087",
        "product": "http://localhost:30082", 
        "order": "http://localhost:30083",
        "payment": "http://localhost:30084",
        "shipping": "http://localhost:30085",
        "favourite": "http://localhost:30086"
    }
    
    @task
    def stress_product_catalog(self):
        """Estrés en el catálogo de productos"""
        product_service_url = self.services["product"]
        with self.client.get(f"{product_service_url}/api/products", 
                           catch_response=True,
                           name="GET /api/products (stress)") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Stress test failed: {response.status_code}")
    
    @task
    def stress_search(self):
        """Estrés en búsquedas de productos"""
        search_term = random.choice(["test", "product", "item", "phone", "laptop"])
        product_service_url = self.services["product"]
        with self.client.get(f"{product_service_url}/api/products/search?title={search_term}", 
                           catch_response=True,
                           name="GET /api/products/search (stress)") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Stress search failed: {response.status_code}") 