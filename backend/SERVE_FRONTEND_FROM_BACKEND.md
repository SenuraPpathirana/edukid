# Serve Frontend from Backend (Alternative Deployment)

If you want to deploy both frontend and backend as a single service on Render:

## Step 1: Build Frontend

```bash
# In root directory
npm run build
```

This creates a `dist` folder with your production build.

## Step 2: Update Backend to Serve Static Files

Add to `backend/src/app.js` (after all API routes):

```javascript
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Serve static files from React app (only in production)
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../../dist')));
  
  // All non-API routes return the React app
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../../dist/index.html'));
  });
}
```

## Step 3: Update Render Configuration

**Root Directory**: Leave empty (deploy whole repo)

**Build Command**:
```
npm install && cd backend && npm install && cd .. && npm run build
```

**Start Command**:
```
cd backend && npm start
```

## Step 4: Update Environment Variables

Set `VITE_API_URL` to use relative path:
```
VITE_API_URL=/api
```

## Pros & Cons

**Pros:**
- Single deployment
- No CORS issues
- Simpler setup

**Cons:**
- Backend redeploys require frontend rebuild
- Less flexible scaling
- Larger deployment size

## Recommendation

For production, deploy separately:
- **Backend**: Render
- **Frontend**: Vercel/Netlify (better CDN, faster builds)
