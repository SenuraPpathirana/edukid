# JWT Testing Guide

## Quick Test Steps

### 1. Verify Backend is Running
```bash
cd backend
npm start
```
Expected output: `Server running on port 3000`

### 2. Test Registration Flow
1. Open Flutter app in browser/emulator
2. Click "Don't have an account? SignUp"
3. Fill in registration form:
   - First Name: Test
   - Last Name: User
   - Email: test@example.com
   - Password: Test1234
   - Gender: Select one
4. Click "CONTINUE"
5. Enter OTP from console/debug output
6. Click "VERIFY"

### 3. Test Login Flow
1. Navigate to login screen
2. Enter credentials:
   - Email: test@example.com
   - Password: Test1234
3. Click "LOGIN"
4. Should navigate to Add Kid Profiles screen
5. JWT token stored automatically

### 4. Verify Token Storage
Check Flutter debug console for:
```
🌐 API Client initialized with baseUrl: http://localhost:3000/api
```

### 5. Test Protected Routes (Future)
Once you create protected routes:
```dart
// This will automatically include the JWT token
final response = await apiClient.get('/protected-endpoint');
```

## Manual API Testing (Postman/cURL)

### Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fname": "John",
    "lname": "Doe",
    "email": "john@example.com",
    "password": "Test1234",
    "gender": "male"
  }'
```

### Verify OTP
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "otp": "123456"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "Test1234"
  }'
```

Expected response:
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "user_id": 1,
    "email": "john@example.com",
    "account_status": "active"
  }
}
```

### Test Protected Route (Example)
```bash
curl http://localhost:3000/api/protected-route \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Common Issues

### Issue: "Email not verified"
**Solution**: Make sure to verify email with OTP before logging in

### Issue: "Invalid email or password"
**Solution**: 
- Check email is correct
- Ensure password meets requirements (min 8 chars, uppercase, lowercase, number)
- Verify user exists in database

### Issue: "Token expired"
**Solution**: Login again to get a new token (default expiry: 15 minutes)

### Issue: Network error
**Solution**:
- Check backend server is running on port 3000
- For web: verify CORS is enabled
- Check firewall/antivirus isn't blocking connections

## Next Steps

1. ✅ JWT implementation complete
2. ⏭️ Add refresh token mechanism (optional)
3. ⏭️ Create protected routes for user data
4. ⏭️ Add logout functionality with token cleanup
5. ⏭️ Implement auto-login (check token on app start)

