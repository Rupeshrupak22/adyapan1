import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { protectRouteByRole } from '@/lib/auth';
import Certificate from '@/models/Certificate';
import AuthUser from '@/models/AuthUser';
import mongoose from 'mongoose';

type RouteContext = { params: Promise<{ id: string }> };

// ── PATCH /api/admin/certificates/:id — edit a certificate ────
export async function PATCH(request: NextRequest, { params }: RouteContext) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { id } = await params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return NextResponse.json({ error: 'Invalid certificate ID' }, { status: 400 });
    }

    const body = await request.json();
    const {
      studentName,
      studentEmail,
      courseName,
      courseSlug,
      certificateTypes = [] as string[],
      otherType        = '',
      issuedAt,
      status,
      certificateFiles, // Array<{ name: string; url: string }>
    } = body;

    // Build final types array — resolve "other" placeholder
    let finalTypes: string[] = Array.isArray(certificateTypes) ? [...certificateTypes] : [];
    if (finalTypes.includes('other')) {
      if (!otherType?.trim()) {
        return NextResponse.json({ error: 'Please enter a name for the custom certificate type' }, { status: 400 });
      }
      finalTypes = finalTypes.filter(t => t !== 'other');
      finalTypes.push(otherType.trim());
    }

    const updateFields: Record<string, any> = {};
    if (studentName?.trim())       updateFields.studentName     = studentName.trim();
    if (studentEmail?.trim()) {
      // Store the email directly so it persists on the certificate
      updateFields.studentEmail = studentEmail.toLowerCase().trim();
      // Re-link to a registered user if one exists; keep existing userId otherwise
      const user = await AuthUser.findOne({ email: studentEmail.toLowerCase().trim() }).select('_id').lean();
      if (user) updateFields.userId = (user as any)._id.toString();
    }
    if (courseName?.trim())        updateFields.courseName      = courseName.trim();
    if (courseSlug?.trim())        updateFields.courseSlug      = courseSlug.trim();
    if (finalTypes.length > 0) {
      updateFields.certificateTypes = finalTypes;
      updateFields.certificateType  = finalTypes[0];
    }
    if (issuedAt)                  updateFields.issuedAt        = new Date(issuedAt);
    if (status)                    updateFields.status          = status;

    // certificateFiles — replace the whole array when provided
    if (Array.isArray(certificateFiles)) {
      // validate each entry has a url
      const cleaned = (certificateFiles as Array<{ name?: string; url: string }>)
        .filter(f => f?.url?.trim())
        .map(f => ({ name: f.name?.trim() || '', url: f.url.trim() }));
      updateFields.certificateFiles = cleaned;
      // keep legacy single-URL field pointing to first file for backwards compat
      if (cleaned.length > 0) updateFields.certificateUrl = cleaned[0].url;
    }

    const cert = await Certificate.findByIdAndUpdate(
      id,
      { $set: updateFields },
      { new: true, runValidators: true }
    ).lean();

    if (!cert) return NextResponse.json({ error: 'Certificate not found' }, { status: 404 });

    return NextResponse.json({ success: true, certificate: cert });
  } catch (err: any) {
    console.error('[Admin Certificates PATCH]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// ── DELETE /api/admin/certificates/:id ────────────────────────
export async function DELETE(request: NextRequest, { params }: RouteContext) {
  const auth = protectRouteByRole(request, ['ADMIN', 'SUPERADMIN']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { id } = await params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return NextResponse.json({ error: 'Invalid certificate ID' }, { status: 400 });
    }

    const cert = await Certificate.findByIdAndDelete(id).lean();
    if (!cert) return NextResponse.json({ error: 'Certificate not found' }, { status: 404 });

    return NextResponse.json({ success: true, message: 'Certificate deleted' });
  } catch (err: any) {
    console.error('[Admin Certificates DELETE]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// ── GET /api/admin/certificates/:id — fetch single cert ───────
export async function GET(request: NextRequest, { params }: RouteContext) {
  const auth = protectRouteByRole(request, ['ADMIN', 'COMPANY']);
  if (auth instanceof NextResponse) return auth;

  try {
    await connectToDatabase();

    const { id } = await params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return NextResponse.json({ error: 'Invalid certificate ID' }, { status: 400 });
    }

    const cert = await Certificate.findById(id).lean();
    if (!cert) return NextResponse.json({ error: 'Certificate not found' }, { status: 404 });

    return NextResponse.json({ success: true, certificate: cert });
  } catch (err: any) {
    console.error('[Admin Certificates GET/:id]', err.message);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
