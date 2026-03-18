'use client'

import { useEffect, useState, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { User } from '@supabase/supabase-js'

export type UserRole = 'student' | 'faculty' | 'admin'

export interface Profile {
  id: string
  role: UserRole
  full_name: string | null
  roll_number: string | null
  department: string | null
  avatar_url: string | null
  phone: string | null
}

export interface UserWithProfile {
  user: User
  profile: Profile
}

export function useUser() {
  const [data, setData] = useState<UserWithProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const supabase = createClient()

  const fetchUser = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const {
        data: { user },
        error: userError,
      } = await supabase.auth.getUser()

      if (userError || !user) {
        setData(null)
        return
      }

      // Fetch profile with role
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('id, role, full_name, roll_number, department, avatar_url, phone')
        .eq('id', user.id)
        .single()

      if (profileError) {
        console.error('Error fetching profile:', profileError)
        setError(profileError.message)
        // Still set user even if profile fetch fails
        setData({
          user,
          profile: {
            id: user.id,
            role: 'student',
            full_name: user.user_metadata?.full_name || null,
            roll_number: null,
            department: null,
            avatar_url: null,
            phone: null,
          },
        })
        return
      }

      setData({
        user,
        profile: profile as Profile,
      })
    } catch (err) {
      console.error('Unexpected error:', err)
      setError('An unexpected error occurred')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    fetchUser()

    // Listen for auth state changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        fetchUser()
      } else {
        setData(null)
        setLoading(false)
      }
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [fetchUser, supabase.auth])

  const signOut = useCallback(async () => {
    await supabase.auth.signOut()
    setData(null)
  }, [supabase.auth])

  return {
    user: data?.user ?? null,
    profile: data?.profile ?? null,
    role: data?.profile?.role ?? null,
    loading,
    error,
    signOut,
    refresh: fetchUser,
  }
}
