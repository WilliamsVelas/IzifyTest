import { Router } from "express";
import { getSales, getSalesReport, processSale } from "../controllers/sales.controller";

const router = Router();

router.post("/", processSale);
router.get('/', getSales);
router.get("/report", getSalesReport);

export default router;