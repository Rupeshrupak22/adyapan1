'use client';

import api from '@/lib/api';
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Package, Users, IndianRupee, TrendingUp, Star,
  CheckCircle, ArrowUpRight,
} from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, Cell,
} from 'recharts';

interface Plan {
  id: string;
  label: string;
  price: number;
  description: string;
  purchaseCount: number;
  revenue: number;
  paymentCount: number;
}

const PLAN_COLORS = ['#ffa800', '#ff6b00', '#f59e0b', '#d97706'];
const PLAN_FEATURES: Record<string, string[]> = {
  'Plan 1': ['Course access', 'Study materials', 'Community support', 'Basic certificate'],
  'Plan 2': ['Everything in Plan 1', '1-on-1 mentorship sessions', 'Live doubt clearing', 'Enhanced certificate'],
  'Plan 3': ['Everything in Plan 2', 'Real-world projects', 'Portfolio building', 'Industry certificate'],
  'Plan 4': ['Everything in Plan 3', 'Placement assistance', 'Resume review', 'Interview prep', 'Job referrals'],
};

export default function AdminPlansPage() {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/api/admin/plans')
      .then(res => setPlans(res.data.plans || []))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const totalRevenue = plans.reduce((s, p) => s + p.revenue, 0);
  const totalPurchases = plans.reduce((s, p) => s + p.purchaseCount, 0);

  return (
    <div className="p-4 sm:p-6 lg:p-8 space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Plans</h1>
          <p className="text-gray-500 text-sm mt-0.5">Manage and monitor Adyapan subscription plans</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 px-3 py-2 bg-orange-50 rounded-xl border border-orange-100">
            <Users className="w-4 h-4 text-[#ffa800]" />
            <span className="text-sm font-semibold text-[#ffa800]">{totalPurchases} purchases</span>
          </div>
          <div className="flex items-center gap-2 px-3 py-2 bg-green-50 rounded-xl border border-green-100">
            <IndianRupee className="w-4 h-4 text-green-600" />
            <span className="text-sm font-semibold text-green-700">Rs. {totalRevenue.toLocaleString('en-IN')}</span>
          </div>
        </div>
      </div>

      {/* Plan cards */}
      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white rounded-2xl p-5 h-64 animate-pulse border border-gray-100" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
          {plans.map((plan, i) => {
            const isPremium = plan.id === 'plan-4';
            const features = PLAN_FEATURES[plan.label] || [];
            return (
              <motion.div
                key={plan.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.08 }}
                className={`relative bg-white rounded-2xl p-5 shadow-sm border transition-all hover:shadow-md
                  ${isPremium ? 'border-[#ffa800]/40 ring-2 ring-[#ffa800]/20' : 'border-gray-100'}`}
              >
                {isPremium && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                    <span className="flex items-center gap-1 px-3 py-1 rounded-full text-xs font-bold text-white"
                      style={{ background: 'linear-gradient(135deg, #ffa800, #ff6b00)' }}>
                      <Star className="w-3 h-3" />
                      Most Popular
                    </span>
                  </div>
                )}

                {/* Plan header */}
                <div className="flex items-center justify-between mb-4">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center"
                    style={{ backgroundColor: `${PLAN_COLORS[i]}20` }}>
                    <Package className="w-5 h-5" style={{ color: PLAN_COLORS[i] }} />
                  </div>
                  <ArrowUpRight className="w-4 h-4 text-gray-300" />
                </div>

                <h3 className="font-bold text-gray-900 text-lg mb-0.5">{plan.label}</h3>
                <p className="text-2xl font-extrabold mb-1" style={{ color: PLAN_COLORS[i] }}>
                  Rs. {plan.price.toLocaleString('en-IN')}
                </p>
                <p className="text-xs text-gray-400 mb-4">{plan.description}</p>

                {/* Stats */}
                <div className="grid grid-cols-2 gap-2 mb-4">
                  <div className="p-2.5 bg-gray-50 rounded-xl">
                    <p className="text-[10px] text-gray-400 mb-0.5">Purchases</p>
                    <p className="text-sm font-bold text-gray-900">{plan.purchaseCount}</p>
                  </div>
                  <div className="p-2.5 bg-gray-50 rounded-xl">
                    <p className="text-[10px] text-gray-400 mb-0.5">Revenue</p>
                    <p className="text-sm font-bold text-gray-900">Rs. {(plan.revenue / 1000).toFixed(1)}k</p>
                  </div>
                </div>

                {/* Features */}
                <div className="space-y-1.5">
                  {features.slice(0, 4).map(f => (
                    <div key={f} className="flex items-center gap-2">
                      <CheckCircle className="w-3.5 h-3.5 flex-shrink-0" style={{ color: PLAN_COLORS[i] }} />
                      <span className="text-xs text-gray-600">{f}</span>
                    </div>
                  ))}
                </div>
              </motion.div>
            );
          })}
        </div>
      )}

      {/* Revenue comparison chart */}
      {!loading && plans.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100"
          >
            <h3 className="font-semibold text-gray-900 mb-1">Revenue by Plan</h3>
            <p className="text-xs text-gray-400 mb-5">Total revenue generated per plan</p>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={plans} barSize={40}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
                <XAxis dataKey="label" tick={{ fontSize: 12, fill: '#9ca3af' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#9ca3af' }} axisLine={false} tickLine={false}
                  tickFormatter={v => `Rs. ${(v / 1000).toFixed(0)}k`} />
                <Tooltip
                  formatter={(v: any) => [`Rs. ${v.toLocaleString('en-IN')}`, 'Revenue']}
                  contentStyle={{ borderRadius: 12, border: '1px solid #f3f4f6', fontSize: 12 }}
                />
                <Bar dataKey="revenue" radius={[8, 8, 0, 0]}>
                  {plans.map((_, i) => (
                    <Cell key={i} fill={PLAN_COLORS[i % PLAN_COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.45 }}
            className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100"
          >
            <h3 className="font-semibold text-gray-900 mb-1">Purchases by Plan</h3>
            <p className="text-xs text-gray-400 mb-5">Number of students per plan</p>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={plans} barSize={40}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
                <XAxis dataKey="label" tick={{ fontSize: 12, fill: '#9ca3af' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#9ca3af' }} axisLine={false} tickLine={false} />
                <Tooltip
                  formatter={(v: any) => [v, 'Purchases']}
                  contentStyle={{ borderRadius: 12, border: '1px solid #f3f4f6', fontSize: 12 }}
                />
                <Bar dataKey="purchaseCount" radius={[8, 8, 0, 0]}>
                  {plans.map((_, i) => (
                    <Cell key={i} fill={PLAN_COLORS[i % PLAN_COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </motion.div>
        </div>
      )}

      {/* Detailed table */}
      {!loading && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden"
        >
          <div className="px-5 py-4 border-b border-gray-100">
            <h3 className="font-semibold text-gray-900">Plan Details</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50/50">
                  {['Plan', 'Price', 'Description', 'Purchases', 'Revenue', 'Avg. per Sale'].map(h => (
                    <th key={h} className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {plans.map((plan, i) => (
                  <tr key={plan.id} className="hover:bg-orange-50/30 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2.5">
                        <div className="w-3 h-3 rounded-full" style={{ background: PLAN_COLORS[i] }} />
                        <span className="font-semibold text-gray-900">{plan.label}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 font-bold" style={{ color: PLAN_COLORS[i] }}>
                      Rs. {plan.price.toLocaleString('en-IN')}
                    </td>
                    <td className="px-4 py-3 text-gray-500">{plan.description}</td>
                    <td className="px-4 py-3 font-semibold text-gray-900">{plan.purchaseCount}</td>
                    <td className="px-4 py-3 font-semibold text-gray-900">Rs. {plan.revenue.toLocaleString('en-IN')}</td>
                    <td className="px-4 py-3 text-gray-600">
                      {plan.purchaseCount > 0
                        ? `Rs. ${Math.round(plan.revenue / plan.purchaseCount).toLocaleString('en-IN')}`
                        : '-'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>
      )}
    </div>
  );
}
