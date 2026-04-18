# Admin Login with Token - Fix Summary

## Issue
When a user logged in as admin with a token, the system was not:
1. Setting the user role to 'pending' status properly in the JWT
2. Deactivating the token exactly like admin registration does

## Root Causes

### 1. Hardcoded Role in Login JWT
**File:** `backend/src/modules/auth/auth.routes.js` (Line 346)

**Problem:** The login endpoint was hardcoding the role as "parent" in the JWT token instead of using the actual user role from the database.

```javascript
// BEFORE (Incorrect)
const accessToken = signAccessToken({
  user_id: parentRow.user_id,
  role: "parent", // ❌ Hardcoded, ignores database role
  account_status: parentRow.account_status,
});
```

**Solution:** Use the actual role from the database
```javascript
// AFTER (Correct)
const accessToken = signAccessToken({
  user_id: parentRow.user_id,
  role: parentRow.role || "user", // ✅ Uses actual role from DB
  account_status: parentRow.account_status,
});
```

### 2. Inconsistent Token Deactivation
**File:** `backend/src/modules/admin/admin.service.js` (Lines 184-197)

**Problem:** The `verifyAndCreateRequest` function was incrementing `used_count` and only deactivating when max uses reached, instead of immediately setting `used_count = 1` and `is_active = false` like the registration flow.

```javascript
// BEFORE (Incorrect - incremental approach)
const newCount = matchedInvite.used_count + 1;
const shouldDeactivate = newCount >= matchedInvite.max_uses;

const { error: updateError } = await supabase
  .from('admin_invites')
  .update({ 
    used_count: newCount,
    is_active: !shouldDeactivate // ❌ Only deactivates when max reached
  })
  .eq('invite_id', matchedInvite.invite_id);
```

**Solution:** Match the registration flow exactly
```javascript
// AFTER (Correct - immediate deactivation)
const { error: updateError } = await supabase
  .from('admin_invites')
  .update({ 
    used_count: 1,
    is_active: false // ✅ Immediately deactivate like registration
  })
  .eq('invite_id', matchedInvite.invite_id);
```

## Flow Comparison

### Registration with Token (BEFORE FIX - Working)
1. User registers with `role: 'pending'` ✅
2. Creates admin request ✅
3. Sets `used_count = 1`, `is_active = false` ✅
4. User gets JWT with `role: 'pending'` ✅

### Login with Token (BEFORE FIX - Broken)
1. User already exists with `role: 'user'` 
2. Calls `/api/admin/create-request`
3. Updates user `role: 'pending'` ✅
4. Creates admin request ✅
5. Increments `used_count`, conditionally deactivates ❌
6. User gets JWT with hardcoded `role: 'parent'` ❌

### Login with Token (AFTER FIX - Working)
1. User already exists with `role: 'user'`
2. Calls `/api/admin/create-request`
3. Updates user `role: 'pending'` ✅
4. Creates admin request ✅
5. Sets `used_count = 1`, `is_active = false` ✅
6. User gets JWT with actual `role: 'pending'` from DB ✅

## Files Changed
1. `backend/src/modules/auth/auth.routes.js` - Fixed login JWT to use actual user role
2. `backend/src/modules/admin/admin.service.js` - Fixed token deactivation to match registration flow

## Testing Steps
1. Create a new admin token
2. Register a normal user account (without token)
3. Login with that account
4. Use the admin token to request admin access
5. Verify:
   - User role is set to 'pending' ✅
   - Token is deactivated (used_count = 1, is_active = false) ✅
   - JWT contains role: 'pending' ✅
   - Admin dashboard shows the pending request ✅

## Date Fixed
January 27, 2026
