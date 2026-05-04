import mongoose, { Schema, Document } from 'mongoose';

export interface IUnit extends Document {
  product: mongoose.Types.ObjectId;
  barcode: string;
  status: 'AVAILABLE' | 'SOLD' | 'DEFECTIVE';
  isDisabled: boolean; 
}

const unitSchema: Schema = new Schema(
  {
    product: {
      type: Schema.Types.ObjectId,
      ref: 'Product',
    },
    barcode: {
      type: String,
      required: true,
      unique: true,
    },
    status: {
      type: String,
      enum: ['AVAILABLE', 'SOLD', 'DEFECTIVE'],
      default: 'AVAILABLE',
    },
    isDisabled: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

unitSchema.set('toJSON', {
  transform: (document, returnedObject) => {
    returnedObject.id = returnedObject._id;
    delete returnedObject._id;
  }
});

export default mongoose.model<IUnit>('Unit', unitSchema);