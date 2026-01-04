// Load environment variables
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mysql = require("mysql2");

const app = express();

// CORS configuration
app.use(cors({
  origin: '*', // Allow all for now
  credentials: true
}));

app.use(bodyParser.json());

// Database connection with environment variables
const db = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "samer",
  port: process.env.DB_PORT || 3306,  // ← CHANGED BACK TO 3306 (Railway uses 3306)
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
db.getConnection((err, connection) => {
  if (err) {
    console.error("❌ DB connection error:", err.message);
    return;
  }
  console.log("✅ MySQL Connected successfully!");
  connection.release();
});

// API Routes
app.get("/api/destinations", (req, res) => {
  db.query("SELECT * FROM destinations", (err, result) => {
    if (err) {
      console.error("Database error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(result);
  });
});

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

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "OK", message: "Server is running" });
});

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

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 API available at: http://localhost:${PORT}`);
});