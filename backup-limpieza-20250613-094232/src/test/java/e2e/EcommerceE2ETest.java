package e2e;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.time.LocalDateTime;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.web.context.WebApplicationContext;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
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
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("E-commerce End-to-End Tests")
class EcommerceE2ETest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    private Integer createdUserId;
    private Integer createdProductId;
    private Integer createdOrderId;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        objectMapper = new ObjectMapper();
    }

    @Test
    @Order(1)
    @DisplayName("E2E: Complete user registration and authentication flow")
    void testCompleteUserRegistrationFlow() throws Exception {
        // 1. Register new user
        CredentialDto credentialDto = CredentialDto.builder()
                .username("e2euser")
                .password("securepassword123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        UserDto newUser = UserDto.builder()
                .firstName("E2E")
                .lastName("TestUser")
                .email("e2e.test@example.com")
                .phone("9876543210")
                .imageUrl("http://example.com/avatar.jpg")
                .credentialDto(credentialDto)
                .build();

        String userJson = objectMapper.writeValueAsString(newUser);
        
        MvcResult result = mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.firstName").value("E2E"))
                .andExpect(jsonPath("$.email").value("e2e.test@example.com"))
                .andReturn();

        // Extract user ID for subsequent tests
        JsonNode responseJson = objectMapper.readTree(result.getResponse().getContentAsString());
        createdUserId = responseJson.get("userId").asInt();

        // 2. Verify user can be retrieved
        mockMvc.perform(get("/api/users/" + createdUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(createdUserId))
                .andExpect(jsonPath("$.email").value("e2e.test@example.com"));

        // 3. Update user profile
        UserDto updatedUser = UserDto.builder()
                .userId(createdUserId)
                .firstName("E2E Updated")
                .lastName("TestUser")
                .email("e2e.updated@example.com")
                .phone("9876543210")
                .credentialDto(credentialDto)
                .build();

        String updatedUserJson = objectMapper.writeValueAsString(updatedUser);
        mockMvc.perform(put("/api/users/" + createdUserId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(updatedUserJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("E2E Updated"));
    }

    @Test
    @Order(2)
    @DisplayName("E2E: Complete product catalog management flow")
    void testCompleteProductCatalogFlow() throws Exception {
        // 1. Create category first
        CategoryDto categoryDto = CategoryDto.builder()
                .categoryTitle("E2E Electronics")
                .imageUrl("http://example.com/e2e-electronics.jpg")
                .build();

        // 2. Create product
        ProductDto newProduct = ProductDto.builder()
                .productTitle("E2E Test Smartphone")
                .imageUrl("http://example.com/smartphone.jpg")
                .sku("E2E-PHONE-001")
                .priceUnit(799.99)
                .quantity(25)
                .categoryDto(categoryDto)
                .build();

        String productJson = objectMapper.writeValueAsString(newProduct);
        
        MvcResult result = mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(productJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.productTitle").value("E2E Test Smartphone"))
                .andExpect(jsonPath("$.sku").value("E2E-PHONE-001"))
                .andReturn();

        // Extract product ID
        JsonNode responseJson = objectMapper.readTree(result.getResponse().getContentAsString());
        createdProductId = responseJson.get("productId").asInt();

        // 3. Verify product in catalog
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.sku == 'E2E-PHONE-001')].productTitle").value("E2E Test Smartphone"));

        // 4. Search for product
        mockMvc.perform(get("/api/products/search")
                .param("title", "E2E Test"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].productTitle").value("E2E Test Smartphone"));

        // 5. Update product inventory
        ProductDto updatedProduct = ProductDto.builder()
                .productId(createdProductId)
                .productTitle("E2E Test Smartphone")
                .sku("E2E-PHONE-001")
                .priceUnit(749.99) // Price reduction
                .quantity(30) // Increased stock
                .categoryDto(categoryDto)
                .build();

        String updatedProductJson = objectMapper.writeValueAsString(updatedProduct);
        mockMvc.perform(put("/api/products/" + createdProductId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(updatedProductJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.priceUnit").value(749.99))
                .andExpect(jsonPath("$.quantity").value(30));
    }

    @Test
    @Order(3)
    @DisplayName("E2E: Complete shopping and order management flow")
    void testCompleteShoppingFlow() throws Exception {
        // Assume user and product from previous tests exist
        assertNotNull(createdUserId, "User must be created before this test");
        assertNotNull(createdProductId, "Product must be created before this test");

        // 1. Add product to cart
        mockMvc.perform(post("/api/cart/add")
                .param("userId", createdUserId.toString())
                .param("productId", createdProductId.toString())
                .param("quantity", "2"))
                .andExpect(status().isOk());

        // 2. View cart
        mockMvc.perform(get("/api/cart/user/" + createdUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].quantity").value(2));

        // 3. Create order from cart
        OrderDto newOrder = OrderDto.builder()
                .orderDate(LocalDateTime.now())
                .orderDesc("E2E test order for smartphone")
                .orderFee(1519.98) // 2 * 749.99 + shipping
                .build();

        String orderJson = objectMapper.writeValueAsString(newOrder);
        
        MvcResult result = mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(orderJson)
                .param("userId", createdUserId.toString()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.orderDesc").value("E2E test order for smartphone"))
                .andReturn();

        // Extract order ID
        JsonNode responseJson = objectMapper.readTree(result.getResponse().getContentAsString());
        createdOrderId = responseJson.get("orderId").asInt();

        // 4. Verify order status
        mockMvc.perform(get("/api/orders/" + createdOrderId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.orderId").value(createdOrderId));

        // 5. Verify inventory was updated
        mockMvc.perform(get("/api/products/" + createdProductId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.quantity").value(28)); // 30 - 2 = 28
    }

    @Test
    @Order(4)
    @DisplayName("E2E: Complete payment and shipping workflow")
    void testCompletePaymentShippingFlow() throws Exception {
        assertNotNull(createdOrderId, "Order must be created before this test");

        // 1. Process payment
        mockMvc.perform(post("/api/payments/process")
                .param("orderId", createdOrderId.toString())
                .param("paymentMethod", "CREDIT_CARD")
                .param("amount", "1519.98"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));

        // 2. Initiate shipping
        mockMvc.perform(post("/api/shipping/create")
                .param("orderId", createdOrderId.toString())
                .param("shippingAddress", "123 E2E Test Street, Test City, 12345")
                .param("shippingMethod", "STANDARD"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("PROCESSING"));

        // 3. Track shipment
        mockMvc.perform(get("/api/shipping/track/" + createdOrderId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PROCESSING"));

        // 4. Update shipping status
        mockMvc.perform(put("/api/shipping/update-status")
                .param("orderId", createdOrderId.toString())
                .param("status", "SHIPPED"))
                .andExpect(status().isOk());

        // 5. Verify final order status
        mockMvc.perform(get("/api/orders/" + createdOrderId + "/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.orderStatus").value("SHIPPED"));
    }

    @Test
    @Order(5)
    @DisplayName("E2E: Complete user experience with favorites and reviews")
    void testCompleteUserExperienceFlow() throws Exception {
        assertNotNull(createdUserId, "User must be created before this test");
        assertNotNull(createdProductId, "Product must be created before this test");

        // 1. Add product to favorites
        mockMvc.perform(post("/api/favourites")
                .param("userId", createdUserId.toString())
                .param("productId", createdProductId.toString()))
                .andExpect(status().isCreated());

        // 2. View user's favorites
        mockMvc.perform(get("/api/favourites/user/" + createdUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].productDto.productId").value(createdProductId));

        // 3. Add product review
        mockMvc.perform(post("/api/reviews")
                .param("userId", createdUserId.toString())
                .param("productId", createdProductId.toString())
                .param("rating", "5")
                .param("comment", "Excellent E2E test product!"))
                .andExpect(status().isCreated());

        // 4. View product reviews
        mockMvc.perform(get("/api/reviews/product/" + createdProductId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].rating").value(5))
                .andExpect(jsonPath("$[0].comment").value("Excellent E2E test product!"));

        // 5. Remove from favorites
        mockMvc.perform(delete("/api/favourites")
                .param("userId", createdUserId.toString())
                .param("productId", createdProductId.toString()))
                .andExpect(status().isOk());

        // 6. Verify favorites list is empty
        mockMvc.perform(get("/api/favourites/user/" + createdUserId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }
} 