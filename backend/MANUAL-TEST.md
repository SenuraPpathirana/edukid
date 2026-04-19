# MANUAL TEST GUIDE - Verify Admin Token Updates Database

## Current Database State
- ✅ 5 Active tokens, all with used_count = 0
- ❌ 0 Admin requests
- ✅ Pending user ready: senu1@test.com (role=pending)

## Test Token
```
6108a741cf8852aa
```

---

## STEP-BY-STEP TEST

### Step 1: Open Application
1. Open browser: http://localhost:8081/login
2. Press `F12` to open Developer Console

### Step 2: Manually Set Token (Simulate Token Verification Flow)
In the Console tab, paste and run:
```javascript
sessionStorage.setItem('adminToken', '6108a741cf8852aa');
console.log('✅ Token set:', sessionStorage.getItem('adminToken'));
```

### Step 3: Login as Pending User
- Email: `senu1@test.com`
- Password: `Test123!` (or whatever you set)
- Click "Login"

### Step 4: Watch Console Output
You should see in browser console:
```
👤 User logged in with role: pending
🔑 Admin token in sessionStorage: 6108a741...
📝 Creating admin request...
✅ Admin request created successfully
```

### Step 5: Watch Backend Terminal
You should see in backend terminal:
```
📝 Create admin request - User ID: 6708f060-e174-4a3c-a334-6926cd0a22d7
🔑 Token received: 6108a741...
🔍 Verifying token and creating request for user: 6708f060-e174-4a3c-a334-6926cd0a22d7
📋 Found active invites: 5
✅ Token matched invite: 85d52939-90dd-4e25-85e5-771353b45b90
📊 Token usage: 0 / 1
✅ Admin request created: [some-uuid]
✅ Token usage updated: 0 → 1
```

### Step 6: Verify Database Updates
Run in backend folder:
```bash
node check-database-state.js
```

**Expected Results:**
- ✅ One token should have `used_count: 1` (incremented from 0)
- ✅ admin_requests table should have 1 new record
- ✅ User role should still be `pending` (awaiting admin approval)

---

## TROUBLESHOOTING

### If token is not found in sessionStorage:
1. Make sure you set it in Step 2
2. Verify: `sessionStorage.getItem('adminToken')`

### If "Creating admin request..." doesn't appear:
- Check user role in login response
- Must be `pending`, not `admin` or `user`

### If backend logs don't appear:
- Verify backend is running on port 3000
- Check terminal where you ran `npm run dev`

### If database doesn't update:
- Check backend logs for errors
- Verify the token matches one in admin_invites table
- Make sure invite is active and not expired

---

## COMPLETE FLOW (Including Token Verification UI)

### Alternative: Test Complete Flow from Token Entry

1. **Generate Fresh Token** (optional):
   ```bash
   cd backend
   node generate-test-token.js
   ```

2. **Go to Token Verification**:
   - Visit: http://localhost:8081/admin-token
   - Enter token: `6108a741cf8852aa`
   - Click "Verify Token"
   - Choose "New Admin Signup" or "Existing Admin Login"

3. **For New Signup**:
   - Complete admin signup form (use new email)
   - Verify email with OTP
   - Login with new credentials
   - Watch logs - should create request automatically

4. **For Existing Login** (with pending user):
   - Login as: senu1@test.com
   - Watch logs - should create request automatically

5. **Verify Database**:
   ```bash
   node check-database-state.js
   ```

---

## IMPORTANT NOTES

⚠️  The `used_count` is incremented when:
- POST /api/admin/create-request is called
- This happens AFTER login for role='pending' users
- NOT during token verification (that's just validation)

✅ This ensures tokens are only "used" when a request is actually created
