import express from "express";
import cors from "cors";
import { supabase } from "./config/supabase.js";
import authRoutes from "./modules/auth/auth.routes.js";
import adminRoutes from "./modules/admin/admin.routes.js";
import { testEmailConfig, sendVerificationEmail } from "./modules/email/email.service.js";

const app = express();

// middlewares
// Configure CORS for hybrid mode (development + production)
const allowedOrigins = [
  'http://localhost:8080',
  'http://localhost:5173',
  'http://localhost:3000',
  'capacitor://localhost',
  'ionic://localhost',
  'http://localhost',
  'https://localhost',
  process.env.FRONTEND_URL,
  process.env.RENDER_EXTERNAL_URL
].filter(Boolean);

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    if (process.env.NODE_ENV === 'production') {
      if (allowedOrigins.indexOf(origin) !== -1 || origin.startsWith('capacitor://') || origin.startsWith('ionic://')) {
        callback(null, true);
      } else {
        callback(null, true); // Allow all for now, restrict later
      }
    } else {
      callback(null, true);
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Parse JSON with better error handling
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Global error handler for JSON parsing errors
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({ 
      error: 'Invalid JSON format. Please ensure Content-Type is application/json and body is valid JSON.' 
    });
  }
  next();
});

// ✅ REGISTER ROUTES HERE (NOT inside another route)
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);

// Email test endpoint
app.post("/api/test-email", async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Test configuration
    const configOk = await testEmailConfig();
    if (!configOk) {
      return res.status(500).json({ 
        error: "Email configuration is invalid. Please check your .env settings." 
      });
    }

    // Send test email
    const testOtp = "123456";
    await sendVerificationEmail(email, testOtp, "Test User");

    res.json({ 
      message: "Test email sent successfully! Check your inbox.",
      email: email
    });
  } catch (error) {
    res.status(500).json({ 
      error: error.message,
      details: "Failed to send test email. Check console for details."
    });
  }
});

// root test
app.get("/", (req, res) => {
  res.send("EduKid Backend Running");
});

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({ 
    status: "ok", 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// ✅ test insert route
app.post("/test-insert", async (req, res) => {
  const { fname, lname, email } = req.body;

  const { data, error } = await supabase
    .from("user") // make sure this table exists
    .insert([{
      fname,
      lname,
      email
    }])
    .select();

  if (error) return res.status(400).json({ error: error.message });

  res.json({ inserted: data });
});

export default app;


