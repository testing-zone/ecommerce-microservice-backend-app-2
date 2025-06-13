package integration;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.time.LocalDateTime;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.dto.CredentialDto;
import com.selimhorri.app.dto.CategoryDto;
import com.selimhorri.app.domain.RoleBasedAuthority;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebMvc
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "eureka.client.enabled=false",
    "spring.cloud.discovery.enabled=false"
})
@DisplayName("E-commerce Integration Tests")
class EcommerceIntegrationTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    private UserDto testUser;
    private ProductDto testProduct;
    private OrderDto testOrder;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        objectMapper = new ObjectMapper();

        // Setup test data
        CredentialDto credentialDto = CredentialDto.builder()
                .username("testuser")
                .password("password123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        testUser = UserDto.builder()
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .phone("1234567890")
                .credentialDto(credentialDto)
                .build();

        CategoryDto categoryDto = CategoryDto.builder()
                .categoryTitle("Electronics")
                .imageUrl("http://example.com/electronics.jpg")
                .build();

        testProduct = ProductDto.builder()
                .productTitle("Test Product")
                .imageUrl("http://example.com/product.jpg")
                .sku("TEST-001")
                .priceUnit(99.99)
                .quantity(10)
                .categoryDto(categoryDto)
                .build();

        testOrder = OrderDto.builder()
                .orderDate(LocalDateTime.now())
                .orderDesc("Test order")
                .orderFee(29.99)
                .build();
    }

    @Test
    @DisplayName("Should create user and retrieve it successfully")
    void testUserCreationAndRetrieval() throws Exception {
        // Create user
        String userJson = objectMapper.writeValueAsString(testUser);
        
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"));

        // Retrieve users
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    @DisplayName("Should create product and verify inventory")
    void testProductCreationAndInventoryCheck() throws Exception {
        // Create product
        String productJson = objectMapper.writeValueAsString(testProduct);
        
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(productJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.productTitle").value("Test Product"))
                .andExpect(jsonPath("$.quantity").value(10));

        // Check inventory
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].quantity").value(10));
    }

    @Test
    @DisplayName("Should process complete order workflow")
    void testCompleteOrderWorkflow() throws Exception {
        // 1. Create user first
        String userJson = objectMapper.writeValueAsString(testUser);
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isCreated());

        // 2. Create product
        String productJson = objectMapper.writeValueAsString(testProduct);
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(productJson))
                .andExpect(status().isCreated());

        // 3. Create order
        String orderJson = objectMapper.writeValueAsString(testOrder);
        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(orderJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.orderDesc").value("Test order"));

        // 4. Verify order was created
        mockMvc.perform(get("/api/orders"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].orderDesc").value("Test order"));
    }

    @Test
    @DisplayName("Should handle user-product favorite relationship")
    void testUserProductFavoriteIntegration() throws Exception {
        // Create user
        String userJson = objectMapper.writeValueAsString(testUser);
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isCreated());

        // Create product
        String productJson = objectMapper.writeValueAsString(testProduct);
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(productJson))
                .andExpect(status().isCreated());

        // Add product to favorites (assuming user ID 1 and product ID 1)
        mockMvc.perform(post("/api/favourites")
                .param("userId", "1")
                .param("productId", "1"))
                .andExpect(status().isCreated());

        // Verify favorite was added
        mockMvc.perform(get("/api/favourites/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    @DisplayName("Should validate product availability before order creation")
    void testProductAvailabilityValidation() throws Exception {
        // Create product with limited stock
        ProductDto limitedProduct = ProductDto.builder()
                .productTitle("Limited Product")
                .sku("LIMITED-001")
                .priceUnit(199.99)
                .quantity(1)
                .build();

        String productJson = objectMapper.writeValueAsString(limitedProduct);
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(productJson))
                .andExpect(status().isCreated());

        // Verify product availability
        mockMvc.perform(get("/api/products/check-availability/LIMITED-001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.available").value(true))
                .andExpect(jsonPath("$.quantity").value(1));

        // Create order that would consume the product
        OrderDto orderForLimitedProduct = OrderDto.builder()
                .orderDate(LocalDateTime.now())
                .orderDesc("Order for limited product")
                .orderFee(199.99)
                .build();

        String orderJson = objectMapper.writeValueAsString(orderForLimitedProduct);
        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(orderJson))
                .andExpect(status().isCreated());
    }
} 