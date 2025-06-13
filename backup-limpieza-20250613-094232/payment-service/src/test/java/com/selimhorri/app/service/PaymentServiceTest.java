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

import com.selimhorri.app.domain.Payment;
import com.selimhorri.app.domain.PaymentStatus;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.dto.PaymentDto;
import com.selimhorri.app.exception.wrapper.PaymentNotFoundException;
import com.selimhorri.app.repository.PaymentRepository;
import com.selimhorri.app.service.impl.PaymentServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("Payment Service Tests")
class PaymentServiceTest {

    @Mock
    private PaymentRepository paymentRepository;

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private PaymentServiceImpl paymentService;

    private Payment payment;
    private PaymentDto paymentDto;
    private OrderDto orderDto;

    @BeforeEach
    void setUp() {
        orderDto = OrderDto.builder()
                .orderId(1)
                .orderDesc("Test Order")
                .orderFee(199.99)
                .build();

        payment = Payment.builder()
                .paymentId(1)
                .orderId(1)
                .isPayed(false)
                .paymentStatus(PaymentStatus.IN_PROGRESS)
                .build();

        paymentDto = PaymentDto.builder()
                .paymentId(1)
                .isPayed(false)
                .paymentStatus(PaymentStatus.IN_PROGRESS)
                .orderDto(orderDto)
                .build();
    }

    @Test
    @DisplayName("Should find all payments")
    void testFindAll_Success() {
        // Given
        List<Payment> payments = Arrays.asList(payment);
        when(paymentRepository.findAll()).thenReturn(payments);
        when(restTemplate.getForObject(contains("orders"), eq(OrderDto.class)))
                .thenReturn(orderDto);

        // When
        List<PaymentDto> result = paymentService.findAll();

        // Then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        assertEquals(1, result.size());
        assertEquals(payment.getPaymentId(), result.get(0).getPaymentId());
        assertEquals(payment.getIsPayed(), result.get(0).getIsPayed());
        assertEquals(payment.getPaymentStatus(), result.get(0).getPaymentStatus());

        verify(paymentRepository).findAll();
        verify(restTemplate).getForObject(anyString(), eq(OrderDto.class));
    }

    @Test
    @DisplayName("Should find payment by ID")
    void testFindById_Success() {
        // Given
        when(paymentRepository.findById(1)).thenReturn(Optional.of(payment));
        when(restTemplate.getForObject(contains("orders"), eq(OrderDto.class)))
                .thenReturn(orderDto);

        // When
        PaymentDto result = paymentService.findById(1);

        // Then
        assertNotNull(result);
        assertEquals(payment.getPaymentId(), result.getPaymentId());
        assertEquals(payment.getIsPayed(), result.getIsPayed());
        assertEquals(payment.getPaymentStatus(), result.getPaymentStatus());
        assertNotNull(result.getOrderDto());

        verify(paymentRepository).findById(1);
        verify(restTemplate).getForObject(anyString(), eq(OrderDto.class));
    }

    @Test
    @DisplayName("Should throw exception when payment not found")
    void testFindById_NotFound() {
        // Given
        when(paymentRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(PaymentNotFoundException.class, () -> {
            paymentService.findById(999);
        });

        verify(paymentRepository).findById(999);
        verify(restTemplate, never()).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should save payment")
    void testSave_Success() {
        // Given
        when(paymentRepository.save(any(Payment.class))).thenReturn(payment);

        // When
        PaymentDto result = paymentService.save(paymentDto);

        // Then
        assertNotNull(result);
        assertEquals(payment.getPaymentId(), result.getPaymentId());
        assertEquals(payment.getIsPayed(), result.getIsPayed());
        assertEquals(payment.getPaymentStatus(), result.getPaymentStatus());

        verify(paymentRepository).save(any(Payment.class));
    }

    @Test
    @DisplayName("Should update payment")
    void testUpdate_Success() {
        // Given
        Payment updatedPayment = Payment.builder()
                .paymentId(1)
                .orderId(1)
                .isPayed(true) // Updated to paid
                .paymentStatus(PaymentStatus.COMPLETED)
                .build();

        when(paymentRepository.save(any(Payment.class))).thenReturn(updatedPayment);

        // When
        PaymentDto result = paymentService.update(paymentDto);

        // Then
        assertNotNull(result);
        assertEquals(updatedPayment.getPaymentId(), result.getPaymentId());
        assertEquals(true, result.getIsPayed());
        assertEquals(PaymentStatus.COMPLETED, result.getPaymentStatus());

        verify(paymentRepository).save(any(Payment.class));
    }

    @Test
    @DisplayName("Should delete payment by ID")
    void testDeleteById_Success() {
        // Given
        doNothing().when(paymentRepository).deleteById(1);

        // When
        assertDoesNotThrow(() -> {
            paymentService.deleteById(1);
        });

        // Then
        verify(paymentRepository).deleteById(1);
    }

    @Test
    @DisplayName("Should validate payment status transitions")
    void testPaymentStatusValidation() {
        // Given
        PaymentDto notStartedPayment = PaymentDto.builder()
                .paymentId(2)
                .isPayed(false)
                .paymentStatus(PaymentStatus.NOT_STARTED)
                .orderDto(orderDto)
                .build();

        Payment savedPayment = Payment.builder()
                .paymentId(2)
                .orderId(1)
                .isPayed(false)
                .paymentStatus(PaymentStatus.NOT_STARTED)
                .build();

        when(paymentRepository.save(any(Payment.class))).thenReturn(savedPayment);

        // When
        PaymentDto result = paymentService.save(notStartedPayment);

        // Then
        assertNotNull(result);
        assertEquals(PaymentStatus.NOT_STARTED, result.getPaymentStatus());
        assertFalse(result.getIsPayed());

        verify(paymentRepository).save(any(Payment.class));
    }
} 