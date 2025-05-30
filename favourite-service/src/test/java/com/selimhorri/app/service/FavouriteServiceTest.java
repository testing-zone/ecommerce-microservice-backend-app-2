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
import org.springframework.web.client.RestTemplate;

import com.selimhorri.app.domain.Favourite;
import com.selimhorri.app.domain.id.FavouriteId;
import com.selimhorri.app.dto.FavouriteDto;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.exception.wrapper.FavouriteNotFoundException;
import com.selimhorri.app.repository.FavouriteRepository;
import com.selimhorri.app.service.impl.FavouriteServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("Favourite Service Tests")
class FavouriteServiceTest {

    @Mock
    private FavouriteRepository favouriteRepository;

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private FavouriteServiceImpl favouriteService;

    private Favourite favourite;
    private FavouriteDto favouriteDto;
    private FavouriteId favouriteId;
    private UserDto userDto;
    private ProductDto productDto;
    private LocalDateTime testDate;

    @BeforeEach
    void setUp() {
        testDate = LocalDateTime.now();
        
        favouriteId = new FavouriteId(1, 1, testDate);

        userDto = UserDto.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@test.com")
                .phone("1234567890")
                .build();

        productDto = ProductDto.builder()
                .productId(1)
                .productTitle("Test Product")
                .sku("TEST-001")
                .priceUnit(99.99)
                .quantity(10)
                .build();

        favourite = Favourite.builder()
                .userId(1)
                .productId(1)
                .likeDate(testDate)
                .build();

        favouriteDto = FavouriteDto.builder()
                .userId(1)
                .productId(1)
                .likeDate(testDate)
                .userDto(userDto)
                .productDto(productDto)
                .build();
    }

    @Test
    @DisplayName("Should find all favourites")
    void testFindAll_Success() {
        // Given
        List<Favourite> favourites = Arrays.asList(favourite);
        when(favouriteRepository.findAll()).thenReturn(favourites);
        when(restTemplate.getForObject(contains("users"), eq(UserDto.class)))
                .thenReturn(userDto);
        when(restTemplate.getForObject(contains("products"), eq(ProductDto.class)))
                .thenReturn(productDto);

        // When
        List<FavouriteDto> result = favouriteService.findAll();

        // Then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        assertEquals(1, result.size());
        assertEquals(favourite.getUserId(), result.get(0).getUserId());
        assertEquals(favourite.getProductId(), result.get(0).getProductId());
        assertEquals(favourite.getLikeDate(), result.get(0).getLikeDate());

        verify(favouriteRepository).findAll();
        verify(restTemplate).getForObject(contains("users"), eq(UserDto.class));
        verify(restTemplate).getForObject(contains("products"), eq(ProductDto.class));
    }

    @Test
    @DisplayName("Should find favourite by ID")
    void testFindById_Success() {
        // Given
        when(favouriteRepository.findById(favouriteId)).thenReturn(Optional.of(favourite));
        when(restTemplate.getForObject(contains("users"), eq(UserDto.class)))
                .thenReturn(userDto);
        when(restTemplate.getForObject(contains("products"), eq(ProductDto.class)))
                .thenReturn(productDto);

        // When
        FavouriteDto result = favouriteService.findById(favouriteId);

        // Then
        assertNotNull(result);
        assertEquals(favourite.getUserId(), result.getUserId());
        assertEquals(favourite.getProductId(), result.getProductId());
        assertEquals(favourite.getLikeDate(), result.getLikeDate());
        assertNotNull(result.getUserDto());
        assertNotNull(result.getProductDto());

        verify(favouriteRepository).findById(favouriteId);
        verify(restTemplate).getForObject(contains("users"), eq(UserDto.class));
        verify(restTemplate).getForObject(contains("products"), eq(ProductDto.class));
    }

