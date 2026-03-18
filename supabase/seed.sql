-- ============================================================
-- SMART COLLEGE CLOUD PLATFORM — SEED DATA
-- Run AFTER the schema migration has been applied.
--
-- Creates:  3 students · 2 faculty · 1 admin · 3 departments
--           3 courses · 5 books · enrollments · attendance
--           book issues · complaints · assets · grades · notifs
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. DEPARTMENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.departments (id, name, code) VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Computer Science',       'CS'),
  ('d0000000-0000-0000-0000-000000000002', 'Electronics Engineering','ECE'),
  ('d0000000-0000-0000-0000-000000000003', 'Mechanical Engineering', 'ME');

-- ────────────────────────────────────────────────────────────
-- 2. AUTH USERS  (inserted via Supabase auth, simulated here)
--    NOTE: In production these are created via sign-up.
--    The trigger auto-creates profiles, so we insert profiles
--    manually here and skip auth.users for seed purposes.
-- ────────────────────────────────────────────────────────────

-- We'll use well-known UUIDs for profiles so we can reference them.
-- Students
INSERT INTO public.profiles (id, role, full_name, roll_number, department_id, phone) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'student', 'Aarav Sharma',    'CS2025001', 'd0000000-0000-0000-0000-000000000001', '+91-9876543210'),
  ('a0000000-0000-0000-0000-000000000002', 'student', 'Priya Patel',     'ECE2025002','d0000000-0000-0000-0000-000000000002', '+91-9876543211'),
  ('a0000000-0000-0000-0000-000000000003', 'student', 'Rohan Desai',     'ME2025003', 'd0000000-0000-0000-0000-000000000003', '+91-9876543212');

-- Faculty
INSERT INTO public.profiles (id, role, full_name, department_id, phone) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'faculty', 'Dr. Meera Iyer',  'd0000000-0000-0000-0000-000000000001', '+91-9800000001'),
  ('b0000000-0000-0000-0000-000000000002', 'faculty', 'Prof. Ravi Kumar','d0000000-0000-0000-0000-000000000002', '+91-9800000002');

-- Admin
INSERT INTO public.profiles (id, role, full_name, phone) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'admin', 'Admin User', '+91-9900000001');


-- ────────────────────────────────────────────────────────────
-- 3. COURSES
-- ────────────────────────────────────────────────────────────
INSERT INTO public.courses (id, name, code, department_id, faculty_id, semester, credits) VALUES
  ('e0000000-0000-0000-0000-000000000001', 'Data Structures & Algorithms',  'CS301', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 3, 4),
  ('e0000000-0000-0000-0000-000000000002', 'Digital Signal Processing',     'ECE401','d0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 4, 3),
  ('e0000000-0000-0000-0000-000000000003', 'Database Management Systems',   'CS302', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 3, 4);


-- ────────────────────────────────────────────────────────────
-- 4. ENROLLMENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.enrollments (student_id, course_id, academic_year) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', '2025-26'),
  ('a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000003', '2025-26'),
  ('a0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', '2025-26'),
  ('a0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', '2025-26');


-- ────────────────────────────────────────────────────────────
-- 5. BOOKS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.books (id, title, author, isbn, category, total_copies, available_copies) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'Introduction to Algorithms',         'Thomas H. Cormen',     '978-0262033848', 'Computer Science', 5, 4),
  ('f0000000-0000-0000-0000-000000000002', 'Design Patterns',                    'Erich Gamma et al.',   '978-0201633610', 'Computer Science', 3, 3),
  ('f0000000-0000-0000-0000-000000000003', 'Signals and Systems',                'Alan V. Oppenheim',    '978-0138147570', 'Electronics',      4, 4),
  ('f0000000-0000-0000-0000-000000000004', 'Database System Concepts',           'Abraham Silberschatz', '978-0078022159', 'Computer Science', 6, 5),
  ('f0000000-0000-0000-0000-000000000005', 'Engineering Mechanics: Dynamics',    'J.L. Meriam',          '978-1119390985', 'Mechanical',       3, 3);


