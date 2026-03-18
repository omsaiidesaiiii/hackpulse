-- ============================================================
-- SMART COLLEGE CLOUD PLATFORM — COMPLETE SCHEMA
-- Migration: 20260318120900_complete_schema
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 0. EXTENSIONS
-- ────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ────────────────────────────────────────────────────────────
-- 1. CUSTOM ENUM TYPES
-- ────────────────────────────────────────────────────────────
-- Drop old enum if it exists (from previous migration)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    -- already exists, skip
    NULL;
  ELSE
    CREATE TYPE user_role AS ENUM ('student', 'faculty', 'admin');
  END IF;
END $$;

CREATE TYPE attendance_status  AS ENUM ('present', 'absent', 'late');
CREATE TYPE complaint_category AS ENUM ('infrastructure', 'academic', 'hostel', 'other');
CREATE TYPE complaint_status   AS ENUM ('pending', 'in-review', 'resolved');
CREATE TYPE asset_condition    AS ENUM ('good', 'damaged', 'maintenance');
CREATE TYPE book_issue_role    AS ENUM ('faculty', 'admin');

-- ────────────────────────────────────────────────────────────
-- 2. DROP EXISTING users TABLE (will be replaced by profiles)
-- ────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.users CASCADE;

-- ────────────────────────────────────────────────────────────
-- 3. TABLES
-- ────────────────────────────────────────────────────────────

-- 3.1  departments
CREATE TABLE public.departments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL UNIQUE,
  code       TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.2  profiles (extends auth.users)
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role          user_role   NOT NULL DEFAULT 'student',
  full_name     TEXT        NOT NULL,
  roll_number   TEXT        UNIQUE,
  department_id UUID        REFERENCES public.departments(id) ON DELETE SET NULL,
  avatar_url    TEXT,
  phone         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.3  courses
CREATE TABLE public.courses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT    NOT NULL,
  code          TEXT    NOT NULL UNIQUE,
  department_id UUID    NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
  faculty_id    UUID    NOT NULL REFERENCES public.profiles(id)    ON DELETE CASCADE,
  semester      INT     NOT NULL CHECK (semester BETWEEN 1 AND 8),
  credits       INT     NOT NULL CHECK (credits > 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.4  enrollments
CREATE TABLE public.enrollments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  course_id     UUID NOT NULL REFERENCES public.courses(id)  ON DELETE CASCADE,
  academic_year TEXT NOT NULL,                              -- e.g. '2025-26'
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (student_id, course_id, academic_year)
);

-- 3.5  attendance_sessions
CREATE TABLE public.attendance_sessions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id      UUID NOT NULL REFERENCES public.courses(id)  ON DELETE CASCADE,
  faculty_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  date           DATE NOT NULL,
  start_time     TIME NOT NULL,
  end_time       TIME NOT NULL,
  qr_code_token  TEXT UNIQUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.6  attendance_records
CREATE TABLE public.attendance_records (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID              NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
  student_id UUID              NOT NULL REFERENCES public.profiles(id)            ON DELETE CASCADE,
  status     attendance_status NOT NULL DEFAULT 'absent',
  marked_at  TIMESTAMPTZ       NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ       NOT NULL DEFAULT now(),
  UNIQUE (session_id, student_id)
);

-- 3.7  books
CREATE TABLE public.books (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL,
  author           TEXT NOT NULL,
  isbn             TEXT UNIQUE,
  category         TEXT,
  total_copies     INT  NOT NULL DEFAULT 1 CHECK (total_copies >= 0),
  available_copies INT  NOT NULL DEFAULT 1 CHECK (available_copies >= 0),
  cover_url        TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT copies_check CHECK (available_copies <= total_copies)
);

-- 3.8  book_issues
CREATE TABLE public.book_issues (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id     UUID           NOT NULL REFERENCES public.books(id)    ON DELETE CASCADE,
  student_id  UUID           NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  issued_by   UUID           NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  issued_by_role book_issue_role NOT NULL,
  issued_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
  due_date    DATE           NOT NULL,
  returned_at TIMESTAMPTZ,
  fine_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT now()
);

