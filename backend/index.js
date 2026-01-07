// ==============================
// Start: Environment Variables
// ==============================

// Load environment variables from a .env file in development only
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}
// Q: Why only in non-production?
// A: In production, env vars are injected by the platform (Railway, Heroku, AWS, etc.).
// Loading .env in production can cause conflicts or expose sensitive info. This ensures
// local development/testing uses .env safely.
// ==============================


// ==============================
// Start: Imports and Setup
// ==============================
const express = require("express");       // Web server framework
const cors = require("cors");             // Cross-Origin Resource Sharing
const bodyParser = require("body-parser"); // Parsing JSON request bodies
const mysql = require("mysql2");          // MySQL database client

const app = express();                    // Initialize Express app
// ==============================


// ==============================
// Start: CORS Configuration
// ==============================
app.use(cors({
  origin: '*',        // Allow all origins (development only)
  credentials: true   // Allow cookies/auth headers cross-origin
}));
// Q: Why '*'?
// A: Simplifies local dev by allowing requests from anywhere. In production, restrict
// to trusted frontend URLs for security.
// ==============================


// ==============================
// Start: Body Parser
// ==============================
app.use(bodyParser.json());
// Q: Why bodyParser.json()?
// A: Express has built-in JSON parsing, but bodyParser is still widely used. Either works;
// consistency matters across a codebase.
// ==============================


// ==============================
// Start: Database Connection (Pool)
// ==============================
const db = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "samer",
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10, // Max simultaneous connections
  queueLimit: 0        // Unlimited queue if connections busy
});
// Q: Why use a pool?
// A: Reuses connections, improves performance, avoids creating new connections per query.
// ==============================


// ==============================
// Start: Test DB Connection
// ==============================
db.getConnection((err, connection) => {
  if (err) {
    console.error("❌ DB connection error:", err.message);
    return; // In production, consider retry or exit
  }
  console.log("✅ MySQL Connected successfully!");
  connection.release(); // Release connection back to pool
});
// Q: Why test upfront?
// A: Detect DB issues during startup, not after first request. Easier debugging.
// ==============================


// ==============================
// Start: API Routes
// ==============================

// GET all destinations
app.get("/api/destinations", (req, res) => {
  db.query("SELECT * FROM destinations", (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(result);
  });
});
// Q: Why callbacks not async/await?
// A: Simpler for demonstration. For production, prefer mysql2/promise with async/await
// for better readability and error handling.


// GET hotels by destination
app.get("/api/hotels/:destination_id", (req, res) => {
  const { destination_id } = req.params;
  const sql = "SELECT id, name, price_per_night FROM hotels WHERE destination_id = ?";
  
  db.query(sql, [destination_id], (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(result);
  });
});
// Q: Why parameterized query?
// A: Prevents SQL injection by safely handling user input.


// POST contact form submissions
app.post("/api/contact", (req, res) => {
  const { name, email, message } = req.body;
  const sql = "INSERT INTO contact_us (name, email, message) VALUES (?, ?, ?)";
  
  db.query(sql, [name, email, message], (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json({ message: "Message sent successfully", id: result.insertId });
  });
});
// Q: Why no validation here?
// A: Input validation should be added in production (required fields, email format, message length).
// Use libraries like Joi or express-validator.


// Health check
app.get("/health", (req, res) => {
  res.json({ status: "OK", message: "Server is running" });
});
// Q: Why health checks?
// A: Useful for monitoring, container orchestration (Kubernetes, Docker) to check app status.


// Database test endpoint
app.get("/api/test-db", (req, res) => {
  db.query("SELECT 1 as test", (err, result) => {
    if (err) {
      return res.status(500).json({ 
        error: err.message,
        connection: "Failed",
        env: process.env.NODE_ENV
      });
    }
    res.json({ 
      connection: "Success", 
      test: result[0],
      env: process.env.NODE_ENV
    });
  });
});
// Q: Why separate test endpoint?
// A: Allows external monitoring to verify DB without restarting app.


// ==============================
// Start: Start Server
// ==============================
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 API available at: http://localhost:${PORT}`);
});
// Q: Why environment variable PORT?
// A: Platforms assign ports dynamically; fallback 5000 is for local dev.
// ==============================


// ==============================
// Start: Production Considerations
// ==============================
// 1. Request logging (morgan/winston)
// 2. Rate limiting
// 3. Helmet for security headers
// 4. Environment-specific configs
// 5. Proper error handling middleware
// 6. Input validation
// 7. Optimized DB pool for production
// 8. API documentation (Swagger/OpenAPI)
// 9. Structured logging
// 10. Graceful shutdown for DB connections
// ==============================
