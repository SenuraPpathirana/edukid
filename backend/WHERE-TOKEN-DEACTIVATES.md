## WHERE TOKEN DEACTIVATION HAPPENS

### File Location:
`backend/src/modules/admin/admin.service.js`

### Function:
`verifyAndCreateRequest(token, userId)`

### When It Executes:
When user logs in with `role='pending'` and has a token in sessionStorage, the frontend calls:
```
POST /api/admin/create-request
```

### What Happens (Lines 155-175):

```javascript
// 1. Create admin_requests record
const request = await supabase
  .from('admin_requests')
  .insert({
    user_id: userId,
    invite_id: matchedInvite.invite_id,
    is_approved: false,
  })
  .select()
  .single();

// 2. Update admin_invites table
const newCount = matchedInvite.used_count + 1;
const shouldDeactivate = newCount >= matchedInvite.max_uses;

await supabase
  .from('admin_invites')
  .update({ 
    used_count: newCount,          // ✅ Set to 1 (from 0)
    is_active: !shouldDeactivate   // ✅ Set to false (when max uses reached)
  })
  .eq('invite_id', matchedInvite.invite_id);
```

### Flow Diagram:

```
User enters token in UI
        ↓
Token stored in sessionStorage (AdminTokenVerification.tsx line 29)
        ↓
User signs up with role='pending'
        ↓
User logs in
        ↓
Login detects: role='pending' AND token exists (Login.tsx line 52-55)
        ↓
Calls: POST /api/admin/create-request (Login.tsx line 59)
        ↓
Backend: admin.controller.js → createAdminRequest (line 68)
        ↓
Backend: admin.service.js → verifyAndCreateRequest (line 89)
        ↓
Updates admin_invites table (line 162-167):
  - used_count: 0 → 1
  - is_active: true → false (if max_uses reached)
```

### Expected Database Result:

**Before:**
```
invite_id: 3b4b00ae-77c8-4611-88e4-b2460589e391
is_active: true
max_uses: 1
used_count: 0
```

**After:**
```
invite_id: 3b4b00ae-77c8-4611-88e4-b2460589e391
is_active: false  ← Changed!
max_uses: 1
used_count: 1     ← Changed!
```

### To Test:

1. Open http://localhost:8081/login
2. Open browser console (F12)
3. Run: `sessionStorage.setItem('adminToken', '6108a741cf8852aa');`
4. Login as: `senu1@test.com`
5. Check backend logs for:
   ```
   ✅ Token usage updated: 0 → 1
   ✅ Token is_active set to: false
   ```
6. Verify database:
   ```bash
   node check-database-state.js
   ```