-- 3.9  complaints
CREATE TABLE public.complaints (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raised_by   UUID               NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category    complaint_category NOT NULL DEFAULT 'other',
  title       TEXT               NOT NULL,
  description TEXT,
  status      complaint_status   NOT NULL DEFAULT 'pending',
  assigned_to UUID               REFERENCES public.profiles(id) ON DELETE SET NULL,
  resolved_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ        NOT NULL DEFAULT now()
);

-- 3.10 assets
CREATE TABLE public.assets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT            NOT NULL,
  category      TEXT,
  asset_tag     TEXT            UNIQUE NOT NULL,
  location      TEXT,
  condition     asset_condition NOT NULL DEFAULT 'good',
  assigned_to   UUID            REFERENCES public.profiles(id) ON DELETE SET NULL,
  purchase_date DATE,
  created_at    TIMESTAMPTZ     NOT NULL DEFAULT now()
);

-- 3.11 grades
CREATE TABLE public.grades (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    UUID    NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  course_id     UUID    NOT NULL REFERENCES public.courses(id)  ON DELETE CASCADE,
  mid_term      NUMERIC(5, 2) DEFAULT 0,
  end_term      NUMERIC(5, 2) DEFAULT 0,
  assignments   NUMERIC(5, 2) DEFAULT 0,
  total         NUMERIC(5, 2) GENERATED ALWAYS AS (mid_term + end_term + assignments) STORED,
  grade_letter  TEXT,
  academic_year TEXT    NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (student_id, course_id, academic_year)
);

-- 3.12 notifications
CREATE TABLE public.notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID    NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title      TEXT    NOT NULL,
  message    TEXT,
  type       TEXT,                       -- e.g. 'attendance', 'library', 'complaint', 'grade'
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ────────────────────────────────────────────────────────────
-- 4. INDEXES FOR PERFORMANCE
-- ────────────────────────────────────────────────────────────

-- profiles
CREATE INDEX idx_profiles_role          ON public.profiles (role);
CREATE INDEX idx_profiles_department    ON public.profiles (department_id);
CREATE INDEX idx_profiles_roll_number   ON public.profiles (roll_number);

-- courses
CREATE INDEX idx_courses_department     ON public.courses (department_id);
CREATE INDEX idx_courses_faculty        ON public.courses (faculty_id);
CREATE INDEX idx_courses_semester       ON public.courses (semester);

-- enrollments
CREATE INDEX idx_enrollments_student    ON public.enrollments (student_id);
CREATE INDEX idx_enrollments_course     ON public.enrollments (course_id);
CREATE INDEX idx_enrollments_year       ON public.enrollments (academic_year);

-- attendance_sessions
CREATE INDEX idx_att_sessions_course    ON public.attendance_sessions (course_id);
CREATE INDEX idx_att_sessions_faculty   ON public.attendance_sessions (faculty_id);
CREATE INDEX idx_att_sessions_date      ON public.attendance_sessions (date);

-- attendance_records
CREATE INDEX idx_att_records_session    ON public.attendance_records (session_id);
CREATE INDEX idx_att_records_student    ON public.attendance_records (student_id);
CREATE INDEX idx_att_records_status     ON public.attendance_records (status);

-- books
CREATE INDEX idx_books_isbn             ON public.books (isbn);
CREATE INDEX idx_books_category         ON public.books (category);

-- book_issues
CREATE INDEX idx_book_issues_book       ON public.book_issues (book_id);
CREATE INDEX idx_book_issues_student    ON public.book_issues (student_id);
CREATE INDEX idx_book_issues_due        ON public.book_issues (due_date);
CREATE INDEX idx_book_issues_returned   ON public.book_issues (returned_at);

