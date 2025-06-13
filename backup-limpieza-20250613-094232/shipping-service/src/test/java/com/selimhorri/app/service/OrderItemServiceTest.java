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
import org.springframework.web.client.RestTemplate;

import com.selimhorri.app.domain.OrderItem;
import com.selimhorri.app.domain.id.OrderItemId;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.dto.OrderItemDto;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.exception.wrapper.OrderItemNotFoundException;
import com.selimhorri.app.repository.OrderItemRepository;
import com.selimhorri.app.service.impl.OrderItemServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("OrderItem Service Tests")
class OrderItemServiceTest {

    @Mock
    private OrderItemRepository orderItemRepository;

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private OrderItemServiceImpl orderItemService;

    private OrderItem orderItem;
    private OrderItemDto orderItemDto;
    private OrderItemId orderItemId;
    private ProductDto productDto;
    private OrderDto orderDto;

    @BeforeEach
    void setUp() {
        orderItemId = new OrderItemId(1, 1);
        
        productDto = ProductDto.builder()
                .productId(1)
                .productTitle("Test Product")
                .sku("TEST-001")
                .priceUnit(99.99)
                .quantity(10)
                .build();

        orderDto = OrderDto.builder()
                .orderId(1)
                .orderDesc("Test Order")
                .orderFee(199.99)
                .build();

        orderItem = OrderItem.builder()
                .productId(1)
                .orderId(1)
                .orderedQuantity(2)
                .build();

        orderItemDto = OrderItemDto.builder()
                .productId(1)
                .orderId(1)
                .orderedQuantity(2)
                .productDto(productDto)
                .orderDto(orderDto)
                .build();
    }

    @Test
    @DisplayName("Should find all order items")
    void testFindAll_Success() {
        // Given
        List<OrderItem> orderItems = Arrays.asList(orderItem);
        when(orderItemRepository.findAll()).thenReturn(orderItems);
        when(restTemplate.getForObject(contains("products"), eq(ProductDto.class)))
                .thenReturn(productDto);
        when(restTemplate.getForObject(contains("orders"), eq(OrderDto.class)))
                .thenReturn(orderDto);

        // When
        List<OrderItemDto> result = orderItemService.findAll();

        // Then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        assertEquals(1, result.size());
        assertEquals(orderItem.getProductId(), result.get(0).getProductId());
        assertEquals(orderItem.getOrderId(), result.get(0).getOrderId());
        assertEquals(orderItem.getOrderedQuantity(), result.get(0).getOrderedQuantity());

        verify(orderItemRepository).findAll();
        verify(restTemplate, times(2)).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should find order item by ID")
    void testFindById_Success() {
        // Given
        when(orderItemRepository.findById(any())).thenReturn(Optional.of(orderItem));
        when(restTemplate.getForObject(contains("products"), eq(ProductDto.class)))
                .thenReturn(productDto);
        when(restTemplate.getForObject(contains("orders"), eq(OrderDto.class)))
                .thenReturn(orderDto);

        // When
        OrderItemDto result = orderItemService.findById(orderItemId);

        // Then
        assertNotNull(result);
        assertEquals(orderItem.getProductId(), result.getProductId());
        assertEquals(orderItem.getOrderId(), result.getOrderId());
        assertEquals(orderItem.getOrderedQuantity(), result.getOrderedQuantity());

        verify(orderItemRepository).findById(any());
        verify(restTemplate, times(2)).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should throw exception when order item not found")
    void testFindById_NotFound() {
        // Given
        when(orderItemRepository.findById(any())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(OrderItemNotFoundException.class, () -> {
            orderItemService.findById(orderItemId);
        });

        verify(orderItemRepository).findById(any());
        verify(restTemplate, never()).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should save order item")
    void testSave_Success() {
        // Given
        when(orderItemRepository.save(any(OrderItem.class))).thenReturn(orderItem);

        // When
        OrderItemDto result = orderItemService.save(orderItemDto);

        // Then
        assertNotNull(result);
        assertEquals(orderItem.getProductId(), result.getProductId());
        assertEquals(orderItem.getOrderId(), result.getOrderId());
        assertEquals(orderItem.getOrderedQuantity(), result.getOrderedQuantity());

        verify(orderItemRepository).save(any(OrderItem.class));
    }

    @Test
    @DisplayName("Should update order item")
    void testUpdate_Success() {
        // Given
        OrderItem updatedOrderItem = OrderItem.builder()
                .productId(1)
                .orderId(1)
                .orderedQuantity(5) // Updated quantity
                .build();

        when(orderItemRepository.save(any(OrderItem.class))).thenReturn(updatedOrderItem);

        // When
        OrderItemDto result = orderItemService.update(orderItemDto);

        // Then
        assertNotNull(result);
        assertEquals(updatedOrderItem.getProductId(), result.getProductId());
        assertEquals(updatedOrderItem.getOrderId(), result.getOrderId());
        assertEquals(5, result.getOrderedQuantity());

        verify(orderItemRepository).save(any(OrderItem.class));
    }

    @Test
    @DisplayName("Should delete order item by ID")
    void testDeleteById_Success() {
        // Given
        doNothing().when(orderItemRepository).deleteById(orderItemId);

        // When
        assertDoesNotThrow(() -> {
            orderItemService.deleteById(orderItemId);
        });

        // Then
        verify(orderItemRepository).deleteById(orderItemId);
    }
} 