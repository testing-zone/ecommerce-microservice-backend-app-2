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

import com.selimhorri.app.domain.Cart;
import com.selimhorri.app.dto.CartDto;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.exception.wrapper.CartNotFoundException;
import com.selimhorri.app.repository.CartRepository;
import com.selimhorri.app.service.impl.CartServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("Cart Service Tests")
class CartServiceTest {

    @Mock
    private CartRepository cartRepository;

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private CartServiceImpl cartService;

    private Cart cart;
    private CartDto cartDto;
    private UserDto userDto;

    @BeforeEach
    void setUp() {
        userDto = UserDto.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@test.com")
                .phone("1234567890")
                .build();

        cart = Cart.builder()
                .cartId(1)
                .userId(1)
                .build();

        cartDto = CartDto.builder()
                .cartId(1)
                .userId(1)
                .userDto(userDto)
                .build();
    }

    @Test
    @DisplayName("Should find all carts")
    void testFindAll_Success() {
        // Given
        List<Cart> carts = Arrays.asList(cart);
        when(cartRepository.findAll()).thenReturn(carts);
        when(restTemplate.getForObject(contains("users"), eq(UserDto.class)))
                .thenReturn(userDto);

        // When
        List<CartDto> result = cartService.findAll();

        // Then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        assertEquals(1, result.size());
        assertEquals(cart.getCartId(), result.get(0).getCartId());
        assertEquals(cart.getUserId(), result.get(0).getUserId());

        verify(cartRepository).findAll();
        verify(restTemplate).getForObject(anyString(), eq(UserDto.class));
    }

    @Test
    @DisplayName("Should find cart by ID")
    void testFindById_Success() {
        // Given
        when(cartRepository.findById(1)).thenReturn(Optional.of(cart));
        when(restTemplate.getForObject(contains("users"), eq(UserDto.class)))
                .thenReturn(userDto);

        // When
        CartDto result = cartService.findById(1);

        // Then
        assertNotNull(result);
        assertEquals(cart.getCartId(), result.getCartId());
        assertEquals(cart.getUserId(), result.getUserId());
        assertNotNull(result.getUserDto());

        verify(cartRepository).findById(1);
        verify(restTemplate).getForObject(anyString(), eq(UserDto.class));
    }

    @Test
    @DisplayName("Should throw exception when cart not found")
    void testFindById_NotFound() {
        // Given
        when(cartRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(CartNotFoundException.class, () -> {
            cartService.findById(999);
        });

        verify(cartRepository).findById(999);
        verify(restTemplate, never()).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should save cart")
    void testSave_Success() {
        // Given
        when(cartRepository.save(any(Cart.class))).thenReturn(cart);

        // When
        CartDto result = cartService.save(cartDto);

        // Then
        assertNotNull(result);
        assertEquals(cart.getCartId(), result.getCartId());
        assertEquals(cart.getUserId(), result.getUserId());

        verify(cartRepository).save(any(Cart.class));
    }

    @Test
    @DisplayName("Should update cart")
    void testUpdate_Success() {
        // Given
        Cart updatedCart = Cart.builder()
                .cartId(1)
                .userId(2) // Updated user ID
                .build();

        when(cartRepository.save(any(Cart.class))).thenReturn(updatedCart);

        // When
        CartDto result = cartService.update(cartDto);

        // Then
        assertNotNull(result);
        assertEquals(updatedCart.getCartId(), result.getCartId());
        assertEquals(2, result.getUserId());

        verify(cartRepository).save(any(Cart.class));
    }

    @Test
    @DisplayName("Should delete cart by ID")
    void testDeleteById_Success() {
        // Given
        doNothing().when(cartRepository).deleteById(1);

        // When
        assertDoesNotThrow(() -> {
            cartService.deleteById(1);
        });

        // Then
        verify(cartRepository).deleteById(1);
    }

    @Test
    @DisplayName("Should update cart with cart ID")
    void testUpdateWithCartId_Success() {
        // Given
        when(cartRepository.findById(1)).thenReturn(Optional.of(cart));
        when(restTemplate.getForObject(contains("users"), eq(UserDto.class)))
                .thenReturn(userDto);
        when(cartRepository.save(any(Cart.class))).thenReturn(cart);

        // When
        CartDto result = cartService.update(1, cartDto);

        // Then
        assertNotNull(result);
        assertEquals(cart.getCartId(), result.getCartId());
        assertEquals(cart.getUserId(), result.getUserId());

        verify(cartRepository).findById(1);
        verify(cartRepository).save(any(Cart.class));
    }
} 