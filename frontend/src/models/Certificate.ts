import mongoose, { Schema, model, models } from 'mongoose';

export type CertificateType = 'course_completion' | 'internship_completion' | 'project_completion' | 'best_performance' | string;

export interface CertificateDocument {
  _id: mongoose.Types.ObjectId;
  userId: string;
  studentEmail: string;
  courseSlug: string;
  certificateType: CertificateType;
  certificateTypes: string[];   // multi-select values including custom "other"
  certificateId: string;       // e.g. ADYP-2024-XXXXXX
  studentName: string;
  courseName: string;
  issuedAt: Date;
  certificateUrl: string;
  certificateFiles: Array<{ name: string; url: string }>;
  status: 'ready' | 'pending';
  emailSent: boolean;
  emailSentAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const certificateSchema = new Schema<CertificateDocument>(
  {
    userId:          { type: String, required: true, index: true },
    studentEmail:    { type: String, default: '', lowercase: true, trim: true, index: true },
    courseSlug:      { type: String, required: true, index: true },
    certificateType: {
      type: String,
      // Open string — accepts preset values + custom "other" types
      default: 'course_completion',
    },
    // Array of all selected types (multi-select support)
    certificateTypes: {
      type: [String],
      default: [],
    },
    certificateId:   { type: String, required: true, index: true },
    studentName:     { type: String, required: true, trim: true },
    courseName:      { type: String, required: true, trim: true },
    issuedAt:        { type: Date, default: Date.now },
    certificateUrl:  { type: String, default: '' },
    // Multiple uploaded files (PDFs, images) — each has a display name + S3 URL
    certificateFiles: {
      type: [{ name: { type: String, default: '' }, url: { type: String, required: true } }],
      default: [],
    },
    status:          { type: String, enum: ['ready', 'pending'], default: 'pending', index: true },
    emailSent:       { type: Boolean, default: false },
    emailSentAt:     { type: Date },
  },
  { timestamps: true }
);

certificateSchema.index({ userId: 1, courseSlug: 1 }); // non-unique — admin can add multiple certs per student/course
certificateSchema.index({ userId: 1, status: 1 });
certificateSchema.index({ status: 1, emailSent: 1 });
certificateSchema.index({ issuedAt: -1 });

const Certificate = models.Certificate || model<CertificateDocument>('Certificate', certificateSchema);
export default Certificate;
