-- ============================================================
-- ENABLE SUPABASE REALTIME + STORAGE BUCKETS
-- Migration: 20260318121500_realtime_and_storage
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. ENABLE REALTIME on selected tables
-- ────────────────────────────────────────────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE public.attendance_records;
ALTER PUBLICATION supabase_realtime ADD TABLE public.complaints;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- REPLICA IDENTITY FULL so UPDATE/DELETE events include full row
ALTER TABLE public.attendance_records REPLICA IDENTITY FULL;
ALTER TABLE public.complaints         REPLICA IDENTITY FULL;
ALTER TABLE public.notifications      REPLICA IDENTITY FULL;


-- ────────────────────────────────────────────────────────────
-- 2. STORAGE BUCKETS
-- ────────────────────────────────────────────────────────────

-- avatars (public, 5MB, images only)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880,
        ARRAY['image/jpeg','image/png','image/webp','image/gif']);

-- book-covers (public, 5MB, images only)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('book-covers', 'book-covers', true, 5242880,
        ARRAY['image/jpeg','image/png','image/webp']);

-- complaint-attachments (private, 10MB, images + pdf + video)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('complaint-attachments', 'complaint-attachments', false, 10485760,
        ARRAY['image/jpeg','image/png','image/webp','application/pdf','video/mp4']);


-- ────────────────────────────────────────────────────────────
-- 3. STORAGE RLS POLICIES
-- ────────────────────────────────────────────────────────────

-- ── avatars ──
CREATE POLICY "avatars_select_public"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');

CREATE POLICY "avatars_insert_own"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_update_own"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_delete_own"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ── book-covers ──
CREATE POLICY "book_covers_select_public"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'book-covers');

CREATE POLICY "book_covers_insert_staff"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'book-covers' AND (public.is_admin() OR public.is_faculty()));

CREATE POLICY "book_covers_update_staff"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'book-covers' AND (public.is_admin() OR public.is_faculty()));

CREATE POLICY "book_covers_delete_admin"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'book-covers' AND public.is_admin());

-- ── complaint-attachments ──
CREATE POLICY "complaint_att_select_own_or_admin"
  ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'complaint-attachments'
    AND ((storage.foldername(name))[1] = auth.uid()::text OR public.is_admin()));

CREATE POLICY "complaint_att_insert_own"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'complaint-attachments'
    AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "complaint_att_update_own"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'complaint-attachments'
    AND ((storage.foldername(name))[1] = auth.uid()::text OR public.is_admin()));

CREATE POLICY "complaint_att_delete_admin"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'complaint-attachments' AND public.is_admin());
