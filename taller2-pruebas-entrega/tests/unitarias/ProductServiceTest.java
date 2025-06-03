package com.selimhorri.app.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.selimhorri.app.domain.Product;
import com.selimhorri.app.domain.Category;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.dto.CategoryDto;
import com.selimhorri.app.exception.wrapper.ProductNotFoundException;
import com.selimhorri.app.repository.ProductRepository;
import com.selimhorri.app.service.impl.ProductServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("Product Service Unit Tests")
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private ProductDto productDto;
    private Product product;
    private CategoryDto categoryDto;
    private Category category;

    @BeforeEach
    void setUp() {
        // Setup Category
        categoryDto = CategoryDto.builder()
                .categoryId(1)
                .categoryTitle("Electronics")
                .imageUrl("http://example.com/electronics.jpg")
                .build();

        category = Category.builder()
                .categoryId(1)
                .categoryTitle("Electronics")
                .imageUrl("http://example.com/electronics.jpg")
                .build();

        // Setup Product
        productDto = ProductDto.builder()
                .productId(1)
                .productTitle("iPhone 14")
                .imageUrl("http://example.com/iphone14.jpg")
                .sku("IPH14-001")
                .priceUnit(999.99)
                .quantity(50)
                .categoryDto(categoryDto)
                .build();

        product = Product.builder()
                .productId(1)
                .productTitle("iPhone 14")
                .imageUrl("http://example.com/iphone14.jpg")
                .sku("IPH14-001")
                .priceUnit(999.99)
                .quantity(50)
                .category(category)
                .build();
    }

    @Test
    @DisplayName("Should find all products successfully")
    void testFindAll_Success() {
        // Given
        List<Product> products = Arrays.asList(product);
        when(productRepository.findAll()).thenReturn(products);

        // When
        List<ProductDto> result = productService.findAll();

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("iPhone 14", result.get(0).getProductTitle());
        assertEquals("IPH14-001", result.get(0).getSku());
        assertEquals(999.99, result.get(0).getPriceUnit());
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find product by id successfully")
    void testFindById_Success() {
        // Given
        when(productRepository.findById(1)).thenReturn(Optional.of(product));

        // When
        ProductDto result = productService.findById(1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getProductId());
        assertEquals("iPhone 14", result.getProductTitle());
        assertEquals("IPH14-001", result.getSku());
        assertEquals(50, result.getQuantity());
        verify(productRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Should throw exception when product not found by id")
    void testFindById_ProductNotFound() {
        // Given
        when(productRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        ProductNotFoundException exception = assertThrows(
                ProductNotFoundException.class,
                () -> productService.findById(999)
        );
        
        assertEquals("Product with id: 999 not found", exception.getMessage());
        verify(productRepository, times(1)).findById(999);
    }

    @Test
    @DisplayName("Should save product successfully")
    void testSave_Success() {
        // Given
        when(productRepository.save(any(Product.class))).thenReturn(product);

        // When
        ProductDto result = productService.save(productDto);

        // Then
        assertNotNull(result);
        assertEquals("iPhone 14", result.getProductTitle());
        assertEquals("IPH14-001", result.getSku());
        assertEquals(999.99, result.getPriceUnit());
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("Should validate product stock availability")
    void testValidateStockAvailability_Success() {
        // Given
        Category testCategory = Category.builder()
                .categoryId(1)
                .categoryTitle("Electronics")
                .imageUrl("http://example.com/electronics.jpg")
                .build();
        
        Product productWithStock = Product.builder()
                .productId(1)
                .productTitle("iPhone 14")
                .imageUrl("http://example.com/iphone14.jpg")
                .sku("IPH14-001")
                .priceUnit(999.99)
                .quantity(10)
                .category(testCategory)
                .build();
        
        when(productRepository.findById(1)).thenReturn(Optional.of(productWithStock));

        // When
        ProductDto result = productService.findById(1);

        // Then
        assertNotNull(result);
        assertNotNull(result.getCategoryDto());
        assertTrue(result.getQuantity() > 0);
        assertEquals(10, result.getQuantity());
        assertEquals(1, result.getCategoryDto().getCategoryId());
        assertEquals("Electronics", result.getCategoryDto().getCategoryTitle());
        verify(productRepository, times(1)).findById(1);
    }
} 