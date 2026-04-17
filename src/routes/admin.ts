import { Router, type IRouter, type Request, type Response } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const UPLOADS_DIR = path.resolve(__dirname, "../../uploads");
const DATA_FILE = path.resolve(__dirname, "../../uploads/wardenx_data.json");

if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR, { recursive: true });

interface Category {
  id: string;
  name: string;
  color: string;
  icon: string;
  features: Feature[];
}
interface Feature {
  id: string;
  name: string;
  desc: string;
}
interface PortalData {
  version: string;
  releaseDate: string;
  releaseType: string;
  file: string;
  categories: Category[];
}

function loadData(): PortalData {
  if (fs.existsSync(DATA_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(DATA_FILE, "utf-8"));
    } catch {
      /* fall through */
    }
  }
  return {
    version: "v1.0.1",
    releaseDate: "2025-04-01",
    releaseType: "Release",
    file: "",
    categories: [
      {
        id: "core",
        name: "Core Features",
        color: "#5196ff",
        icon: "⚡",
        features: [
          { id: "f1", name: "Hypixel Ban & Rank checker", desc: "" },
          { id: "f2", name: "DonutSMP Ban & Stats Checker", desc: "" },
          { id: "f3", name: "Microsoft Reward Points & Balance Fetcher", desc: "" },
          { id: "f4", name: "Xbox Game Pass detection", desc: "" },
          { id: "f5", name: "Xbox Codes & Nitro Promo Fetcher", desc: "" },
          { id: "f6", name: "High-speed multi-threading", desc: "" },
        ],
      },
      {
        id: "advanced",
        name: "Advanced Technology",
        color: "#7c5cff",
        icon: "🔐",
        features: [
          { id: "f7", name: "TLS fingerprinting for stable sessions", desc: "" },
          { id: "f8", name: "HWID-locked licensing", desc: "" },
          { id: "f9", name: "Multi-channel webhooks (Hypixel, Donut, XboxPerks)", desc: "" },
          { id: "f10", name: "Minecraft Auto-Skin changer", desc: "" },
          { id: "f11", name: "Minecraft Auto-Name changer", desc: "" },
        ],
      },
      {
        id: "bugs",
        name: "Bugs & Fixes",
        color: "#f59e0b",
        icon: "⚙️",
        features: [
          { id: "f12", name: "Added High CPM Support (500+ CPM on 5 Threads)", desc: "" },
          { id: "f13", name: "85% Accurate Results on High CPM", desc: "" },
          { id: "f14", name: "MS Rewards & Balance in Development", desc: "" },
          { id: "f15", name: "Logs Screen mode is not Completed yet", desc: "" },
        ],
      },
    ],
  };
}

function saveData(data: PortalData) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
}

function genId() {
  return Math.random().toString(36).slice(2, 10);
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOADS_DIR),
  filename: (_req, file, cb) => cb(null, file.originalname),
});
const upload = multer({
  storage,
  fileFilter: (_req, file, cb) => {
    if (file.originalname.endsWith(".zip")) cb(null, true);
    else cb(new Error("Only .zip files allowed"));
  },
  limits: { fileSize: 500 * 1024 * 1024 },
});

const router: IRouter = Router();

router.get("/admin/data", (_req: Request, res: Response) => {
  res.json(loadData());
});

router.post("/admin/version", (req: Request, res: Response) => {
  const { version, releaseDate, releaseType } = req.body as {
    version?: string;
    releaseDate?: string;
    releaseType?: string;
  };
  const data = loadData();
  if (version) data.version = version;
  if (releaseDate) data.releaseDate = releaseDate;
  if (releaseType) data.releaseType = releaseType;
  saveData(data);
  res.json({ ok: true, data });
});

router.post(
  "/admin/upload",
  (req: Request, res: Response, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        res.status(400).json({ ok: false, error: String(err) });
        return;
      }
      next();
    });
  },
  (req: Request, res: Response) => {
    if (!req.file) {
      res.status(400).json({ ok: false, error: "No file uploaded" });
      return;
    }
    const data = loadData();
    if (data.file) {
      const oldPath = path.join(UPLOADS_DIR, path.basename(data.file));
      if (fs.existsSync(oldPath)) {
        try {
          fs.unlinkSync(oldPath);
        } catch {
          /* ignore */
        }
      }
    }
    data.file = `/api/download/${req.file.filename}`;
    saveData(data);
    res.json({ ok: true, file: data.file, data });
  }
);

router.get("/download/:filename", (req: Request, res: Response) => {
  const filename = path.basename(req.params["filename"] ?? "");
  const filePath = path.join(UPLOADS_DIR, filename);
  if (!fs.existsSync(filePath)) {
    res.status(404).json({ error: "File not found" });
    return;
  }
  res.download(filePath);
});

router.post("/admin/category/add", (req: Request, res: Response) => {
  const { name, color, icon } = req.body as {
    name?: string;
    color?: string;
    icon?: string;
  };
  if (!name) {
    res.status(400).json({ ok: false, error: "Name required" });
    return;
  }
  const data = loadData();
  const cat: Category = {
    id: genId(),
    name,
    color: color || "#5196ff",
    icon: icon || "⚙️",
    features: [],
  };
  data.categories.push(cat);
  saveData(data);
  res.json({ ok: true, category: cat, data });
});

router.post("/admin/category/delete", (req: Request, res: Response) => {
  const { id } = req.body as { id?: string };
  const data = loadData();
  data.categories = data.categories.filter((c) => c.id !== id);
  saveData(data);
  res.json({ ok: true, data });
});

router.post("/admin/feature/add", (req: Request, res: Response) => {
  const { categoryId, name, desc } = req.body as {
    categoryId?: string;
    name?: string;
    desc?: string;
  };
  if (!categoryId || !name) {
    res.status(400).json({ ok: false, error: "categoryId and name required" });
    return;
  }
  const data = loadData();
  const cat = data.categories.find((c) => c.id === categoryId);
  if (!cat) {
    res.status(404).json({ ok: false, error: "Category not found" });
    return;
  }
  const feat: Feature = { id: genId(), name, desc: desc || "" };
  cat.features.push(feat);
  saveData(data);
  res.json({ ok: true, feature: feat, data });
});

router.post("/admin/feature/edit", (req: Request, res: Response) => {
  const { categoryId, featureId, name, desc } = req.body as {
    categoryId?: string;
    featureId?: string;
    name?: string;
    desc?: string;
  };
  if (!categoryId || !featureId) {
    res.status(400).json({ ok: false, error: "categoryId and featureId required" });
    return;
  }
  const data = loadData();
  const cat = data.categories.find((c) => c.id === categoryId);
  if (!cat) {
    res.status(404).json({ ok: false, error: "Category not found" });
    return;
  }
  const feat = cat.features.find((f) => f.id === featureId);
  if (!feat) {
    res.status(404).json({ ok: false, error: "Feature not found" });
    return;
  }
  if (name !== undefined) feat.name = name;
  if (desc !== undefined) feat.desc = desc;
  saveData(data);
  res.json({ ok: true, feature: feat, data });
});

router.post("/admin/feature/delete", (req: Request, res: Response) => {
  const { categoryId, featureId } = req.body as {
    categoryId?: string;
    featureId?: string;
  };
  const data = loadData();
  const cat = data.categories.find((c) => c.id === categoryId);
  if (cat) {
    cat.features = cat.features.filter((f) => f.id !== featureId);
  }
  saveData(data);
  res.json({ ok: true, data });
});

export default router;
