import mongoose, { Schema, Document } from "mongoose";

export interface IInvoiceLine extends Document {
  invoice: mongoose.Types.ObjectId;
  product: mongoose.Types.ObjectId;
  productName: string; 
  unitPrice: number; 
  lineTotal: number;
  barcodes: string[];
}

const invoiceLineSchema: Schema = new Schema(
  {
    invoice: {
      type: Schema.Types.ObjectId,
      ref: "Invoice",
      required: true,
    },
    product: {
      type: Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    productName: {
      type: String,
      required: true,
    },
    unitPrice: {
      type: Number,
      required: true,
    },
    lineTotal: {
      type: Number,
      required: true,
    },
    barcodes: {
      type: [String],
      required: true,
    },
  },
  { timestamps: true },
);

invoiceLineSchema.set("toJSON", {
  transform: (document, returnedObject) => {
    returnedObject.id = returnedObject._id;
    delete returnedObject._id;
  },
});

export default mongoose.model<IInvoiceLine>("InvoiceLine", invoiceLineSchema);
