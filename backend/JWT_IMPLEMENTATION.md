# JWT Authentication Implementation

## Overview
This project uses JSON Web Tokens (JWT) for secure user authentication. When a user logs in successfully, they receive an access token that must be included in subsequent API requests.

## Backend Implementation

### Files Created/Modified:
1. **`backend/src/utils/jwt.js`** - JWT signing and verification utilities
2. **`backend/src/middleware/auth.js`** - Authentication middleware
3. **`backend/src/modules/auth/auth.routes.js`** - Login endpoint with JWT generation

### Environment Variables
Add to `backend/.env`:
```env
JWT_SECRET=change_this_to_a_long_random_secret_123456789
JWT_EXPIRES_IN=15m
```

⚠️ **IMPORTANT**: Change `JWT_SECRET` to a long, random string in production!

### Login Endpoint
**POST** `/auth/login`

Request:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response (200):
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "user_id": 1,
    "email": "user@example.com",
    "account_status": "active"
  }
}
```

Error Responses:
- `400` - Invalid email or missing password
- `401` - Invalid credentials
- `403` - Email not verified
- `500` - Server error

### JWT Payload Structure
```javascript
{
  user_id: 123,
  role: "parent",
  account_status: "active",
  iat: 1234567890,  // issued at
  exp: 1234568790   // expires at
}
```

## Frontend Implementation

### Files Created/Modified:
1. **`lib/core/utils/token_storage.dart`** - JWT token storage helper
2. **`lib/core/network/api_client.dart`** - Automatic token injection in requests
3. **`lib/features/auth/presentation/screens/ui_3113_login.dart`** - Login screen with token storage

### Usage

#### 1. Login and Store Token
```dart
final response = await _dataSource.login(
  email: email,
  password: password,
);

final token = response['accessToken'];
await TokenStorage.saveToken(token);
```

#### 2. Check if User is Logged In
```dart
final isLoggedIn = await TokenStorage.isLoggedIn();
if (isLoggedIn) {
  // Navigate to home screen
}
```

#### 3. Logout (Clear Tokens)
```dart
await TokenStorage.clearTokens();
// Navigate to login screen
```

#### 4. Token Auto-Injection
The `ApiClient` automatically adds the JWT token to all requests:
```dart
// No need to manually add Authorization header
final response = await apiClient.get('/protected-route');
```

## Protected Routes (Backend)

### Using Authentication Middleware

```javascript
import { authenticate, requireRole } from '../middleware/auth.js';

// Protected route - requires valid token
router.get('/profile', authenticate, (req, res) => {
  // req.user contains decoded JWT payload
  res.json({ user: req.user });
});

// Admin-only route
router.delete('/user/:id', authenticate, requireRole('admin'), (req, res) => {
  // Only users with role: "admin" can access
});

// Optional auth - works with or without token
import { optionalAuth } from '../middleware/auth.js';
router.get('/content', optionalAuth, (req, res) => {
  // req.user is set if token is valid, null otherwise
});
```

## Security Best Practices

### Backend:
1. ✅ Use strong, random JWT_SECRET (min 32 characters)
2. ✅ Set appropriate token expiration (15m for access tokens)
3. ✅ Hash passwords with bcrypt before storing
4. ✅ Validate all inputs before processing
5. ✅ Use HTTPS in production
6. ⚠️ Consider implementing refresh tokens for longer sessions

### Frontend:
1. ✅ Store tokens in SharedPreferences (not localStorage on web)
2. ✅ Clear tokens on logout
3. ✅ Handle token expiration gracefully
4. ✅ Never expose tokens in URLs or logs
5. ⚠️ Implement token refresh mechanism

## Token Expiration Handling

### Current Behavior:
- Access tokens expire after 15 minutes (configurable)
- User must login again when token expires

### Recommended Enhancement:
Implement refresh token flow:
1. Issue both access token (short-lived) and refresh token (long-lived) on login
2. Use refresh token to get new access token when it expires
3. Only require re-login when refresh token expires

## Testing

### Test Login Flow:
1. Start backend: `cd backend && npm start`
2. Register a new user
3. Verify email with OTP
4. Login with credentials
5. Token should be automatically stored and used in subsequent requests

### Verify Token Storage:
```dart
final token = await TokenStorage.getToken();
print('Stored token: $token');
```

### Test Protected Route:
```bash
# Without token (should fail)
curl http://localhost:3000/protected

# With token (should succeed)
curl http://localhost:3000/protected \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Troubleshooting

### "Invalid token" error:
- Check JWT_SECRET is same in .env file
- Verify token hasn't expired
- Ensure Authorization header format is "Bearer TOKEN"

### "No token provided" error:
- User needs to login first
- Check TokenStorage.getToken() returns valid token
- Verify ApiClient interceptor is adding token to headers

### Token not persisting:
- Check SharedPreferences is working
- Verify TokenStorage.saveToken() is called after login
- Restart app to test persistence

