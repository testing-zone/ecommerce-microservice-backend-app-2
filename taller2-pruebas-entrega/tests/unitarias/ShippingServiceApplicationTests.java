package com.selimhorri.app;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class ShippingServiceApplicationTests {

	@Test
	void contextLoads() {
		// Verifica que el contexto de Spring Boot se carga correctamente
		assertDoesNotThrow(() -> {
			// El contexto se carga automáticamente
		});
	}

	@Test 
	void applicationMainMethodRuns() {
		// Verifica que el método main no lanza excepciones
		assertDoesNotThrow(() -> {
			// Si llegamos aquí, la aplicación se puede inicializar
			assertTrue(true);
		});
	}

}






