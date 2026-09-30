import mongoose, { Schema, Document, Model } from 'mongoose';

export interface ICampusAmbassadorLead extends Document {
  name: string;
  email: string;
  phone: string;
  college: string;
  city: string;
  branch: string;
  year: string;
  linkedin: string;
  why: string;
  status: 'new' | 'reviewing' | 'accepted' | 'rejected';
  ip: string;
  createdAt: Date;
  updatedAt: Date;
}

const CampusAmbassadorLeadSchema = new Schema<ICampusAmbassadorLead>(
  {
    name:     { type: String, required: true, trim: true, maxlength: 100 },
    email:    { type: String, required: true, lowercase: true, trim: true, index: true },
    phone:    { type: String, required: true, trim: true },
    college:  { type: String, required: true, trim: true, maxlength: 200 },
    city:     { type: String, required: true, trim: true, maxlength: 100 },
    branch:   { type: String, required: true, trim: true, maxlength: 100 },
    year:     { type: String, required: true, enum: ['1st Year', '2nd Year', '3rd Year', '4th Year', 'PG'] },
    linkedin: { type: String, default: '', trim: true, maxlength: 300 },
    why:      { type: String, required: true, trim: true, maxlength: 2000 },
    status:   { type: String, enum: ['new', 'reviewing', 'accepted', 'rejected'], default: 'new' },
    ip:       { type: String, default: '' },
  },
  { timestamps: true, collection: 'campusAmbassadorLeads' }
);

CampusAmbassadorLeadSchema.index({ createdAt: -1 });
CampusAmbassadorLeadSchema.index({ email: 1, createdAt: -1 });

const CampusAmbassadorLead: Model<ICampusAmbassadorLead> =
  mongoose.models.CampusAmbassadorLead ||
  mongoose.model<ICampusAmbassadorLead>('CampusAmbassadorLead', CampusAmbassadorLeadSchema);

export default CampusAmbassadorLead;
