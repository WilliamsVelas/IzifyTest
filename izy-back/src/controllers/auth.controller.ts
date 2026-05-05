import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import User from "../models/User";
import { sendResponse } from "../utils/responseHandler";

const JWT_SECRET = process.env.JWT_SECRET || "mi_super_secreto_para_izify_2026";

export const register = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return sendResponse(
        res,
        400,
        "failed",
        "MISSING_CREDENTIALS",
        null,
        "Usuario y contraseña son obligatorios",
      );
    }

    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return sendResponse(
        res,
        400,
        "failed",
        "USER_EXISTS",
        null,
        "El nombre de usuario ya está en uso",
      );
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = await User.create({
      username,
      password: hashedPassword,
    });

    sendResponse(res, 201, "success", "USER_REGISTERED", newUser, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "REGISTER_ERROR",
      null,
      error.message || "Error al registrar usuario",
    );
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return sendResponse(
        res,
        400,
        "failed",
        "MISSING_CREDENTIALS",
        null,
        "Usuario y contraseña son obligatorios",
      );
    }

    const user = await User.findOne({ username });
    if (!user) {
      return sendResponse(
        res,
        404,
        "failed",
        "USER_NOT_FOUND",
        null,
        "Usuario no encontrado",
      );
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return sendResponse(
        res,
        401,
        "failed",
        "INVALID_PASSWORD",
        null,
        "Contraseña incorrecta",
      );
    }

    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: "8h" },
    );

    const responseData = {
      user,
      token,
    };

    sendResponse(res, 200, "success", "LOGIN_SUCCESS", responseData, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "LOGIN_ERROR",
      null,
      error.message || "Error al iniciar sesión",
    );
  }
};
