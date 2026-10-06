'use client';

import api from '@/lib/api';
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import {
  BookOpen, Users, Clock, BarChart2, Eye, Edit,
  TrendingUp, IndianRupee, Layers, GraduationCap,
} from 'lucide-react';

interface Course {
  id: string;
  slug: string;
  title: string;
  subtitle: string;
  duration: string;
  totalLessons: number;
  category: string;
  level: string;
  totalModules: number;
  totalEnrolled: number;
  totalRevenue: number;
  status: string;
}

const LEVEL_COLORS: Record<string, string> = {
  Beginner: 'bg-green-100 text-green-700',
  Intermediate: 'bg-blue-100 text-blue-700',
  Advanced: 'bg-purple-100 text-purple-700',
};

export default function AdminCoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/api/admin/courses')
      .then(res => setCourses(res.data.courses || []))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const totalEnrolled = courses.reduce((s, c) => s + c.totalEnrolled, 0);
  const totalRevenue = courses.reduce((s, c) => s + c.totalRevenue, 0);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Courses</h1>
          <p className="text-gray-500 text-sm mt-0.5">{courses.length} courses available</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 px-3 py-2 bg-blue-50 rounded-xl border border-blue-100">
            <Users className="w-4 h-4 text-blue-600" />
            <span className="text-sm font-semibold text-blue-700">{totalEnrolled} enrolled</span>
          </div>
          <div className="flex items-center gap-2 px-3 py-2 bg-green-50 rounded-xl border border-green-100">
            <IndianRupee className="w-4 h-4 text-green-600" />
            <span className="text-sm font-semibold text-green-700">Rs. {totalRevenue.toLocaleString('en-IN')}</span>
          </div>
        </div>
      </div>

      {/* Course cards */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl p-5 h-48 animate-pulse border border-gray-100" />
          ))}
        </div>
      ) : courses.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center border border-gray-100">
          <BookOpen className="w-10 h-10 mx-auto mb-3 text-gray-200" />
          <p className="text-gray-400">No courses found. Seed courses first.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {courses.map((course, i) => (
            <motion.div
              key={course.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 hover:shadow-md hover:border-orange-100 transition-all group"
            >
              {/* Top */}
              <div className="flex items-start justify-between mb-3">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center"
                  style={{ background: 'linear-gradient(135deg, #ffa800/15, #ff6b00/10)', backgroundColor: '#fff7ed' }}>
                  <BookOpen className="w-5 h-5 text-[#ffa800]" />
                </div>
                <div className="flex items-center gap-1.5">
                  <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${LEVEL_COLORS[course.level] || 'bg-gray-100 text-gray-500'}`}>
                    {course.level}
                  </span>
                  <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-700">
                    {course.status}
                  </span>
                </div>
              </div>

              {/* Title */}
              <h3 className="font-semibold text-gray-900 mb-1 line-clamp-2 group-hover:text-[#ffa800] transition-colors">
                {course.title}
              </h3>
              <p className="text-xs text-gray-400 mb-4 line-clamp-1">{course.category}</p>

              {/* Stats */}
              <div className="grid grid-cols-2 gap-2 mb-4">
                {[
                  { icon: Users, label: 'Enrolled', value: course.totalEnrolled },
                  { icon: IndianRupee, label: 'Revenue', value: `Rs. ${(course.totalRevenue / 1000).toFixed(1)}k` },
                  { icon: Layers, label: 'Modules', value: course.totalModules },
                  { icon: GraduationCap, label: 'Lessons', value: course.totalLessons },
                ].map(({ icon: Icon, label, value }) => (
                  <div key={label} className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
                    <Icon className="w-3.5 h-3.5 text-gray-400" />
                    <div>
                      <p className="text-[10px] text-gray-400">{label}</p>
                      <p className="text-xs font-semibold text-gray-900">{value}</p>
                    </div>
                  </div>
                ))}
              </div>

              {/* Footer */}
              <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                <div className="flex items-center gap-1 text-xs text-gray-400">
                  <Clock className="w-3.5 h-3.5" />
                  {course.duration}
                </div>
                <div className="flex items-center gap-1">
                  <button className="p-1.5 rounded-lg text-gray-400 hover:text-[#ffa800] hover:bg-orange-50 transition-all" title="View Students">
                    <Eye className="w-3.5 h-3.5" />
                  </button>
                  <button className="p-1.5 rounded-lg text-gray-400 hover:text-blue-500 hover:bg-blue-50 transition-all" title="Edit">
                    <Edit className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Summary table */}
      {!loading && courses.length > 0 && (
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-5 py-4 border-b border-gray-100">
            <h3 className="font-semibold text-gray-900">Course Summary Table</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/50">
                  {['Course', 'Category', 'Duration', 'Modules', 'Lessons', 'Enrolled', 'Revenue', 'Level', 'Status'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {courses.map(course => (
                  <tr key={course.id} className="hover:bg-orange-50/30 transition-colors">
                    <td className="px-4 py-3">
                      <p className="font-medium text-gray-900 max-w-[200px] truncate">{course.title}</p>
                    </td>
                    <td className="px-4 py-3 text-gray-500 whitespace-nowrap">{course.category || '-'}</td>
                    <td className="px-4 py-3 text-gray-500 whitespace-nowrap">{course.duration || '-'}</td>
                    <td className="px-4 py-3 text-gray-700 font-medium">{course.totalModules}</td>
                    <td className="px-4 py-3 text-gray-700 font-medium">{course.totalLessons}</td>
                    <td className="px-4 py-3">
                      <span className="font-semibold text-gray-900">{course.totalEnrolled}</span>
                    </td>
                    <td className="px-4 py-3 font-semibold text-gray-900 whitespace-nowrap">
                      Rs. {course.totalRevenue.toLocaleString('en-IN')}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${LEVEL_COLORS[course.level] || 'bg-gray-100 text-gray-500'}`}>
                        {course.level}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-700">
                        {course.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
