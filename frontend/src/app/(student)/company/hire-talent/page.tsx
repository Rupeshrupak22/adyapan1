'use client';

import Link from 'next/link';
import { useState } from 'react';
import { 
  Code, Database, Smartphone, Palette, TrendingUp, Users, 
  Brain, Cpu, Globe, BarChart, Briefcase, BookOpen, ChevronRight
} from 'lucide-react';
import AuthNavButtons from '@/components/AuthNavButtons';

const programCategories = [
  {
    id: 'cse-it',
    title: 'CSE / IT DOMAINS',
    count: '12 PROGRAMS',
    isActive: true,
    icon: Code,
    color: '#ffa800'
  },
  {
    id: 'management',
    title: 'MANAGEMENT & COMMERCE',
    count: '6 PROGRAMS',
    isActive: false,
    icon: Briefcase,
    color: '#6b7280'
  },
  {
    id: 'ece',
    title: 'ECE DOMAINS',
    count: '5 PROGRAMS',
    isActive: false,
    icon: Cpu,
    color: '#6b7280'
  },
  {
    id: 'economics',
    title: 'ECONOMICS',
    count: '4 PROGRAMS',
    isActive: false,
    icon: BarChart,
    color: '#6b7280'
  },
  {
    id: 'mechanical',
    title: 'MECHANICAL ENGINEERING',
    count: '4 PROGRAMS',
    isActive: false,
    icon: Users,
    color: '#6b7280'
  },
  {
    id: 'bio-sciences',
    title: 'BIO & LIFE SCIENCES',
    count: '6 PROGRAMS',
    isActive: false,
    icon: BookOpen,
    color: '#6b7280'
  },
  {
    id: 'civil',
    title: 'CIVIL ENGINEERING',
    count: '1 PROGRAM',
    isActive: false,
    icon: Globe,
    color: '#6b7280'
  }
];

