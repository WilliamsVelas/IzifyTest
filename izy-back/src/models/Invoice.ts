import mongoose, { Schema, Document } from "mongoose";

export interface IInvoice extends Document {
  total: number;
}

const invoiceSchema: Schema = new Schema(
  {
    total: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  { timestamps: true },
);

invoiceSchema.set("toJSON", {});

export default mongoose.model<IInvoice>("Invoice", invoiceSchema);
