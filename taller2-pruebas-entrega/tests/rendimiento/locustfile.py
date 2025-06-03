import random
import json
from locust import HttpUser, task, between

class EcommerceLoadTest(HttpUser):
    """
    Pruebas de rendimiento para el sistema e-commerce.
    Simula comportamiento de usuarios reales navegando, comprando y gestionando productos.
    """
    wait_time = between(1, 3)  # Tiempo de espera entre tareas (1-3 segundos)
    
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
        
        with self.client.post("/api/users", 
                            json=user_data, 
                            catch_response=True) as response:
            if response.status_code == 201:
                user_response = response.json()
                self.user_id = user_response.get('userId')
                response.success()
            else:
                response.failure(f"Failed to create user: {response.status_code}")
    
    @task(3)
    def browse_products(self):
        """Simula navegación por el catálogo de productos - Tarea más frecuente"""
        with self.client.get("/api/products", catch_response=True) as response:
            if response.status_code == 200:
                products = response.json()
                if products:
                    # Seleccionar un producto aleatorio para futuras tareas
                    self.product_id = random.choice(products).get('productId')
                response.success()
            else:
                response.failure(f"Failed to browse products: {response.status_code}")
    
    @task(2)
    def view_product_details(self):
        """Simula ver detalles de un producto específico"""
        if self.product_id:
            with self.client.get(f"/api/products/{self.product_id}", 
                               catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view product details: {response.status_code}")
    
    @task(2)
    def search_products(self):
        """Simula búsqueda de productos"""
        search_terms = ["phone", "laptop", "camera", "headphones", "tablet"]
        search_term = random.choice(search_terms)
        
        with self.client.get(f"/api/products/search?title={search_term}", 
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to search products: {response.status_code}")
    
    @task(1)
    def add_to_cart(self):
        """Simula agregar producto al carrito"""
        if self.user_id and self.product_id:
            quantity = random.randint(1, 3)
            with self.client.post(f"/api/cart/add?userId={self.user_id}&productId={self.product_id}&quantity={quantity}", 
                                catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to add to cart: {response.status_code}")
    
    @task(1)
    def view_cart(self):
        """Simula ver el carrito del usuario"""
        if self.user_id:
            with self.client.get(f"/api/cart/user/{self.user_id}", 
                               catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view cart: {response.status_code}")
    
    @task(1)
    def create_order(self):
        """Simula creación de una orden"""
        if self.user_id:
            order_data = {
                "orderDate": "2024-01-15T10:00:00",
                "orderDesc": f"Load test order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(10.0, 500.0), 2)
            }
            
            with self.client.post(f"/api/orders?userId={self.user_id}", 
                                json=order_data, 
                                catch_response=True) as response:
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
            with self.client.post(f"/api/favourites?userId={self.user_id}&productId={self.product_id}", 
                                catch_response=True) as response:
                if response.status_code == 201:
                    response.success()
                else:
                    response.failure(f"Failed to add to favorites: {response.status_code}")
    
    @task(1)
    def view_user_profile(self):
        """Simula ver perfil de usuario"""
        if self.user_id:
            with self.client.get(f"/api/users/{self.user_id}", 
                               catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Failed to view user profile: {response.status_code}")


class AdminLoadTest(HttpUser):
    """
    Pruebas de rendimiento para operaciones administrativas.
    Simula administradores gestionando productos, órdenes y usuarios.
    """
    wait_time = between(2, 5)
    weight = 1  # Menos administradores que usuarios normales
    
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
        
        with self.client.post("/api/users", 
                            json=admin_data, 
                            catch_response=True) as response:
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
            "productTitle": f"LoadTest Product {random.randint(1000, 9999)}",
            "imageUrl": "http://example.com/product.jpg",
            "sku": f"LT-{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(10.0, 1000.0), 2),
            "quantity": random.randint(1, 100),
            "categoryDto": {
                "categoryTitle": "Load Test Category",
                "imageUrl": "http://example.com/category.jpg"
            }
        }
        
        with self.client.post("/api/products", 
                            json=product_data, 
                            catch_response=True) as response:
            if response.status_code == 201:
                response.success()
            else:
                response.failure(f"Failed to create product: {response.status_code}")
    
    @task(1)
    def view_all_orders(self):
        """Simula visualización de todas las órdenes por administrador"""
        with self.client.get("/api/orders", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to view all orders: {response.status_code}")
    
    @task(1)
    def view_all_users(self):
        """Simula visualización de todos los usuarios por administrador"""
        with self.client.get("/api/users", catch_response=True) as response:
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
    wait_time = between(0.1, 0.5)  # Tiempo de espera muy corto para estrés
    weight = 2
    
    @task
    def stress_product_catalog(self):
        """Estrés en el catálogo de productos"""
        with self.client.get("/api/products", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Stress test failed: {response.status_code}")
    
    @task
    def stress_search(self):
        """Estrés en búsquedas de productos"""
        search_term = random.choice(["test", "product", "item", "phone", "laptop"])
        with self.client.get(f"/api/products/search?title={search_term}", 
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Stress search failed: {response.status_code}") 