-- ────────────────────────────────────────────────────────────
-- 6. ATTENDANCE SESSIONS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.attendance_sessions (id, course_id, faculty_id, date, start_time, end_time, qr_code_token) VALUES
  ('11000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', '2026-03-15', '09:00', '10:00', 'qr-token-cs301-20260315'),
  ('11000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', '2026-03-15', '11:00', '12:00', 'qr-token-ece401-20260315');

-- ────────────────────────────────────────────────────────────
-- 7. ATTENDANCE RECORDS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.attendance_records (session_id, student_id, status) VALUES
  ('11000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'present'),
  ('11000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003', 'late'),
  ('11000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'present');


-- ────────────────────────────────────────────────────────────
-- 8. BOOK ISSUES
-- ────────────────────────────────────────────────────────────
INSERT INTO public.book_issues (book_id, student_id, issued_by, issued_by_role, due_date) VALUES
  ('f0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'faculty', '2026-04-15'),
  ('f0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'admin',   '2026-04-10');


-- ────────────────────────────────────────────────────────────
-- 9. COMPLAINTS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.complaints (raised_by, category, title, description, status, assigned_to) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'infrastructure', 'WiFi not working in Block A',    'WiFi has been down for 3 days in CS block A, room 204.', 'pending',   'c0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'hostel',         'Water heater broken in Hostel 2','The geyser in bathroom on 3rd floor is not working.',    'in-review', 'c0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000003', 'academic',       'Lab equipment not calibrated',   'Oscilloscopes in ECE lab need recalibration.',           'pending',    NULL);


-- ────────────────────────────────────────────────────────────
-- 10. ASSETS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.assets (name, category, asset_tag, location, condition, assigned_to, purchase_date) VALUES
  ('Dell Latitude 5520 Laptop',  'IT Equipment', 'AST-IT-001',  'CS Lab 1',        'good',        'b0000000-0000-0000-0000-000000000001', '2024-06-15'),
  ('Epson Projector EB-X51',     'IT Equipment', 'AST-IT-002',  'Lecture Hall 3',  'good',         NULL,                                   '2023-01-20'),
  ('Oscilloscope Tektronix TBS', 'Lab Equipment','AST-LAB-001', 'ECE Lab 2',       'damaged',      NULL,                                   '2022-09-10'),
  ('Office Chair ErgoMax Pro',   'Furniture',    'AST-FUR-001', 'Admin Office',    'good',        'c0000000-0000-0000-0000-000000000001', '2025-01-05'),
  ('3D Printer Creality Ender',  'Lab Equipment','AST-LAB-002', 'ME Workshop',     'maintenance',  NULL,                                   '2024-11-01');


-- ────────────────────────────────────────────────────────────
-- 11. GRADES
-- ────────────────────────────────────────────────────────────
INSERT INTO public.grades (student_id, course_id, mid_term, end_term, assignments, grade_letter, academic_year) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 22.5,  45.0, 18.0, 'A',  '2025-26'),
  ('a0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000003', 20.0,  40.0, 17.0, 'A-', '2025-26'),
  ('a0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 18.0,  38.0, 15.0, 'B+', '2025-26'),
  ('a0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 15.0,  30.0, 12.0, 'B',  '2025-26');


-- ────────────────────────────────────────────────────────────
-- 12. NOTIFICATIONS
-- ────────────────────────────────────────────────────────────
INSERT INTO public.notifications (user_id, title, message, type, is_read) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Welcome to HackPulse!',                 'Your account has been set up successfully. Explore your dashboard.',         'system',     false),
  ('a0000000-0000-0000-0000-000000000001', 'Book Due Reminder',                     'Your book "Introduction to Algorithms" is due on April 15, 2026.',           'library',    false),
  ('a0000000-0000-0000-0000-000000000002', 'Attendance Marked',                     'Your attendance for DSP (ECE401) on March 15 has been marked as present.',   'attendance', true),
  ('b0000000-0000-0000-0000-000000000001', 'New Complaint Assigned',                'A new complaint regarding WiFi has been raised. Please review.',             'complaint',  false),
  ('c0000000-0000-0000-0000-000000000001', 'System Health Alert',                   'All services are running normally. Weekly report attached.',                 'system',     true);
