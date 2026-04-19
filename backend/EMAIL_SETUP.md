# Email OTP Setup Guide

## Overview
The application now sends real OTP codes via email for:
- Email verification during registration
- Password reset requests

## Email Service Configuration

### Using Gmail (Recommended for Development)

1. **Enable 2-Factor Authentication**
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Enable 2-Step Verification

2. **Generate App Password**
   - Visit [App Passwords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and your device
   - Copy the generated 16-character password

3. **Update .env file**
   ```env
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_SECURE=false
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-16-char-app-password
   EMAIL_FROM=EduKid <noreply@edukid.com>
   ```

### Using Other Email Services

#### Outlook/Hotmail
```env
EMAIL_HOST=smtp-mail.outlook.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@outlook.com
EMAIL_PASS=your-password
```

#### Yahoo Mail
```env
EMAIL_HOST=smtp.mail.yahoo.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@yahoo.com
EMAIL_PASS=your-app-password
```

#### SendGrid (Production Recommended)
```env
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=apikey
EMAIL_PASS=your-sendgrid-api-key
EMAIL_FROM=noreply@yourdomain.com
```

#### Mailgun (Production Alternative)
```env
EMAIL_HOST=smtp.mailgun.org
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-mailgun-smtp-username
EMAIL_PASS=your-mailgun-smtp-password
EMAIL_FROM=noreply@yourdomain.com
```

## Email Templates

### Verification Email
- Subject: "Verify Your Email - EduKid"
- Contains: 6-digit OTP code
- Expiry: 10 minutes
- HTML formatted with branding

### Password Reset Email
- Subject: "Password Reset Code - EduKid"
- Contains: 6-digit reset code
- Expiry: 10 minutes
- Includes security warning

## Testing Email Configuration

Run this test endpoint to verify email setup:
```bash
curl -X POST http://localhost:3000/api/test-email \
  -H "Content-Type: application/json" \
  -d '{"email": "your-test-email@example.com"}'
```

Or use the test function in the backend:
```javascript
import { testEmailConfig } from './src/modules/email/email.service.js';
await testEmailConfig();
```

## Production Recommendations

### 1. Use Professional Email Service
- SendGrid (Free tier: 100 emails/day)
- Mailgun (Free tier: 5,000 emails/month)
- Amazon SES (Very cheap, $0.10 per 1,000 emails)
- Postmark (Free tier: 100 emails/month)

### 2. Domain Configuration
- Set up SPF, DKIM, and DMARC records
- Use a custom domain for professional appearance
- Verify your sending domain

### 3. Email Best Practices
- Monitor bounce and complaint rates
- Implement email rate limiting
- Add unsubscribe options (for marketing emails)
- Keep email content concise and branded

### 4. Security
- Never commit .env file to version control
- Use environment-specific configurations
- Rotate email credentials regularly
- Monitor for unauthorized usage

## Troubleshooting

### Gmail: "Less secure app access"
- Solution: Use App Passwords (requires 2FA)

### Emails going to spam
- Verify SPF/DKIM records
- Use a professional email service
- Avoid spam trigger words in subject/content

### Connection timeout
- Check firewall settings
- Verify SMTP port is not blocked
- Try different port (465 for SSL, 587 for TLS)

### Authentication failed
- Verify credentials are correct
- Check if 2FA is enabled (use app password)
- Ensure account has SMTP enabled

## Development Mode

During development, you can view sent emails in the console logs. The system will log:
- Email recipient
- Message ID
- Any errors encountered

## Rate Limiting (Recommended)

Implement rate limiting to prevent abuse:
```javascript
// Example: Max 3 OTP emails per hour per user
const maxOtpPerHour = 3;
```

## Monitoring

Keep track of:
- Email delivery success rate
- Failed email attempts
- OTP expiration/usage rates
- User verification completion rates
