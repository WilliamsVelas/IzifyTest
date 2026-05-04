import { Request, Response } from "express";
import Invoice from "../models/Invoice";
import InvoiceLine from "../models/InvoiceLine";
import Unit from "../models/Unit";
import { sendResponse } from "../utils/responseHandler";

export const getSales = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 15;
    const skip = (page - 1) * limit;

    const invoices = await Invoice.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const invoiceIds = invoices.map((inv: any) => inv._id);

    const invoiceLines = await InvoiceLine.find({
      invoice: { $in: invoiceIds },
    }).lean();

    const data = invoices.map((invoice: any) => {
      const lines = invoiceLines.filter(
        (line: any) => line.invoice.toString() === invoice._id.toString(),
      );

      return {
        ...invoice,
        invoice_number:
          invoice.invoiceNumber ||
          invoice._id.toString().slice(-6).toUpperCase(),
        total_amount: invoice.total,
        lines: lines,
      };
    });

    sendResponse(res, 200, "success", "SALES_FETCHED", data, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "FETCH_SALES_ERROR",
      null,
      error.message || "Error al obtener las ventas",
    );
  }
};

export const processSale = async (req: Request, res: Response) => {
  try {
    const { total, lines } = req.body;

    if (!total || !lines || !Array.isArray(lines) || lines.length === 0) {
      return sendResponse(
        res,
        400,
        "failed",
        "INVALID_SALE_DATA",
        null,
        "Faltan datos de la factura o las líneas",
      );
    }

    const allBarcodesToSell = lines.flatMap((line: any) => line.barcodes);

    const availableUnits = await Unit.find({
      barcode: { $in: allBarcodesToSell },
      status: "AVAILABLE",
    });

    if (availableUnits.length !== allBarcodesToSell.length) {
      return sendResponse(
        res,
        400,
        "failed",
        "UNITS_UNAVAILABLE",
        null,
        "Algunos códigos de barras enviados ya fueron vendidos o no existen.",
      );
    }

    const newInvoice = await Invoice.create({ total });

    const linesToInsert = lines.map((line: any) => ({
      invoice: newInvoice._id,
      product: line.productId,
      productName: line.productName,
      unitPrice: line.unitPrice,
      lineTotal: line.lineTotal,
      barcodes: line.barcodes,
    }));

    const createdLines = await InvoiceLine.insertMany(linesToInsert);

    await Unit.updateMany(
      { barcode: { $in: allBarcodesToSell } },
      { $set: { status: "SOLD" } },
    );

    const responseData = {
      invoice: newInvoice,
      lines: createdLines,
    };

    sendResponse(res, 201, "success", "SALE_COMPLETED", responseData, "");
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "SALE_ERROR",
      null,
      error.message || "Error al procesar la venta",
    );
  }
};

export const getSalesReport = async (req: Request, res: Response) => {
  try {
    const { productId, startDate, endDate } = req.query;

    const query: any = {};

    if (productId) {
      query.product = productId;
    }

    if (startDate || endDate) {
      query.createdAt = {};

      if (startDate) {
        query.createdAt.$gte = new Date(startDate as string);
      }

      if (endDate) {
        query.createdAt.$lte = new Date(endDate as string);
      }
    }

    const invoiceLines = await InvoiceLine.find(query).populate(
      "invoice",
      "createdAt",
    );

    const reportData = invoiceLines.map((line: any) => ({
      invoiceLineId: line._id,
      invoiceId: line.invoice._id,
      date: line.createdAt,
      productId: line.product,
      productName: line.productName,
      quantity: line.barcodes.length,
      lineTotal: line.lineTotal,
      barcodes: line.barcodes,
    }));

    sendResponse(
      res,
      200,
      "success",
      "REPORT_GENERATED",
      {
        totalLinesMatched: reportData.length,
        totalRevenue: reportData.reduce((sum, item) => sum + item.lineTotal, 0),
        report: reportData,
      },
      "",
    );
  } catch (error: any) {
    sendResponse(
      res,
      500,
      "failed",
      "REPORT_ERROR",
      null,
      error.message || "Error al generar el reporte",
    );
  }
};
