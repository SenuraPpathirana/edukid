import express from "express";
import multer from "multer";
import * as materialsController from "./materials.controller.js";
import { authenticate } from "../../middleware/auth.js";

const router = express.Router();
const upload = multer({
	storage: multer.memoryStorage(),
	limits: { fileSize: 50 * 1024 * 1024 },
});

// All materials routes require authentication
router.use(authenticate);

// Get all learning materials
router.get("/", materialsController.getMaterials);

// Record material access
router.post("/:id/access", materialsController.recordMaterialAccess);

// Upload raw file to storage
router.post("/upload-file", upload.single("file"), materialsController.uploadMaterialFile);

// Upload new learning material
router.post("/", materialsController.uploadMaterial);

// Delete a learning material
router.delete("/:id", materialsController.deleteMaterial);

export default router;
