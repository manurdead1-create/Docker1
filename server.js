const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = 3000;

const uploadPath = path.join(__dirname, "files");

if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath);
}

const storage = multer.diskStorage({
    destination: uploadPath,
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: Infinity }
});

app.post("/upload", upload.single("file"), (req, res) => {

    // Delete old zip files
    fs.readdirSync(uploadPath).forEach(file => {
        if (file.endsWith(".zip") && file !== req.file.filename) {
            fs.unlinkSync(path.join(uploadPath, file));
        }
    });

    res.json({
        success: true,
        file: `/files/${req.file.filename}`
    });
});

app.use("/files", express.static(uploadPath));
app.use(express.static(__dirname));

app.listen(PORT, () => {
    console.log("Upload server running on port " + PORT);
});
