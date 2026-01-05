// Load environment variables
// Q: Why are we conditionally loading dotenv only in non-production environments?
// A: In production, environment variables are typically injected by the platform (Railway, Heroku, AWS, etc.).
// Loading dotenv in production could cause conflicts or security issues. This pattern ensures we only
// use the local .env file during development and testing.
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mysql = require("mysql2");

const app = express();

// CORS configuration
// Q: Why use origin: '*' in CORS configuration?
// A: This is a development configuration that allows any origin to access the API.
// In production, this should be restricted to specific trusted domains (e.g., ['https://yourfrontend.com'])
// for security reasons. credentials: true allows cookies/auth headers to be sent cross-origin.
app.use(cors({
  origin: '*', // Allow all for now - TODO: Restrict in production
  credentials: true
}));

// Q: Why use bodyParser.json() instead of express.json()?
// A: bodyParser was the original middleware for parsing JSON bodies. While express now has built-in
// JSON parsing, bodyParser.json() is still widely used and offers the same functionality. Both are
// acceptable, but consistency across the codebase is key.
app.use(bodyParser.json());

// Database connection with environment variables
// Q: Why use a connection pool instead of a single connection?
// A: Connection pooling improves performance by reusing connections, reducing the overhead of
// establishing new connections for each query. The pool manages multiple connections (connectionLimit: 10)
// and queues requests when all connections are busy (queueLimit: 0 means unlimited queue).
const db = mysql.createPool({
  host: process.env.DB_HOST || "localhost",  // Environment variable with fallback
  user: process.env.DB_USER || "root",       // Environment variable with fallback
  password: process.env.DB_PASSWORD || "",   // Environment variable with fallback
  database: process.env.DB_NAME || "samer",  // Environment variable with fallback
  port: process.env.DB_PORT || 3306,         // Standard MySQL port with environment variable fallback
  waitForConnections: true,                  // Pool will wait for available connection if all are busy
  connectionLimit: 10,                       // Maximum number of connections in pool
  queueLimit: 0                              // Unlimited queue for connection requests
});

// Test database connection
// Q: Why test the connection separately instead of relying on query errors?
// A: Proactive connection testing helps identify database connectivity issues during startup
// rather than during the first user request. This improves debugging and ensures the application
// starts only when dependencies are available.
db.getConnection((err, connection) => {
  if (err) {
    console.error("❌ DB connection error:", err.message);
    // In production, consider exiting the process here or implementing a retry mechanism
    return;
  }
  console.log("✅ MySQL Connected successfully!");
  connection.release(); // Release the test connection back to the pool
});

// API Routes

// GET /api/destinations - Retrieve all destinations
// Q: Why not use async/await or Promises instead of callbacks?
// A: While async/await with mysql2/promise is preferable for modern code, the callback pattern
// is shown here for simplicity. In production, consider using the promise-based interface
// for better error handling and code readability with async/await.
app.get("/api/destinations", (req, res) => {
  db.query("SELECT * FROM destinations", (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(result);
  });
});

// GET /api/hotels/:destination_id - Retrieve hotels for a specific destination
// Q: Why use parameterized queries instead of string concatenation?
// A: Parameterized queries prevent SQL injection attacks by separating SQL code from data.
// The database driver properly escapes and handles the parameters, making this approach secure.
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

// POST /api/contact - Handle contact form submissions
// Q: Why not validate the input data before database insertion?
// A: Input validation is missing here - in production, you should validate:
// 1. Required fields are present
// 2. Email format is valid
// 3. Message length is reasonable
// Consider using a validation library like Joi or express-validator.
app.post("/api/contact", (req, res) => {
  const { name, email, message } = req.body;
  const sql = "INSERT INTO contact_us (name, email, message) VALUES (?, ?, ?)";
  
  db.query(sql, [name, email, message], (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    // Return the inserted ID for reference - useful for client-side tracking
    res.json({ message: "Message sent successfully", id: result.insertId });
  });
});

// Health check endpoint
// Q: Why include a health check endpoint?
// A: Health checks are essential for containerized deployments (Docker, Kubernetes) and
// monitoring systems. They allow load balancers and orchestration tools to verify if the
// application is running properly before routing traffic to it.
app.get("/health", (req, res) => {
  res.json({ status: "OK", message: "Server is running" });
});

// Database test endpoint
// Q: Why create a separate test endpoint when we already test on startup?
// A: This endpoint allows external monitoring systems to verify database connectivity
// without restarting the application. It's useful for automated monitoring and alerting.
app.get("/api/test-db", (req, res) => {
  db.query("SELECT 1 as test", (err, result) => {
    if (err) {
      return res.status(500).json({ 
        error: err.message,
        connection: "Failed",
        env: process.env.NODE_ENV  // Useful for debugging environment-specific issues
      });
    }
    res.json({ 
      connection: "Success", 
      test: result[0],
      env: process.env.NODE_ENV
    });
  });
});

// Start server
// Q: Why use environment variable for PORT with a fallback?
// A: Deployment platforms (Railway, Heroku, etc.) dynamically assign ports. Using process.env.PORT
// ensures compatibility with these platforms, while the fallback (5000) works for local development.
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 API available at: http://localhost:${PORT}`);
  // TODO: In production, consider adding process monitoring and graceful shutdown handlers
});

// Production Considerations (Not implemented but important):
// 1. Add request logging middleware (morgan/winston)
// 2. Implement rate limiting
// 3. Add helmet.js for security headers
// 4. Use environment-specific configuration files
// 5. Implement proper error handling middleware
// 6. Add request validation
// 7. Use connection pooling configuration optimized for production workload
// 8. Add API documentation (Swagger/OpenAPI)
// 9. Implement structured logging for better monitoring
// 10. Add graceful shutdown handling for database connections