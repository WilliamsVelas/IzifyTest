import { Router } from "express";
import {
  getProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  addStock,
  sellUnit,
  deleteUnit
} from "../controllers/product.controller";

const router = Router();

router.get("/", getProducts);
router.post("/", createProduct);
router.post("/sell", sellUnit);
router.post("/:id/stock", addStock);
router.put("/:id", updateProduct);
router.delete("/:id", deleteProduct);
router.delete("/unit/:id", deleteUnit);

export default router;