const allTalentPrograms = {
  'cse-it': [
    {
      title: 'Artificial Intelligence',
      duration: '2-3 Months',
      status: 'Live',
      category: 'AI & Machine Learning',
      skills: ['Python', 'TensorFlow', 'Deep Learning', 'Neural Networks'],
      graduates: '150+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&q=80'
    },
    {
      title: 'Full Stack Development',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Web Development',
      skills: ['React', 'Node.js', 'MongoDB', 'TypeScript'],
      graduates: '200+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400&q=80'
    },
    {
      title: 'Data Science & Analytics',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Data & Analytics',
      skills: ['Python', 'SQL', 'Tableau', 'Machine Learning'],
      graduates: '120+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80'
    },
    {
      title: 'Cloud Computing (AWS)',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Cloud & DevOps',
      skills: ['AWS', 'Docker', 'Kubernetes', 'CI/CD'],
      graduates: '80+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&q=80'
    },
    {
      title: 'Mobile App Development',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Mobile Development',
      skills: ['React Native', 'Flutter', 'iOS', 'Android'],
      graduates: '90+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&q=80'
    },
    {
      title: 'Cybersecurity',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Security & Compliance',
      skills: ['Ethical Hacking', 'Network Security', 'CISSP', 'Penetration Testing'],
      graduates: '60+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=400&q=80'
    },
    {
      title: 'Machine Learning Engineering',
      duration: '3-4 Months',
      status: 'Live',
      category: 'AI & Machine Learning',
      skills: ['Python', 'Scikit-learn', 'MLOps', 'TensorFlow'],
      graduates: '75+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400&q=80'
    },
    {
      title: 'DevOps Engineering',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Cloud & DevOps',
      skills: ['Jenkins', 'Docker', 'Terraform', 'Ansible'],
      graduates: '65+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1518432031352-d6fc5c10da5a?w=400&q=80'
    },
    {
      title: 'Blockchain Development',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Blockchain & Web3',
      skills: ['Solidity', 'Ethereum', 'Smart Contracts', 'Web3.js'],
      graduates: '45+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400&q=80'
    },
    {
      title: 'Software Testing & QA',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Quality Assurance',
      skills: ['Selenium', 'Jest', 'Cypress', 'API Testing'],
      graduates: '85+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&q=80'
    },
    {
      title: 'Database Administration',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Database Management',
      skills: ['MySQL', 'PostgreSQL', 'MongoDB', 'Redis'],
      graduates: '55+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=400&q=80'
    },
    {
      title: 'UI/UX Design',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Design & User Experience',
      skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
      graduates: '70+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&q=80'
    }
  ],
  'management': [
    {
      title: 'Digital Marketing',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Marketing & Growth',
      skills: ['SEO', 'Google Ads', 'Social Media', 'Analytics'],
      graduates: '120+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80'
    },
    {
      title: 'Business Analytics',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Business Intelligence',
      skills: ['Excel', 'Power BI', 'Tableau', 'SQL'],
      graduates: '95+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80'
    },
    {
      title: 'Project Management',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Management & Leadership',
      skills: ['Agile', 'Scrum', 'JIRA', 'Risk Management'],
      graduates: '80+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&q=80'
    },
    {
      title: 'Human Resource Management',
      duration: '2-3 Months',
      status: 'Live',
      category: 'HR & Talent Management',
      skills: ['Recruitment', 'Performance Management', 'HRIS', 'Employee Relations'],
      graduates: '65+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=400&q=80'
    },
    {
      title: 'Financial Analysis',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Finance & Accounting',
      skills: ['Financial Modeling', 'Excel', 'SAP', 'Risk Analysis'],
      graduates: '70+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80'
    },
    {
      title: 'Supply Chain Management',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Operations & Logistics',
      skills: ['Logistics', 'Inventory Management', 'ERP', 'Procurement'],
      graduates: '50+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400&q=80'
    }
  ],
  'ece': [
    {
      title: 'Embedded Systems',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Hardware & Embedded',
      skills: ['C/C++', 'Arduino', 'Raspberry Pi', 'RTOS'],
      graduates: '40+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1518432031352-d6fc5c10da5a?w=400&q=80'
    },
    {
      title: 'IoT Development',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Internet of Things',
      skills: ['Sensors', 'MQTT', 'Cloud Integration', 'Edge Computing'],
      graduates: '35+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400&q=80'
    },
    {
      title: 'VLSI Design',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Chip Design',
      skills: ['Verilog', 'VHDL', 'Cadence', 'Synopsis'],
      graduates: '25+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1518432031352-d6fc5c10da5a?w=400&q=80'
    },
    {
      title: 'Signal Processing',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Digital Signal Processing',
      skills: ['MATLAB', 'DSP', 'Image Processing', 'Audio Processing'],
      graduates: '30+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80'
    },
    {
      title: 'Telecommunications',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Network & Communications',
      skills: ['5G', 'Network Protocols', 'RF Engineering', 'Antenna Design'],
      graduates: '20+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=400&q=80'
    }
  ],
  'economics': [
    {
      title: 'Economic Research & Analysis',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Research & Analytics',
      skills: ['Econometrics', 'STATA', 'R', 'Economic Modeling'],
      graduates: '25+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80'
    },
    {
      title: 'Financial Economics',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Finance & Markets',
      skills: ['Financial Markets', 'Investment Analysis', 'Portfolio Management', 'Risk Assessment'],
      graduates: '30+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&q=80'
    },
    {
      title: 'Development Economics',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Policy & Development',
      skills: ['Policy Analysis', 'Development Finance', 'Impact Assessment', 'Microfinance'],
      graduates: '20+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80'
    },
    {
      title: 'Behavioral Economics',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Consumer Behavior',
      skills: ['Consumer Psychology', 'Market Research', 'Experimental Design', 'Data Analysis'],
      graduates: '15+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80'
    }
  ],
  'mechanical': [
    {
      title: 'CAD Design & Engineering',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Design & Manufacturing',
      skills: ['AutoCAD', 'SolidWorks', 'CATIA', '3D Modeling'],
      graduates: '45+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=400&q=80'
    },
    {
      title: 'Manufacturing Engineering',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Production & Quality',
      skills: ['Lean Manufacturing', 'Six Sigma', 'Quality Control', 'Process Optimization'],
      graduates: '35+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1565043666747-69f6646db940?w=400&q=80'
    },
    {
      title: 'Robotics & Automation',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Automation & Control',
      skills: ['PLC Programming', 'Industrial Robotics', 'Control Systems', 'SCADA'],
      graduates: '30+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400&q=80'
    },
    {
      title: 'Thermal Engineering',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Energy & Thermal Systems',
      skills: ['Heat Transfer', 'HVAC', 'Energy Efficiency', 'Thermal Analysis'],
      graduates: '25+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=400&q=80'
    }
  ],
  'bio-sciences': [
    {
      title: 'Bioinformatics',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Computational Biology',
      skills: ['Python', 'R', 'Genomics', 'Protein Analysis'],
      graduates: '30+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&q=80'
    },
    {
      title: 'Biotechnology',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Biotech & Pharma',
      skills: ['Cell Culture', 'Molecular Biology', 'Fermentation', 'Quality Control'],
      graduates: '25+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=400&q=80'
    },
    {
      title: 'Clinical Research',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Medical Research',
      skills: ['Clinical Trials', 'GCP', 'Data Management', 'Regulatory Affairs'],
      graduates: '35+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400&q=80'
    },
    {
      title: 'Food Science & Technology',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Food & Nutrition',
      skills: ['Food Safety', 'Quality Assurance', 'Nutrition Analysis', 'Product Development'],
      graduates: '20+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&q=80'
    },
    {
      title: 'Environmental Science',
      duration: '2-3 Months',
      status: 'Live',
      category: 'Environment & Sustainability',
      skills: ['Environmental Monitoring', 'Waste Management', 'Sustainability', 'Impact Assessment'],
      graduates: '25+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=400&q=80'
    },
    {
      title: 'Pharmaceutical Sciences',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Drug Development',
      skills: ['Drug Discovery', 'Pharmacology', 'Formulation', 'Regulatory Science'],
      graduates: '20+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&q=80'
    }
  ],
  'civil': [
    {
      title: 'Structural Engineering',
      duration: '3-4 Months',
      status: 'Live',
      category: 'Construction & Infrastructure',
      skills: ['AutoCAD', 'STAAD Pro', 'Structural Analysis', 'Building Codes'],
      graduates: '40+ Ready to Hire',
      image: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&q=80'
    }
  ]
};

