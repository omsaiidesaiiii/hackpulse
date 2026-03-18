import { cn } from "@/lib/utils"

interface GradeOverviewProps {
  currentGpa: number
  totalCredits: number
  className?: string
}

export function GradeOverview({ currentGpa, totalCredits, className }: GradeOverviewProps) {
  const percentage = (currentGpa / 10) * 100 // assuming scale of 10

  return (
    <div className={cn("bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6", className)}>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-white font-bold text-xl">Academic Summary</h3>
          <p className="text-slate-500 text-xs">Current Performance</p>
        </div>
        <div className="w-10 h-10 bg-emerald-500/10 rounded-2xl flex items-center justify-center text-emerald-400">
          <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
        </div>
      </div>

      <div className="flex flex-col items-center justify-center py-4">
        {/* Simple Circle Representation */}
        <div className="relative w-32 h-32 flex items-center justify-center transition-transform hover:scale-105 duration-300">
            <svg className="w-full h-full transform -rotate-90">
                <circle
                    cx="64"
                    cy="64"
                    r="58"
                    stroke="rgba(255, 255, 255, 0.05)"
                    strokeWidth="12"
                    fill="transparent"
                />
                <circle
                    cx="64"
                    cy="64"
                    r="58"
                    stroke="url(#gradient)"
                    strokeWidth="12"
                    fill="transparent"
                    strokeLinecap="round"
                    strokeDasharray={364.42}
                    strokeDashoffset={364.42 - (364.42 * (percentage / 100))}
                />
                <defs>
                    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#10b981" />
                        <stop offset="100%" stopColor="#3b82f6" />
                    </linearGradient>
                </defs>
            </svg>
            <div className="absolute flex flex-col items-center">
                <span className="text-3xl font-bold text-white tracking-tighter">{currentGpa}</span>
                <span className="text-slate-500 text-[10px] uppercase font-bold tracking-widest">GPA</span>
            </div>
        </div>

        <div className="grid grid-cols-2 gap-4 w-full mt-8">
          <div className="p-3 bg-white/5 border border-white/5 rounded-2xl text-center">
            <p className="text-slate-500 text-[10px] uppercase font-bold tracking-wider mb-1">Total Credits</p>
            <p className="text-white font-bold">{totalCredits}</p>
          </div>
          <div className="p-3 bg-white/5 border border-white/5 rounded-2xl text-center">
            <p className="text-slate-500 text-[10px] uppercase font-bold tracking-wider mb-1">Academic Year</p>
            <p className="text-white font-bold">2025-26</p>
          </div>
        </div>
      </div>
    </div>
  )
}
