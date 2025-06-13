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

import com.selimhorri.app.domain.Credential;
import com.selimhorri.app.domain.RoleBasedAuthority;
import com.selimhorri.app.domain.User;
import com.selimhorri.app.dto.CredentialDto;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.exception.wrapper.UserObjectNotFoundException;
import com.selimhorri.app.repository.UserRepository;
import com.selimhorri.app.service.impl.UserServiceImpl;

@ExtendWith(MockitoExtension.class)
@DisplayName("User Service Tests")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    private UserDto userDto;
    private User user;
    private CredentialDto credentialDto;
    private Credential credential;

    @BeforeEach
    void setUp() {
        // Configurar CredentialDto
        credentialDto = CredentialDto.builder()
                .credentialId(1)
                .username("johndoe")
                .password("password123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        // Configurar UserDto
        userDto = UserDto.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .phone("1234567890")
                .imageUrl("http://example.com/image.jpg")
                .credentialDto(credentialDto)
                .build();

        // Configurar Credential
        credential = Credential.builder()
                .credentialId(1)
                .username("johndoe")
                .password("password123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        // Configurar User
        user = User.builder()
                .userId(1)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .phone("1234567890")
                .imageUrl("http://example.com/image.jpg")
                .credential(credential)
                .build();
    }

    @Test
    @DisplayName("Should find all users successfully")
    void testFindAll_Success() {
        // Given
        List<User> users = Arrays.asList(user);
        when(userRepository.findAll()).thenReturn(users);

        // When
        List<UserDto> result = userService.findAll();

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("John", result.get(0).getFirstName());
        assertEquals("Doe", result.get(0).getLastName());
        assertEquals("johndoe", result.get(0).getCredentialDto().getUsername());
        verify(userRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find user by id successfully")
    void testFindById_Success() {
        // Given
        when(userRepository.findById(1)).thenReturn(Optional.of(user));

        // When
        UserDto result = userService.findById(1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getUserId());
        assertEquals("John", result.getFirstName());
        assertEquals("john.doe@example.com", result.getEmail());
        assertEquals("johndoe", result.getCredentialDto().getUsername());
        verify(userRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Should throw exception when user not found by id")
    void testFindById_UserNotFound() {
        // Given
        when(userRepository.findById(999)).thenReturn(Optional.empty());

        // When & Then
        UserObjectNotFoundException exception = assertThrows(
                UserObjectNotFoundException.class,
                () -> userService.findById(999)
        );
        
        assertEquals("User with id: 999 not found", exception.getMessage());
        verify(userRepository, times(1)).findById(999);
    }

    @Test
    @DisplayName("Should save user successfully")
    void testSave_Success() {
        // Given
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        UserDto result = userService.save(userDto);

        // Then
        assertNotNull(result);
        assertEquals("John", result.getFirstName());
        assertEquals("Doe", result.getLastName());
        assertEquals("johndoe", result.getCredentialDto().getUsername());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Should update user successfully")
    void testUpdate_Success() {
        // Given
        CredentialDto updatedCredentialDto = CredentialDto.builder()
                .credentialId(1)
                .username("janesmith")
                .password("newpassword123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        UserDto updatedUserDto = UserDto.builder()
                .userId(1)
                .firstName("Jane")
                .lastName("Smith")
                .email("jane.smith@example.com")
                .phone("0987654321")
                .credentialDto(updatedCredentialDto)
                .build();

        Credential updatedCredential = Credential.builder()
                .credentialId(1)
                .username("janesmith")
                .password("newpassword123")
                .roleBasedAuthority(RoleBasedAuthority.ROLE_USER)
                .isEnabled(true)
                .isAccountNonExpired(true)
                .isAccountNonLocked(true)
                .isCredentialsNonExpired(true)
                .build();

        User updatedUser = User.builder()
                .userId(1)
                .firstName("Jane")
                .lastName("Smith")
                .email("jane.smith@example.com")
                .phone("0987654321")
                .credential(updatedCredential)
                .build();

        when(userRepository.save(any(User.class))).thenReturn(updatedUser);

        // When
        UserDto result = userService.update(updatedUserDto);

        // Then
        assertNotNull(result);
        assertEquals("Jane", result.getFirstName());
        assertEquals("Smith", result.getLastName());
        assertEquals("jane.smith@example.com", result.getEmail());
        assertEquals("janesmith", result.getCredentialDto().getUsername());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Should delete user by id successfully")
    void testDeleteById_Success() {
        // Given
        doNothing().when(userRepository).deleteById(1);

        // When
        assertDoesNotThrow(() -> userService.deleteById(1));

        // Then
        verify(userRepository, times(1)).deleteById(1);
    }
} 