export default function HireTalentPage() {
  const [activeCategory, setActiveCategory] = useState('cse-it');
  const [displayedPrograms, setDisplayedPrograms] = useState(12);

  const currentPrograms = allTalentPrograms[activeCategory as keyof typeof allTalentPrograms] || [];
  const visiblePrograms = currentPrograms.slice(0, displayedPrograms);
  const hasMorePrograms = displayedPrograms < currentPrograms.length;

  const handleLoadMore = () => {
    setDisplayedPrograms(prev => prev + 6);
  };

  const handleCategoryChange = (categoryId: string) => {
    setActiveCategory(categoryId);
    setDisplayedPrograms(12); // Reset to show first 12 programs
  };

  return (
    <div className="min-h-screen bg-[#0f1419]">
      {/* Hero Section */}
      <section className="relative py-20 px-6 bg-gradient-to-br from-[#1a2a4e] via-[#0f1419] to-[#0f1419]">
        <div className="max-w-7xl mx-auto">
          <div
            className="text-center mb-16"
          >
            <h1 className="text-5xl md:text-6xl font-black text-white mb-6 leading-tight">
              Hire <span className="text-[#ffa800]">Job-Ready</span> Talent
              <br />
              <span className="text-[#ffa800]">From All Programs</span>
            </h1>
            <p className="text-xl text-gray-400 max-w-3xl mx-auto mb-8 leading-relaxed">
              Access pre-trained, industry-ready professionals from our comprehensive program catalog. Every candidate has completed real-world projects and is ready to contribute from day one.
            </p>

            {/* Stats */}
            <div
              className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12"
            >
              <div className="bg-[#1a2a4e]/50 rounded-2xl p-6 border border-gray-700">
                <div className="text-4xl font-black text-[#ffa800] mb-2">1000+</div>
                <p className="text-gray-300 font-semibold">Ready to Hire</p>
                <p className="text-sm text-gray-500">Across All Programs</p>
              </div>

              <div className="bg-[#1a2a4e]/50 rounded-2xl p-6 border border-gray-700">
                <div className="text-4xl font-black text-[#ffa800] mb-2">67+</div>
                <p className="text-gray-300 font-semibold">Active Programs</p>
                <p className="text-sm text-gray-500">Industry-Aligned</p>
              </div>

              <div className="bg-[#1a2a4e]/50 rounded-2xl p-6 border border-gray-700">
                <div className="text-4xl font-black text-[#ffa800] mb-2">95%</div>
                <p className="text-gray-300 font-semibold">Job Readiness</p>
                <p className="text-sm text-gray-500">Verified Skills</p>
              </div>

              <div className="bg-[#1a2a4e]/50 rounded-2xl p-6 border border-gray-700">
                <div className="text-4xl font-black text-[#ffa800] mb-2">150+</div>
                <p className="text-gray-300 font-semibold">Partner Companies</p>
                <p className="text-sm text-gray-500">Hiring Successfully</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <section className="py-20 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
            {/* Sidebar - Program Categories */}
            <div className="lg:col-span-1">
              <div
                className="space-y-2"
              >
                {programCategories.map((category, i) => (
                  <button
                    key={category.id}
                    onClick={() => handleCategoryChange(category.id)}
                    className={`w-full text-left p-4 rounded-xl transition-all duration-300 ${
                      category.id === activeCategory
                        ? 'bg-[#ffa800] text-white'
                        : 'bg-[#1a2a4e]/30 text-gray-300 hover:bg-[#1a2a4e]/50'
                    }`}
                  >
                    <div className="flex items-center space-x-3">
                      <category.icon className="w-5 h-5" />
                      <div className="flex-1">
                        <h3 className="font-bold text-sm">{category.title}</h3>
                        <p className="text-xs opacity-80">{category.count}</p>
                      </div>
                      <ChevronRight className="w-4 h-4" />
                    </div>
                  </button>
                ))}
              </div>
            </div>

            {/* Main Content - Talent Programs */}
            <div className="lg:col-span-3">
              <div
                key={activeCategory}
                className="grid grid-cols-1 md:grid-cols-2 gap-6"
              >
                {visiblePrograms.map((program, i) => (
                  <div
                    key={i}
                    className="bg-[#1a2a4e]/30 rounded-2xl overflow-hidden border border-gray-700 hover:border-[#ffa800]/50 transition-all duration-300 group"
                  >
                    {/* Program Image */}
                    <div className="relative h-48 overflow-hidden">
                      <img
                        src={program.image}
                        alt={program.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-[#0f1419] via-transparent to-transparent" />
                      <div className="absolute top-4 right-4">
                        <span className="px-3 py-1 bg-green-500 text-white text-xs font-bold rounded-full">
                          â-- {program.status}
                        </span>
                      </div>
                      <div className="absolute bottom-4 left-4">
                        <span className="px-3 py-1 bg-[#ffa800] text-white text-xs font-bold rounded-full">
                          {program.duration}
                        </span>
                      </div>
                    </div>

                    {/* Program Content */}
                    <div className="p-6">
                      <h3 className="text-xl font-bold text-white mb-2">{program.title}</h3>
                      <p className="text-[#ffa800] text-sm font-semibold mb-3">{program.category}</p>
                      
                      {/* Skills */}
                      <div className="flex flex-wrap gap-2 mb-4">
                        {program.skills.map((skill, j) => (
                          <span
                            key={j}
                            className="px-2 py-1 bg-gray-700 text-gray-300 text-xs rounded-lg"
                          >
                            {skill}
                          </span>
                        ))}
                      </div>

                      {/* Graduates Available */}
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-white font-bold text-lg">{program.graduates}</p>
                          <p className="text-gray-400 text-sm">Available Now</p>
                        </div>
                        <Link
                          href="/company/find-employee"
                          className="px-4 py-2 bg-[#ffa800] text-white rounded-lg font-semibold text-sm hover:bg-[#e69500] transition-colors"
                        >
                          View Talent
                        </Link>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Load More */}
              {hasMorePrograms && (
                <div
                  className="text-center mt-12 col-span-full"
                >
                  <button
                    onClick={handleLoadMore}
                    className="px-8 py-3 bg-[#1a2a4e] text-white rounded-lg font-semibold hover:bg-[#1a2a4e]/80 transition-colors border border-gray-700"
                  >
                    Load More Programs
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-6 bg-gradient-to-r from-[#ffa800]/10 to-[#ff6b00]/10 border-t border-gray-800">
        <div className="max-w-4xl mx-auto text-center">
          <div
          >
            <h2 className="text-4xl md:text-5xl font-black text-white mb-6">
              Ready to Hire Top Talent?
            </h2>
            <p className="text-xl text-gray-400 mb-10 leading-relaxed">
              Connect with our pre-trained, job-ready professionals. Schedule a consultation to discuss your hiring needs and find the perfect candidates for your team.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <div>
                <Link
                  href="/company/find-employee"
                  className="inline-flex items-center px-8 py-4 bg-[#ffa800] text-white rounded-lg font-bold text-lg hover:bg-[#e69500] transition-colors"
                >
                  Start Hiring Now
                  <ChevronRight className="w-5 h-5 ml-2" />
                </Link>
              </div>
              
              <div>
                <Link
                  href="/contact"
                  className="inline-flex items-center px-8 py-4 bg-transparent text-white rounded-lg font-bold text-lg border-2 border-gray-600 hover:border-[#ffa800] transition-colors"
                >
                  Schedule Consultation
                </Link>
              </div>
            </div>

            <p className="text-gray-500 text-sm mt-8">
              No upfront costs | Pre-vetted candidates | 30-day replacement guarantee
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
