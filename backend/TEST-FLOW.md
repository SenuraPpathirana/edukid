# COMPLETE TEST FLOW FOR ADMIN TOKEN SYSTEM

## Test Token: `6108a741cf8852aa`

---

## SCENARIO 1: Test with Existing Pending User (senu1@test.com)

### Step 1: Open Browser Console
1. Open http://localhost:8081/login
2. Press F12 to open DevTools Console

### Step 2: Manually Set Token in SessionStorage
In the browser console, run:
```javascript
sessionStorage.setItem('adminToken', '6108a741cf8852aa');
console.log('✅ Token set:', sessionStorage.getItem('adminToken'));
```

### Step 3: Login as Pending User
- Email: `senu1@test.com`
- Password: (whatever was set during registration)
- Click Login

### Expected Console Output:
```
👤 User logged in with role: pending
🔑 Admin token in sessionStorage: 6108a741...
📝 Creating admin request...
```

### Expected Backend Logs (in terminal):
```
📝 Create admin request - User ID: 6708f060-e174-4a3c-a334-6926cd0a22d7
🔑 Token received: 6108a741...
🔍 Verifying token and creating request for user: 6708f060-e174-4a3c-a334-6926cd0a22d7
📋 Found active invites: 4
✅ Token matched invite: 85d52939-90dd-4e25-85e5-771353b45b90
📊 Token usage: 0 / 1
✅ Admin request created: [request_id]
✅ Token usage updated: 0 → 1
```

### Step 4: Verify Database
Run in backend folder:
```bash
node check-database-state.js
```

Should show:
- admin_invites: used_count = 1
- admin_requests: 1 new record
- User: role = pending

---

## SCENARIO 2: Complete Flow from Token Verification UI

### Step 1: Go to Token Verification
http://localhost:8081/admin-token

### Step 2: Enter Token
Token: `6108a741cf8852aa`
Click "Verify Token"

### Step 3A: For New User - Signup
1. Complete admin signup form
2. Verify email with OTP
3. Login with new credentials
4. Should create request automatically

### Step 3B: For Existing Admin - Login
1. Returns to login page with "Admin Login" title
2. Login with existing admin credentials
3. Token is just cleared (no request created)

---

## DEBUGGING CHECKLIST

If admin_requests not created:

✅ Check browser console for logs
✅ Check backend terminal for logs
✅ Verify token is in sessionStorage: `sessionStorage.getItem('adminToken')`
✅ Verify user role: Check response.user.role in login response
✅ Check network tab for POST /api/admin/create-request call
✅ Verify JWT token is sent in Authorization header

---

## QUICK FIX: Manual Token Test

1. Open browser console on login page
2. Run:
```javascript
sessionStorage.setItem('adminToken', '6108a741cf8852aa');
```
3. Login as pending user (senu1@test.com)
4. Watch console and backend logs
