import { cn } from "@/lib/utils"

interface Complaint {
  id: string
  title: string
  category: string
  status: 'pending' | 'in-review' | 'resolved'
  created_at: string
}

interface ComplaintsListProps {
  complaints: Complaint[]
  className?: string
}

export function ComplaintsList({ complaints, className }: ComplaintsListProps) {
  const statusStyles = {
    pending: "bg-slate-500/10 text-slate-400 border-slate-500/20",
    "in-review": "bg-amber-500/10 text-amber-500 border-amber-500/20",
    resolved: "bg-emerald-500/10 text-emerald-500 border-emerald-500/20",
  }

  return (
    <div className={cn("bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6", className)}>
       <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-white font-bold text-xl">Recent Complaints</h3>
          <p className="text-slate-500 text-xs">Tickets help history</p>
        </div>
        <div className="w-10 h-10 bg-amber-500/10 rounded-2xl flex items-center justify-center text-amber-400">
          <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.96-.833-2.73 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>
      </div>

      <div className="space-y-4">
        {complaints.map((c) => (
          <div key={c.id} className="p-4 rounded-2xl bg-white/[0.02] border border-white/5">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[10px] text-slate-500 uppercase tracking-widest font-bold font-mono">{c.category}</span>
              <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold border ${statusStyles[c.status]}`}>
                {c.status.toUpperCase()}
              </span>
            </div>
            <p className="text-white text-sm font-medium mb-2">{c.title}</p>
            <p className="text-slate-600 text-[10px]">{new Date(c.created_at).toLocaleDateString()}</p>
          </div>
        ))}
        {complaints.length === 0 && <p className="text-center text-slate-500 text-sm py-4">No recent complaints</p>}
      </div>
    </div>
  )
}
