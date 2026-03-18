import { cn } from "@/lib/utils"

interface AttendanceStat {
  courseName: string
  courseCode: string
  percentage: number
}

interface AttendanceWidgetProps {
  stats: AttendanceStat[]
  className?: string
}

export function AttendanceWidget({ stats, className }: AttendanceWidgetProps) {
  return (
    <div className={cn("bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6 h-full", className)}>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-white font-bold text-xl">Attendance</h3>
          <p className="text-slate-500 text-xs">Per Course Summary</p>
        </div>
        <div className="w-10 h-10 bg-indigo-500/10 rounded-2xl flex items-center justify-center text-indigo-400">
          <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
          </svg>
        </div>
      </div>

      <div className="space-y-6">
        {stats.map((course, idx) => (
          <div key={idx}>
            <div className="flex items-center justify-between mb-2">
              <div className="flex flex-col">
                <span className="text-white text-sm font-semibold">{course.courseName}</span>
                <span className="text-slate-500 text-[10px] tracking-wider uppercase">{course.courseCode}</span>
              </div>
              <span className={cn(
                "text-sm font-bold",
                course.percentage >= 75 ? "text-emerald-400" : course.percentage >= 65 ? "text-amber-400" : "text-red-400"
              )}>
                {Math.round(course.percentage)}%
              </span>
            </div>
            <div className="h-2 w-full bg-slate-800 rounded-full overflow-hidden">
              <div 
                className={cn(
                  "h-full rounded-full transition-all duration-1000",
                  course.percentage >= 75 ? "bg-emerald-500" : course.percentage >= 65 ? "bg-amber-500" : "bg-red-500"
                )}
                style={{ width: `${course.percentage}%` }}
              />
            </div>
          </div>
        ))}
        {stats.length === 0 && <p className="text-center text-slate-500 text-sm py-4">No data available</p>}
      </div>
    </div>
  )
}
