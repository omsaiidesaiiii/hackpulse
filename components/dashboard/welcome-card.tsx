import { cn } from "@/lib/utils"

interface WelcomeCardProps {
  name: string
  rollNumber: string | null
  department: string | null
  className?: string
}

export function WelcomeCard({ name, rollNumber, department, className }: WelcomeCardProps) {
  return (
    <div className={cn(
      "relative overflow-hidden p-8 rounded-3xl bg-gradient-to-br from-indigo-600 to-purple-600 shadow-2xl shadow-indigo-500/20",
      className
    )}>
      {/* Decorative patterns */}
      <div className="absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 bg-white/10 rounded-full blur-3xl" />
      <div className="absolute bottom-0 left-0 -ml-8 -mb-8 w-32 h-32 bg-white/5 rounded-full blur-xl" />

      <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
            Welcome back, {name}! 👋
          </h1>
          <div className="flex flex-wrap items-center gap-3 text-white/80">
            {department && (
              <span className="px-3 py-1 bg-white/10 backdrop-blur-md rounded-full text-xs font-semibold ring-1 ring-white/20">
                🏢 {department}
              </span>
            )}
            {rollNumber && (
              <span className="px-3 py-1 bg-white/10 backdrop-blur-md rounded-full text-xs font-semibold ring-1 ring-white/20">
                🆔 {rollNumber}
              </span>
            )}
            <span className="px-3 py-1 bg-white/10 backdrop-blur-md rounded-full text-xs font-semibold ring-1 ring-white/20">
              📅 Semester 4
            </span>
          </div>
        </div>
        
        <div className="bg-white/10 backdrop-blur-md border border-white/20 p-4 rounded-2xl flex items-center gap-4">
          <div className="text-right">
            <p className="text-white/60 text-xs font-medium uppercase tracking-wider">Overall Status</p>
            <p className="text-white font-bold">Good Standing</p>
          </div>
          <div className="w-12 h-12 bg-white rounded-xl flex items-center justify-center">
            <svg className="w-6 h-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
      </div>
    </div>
  )
}
