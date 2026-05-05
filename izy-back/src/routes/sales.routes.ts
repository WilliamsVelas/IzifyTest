import { Router } from "express";
import { getSales, getSalesReport, processSale } from "../controllers/sales.controller";

import { verifyToken } from "../middlewares/auth.middleware";

const router = Router();

router.use(verifyToken);

router.post("/", processSale);
router.get('/', getSales);
router.get("/report", getSalesReport);

export default router;