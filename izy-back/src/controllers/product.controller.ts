import { Request, Response } from "express";
import Product from "../models/Product";
import { sendResponse } from "../utils/responseHandler";
import Unit from "../models/Unit";
import mongoose from "mongoose";
import { generateUniqueBarcodes } from "../utils/barcodeGenerator";

export const getProducts = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 15;
    const skip = (page - 1) * limit;

    const products = await Product.find({ isDisabled: false })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate("stock")
      .populate({
        path: "availableUnits",
        select: "barcode",
      })
      .lean();

    sendResponse(res, 200, "success", "PRODUCTS_FETCHED", products, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "SERVER_ERROR",
      null,
      error.message || "Hubo un error al obtener los productos",
    );
  }
};

export const createProduct = async (req: Request, res: Response) => {
  try {
    const { barcodes, qty, ...productData } = req.body;

    let finalBarcodes: string[] = [];

    if (barcodes && Array.isArray(barcodes) && barcodes.length > 0) {
      finalBarcodes = barcodes;
    } else if (qty && typeof qty === "number" && qty > 0) {
      finalBarcodes = await generateUniqueBarcodes(productData.name, qty);
    } else {
      return sendResponse(
        res,
        400,
        "failed",
        "MISSING_STOCK_DATA",
        null,
        "Debes enviar un array de 'barcodes' o una cantidad 'qty' mayor a 0.",
      );
    }

    const newProduct = await Product.create(productData);

    const unitsToInsert = finalBarcodes.map((code: string) => {
      return {
        product: newProduct._id,
        barcode: code,
        status: "AVAILABLE",
      };
    });

    const createdUnits = await Unit.insertMany(unitsToInsert);

    const responseData = {
      product: newProduct,
      stockCreated: createdUnits.length,
      units: createdUnits,
    };

    sendResponse(res, 201, "success", "PRODUCT_CREATED", responseData, "");
  } catch (error: any) {
    sendResponse(
      res,
      400,
      "failed",
      "CREATION_ERROR",
      null,
      error.message || "Error al crear el producto.",
    );
  }
};

export const updateProduct = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const updatedProduct = await Product.findByIdAndUpdate(id, req.body, {
      new: true,
    });

    if (!updatedProduct) {
      sendResponse(
        res,
        404,
        "failed",
        "PRODUCT_NOT_FOUND",
        null,
        "Producto no encontrado",
      );
      return;
    }

    sendResponse(res, 200, "success", "PRODUCT_UPDATED", updatedProduct, "");
  } catch (error: any) {
    sendResponse(
      res,
      400,
      "failed",
      "UPDATE_ERROR",
      null,
      error.message || "Error al actualizar el producto",
    );
  }
};

export const deleteProduct = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const deletedProduct = await Product.findByIdAndUpdate(
      id,
      { isDisabled: true }, 
      { new: true },
    );

    if (!deletedProduct) {
      sendResponse(
        res,
        404,
        "failed",
        "PRODUCT_NOT_FOUND",
        null,
        "Producto no encontrado",
      );
      return;
    }

    await Unit.updateMany(
      { product: id, status: "AVAILABLE", isDisabled: false },
      { $set: { isDisabled: true } },
    );

    sendResponse(res, 200, "success", "PRODUCT_DELETED", null, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "DELETE_ERROR",
      null,
      error.message || "Error al eliminar el producto",
    );
  }
};

export const deleteUnit = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const unit = await Unit.findById(id);

    if (!unit) {
      return sendResponse(
        res,
        404,
        "failed",
        "UNIT_NOT_FOUND",
        null,
        "La unidad especificada no existe.",
      );
    }

    if (unit.status === "SOLD") {
      return sendResponse(
        res,
        400,
        "failed",
        "UNIT_ALREADY_SOLD",
        null,
        "No puedes eliminar una unidad que ya ha sido vendida.",
      );
    }

    unit.isDisabled = true;
    await unit.save();

    sendResponse(
      res,
      200,
      "success",
      "UNIT_DELETED",
      unit,
      "Unidad deshabilitada correctamente.",
    );
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "DELETE_UNIT_ERROR",
      null,
      error.message || "Error al deshabilitar la unidad.",
    );
  }
};

export const sellUnit = async (req: Request, res: Response) => {
  try {
    const { identifiers } = req.body;

    if (
      !identifiers ||
      !Array.isArray(identifiers) ||
      identifiers.length === 0
    ) {
      sendResponse(
        res,
        400,
        "failed",
        "MISSING_IDENTIFIERS",
        null,
        "Debes enviar un array 'identifiers' con los códigos a procesar",
      );
      return;
    }

    const validMongoIds = identifiers.filter((id) =>
      mongoose.Types.ObjectId.isValid(id),
    );

    const units = await Unit.find({
      $or: [{ _id: { $in: validMongoIds } }, { barcode: { $in: identifiers } }],
    });

    const uniqueIdentifiersRequested = new Set(identifiers).size;
    if (units.length !== uniqueIdentifiersRequested) {
      sendResponse(
        res,
        404,
        "failed",
        "UNITS_MISSING",
        null,
        "Algunos de los códigos escaneados no existen en la base de datos",
      );
      return;
    }

    const unavailableUnits = units.filter(
      (unit) => unit.status !== "AVAILABLE",
    );
    if (unavailableUnits.length > 0) {
      const badCodes = unavailableUnits.map((u) => u.barcode).join(", ");
      sendResponse(
        res,
        400,
        "failed",
        "UNITS_UNAVAILABLE",
        null,
        `Venta detenida. Estos productos ya están vendidos o defectuosos: ${badCodes}`,
      );
      return;
    }

    const unitIdsToUpdate = units.map((u) => u._id);

    await Unit.updateMany(
      { _id: { $in: unitIdsToUpdate } },
      { $set: { status: "SOLD" } },
    );

    sendResponse(
      res,
      200,
      "success",
      "UNITS_SOLD_SUCCESSFULLY",
      { unitsSold: units.length, barcodes: units.map((u) => u.barcode) },
      "",
    );
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "SELL_ERROR",
      null,
      error.message || "Error interno al procesar la salida masiva",
    );
  }
};

export const addStock = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { barcodes, qty } = req.body;

    const product = await Product.findById(id);
    if (!product) {
      sendResponse(
        res,
        404,
        "failed",
        "PRODUCT_NOT_FOUND",
        null,
        "El producto especificado no existe",
      );
      return;
    }

    let finalBarcodes: string[] = [];

    if (barcodes && Array.isArray(barcodes) && barcodes.length > 0) {
      finalBarcodes = barcodes;
    } else if (qty && typeof qty === "number" && qty > 0) {
      finalBarcodes = await generateUniqueBarcodes(product.name, qty);
    } else {
      sendResponse(
        res,
        400,
        "failed",
        "MISSING_DATA",
        null,
        "Debes enviar un array de 'barcodes' o una cantidad 'qty'.",
      );
      return;
    }

    const unitsToInsert = finalBarcodes.map((code: string) => ({
      product: id,
      barcode: code,
      status: "AVAILABLE",
    }));

    const createdUnits = await Unit.insertMany(unitsToInsert);

    sendResponse(
      res,
      201,
      "success",
      "STOCK_ADDED_SUCCESSFULLY",
      { addedQty: createdUnits.length, newUnits: createdUnits },
      "",
    );
  } catch (error: any) {
    sendResponse(
      res,
      400,
      "failed",
      "ADD_STOCK_ERROR",
      null,
      error.message || "Error al agregar stock. Revisa los códigos.",
    );
  }
};
