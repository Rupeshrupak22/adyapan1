/**
 * ProjectPayment Model - Next.js Frontend
 * Single source of truth for "Build My Project" payment records.
 */
import mongoose, { Schema, model, models } from 'mongoose';

export interface ProjectPaymentDocument {
  _id: mongoose.Types.ObjectId;
  projectRequestId: mongoose.Types.ObjectId;
  contactName: string;
  contactEmail: string;
  contactPhone: string;
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
  amount: number;
  currency: string;
  status: 'pending' | 'success' | 'failed';
  signatureVerified: boolean;
  isTestMode: boolean;
  paidAt?: Date | null;
  failureReason: string;
  createdAt: Date;
  updatedAt: Date;
}

const projectPaymentSchema = new Schema<ProjectPaymentDocument>(
  {
    projectRequestId:  { type: Schema.Types.ObjectId, ref: 'ProjectRequest', required: true },
    contactName:       { type: String, required: true },
    contactEmail:      { type: String, required: true, lowercase: true },
    contactPhone:      { type: String, default: '' },
    razorpayOrderId:   { type: String, required: true, unique: true },
    razorpayPaymentId: { type: String, default: '' },
    razorpaySignature: { type: String, default: '' },
    amount:            { type: Number, required: true, min: 0 },
    currency:          { type: String, default: 'INR' },
    status:            { type: String, enum: ['pending', 'success', 'failed'], default: 'pending' },
    signatureVerified: { type: Boolean, default: false },
    isTestMode:        { type: Boolean, default: false },
    paidAt:            { type: Date, default: null },
    failureReason:     { type: String, default: '' },
  },
  { timestamps: true, collection: 'projectpayments' }
);

const ProjectPayment = models.ProjectPayment
  || model<ProjectPaymentDocument>('ProjectPayment', projectPaymentSchema);
export default ProjectPayment;
