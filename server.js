const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");

const app = express();
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

const upload = multer({ storage });

app.post("/upload", upload.single("file"), (req, res) => {

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

app.listen(3000, () => {
    console.log("Server running on port 3000");
});
