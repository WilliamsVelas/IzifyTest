import express from "express";
import dotenv from "dotenv";
dotenv.config();

import { connectDB } from "./config/database";
import productRoutes from "./routes/product.routes";
import salesRoutes from "./routes/sales.routes";
import authRoutes from "./routes/auth.routes";
import cors from "cors";

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

app.use("/api/products", productRoutes);
app.use("/api/sales", salesRoutes);
app.use("/api/auth", authRoutes);

app.listen(3000, "0.0.0.0", () => {
  console.log("Servidor corriendo en el puerto 3000");
});
