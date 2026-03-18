import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { WelcomeCard } from '@/components/dashboard/welcome-card'
import { AttendanceWidget } from '@/components/dashboard/attendance-widget'
import { LibraryWidget } from '@/components/dashboard/library-widget'
import { ComplaintsList } from '@/components/dashboard/complaints-list'
import { GradeOverview } from '@/components/dashboard/grade-overview'
import { NotificationBell } from '@/components/dashboard/notification-bell'

export default async function StudentDashboard() {
  const supabase = await createClient()

  // 1. Authenticate and check role
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('*, departments(name)')
    .eq('id', user.id)
    .single()

  if (!profile || profile.role !== 'student') {
    const target = profile?.role ? `/dashboard/${profile.role}` : '/login';
    redirect(target);
  }

  // 2. Fetch all student-related data in parallel
  const [
    { data: enrollments },
    { data: attendanceRecords },
    { data: libraryBooks },
    { data: complaints },
    { data: grades },
    { data: notifications }
  ] = await Promise.all([
    // Enrolled courses
    supabase.from('enrollments').select('*, courses(*)').eq('student_id', user.id),
    // Attendance data
    supabase.from('attendance_records').select('*, session:attendance_sessions(course_id)').eq('student_id', user.id),
    // Currently issued books (returned_at IS NULL)
    supabase.from('book_issues').select('*, books(*)').eq('student_id', user.id).is('returned_at', null),
    // Student complaints
    supabase.from('complaints').select('*').eq('raised_by', user.id).order('created_at', { ascending: false }).limit(5),
    // Student grades
    supabase.from('grades').select('*').eq('student_id', user.id),
    // Unread notifications
    supabase.from('notifications').select('*').eq('user_id', user.id).order('created_at', { ascending: false }).limit(10)
  ])

  // 3. Process Attendance Data
  const courseAttendance: Record<string, { present: number; total: number; name: string; code: string }> = {}
  
  // Initialize with enrolled courses
  enrollments?.forEach(en => {
    courseAttendance[en.courses.id] = { present: 0, total: 0, name: en.courses.name, code: en.courses.code }
  })

  // Count attendance
  attendanceRecords?.forEach(rec => {
    const courseId = (rec.session as any)?.course_id
    if (courseId && courseAttendance[courseId]) {
      courseAttendance[courseId].total += 1
      if (rec.status === 'present') courseAttendance[courseId].present += 1
    }
  })

  const attendanceStats = Object.values(courseAttendance).map(stat => ({
    courseName: stat.name,
    courseCode: stat.code,
    percentage: stat.total > 0 ? (stat.present / stat.total) * 100 : 0
  }))

  // 4. Process Library Data
  const issuedBooks = libraryBooks?.map(b => ({
    title: b.books.title,
    dueDate: b.due_date,
    isOverdue: new Date(b.due_date) < new Date() && !b.returned_at
  })) || []

  // 5. Process Grade/GPA Data
  let totalPoints = 0
  let totalGradeCredits = 0
  const gradeToPoints: Record<string, number> = { 'A+': 10, 'A': 9, 'B+': 8, 'B': 7, 'C': 6, 'D': 5, 'F': 0 }
  
  grades?.forEach(g => {
    const points = gradeToPoints[g.grade_letter || 'F'] || 0
    totalPoints += points
    totalGradeCredits += 1 // assuming 1 course = equal weight for GPA if credits aren't linked here
  })
  
  const gpa = totalGradeCredits > 0 ? Number((totalPoints / totalGradeCredits).toFixed(2)) : 0

  return (
    <div className="min-h-screen bg-transparent p-6 md:p-8 space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      {/* Header with Search and Notifications */}
      <header className="flex items-center justify-between mb-2">
        <div>
          <h2 className="text-white/40 text-sm font-semibold uppercase tracking-widest">Overview</h2>
          <p className="text-white text-2xl font-bold tracking-tight">Student Dashboard</p>
        </div>
        <div className="flex items-center gap-4">
          <div className="hidden lg:flex items-center bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-slate-500 gap-3 group focus-within:border-indigo-500/50 transition-all">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input type="text" placeholder="Search resources..." className="bg-transparent border-none outline-none text-white text-sm w-48" />
          </div>
          <NotificationBell initialNotifications={notifications || []} />
        </div>
      </header>

      {/* Main Grid Layout */}
      <div className="grid grid-cols-1 xl:grid-cols-4 gap-8">
        {/* Welcome Section */}
        <div className="xl:col-span-4 translate-y-0 hover:-translate-y-1 transition-transform duration-300">
          <WelcomeCard 
            name={profile?.full_name} 
            rollNumber={profile?.roll_number} 
            department={(profile?.departments as any)?.name} 
          />
        </div>

        {/* Left Column (Main Stats) */}
        <div className="xl:col-span-3 grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* Attendance */}
            <AttendanceWidget stats={attendanceStats} />

            {/* GPA/Academic Overview */}
            <GradeOverview currentGpa={gpa} totalCredits={grades?.length || 0} />

            {/* Library Section */}
            <LibraryWidget books={issuedBooks} className="md:col-span-2" />
        </div>

        {/* Right Column (Side Widgets) */}
        <div className="space-y-8">
          {/* Complaints */}
          <ComplaintsList complaints={complaints || []} />

          {/* Quick Schedule Today placeholder */}
          <div className="bg-gradient-to-br from-indigo-950/40 to-slate-900/40 border border-white/10 rounded-3xl p-6 relative overflow-hidden group hover:border-indigo-500/30 transition-all">
             {/* Simple Glass effect */}
             <div className="absolute top-0 right-0 w-24 h-24 bg-indigo-500/10 rounded-full blur-2xl group-hover:bg-indigo-500/20 transition-all" />
             
             <h3 className="text-white font-bold text-xl mb-6">Today&apos;s Classes</h3>
             <div className="space-y-4">
               {enrollments?.length ? enrollments.slice(0, 3).map((en, i) => (
                 <div key={i} className="flex gap-4 items-start pb-4 border-b border-white/5 last:border-0">
                   <div className="w-10 h-10 rounded-xl bg-white/5 flex flex-col items-center justify-center border border-white/10">
                     <span className="text-indigo-400 text-[10px] font-bold">14:00</span>
                   </div>
                   <div>
                     <p className="text-white text-sm font-semibold">{en.courses.name}</p>
                     <p className="text-slate-500 text-xs">Room 402 • Sem {en.courses.semester}</p>
                   </div>
                 </div>
               )) : <p className="text-slate-500 text-sm">No classes today</p>}
             </div>
             <button className="w-full mt-6 py-3 bg-white/5 hover:bg-white/10 text-white text-xs font-bold rounded-xl transition-all border border-white/10">
               VIEW FULL SCHEDULE
             </button>
          </div>
        </div>
      </div>
    </div>
  )
}