-- complaints
CREATE INDEX idx_complaints_raised_by   ON public.complaints (raised_by);
CREATE INDEX idx_complaints_status      ON public.complaints (status);
CREATE INDEX idx_complaints_assigned_to ON public.complaints (assigned_to);
CREATE INDEX idx_complaints_category    ON public.complaints (category);

-- assets
CREATE INDEX idx_assets_tag             ON public.assets (asset_tag);
CREATE INDEX idx_assets_condition       ON public.assets (condition);
CREATE INDEX idx_assets_assigned        ON public.assets (assigned_to);

-- grades
CREATE INDEX idx_grades_student         ON public.grades (student_id);
CREATE INDEX idx_grades_course          ON public.grades (course_id);
CREATE INDEX idx_grades_year            ON public.grades (academic_year);

-- notifications
CREATE INDEX idx_notifications_user     ON public.notifications (user_id);
CREATE INDEX idx_notifications_read     ON public.notifications (is_read);
CREATE INDEX idx_notifications_created  ON public.notifications (created_at DESC);


-- ────────────────────────────────────────────────────────────
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ────────────────────────────────────────────────────────────

-- Helper function: get current user's role
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- Helper function: check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- Helper function: check if current user is faculty
CREATE OR REPLACE FUNCTION public.is_faculty()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'faculty'
  );
$$;

-- ── 5.1  profiles ──
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_all"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "profiles_insert_own"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles_admin_update"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "profiles_admin_delete"
  ON public.profiles FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.2  departments ──
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "departments_select_all"
  ON public.departments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "departments_admin_insert"
  ON public.departments FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "departments_admin_update"
  ON public.departments FOR UPDATE
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "departments_admin_delete"
  ON public.departments FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.3  courses ──
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "courses_select_all"
  ON public.courses FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "courses_faculty_insert"
  ON public.courses FOR INSERT
  TO authenticated
  WITH CHECK (public.is_faculty() OR public.is_admin());

CREATE POLICY "courses_faculty_update"
  ON public.courses FOR UPDATE
  TO authenticated
  USING (faculty_id = auth.uid() OR public.is_admin());

CREATE POLICY "courses_admin_delete"
  ON public.courses FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.4  enrollments ──
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "enrollments_select_own_or_faculty_admin"
  ON public.enrollments FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    OR public.is_faculty()
    OR public.is_admin()
  );

CREATE POLICY "enrollments_admin_faculty_insert"
  ON public.enrollments FOR INSERT
  TO authenticated
  WITH CHECK (public.is_faculty() OR public.is_admin());

CREATE POLICY "enrollments_admin_update"
  ON public.enrollments FOR UPDATE
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "enrollments_admin_delete"
  ON public.enrollments FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.5  attendance_sessions ──
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "att_sessions_select_all"
  ON public.attendance_sessions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "att_sessions_faculty_insert"
  ON public.attendance_sessions FOR INSERT
  TO authenticated
  WITH CHECK (faculty_id = auth.uid() AND (public.is_faculty() OR public.is_admin()));

CREATE POLICY "att_sessions_faculty_update"
  ON public.attendance_sessions FOR UPDATE
  TO authenticated
  USING (faculty_id = auth.uid() OR public.is_admin());

CREATE POLICY "att_sessions_admin_delete"
  ON public.attendance_sessions FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.6  attendance_records ──
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "att_records_select_own_or_faculty_admin"
  ON public.attendance_records FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    OR public.is_faculty()
    OR public.is_admin()
  );

CREATE POLICY "att_records_student_insert"
  ON public.attendance_records FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid() OR public.is_faculty() OR public.is_admin());

CREATE POLICY "att_records_faculty_update"
  ON public.attendance_records FOR UPDATE
  TO authenticated
  USING (public.is_faculty() OR public.is_admin());

CREATE POLICY "att_records_admin_delete"
  ON public.attendance_records FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.7  books ──
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "books_select_all"
  ON public.books FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "books_admin_insert"
  ON public.books FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin() OR public.is_faculty());

