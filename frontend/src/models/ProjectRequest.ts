/**
 * ProjectRequest Model - Next.js Frontend
 * Mirrors backend/models/ProjectRequest.js for use in API routes.
 */
import mongoose, { Schema, model, models } from 'mongoose';

export interface ProjectRequestDocument {
  _id: mongoose.Types.ObjectId;
  userId?: mongoose.Types.ObjectId;
  recruiterId?: string;
  projectTitle: string;
  category: string;
  description: string;
  features: string[];
  techPreference: string;
  deadline: Date;
  budget: number;
  contactName: string;
  contactEmail: string;
  contactPhone: string;
  imageUrls: string[];
  pdfUrls: string[];
  referenceFiles: unknown[];
  additionalNotes: string;
  paymentId: string;
  orderId: string;
  paymentStatus: 'pending' | 'success' | 'failed';
  paidAmount: number;
  projectStatus: 'draft' | 'submitted' | 'under_review' | 'assigned' | 'in_progress' | 'completed' | 'delivered' | 'cancelled';
  assignedTo?: mongoose.Types.ObjectId;
  assignedAt?: Date;
  emailSent: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const projectRequestSchema = new Schema<ProjectRequestDocument>(
  {
    userId:          { type: Schema.Types.ObjectId, ref: 'AuthUser', default: null },
    recruiterId:     { type: String, default: null },
    projectTitle:    { type: String, required: true, trim: true },
    category:        { type: String, required: true },
    description:     { type: String, required: true },
    features:        { type: [String], required: true },
    techPreference:  { type: String, default: '' },
    deadline:        { type: Date, required: true },
    budget:          { type: Number, required: true, min: 0 },
    contactName:     { type: String, required: true, trim: true },
    contactEmail:    { type: String, required: true, lowercase: true, trim: true },
    contactPhone:    { type: String, required: true, trim: true },
    imageUrls:       { type: [String], default: [] },
    pdfUrls:         { type: [String], default: [] },
    referenceFiles:  { type: Schema.Types.Mixed, default: [] },
    additionalNotes: { type: String, default: '' },
    paymentId:       { type: String, default: '', index: true, sparse: true },
    orderId:         { type: String, default: '', index: true, sparse: true },
    paymentStatus:   { type: String, enum: ['pending', 'success', 'failed'], default: 'pending' },
    paidAmount:      { type: Number, default: 0 },
    projectStatus: {
      type: String,
      enum: ['draft', 'submitted', 'under_review', 'assigned', 'in_progress', 'completed', 'delivered', 'cancelled'],
      default: 'draft',
    },
    assignedTo:  { type: Schema.Types.ObjectId, ref: 'AuthUser', default: null },
    assignedAt:  { type: Date, default: null },
    emailSent:   { type: Boolean, default: false },
  },
  { timestamps: true, collection: 'projectrequests' }
);

projectRequestSchema.index({ contactEmail: 1 });
projectRequestSchema.index({ projectStatus: 1 });
projectRequestSchema.index({ paymentStatus: 1 });
projectRequestSchema.index({ createdAt: -1 });

const ProjectRequest = models.ProjectRequest
  || model<ProjectRequestDocument>('ProjectRequest', projectRequestSchema);
export default ProjectRequest;
