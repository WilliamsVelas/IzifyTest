import mongoose, { Schema, Document } from "mongoose";

export interface IProduct extends Document {
  name: string;
  price: number;
  description?: string;
  stock?: number;
  availableUnits?: any[];
  isDisabled: boolean; 
}

const productSchema: Schema = new Schema(
  {
    name: {
      type: String,
      required: [true, "El nombre del producto es obligatorio"],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, "El precio es obligatorio"],
      min: [0, "El precio no puede ser negativo"],
    },
    description: {
      type: String,
      required: false,
    },
    isDisabled: {
      type: Boolean,
      default: false, 
    },
  },
  {
    timestamps: true,
  },
);

productSchema.virtual("stock", {
  ref: "Unit",
  localField: "_id",
  foreignField: "product",
  match: { status: "AVAILABLE", isDisabled: false }, 
  count: true,
});

productSchema.virtual('availableUnits', {
  ref: 'Unit',
  localField: '_id',
  foreignField: 'product',
  match: { status: 'AVAILABLE', isDisabled: false }
});

productSchema.set("toJSON", {
  virtuals: true,
});

export default mongoose.model<IProduct>("Product", productSchema);
