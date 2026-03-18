export default function Loading() {
  return (
    <div className="min-h-screen p-8 space-y-8 animate-pulse">
      {/* Header Placeholder */}
      <div className="flex justify-between items-center mb-10">
        <div className="space-y-4">
          <div className="w-24 h-4 bg-white/5 rounded-full" />
          <div className="w-48 h-8 bg-white/10 rounded-xl" />
        </div>
        <div className="w-12 h-12 bg-white/5 rounded-2xl" />
      </div>

      {/* Grid Layout */}
      <div className="grid grid-cols-1 xl:grid-cols-4 gap-8">
        {/* Welcome Card Placeholder */}
        <div className="xl:col-span-4 h-48 bg-white/5 rounded-[40px]" />

        {/* Main Content Areas */}
        <div className="xl:col-span-3 grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="h-64 bg-white/5 rounded-[32px]" />
          <div className="h-64 bg-white/5 rounded-[32px]" />
          <div className="md:col-span-2 h-80 bg-white/5 rounded-[32px]" />
        </div>

        {/* Sidebar Space */}
        <div className="space-y-8">
          <div className="h-72 bg-white/5 rounded-[32px]" />
          <div className="h-72 bg-white/5 rounded-[32px]" />
        </div>
      </div>
    </div>
  )
}