    @Test
    @DisplayName("Should throw exception when favourite not found")
    void testFindById_NotFound() {
        // Given
        when(favouriteRepository.findById(favouriteId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(FavouriteNotFoundException.class, () -> {
            favouriteService.findById(favouriteId);
        });

        verify(favouriteRepository).findById(favouriteId);
        verify(restTemplate, never()).getForObject(anyString(), any(Class.class));
    }

    @Test
    @DisplayName("Should save favourite")
    void testSave_Success() {
        // Given
        when(favouriteRepository.save(any(Favourite.class))).thenReturn(favourite);

        // When
        FavouriteDto result = favouriteService.save(favouriteDto);

        // Then
        assertNotNull(result);
        assertEquals(favourite.getUserId(), result.getUserId());
        assertEquals(favourite.getProductId(), result.getProductId());
        assertEquals(favourite.getLikeDate(), result.getLikeDate());

        verify(favouriteRepository).save(any(Favourite.class));
    }

    @Test
    @DisplayName("Should update favourite")
    void testUpdate_Success() {
        // Given
        LocalDateTime newDate = LocalDateTime.now().plusDays(1);
        Favourite updatedFavourite = Favourite.builder()
                .userId(1)
                .productId(1)
                .likeDate(newDate) // Updated date
                .build();

        when(favouriteRepository.save(any(Favourite.class))).thenReturn(updatedFavourite);

        // When
        FavouriteDto result = favouriteService.update(favouriteDto);

        // Then
        assertNotNull(result);
        assertEquals(updatedFavourite.getUserId(), result.getUserId());
        assertEquals(updatedFavourite.getProductId(), result.getProductId());
        assertEquals(newDate, result.getLikeDate());

        verify(favouriteRepository).save(any(Favourite.class));
    }

    @Test
    @DisplayName("Should delete favourite by ID")
    void testDeleteById_Success() {
        // Given
        doNothing().when(favouriteRepository).deleteById(favouriteId);

        // When
        assertDoesNotThrow(() -> {
            favouriteService.deleteById(favouriteId);
        });

        // Then
        verify(favouriteRepository).deleteById(favouriteId);
    }

    @Test
    @DisplayName("Should handle user-product relationship correctly")
    void testUserProductRelationship() {
        // Given
        FavouriteDto newFavourite = FavouriteDto.builder()
                .userId(2)
                .productId(3)
                .likeDate(LocalDateTime.now())
                .build();

        Favourite savedFavourite = Favourite.builder()
                .userId(2)
                .productId(3)
                .likeDate(newFavourite.getLikeDate())
                .build();

        when(favouriteRepository.save(any(Favourite.class))).thenReturn(savedFavourite);

        // When
        FavouriteDto result = favouriteService.save(newFavourite);

        // Then
        assertNotNull(result);
        assertEquals(2, result.getUserId());
        assertEquals(3, result.getProductId());
        assertNotNull(result.getLikeDate());

        verify(favouriteRepository).save(any(Favourite.class));
    }

    @Test
    @DisplayName("Should validate date handling")
    void testDateHandling() {
        // Given
        LocalDateTime specificDate = LocalDateTime.of(2024, 1, 15, 10, 30, 0);
        FavouriteDto dateSpecificFavourite = FavouriteDto.builder()
                .userId(1)
                .productId(1)
                .likeDate(specificDate)
                .build();

        Favourite savedFavourite = Favourite.builder()
                .userId(1)
                .productId(1)
                .likeDate(specificDate)
                .build();

        when(favouriteRepository.save(any(Favourite.class))).thenReturn(savedFavourite);

        // When
        FavouriteDto result = favouriteService.save(dateSpecificFavourite);

        // Then
        assertNotNull(result);
        assertEquals(specificDate, result.getLikeDate());
        assertEquals(specificDate.getYear(), result.getLikeDate().getYear());
        assertEquals(specificDate.getMonth(), result.getLikeDate().getMonth());
        assertEquals(specificDate.getDayOfMonth(), result.getLikeDate().getDayOfMonth());

        verify(favouriteRepository).save(any(Favourite.class));
    }
} 