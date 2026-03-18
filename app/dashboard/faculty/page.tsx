import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function FacultyDashboard() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, role, departments(name)')
    .eq('id', user.id)
    .single()

  if (profile?.role !== 'faculty') {
    const target = profile?.role ? `/dashboard/${profile.role}` : '/login';
    redirect(target);
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white">
          Welcome, Prof. {profile?.full_name || 'Faculty'} 👋
        </h1>
        <p className="text-slate-400 mt-1">Faculty dashboard • {(profile?.departments as any)?.name || 'General'}</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* My Courses */}
        <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-12 h-12 bg-emerald-500/10 rounded-xl flex items-center justify-center">
              <svg className="w-6 h-6 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
              </svg>
            </div>
            <div>
              <h3 className="text-white font-semibold">My Courses</h3>
              <p className="text-slate-400 text-sm">Manage courses</p>
            </div>
          </div>
          <div className="text-3xl font-bold text-emerald-400">—</div>
        </div>

        {/* Attendance Sessions */}
        <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-12 h-12 bg-blue-500/10 rounded-xl flex items-center justify-center">
              <svg className="w-6 h-6 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <h3 className="text-white font-semibold">Attendance</h3>
              <p className="text-slate-400 text-sm">Mark attendance</p>
            </div>
          </div>
          <div className="text-3xl font-bold text-blue-400">—</div>
        </div>

        {/* Grade Management */}
        <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-12 h-12 bg-amber-500/10 rounded-xl flex items-center justify-center">
              <svg className="w-6 h-6 text-amber-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </div>
            <div>
              <h3 className="text-white font-semibold">Grades</h3>
              <p className="text-slate-400 text-sm">Manage student grades</p>
            </div>
          </div>
          <div className="text-3xl font-bold text-amber-400">—</div>
        </div>
      </div>
    </div>
  )
}
