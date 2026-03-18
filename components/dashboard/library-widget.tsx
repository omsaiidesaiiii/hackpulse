import { cn } from "@/lib/utils"

interface IssuedBook {
  title: string
  dueDate: string
  isOverdue: boolean
}

interface LibraryWidgetProps {
  books: IssuedBook[]
  className?: string
}

export function LibraryWidget({ books, className }: LibraryWidgetProps) {
  return (
    <div className={cn("bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6", className)}>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-white font-bold text-xl">Library</h3>
          <p className="text-slate-500 text-xs">Issued Books & Returns</p>
        </div>
        <div className="w-10 h-10 bg-purple-500/10 rounded-2xl flex items-center justify-center text-purple-400">
          <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
      </div>

      <div className="space-y-4">
        {books.map((book, idx) => (
          <div key={idx} className="p-4 rounded-2xl bg-white/[0.03] border border-white/5 flex items-center justify-between group hover:bg-white/5 transition-all">
            <div className="min-w-0">
              <p className="text-white text-sm font-semibold truncate">{book.title}</p>
              <p className={cn("text-xs mt-1", book.isOverdue ? "text-red-400 font-bold" : "text-slate-500")}>
                Due: {new Date(book.dueDate).toLocaleDateString()}
              </p>
            </div>
            {book.isOverdue && (
              <span className="px-2 py-1 bg-red-500/20 text-red-400 text-[10px] font-bold uppercase rounded-md animate-pulse">
                Overdue
              </span>
            )}
          </div>
        ))}
        {books.length === 0 && (
          <div className="text-center py-8">
            <div className="w-12 h-12 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-3">
              <svg className="w-6 h-6 text-slate-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
            </div>
            <p className="text-slate-500 text-sm">No books issued</p>
          </div>
        )}
      </div>
    </div>
  )
}
