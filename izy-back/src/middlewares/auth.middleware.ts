import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { sendResponse } from "../utils/responseHandler";

const JWT_SECRET = process.env.JWT_SECRET || "mi_super_secreto_para_izify_2026";

export interface AuthRequest extends Request {
  user?: any;
}

export const verifyToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return sendResponse(
      res,
      401,
      "failed",
      "NO_TOKEN",
      null,
      "Acceso denegado. No se proporcionó un token válido.",
    );
  }
  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    req.user = decoded;

    next();
  } catch (error) {
    return sendResponse(
      res,
      401,
      "failed",
      "INVALID_TOKEN",
      null,
      "El token es inválido o ha expirado.",
    );
  }
};