CREATE POLICY "books_admin_update"
  ON public.books FOR UPDATE
  TO authenticated
  USING (public.is_admin() OR public.is_faculty());

CREATE POLICY "books_admin_delete"
  ON public.books FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.8  book_issues ──
ALTER TABLE public.book_issues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "book_issues_select_own_or_staff"
  ON public.book_issues FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    OR public.is_faculty()
    OR public.is_admin()
  );

CREATE POLICY "book_issues_staff_insert"
  ON public.book_issues FOR INSERT
  TO authenticated
  WITH CHECK (public.is_faculty() OR public.is_admin());

CREATE POLICY "book_issues_staff_update"
  ON public.book_issues FOR UPDATE
  TO authenticated
  USING (public.is_faculty() OR public.is_admin());

CREATE POLICY "book_issues_admin_delete"
  ON public.book_issues FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.9  complaints ──
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

CREATE POLICY "complaints_select_own_or_admin"
  ON public.complaints FOR SELECT
  TO authenticated
  USING (
    raised_by = auth.uid()
    OR assigned_to = auth.uid()
    OR public.is_admin()
  );

CREATE POLICY "complaints_student_insert"
  ON public.complaints FOR INSERT
  TO authenticated
  WITH CHECK (raised_by = auth.uid());

CREATE POLICY "complaints_update_own_or_admin"
  ON public.complaints FOR UPDATE
  TO authenticated
  USING (raised_by = auth.uid() OR public.is_admin());

CREATE POLICY "complaints_admin_delete"
  ON public.complaints FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.10 assets ──
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "assets_select_all"
  ON public.assets FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "assets_admin_insert"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "assets_admin_update"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "assets_admin_delete"
  ON public.assets FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.11 grades ──
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "grades_select_own_or_faculty_admin"
  ON public.grades FOR SELECT
  TO authenticated
  USING (
    student_id = auth.uid()
    OR public.is_faculty()
    OR public.is_admin()
  );

CREATE POLICY "grades_faculty_insert"
  ON public.grades FOR INSERT
  TO authenticated
  WITH CHECK (public.is_faculty() OR public.is_admin());

CREATE POLICY "grades_faculty_update"
  ON public.grades FOR UPDATE
  TO authenticated
  USING (public.is_faculty() OR public.is_admin());

CREATE POLICY "grades_admin_delete"
  ON public.grades FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- ── 5.12 notifications ──
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_select_own"
  ON public.notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "notifications_insert_admin_system"
  ON public.notifications FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin() OR public.is_faculty());

CREATE POLICY "notifications_update_own"
  ON public.notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "notifications_admin_delete"
  ON public.notifications FOR DELETE
  TO authenticated
  USING (public.is_admin() OR user_id = auth.uid());


-- ────────────────────────────────────────────────────────────
-- 6. TRIGGER: Auto-create profile on new auth.users sign-up
-- ────────────────────────────────────────────────────────────

-- Drop old trigger/function if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', 'New User'),
    COALESCE((NEW.raw_user_meta_data ->> 'role')::user_role, 'student'),
    NEW.raw_user_meta_data ->> 'avatar_url'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- ────────────────────────────────────────────────────────────
-- 7. TRIGGER: Auto-decrement available_copies on book issue
-- ────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.handle_book_issue()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.books
    SET available_copies = available_copies - 1
    WHERE id = NEW.book_id AND available_copies > 0;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'No available copies for this book';
    END IF;
  END IF;

  -- On return (update returned_at from NULL to a value)
  IF TG_OP = 'UPDATE' AND OLD.returned_at IS NULL AND NEW.returned_at IS NOT NULL THEN
    UPDATE public.books
    SET available_copies = available_copies + 1
    WHERE id = NEW.book_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_book_issued
  AFTER INSERT ON public.book_issues
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_book_issue();

CREATE TRIGGER on_book_returned
  AFTER UPDATE ON public.book_issues
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_book_issue();
