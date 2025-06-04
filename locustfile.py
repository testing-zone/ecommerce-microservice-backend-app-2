from locust import HttpUser, task, between
import random
import json

class EcommerceUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        """Ejecutado al inicio de cada usuario"""
        self.user_id = random.randint(1, 1000)
        self.product_id = random.randint(1, 100)
        
    @task(3)
    def view_user_profile(self):
        """Simular consulta de perfil de usuario"""
        with self.client.get(f"http://localhost:8081/api/users/{self.user_id}", 
                            catch_response=True, name="GET /api/users/[id]") as response:
            if response.status_code == 404:
                response.success()  # 404 es esperado para usuarios que no existen
    
    @task(5)
    def browse_products(self):
        """Simular navegación de productos"""
        with self.client.get(f"http://localhost:8082/api/products", 
                            catch_response=True, name="GET /api/products") as response:
            if response.status_code in [200, 404]:
                response.success()
    
    @task(2)
    def view_product_detail(self):
        """Simular vista detalle de producto"""
        with self.client.get(f"http://localhost:8082/api/products/{self.product_id}", 
                            catch_response=True, name="GET /api/products/[id]") as response:
            if response.status_code in [200, 404]:
                response.success()
    
    @task(1)
    def create_order(self):
        """Simular creación de orden"""
        order_data = {
            "userId": self.user_id,
            "productId": self.product_id,
            "quantity": random.randint(1, 3),
            "totalAmount": random.uniform(10.0, 500.0)
        }
        with self.client.post("http://localhost:8083/api/orders", 
                             json=order_data,
                             catch_response=True, 
                             name="POST /api/orders") as response:
            if response.status_code in [200, 201, 400, 404]:
                response.success()

class HealthCheckUser(HttpUser):
    wait_time = between(5, 10)
    
    @task
    def health_check_user_service(self):
        """Health check user service"""
        self.client.get("http://localhost:8081/actuator/health", name="Health Check - User")
    
    @task
    def health_check_product_service(self):
        """Health check product service"""
        self.client.get("http://localhost:8082/actuator/health", name="Health Check - Product")
        
    @task
    def health_check_order_service(self):
        """Health check order service"""
        self.client.get("http://localhost:8083/actuator/health", name="Health Check - Order")
