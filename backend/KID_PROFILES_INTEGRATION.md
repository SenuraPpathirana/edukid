# Kid Profiles Backend Integration

This document explains the backend integration for the Kid Profiles feature.

## Overview

The Kid Profiles feature allows authenticated parents to create, view, update, and delete profiles for their children. Each profile includes:
- First Name
- Last Name  
- Grade (1-5 or custom)
- Age (1-18)
- Language (optional, defaults to English)
- Premium Status (Yes/No)

## ✅ Complete Integration Status

### Backend
- ✅ API endpoints created at `/api/kids`
- ✅ Routes registered in `backend/src/app.js`
- ✅ Authentication middleware applied
- ✅ Connected to `kid_profile` table in database

### Frontend
- ✅ Kids service created at `src/services/kids.service.ts`
- ✅ AddKidProfile page with form validation
- ✅ KidProfiles landing page fetches real data
- ✅ Loading, error, and empty states implemented
- ✅ Auto-refresh when adding new profiles
- ✅ Toast notifications for user feedback

## Setup Instructions

### Database Schema

The integration uses the existing `kid_profile` table:

```sql
CREATE TABLE public.kid_profile (
  kid_id VARCHAR PRIMARY KEY,
  fname VARCHAR NOT NULL,
  lname VARCHAR NOT NULL,
  age INTEGER NOT NULL,
  grade VARCHAR,
  language VARCHAR,
  created_date DATE NOT NULL,
  premium_status VARCHAR CHECK (premium_status IN ('Yes', 'No')),
  user_id VARCHAR NOT NULL REFERENCES public.user(user_id),
  report_id VARCHAR REFERENCES public.report(report_id)
);
```

**Note:** No SQL migration needed - uses existing table structure!

## API Endpoints

### Base URL
All endpoints are prefixed with `/api/kids`

### Authentication
All endpoints require authentication via Bearer token in the Authorization header.

### Endpoints

#### 1. GET /api/kids
Get all kid profiles for the authenticated user

**Response:**
```json
{
  "kids": [
    {
      "child_id": "uuid",
      "parent_id": "uuid",
      "first_name": "John",
      "last_name": "Doe",
      "grade": 3,
      "age": 8,
      "gender": "male",
      "created_at": "2026-02-09T...",
      "updated_at": "2026-02-09T..."
    }
  ]
}
```

#### 2. POST /api/kids
Create a new kid profile

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "grade": "3",
  "age": "8",
  "gender": "male"
}
```

**Response:**
```json
{
  "message": "Kid profile created successfully",
  "kid": {
    "child_id": "uuid",
    "parent_id": "uuid",
    "first_name": "John",
    "last_name": "Doe",
    "grade": 3,
    "age": 8,
    "gender": "male",
    "created_at": "2026-02-09T...",
    "updated_at": "2026-02-09T..."
  }
}
```

#### 3. PUT /api/kids/:id
Update an existing kid profile

**Request Body:** (all fields optional)
```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "grade": "4",
  "age": "9",
  "gender": "female"
}
```

**Response:**
```json
{
  "message": "Kid profile updated successfully",
  "kid": { ... }
}
```

#### 4. DELETE /api/kids/:id
Delete a kid profile

**Response:**
```json
{
  "message": "Kid profile deleted successfully"
}
```

## Database Schema

```sql
child_profiles (
  child_id UUID PRIMARY KEY,
  parent_id UUID REFERENCES user(user_id),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  grade INTEGER CHECK (1-5),
  age INTEGER CHECK (1-18),
  gender VARCHAR(10) CHECK ('male', 'female'),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

## Security

- **Authentication**: All endpoints require a valid JWT token
- **Authorization**: Users can only access their own children's profiles
- **Row Level Security (RLS)**: Database-level policies enforce parent_id matching
- **Validation**: Server-side validation for all inputs
- **Constraints**: Database constraints ensure data integrity

## Testing

### Using the UI (Complete Flow)

1. **Start Backend**
   ```bash
   cd backend
   npm run dev
   ```

2. **Start Frontend**
   ```bash
   npm run dev
   ```

3. **Test the Flow**
   - Login as a parent user
   - Navigate to `/kids` page
   - See your existing kid profiles (or empty state)
   - Click the "+" button (or "Add Kid Profile" button)
   - Fill out the form:
     - First Name: "John"
     - Last Name: "Doe"  
     - Grade: "3"
     - Age: "8"
     - Gender: (Optional - not stored)
   - Click "ADD PROFILE"
   - See success toast notification
   - Auto-navigate back to `/kids` page
   - See the new profile in the list
   - Profile displays: name, age, grade, premium status

### Testing Data Flow

```
User fills form → AddKidProfile.tsx
                      ↓
                 kidsService.createKid()
                      ↓
                 POST /api/kids
                      ↓
             kids.routes.js (Backend)
                      ↓
          Validates & inserts into kid_profile table
                      ↓
             Returns created kid data
                      ↓
         Success toast & navigate to /kids
                      ↓
              KidProfiles.tsx loads
                      ↓
           kidsService.getKids()
                      ↓
              GET /api/kids
                      ↓
         Fetches all kids for user
                      ↓
    Displays in KidProfileCard components
```

### Using curl
```bash
# Get access token first by logging in
TOKEN="your_access_token"

# Create kid profile
curl -X POST http://localhost:3000/api/kids \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "grade": "3",
    "age": "8",
    "gender": "male"
  }'

# Get all kids
curl -X GET http://localhost:3000/api/kids \
  -H "Authorization: Bearer $TOKEN"
```

## Error Handling

The API returns appropriate HTTP status codes:
- `200 OK` - Successful GET/PUT/DELETE
- `201 Created` - Successful POST
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Missing/invalid token
- `404 Not Found` - Kid profile not found
- `500 Internal Server Error` - Server errors

Error response format:
```json
{
  "error": "Error message here"
}
```

## Next Steps

To integrate with the KidProfiles page to display the created profiles:
1. Update `src/pages/KidProfiles.tsx` to fetch from API
2. Replace mock data with real data from `kidsService.getKids()`
3. Add loading states and error handling

## Files Modified/Created

### Backend
- ✅ `backend/src/modules/kids/kids.routes.js` - Kids API routes
- ✅ `backend/src/app.js` - Registered kids routes
- ✅ `backend/create_child_profiles_table.sql` - Database schema

### Frontend
- ✅ `src/services/kids.service.ts` - Kids API service
- ✅ `src/pages/AddKidProfile.tsx` - Add kid profile form
- ✅ `src/App.tsx` - Added route for `/add-kid`
