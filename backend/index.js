const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mysql = require("mysql2");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "samer",
});

db.connect((err) => {
  if (err) {
    console.error("DB connection error:", err);
    return;
  }
  console.log("MySQL Connected...");
});

// GET ALL COUNTRIES
app.get("/api/destinations", (req, res) => {
  db.query("SELECT * FROM destinations", (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result); //array of countries
  });
});


// GET HOTELS FOR A COUNTRY (DESTINATION)
app.get("/api/hotels/:destination_id", (req, res) => {
  const { destination_id } = req.params;

  const sql = `
    SELECT id, name, price_per_night
    FROM hotels
    WHERE destination_id = ?
  `;

  db.query(sql, [destination_id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result); // array of hotels
  });
});

// SEND MESSAGE FROM CONTACT FORM
app.post("/api/contact", (req, res) => {
  const { name, email, message } = req.body;

  const sql =
    "INSERT INTO contact_us (name, email, message) VALUES (?, ?, ?)";

  db.query(sql, [name, email, message], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ message: "Message sent successfully", result });
  });
});


app.listen(5000, () => {
  console.log("Server running on port 5000");
});
