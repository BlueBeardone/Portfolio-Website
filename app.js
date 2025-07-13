const express = require('express');
const path = require('path');
const app = express();

app.engine('ejs', require('ejs').renderFile);

// Get absolute path to views directory
const viewsPath = path.join(__dirname, 'views');

// Configure EJS with correct paths
app.set('view engine', 'ejs');
app.set('views', viewsPath);

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));



// Main route
app.get('/', (req, res) => {
    res.render('index'); // Renders views/index.ejs
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
    console.log(`Views path: ${viewsPath}`); // Verify path in console
});