# Render Deployment Guide for Edu-Kid Backend

## Prerequisites
- GitHub account
- Render account (free tier available at https://render.com)
- Backend code pushed to a GitHub repository

## Step 1: Push Backend to GitHub

1. Initialize git in backend folder (if not already done):
```bash
cd backend
git init
git add .
git commit -m "Initial backend commit"
```

2. Create a new GitHub repository and push:
```bash
git remote add origin https://github.com/YOUR_USERNAME/edukid-backend.git
git branch -M main
git push -u origin main
```

## Step 2: Deploy to Render

### 2.1 Create Web Service

1. Go to https://render.com and sign in
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure the service:
   - **Name**: `edukid-backend` (or your preferred name)
   - **Environment**: `Node`
   - **Region**: Choose closest to your users
   - **Branch**: `main`
   - **Root Directory**: Leave empty if deploying from backend folder, or set to `backend` if deploying whole repo
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free (or paid if needed)

### 2.2 Configure Environment Variables

In Render dashboard, go to **Environment** tab and add these variables:

```
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://your-frontend-url.vercel.app
SUPABASE_URL=https://tdldajwqcbfyuugvtlnb.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkbGRhandxY2JmeXV1Z3Z0bG5iIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTAwNDg1MSwiZXhwIjoyMDg0NTgwODUxfQ.Yt_YCCS-7_BX4cLizpg0UeC28mwqu2NNgVWPkJCmolM
JWT_SECRET=change_this_to_a_long_random_secret_123456789
JWT_EXPIRES_IN=15m
OTP_EXPIRES_MIN=10
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=465
EMAIL_SECURE=true
EMAIL_USER=senurappathirana@gmail.com
EMAIL_PASS=uiqjzkzqkdcszova
EMAIL_FROM=EduKid <senurappathirana@gmail.com>
```

### 2.3 Deploy

1. Click **"Create Web Service"**
2. Render will automatically build and deploy
3. Wait for deployment to complete (2-5 minutes)
4. Your backend URL will be: `https://edukid-backend.onrender.com`

## Step 3: Update Frontend Configuration

1. Copy your Render backend URL
2. Update `.env.production`:
```
VITE_API_URL=https://edukid-backend.onrender.com/api
```

3. Rebuild your frontend:
```bash
npm run build
```

## Step 4: Test the Connection

Test your deployed backend:
```bash
curl https://edukid-backend.onrender.com/api/auth/health
```

## Step 5: Deploy Frontend

### Option A: Vercel (Recommended for React)
1. Go to https://vercel.com
2. Import your frontend repository
3. Set environment variable: `VITE_API_URL=https://edukid-backend.onrender.com/api`
4. Deploy

### Option B: Netlify
1. Go to https://netlify.com
2. Drag & drop your `dist` folder or connect GitHub
3. Set environment variable: `VITE_API_URL=https://edukid-backend.onrender.com/api`
4. Deploy

### Option C: Serve from Render Backend
See SERVE_FRONTEND_FROM_BACKEND.md for instructions

## Step 6: Update CORS in Backend

After deploying frontend, update the FRONTEND_URL in Render:
```
FRONTEND_URL=https://your-app.vercel.app
```

Render will automatically redeploy with the new settings.

## Important Notes

### Free Tier Limitations
- **Render Free Tier**: Service spins down after 15 minutes of inactivity
- **Cold Start**: First request after sleep takes 30-60 seconds
- **Upgrade to Paid**: $7/month for always-on service

### Security Recommendations
1. **Change JWT_SECRET**: Use a strong random secret for production
   ```bash
   # Generate a secure secret
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

2. **Update CORS**: Set specific frontend URL instead of wildcard
3. **Use HTTPS**: Render provides free SSL certificates
4. **Environment Variables**: Never commit `.env` files to GitHub

### Troubleshooting

**Build Fails:**
- Check logs in Render dashboard
- Ensure `package.json` has correct scripts
- Verify Node version compatibility

**CORS Errors:**
- Update `FRONTEND_URL` in Render environment variables
- Check backend CORS configuration

**Database Connection Fails:**
- Verify Supabase credentials
- Check Supabase URL is accessible from Render

**Email Not Working:**
- Verify Gmail app password
- Check EMAIL_* environment variables
- Test with `/api/test-email` endpoint

## Monitoring

- **Logs**: View in Render dashboard under "Logs" tab
- **Metrics**: Check performance in "Metrics" tab
- **Alerts**: Set up email alerts for failures

## Continuous Deployment

Once set up, any push to your GitHub main branch will automatically trigger a new deployment on Render.

## Cost Estimate

- **Free Tier**: $0/month (with sleep)
- **Starter**: $7/month (always-on, 512MB RAM)
- **Standard**: $25/month (1GB RAM)

## Next Steps

1. Set up a custom domain (optional)
2. Configure automatic backups
3. Set up monitoring/logging
4. Add CI/CD tests before deployment
