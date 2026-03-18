'use client'

import { useState } from 'react'

interface Notification {
  id: string
  title: string
  message: string | null
  is_read: boolean
  created_at: string
  type: string | null
}

interface NotificationBellProps {
  initialNotifications: Notification[]
}

export function NotificationBell({ initialNotifications }: NotificationBellProps) {
  const [notifications, setNotifications] = useState(initialNotifications)
  const [isOpen, setIsOpen] = useState(false)
  
  const unreadCount = notifications.filter(n => !n.is_read).length

  return (
    <div className="relative">
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-slate-400 hover:text-white bg-white/5 border border-white/10 rounded-xl transition-all hover:bg-white/10"
      >
        <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center ring-4 ring-slate-950">
            {unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
          <div className="absolute right-0 mt-4 w-80 bg-slate-900 border border-white/10 rounded-2xl shadow-2xl z-50 overflow-hidden transform origin-top-right transition-all">
            <div className="p-4 border-b border-white/5 flex items-center justify-between bg-white/5">
              <h4 className="text-white font-bold">Notifications</h4>
              <span className="text-xs text-indigo-400 font-medium">{unreadCount} unread</span>
            </div>
            
            <div className="max-h-96 overflow-y-auto">
              {notifications.length > 0 ? (
                notifications.map((n) => (
                  <div key={n.id} className="p-4 border-b border-white/5 hover:bg-white/[0.02] transition-colors cursor-pointer group">
                    <p className={`text-sm ${n.is_read ? 'text-slate-400' : 'text-white font-semibold'}`}>{n.title}</p>
                    <p className="text-xs text-slate-500 mt-1 line-clamp-2">{n.message}</p>
                    <p className="text-[10px] text-slate-600 mt-2">{new Date(n.created_at).toLocaleDateString()}</p>
                  </div>
                ))
              ) : (
                <div className="p-8 text-center">
                  <p className="text-slate-500 text-sm">No notifications yet</p>
                </div>
              )}
            </div>
            
            <div className="p-3 text-center bg-white/5">
              <button className="text-xs text-slate-400 hover:text-white font-medium">View all notifications</button>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
