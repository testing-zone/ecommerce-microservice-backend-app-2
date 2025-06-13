package com.selimhorri.app.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.time.LocalDateTime;
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

import com.selimhorri.app.domain.Cart;
import com.selimhorri.app.domain.Order;
import com.selimhorri.app.dto.CartDto;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.exception.wrapper.OrderNotFoundException;
import com.selimhorri.app.repository.OrderRepository;
import com.selimhorri.app.service.impl.OrderServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("Order Service Unit Tests")
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderServiceImpl orderService;

    private OrderDto orderDto;
    private Order order;
    private Cart cart;
    private CartDto cartDto;

    @BeforeEach
    void setUp() {
        // Setup Cart
        cart = Cart.builder()
                .cartId(1)
                .userId(1)
                .build();

        cartDto = CartDto.builder()
                .cartId(1)
                .userId(1)
                .build();

        // Setup Order with Cart
        orderDto = OrderDto.builder()
                .orderId(1)
                .orderDate(LocalDateTime.now())
                .orderDesc("Test order description")
                .orderFee(29.99)
                .cartDto(cartDto)
                .build();

        order = Order.builder()
                .orderId(1)
                .orderDate(LocalDateTime.now())
                .orderDesc("Test order description")
                .orderFee(29.99)
                .cart(cart)
                .build();
    }

    @Test
    @DisplayName("Should find all orders successfully")
    void testFindAll_Success() {
        // Given
        List<Order> orders = Arrays.asList(order);
        when(orderRepository.findAll()).thenReturn(orders);

        // When
        List<OrderDto> result = orderService.findAll();

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Test order description", result.get(0).getOrderDesc());
        assertEquals(29.99, result.get(0).getOrderFee());
        assertEquals(1, result.get(0).getCartDto().getCartId());
        verify(orderRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find order by id successfully")
    void testFindById_Success() {
        // Given
        when(orderRepository.findById(1)).thenReturn(Optional.of(order));

        // When
        OrderDto result = orderService.findById(1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getOrderId());
        assertEquals("Test order description", result.getOrderDesc());
        assertEquals(29.99, result.getOrderFee());
        assertEquals(1, result.getCartDto().getCartId());
        verify(orderRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Should throw exception when order not found by id")
    void testFindById_OrderNotFound() {
        // Given
        when(orderRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        OrderNotFoundException exception = assertThrows(
                OrderNotFoundException.class,
                () -> orderService.findById(999)
        );
        
        assertEquals("Order with id: 999 not found", exception.getMessage());
        verify(orderRepository, times(1)).findById(999);
    }

    @Test
    @DisplayName("Should save order successfully")
    void testSave_Success() {
        // Given
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        // When
        OrderDto result = orderService.save(orderDto);

        // Then
        assertNotNull(result);
        assertEquals("Test order description", result.getOrderDesc());
        assertEquals(29.99, result.getOrderFee());
        assertEquals(1, result.getCartDto().getCartId());
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    @DisplayName("Should delete order by id successfully")
    void testDeleteById_Success() {
        // Given
        when(orderRepository.findById(1)).thenReturn(Optional.of(order));
        doNothing().when(orderRepository).delete(any(Order.class));

        // When
        assertDoesNotThrow(() -> orderService.deleteById(1));

        // Then
        verify(orderRepository, times(1)).findById(1);
        verify(orderRepository, times(1)).delete(any(Order.class));
    }

    @Test
    @DisplayName("Should update order successfully")
    void testUpdate_Success() {
        // Given
        Order updatedOrder = Order.builder()
                .orderId(1)
                .orderDate(LocalDateTime.now())
                .orderDesc("Updated order description")
                .orderFee(39.99)
                .cart(cart)
                .build();

        when(orderRepository.save(any(Order.class))).thenReturn(updatedOrder);

        // When
        OrderDto result = orderService.update(orderDto);

        // Then
        assertNotNull(result);
        assertEquals("Updated order description", result.getOrderDesc());
        assertEquals(39.99, result.getOrderFee());
        assertEquals(1, result.getCartDto().getCartId());
        verify(orderRepository, times(1)).save(any(Order.class));
    }
} 