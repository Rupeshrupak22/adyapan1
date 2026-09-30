import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IInternLead extends Document {
  name: string;
  courseName: string;
  email: string;
  mobile: string;
  createdAt: Date;
  updatedAt: Date;
}

const InternLeadSchema = new Schema<IInternLead>(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters'],
      maxlength: [100, 'Name too long'],
    },
    courseName: {
      type: String,
      required: [true, 'Course name is required'],
      trim: true,
      maxlength: [200, 'Course name too long'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      lowercase: true,
      trim: true,
      match: [/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/, 'Please enter a valid email'],
      index: true,
    },
    mobile: {
      type: String,
      required: [true, 'Mobile number is required'],
      trim: true,
      match: [/^[6-9]\d{9}$/, 'Enter a valid 10-digit Indian mobile number'],
    },
  },
  {
    timestamps: true,
    collection: 'internLeads',
  }
);

InternLeadSchema.index({ createdAt: -1 });
InternLeadSchema.index({ email: 1, createdAt: -1 });

const InternLead: Model<IInternLead> =
  mongoose.models.InternLead ||
  mongoose.model<IInternLead>('InternLead', InternLeadSchema);

export default InternLead;
