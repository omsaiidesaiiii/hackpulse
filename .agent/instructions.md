# UniCloud Agent Context & Project Plan

You are the AI agent responsible for building "UniCloud" — a Unified Smart College Cloud Ecosystem. Please refer to this complete project plan for all context, folder structures, database schemas, and technical decisions.

## Tech Stack
- **Frontend:** Next.js 14 (App Router)
- **Backend/DB:** Supabase (PostgreSQL + Auth + Realtime + Storage + Edge Functions)
- **Styling:** Tailwind CSS + shadcn/ui
- **Charts:** Recharts
- **Deployment:** Vercel
- **Language:** TypeScript throughout

---

## 1. COMPLETE FOLDER STRUCTURE
```text
unicloud/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── layout.tsx
│   ├── (dashboards)/
│   │   ├── admin/
│   │   │   ├── attendance/page.tsx
│   │   │   ├── library/page.tsx
│   │   │   ├── complaints/page.tsx
│   │   │   ├── assets/page.tsx
│   │   │   └── page.tsx
│   │   ├── faculty/
│   │   │   ├── attendance/page.tsx
│   │   │   ├── complaints/page.tsx
│   │   │   ├── assets/page.tsx
│   │   │   ├── analytics/page.tsx
│   │   │   └── page.tsx
│   │   ├── student/
│   │   │   ├── attendance/page.tsx
│   │   │   ├── library/page.tsx
│   │   │   ├── complaints/page.tsx
│   │   │   ├── analytics/page.tsx
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx (Landing Page)
├── components/
│   ├── ui/ (shadcn components: button, card, input, dialog, etc.)
│   ├── auth/
│   │   └── LoginForm.tsx
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   ├── Topbar.tsx
│   │   └── RoleGuard.tsx
│   ├── dashboards/
│   │   ├── StatCard.tsx
│   │   ├── AdminOverview.tsx
│   │   └── StudentOverview.tsx
│   ├── attendance/
│   │   └── IDScannerInput.tsx
│   ├── library/
│   │   └── BookSearch.tsx
│   ├── complaints/
│   │   ├── KanbanBoard.tsx
│   │   └── ComplaintModal.tsx
│   ├── assets/
│   │   └── AssetTrackingTable.tsx
│   └── analytics/
│       ├── GPARadarChart.tsx
│       └── AttendanceBarChart.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── utils.ts
│   └── predictive-engine.ts
├── actions/ (Server Actions)
│   ├── auth.ts
│   ├── attendance.ts
│   ├── library.ts
│   ├── complaints.ts
│   ├── assets.ts
│   └── analytics.ts
├── types/
│   ├── database.types.ts (Supabase Generated)
│   └── index.ts
├── hooks/
│   ├── useUserRoles.ts
│   └── useSupabaseRealtime.ts
├── supabase/
│   ├── functions/ (Edge Functions)
│   │   └── predict-gpa/
│   │       └── index.ts
│   └── migrations/
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## 2. COMPLETE DATABASE SCHEMA

```sql
-- 1. Profiles Table (Extends Supabase auth.users)
CREATE TYPE user_role AS ENUM ('student', 'faculty', 'admin');

CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role user_role NOT NULL,
  college_id VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  department VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Subjects Table
CREATE TABLE subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  credits INT NOT NULL,
  semester INT NOT NULL
);

-- 3. Enrollments Table
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
  semester INT NOT NULL,
  UNIQUE(student_id, subject_id)
);

-- 4. Attendance Table (ID-Based)
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE NOT NULL,
  faculty_id UUID REFERENCES profiles(id) NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) CHECK (status IN ('present', 'absent', 'late')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, subject_id, date)
);

-- 5. Library Books Table
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  isbn VARCHAR(20) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  total_copies INT DEFAULT 1,
  available_copies INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Book Issues Table
CREATE TABLE book_issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  due_date TIMESTAMPTZ NOT NULL,
  returned_at TIMESTAMPTZ,
  status VARCHAR(20) DEFAULT 'issued' CHECK (status IN ('issued', 'returned', 'overdue'))
);

-- 7. Complaints Table
CREATE TYPE complaint_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE complaint_status AS ENUM ('open', 'assigned', 'resolved', 'closed');

CREATE TABLE complaints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  category VARCHAR(100) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  priority complaint_priority DEFAULT 'medium',
  status complaint_status DEFAULT 'open',
  attachment_url TEXT,
  assigned_to UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Assets Table
CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_tag VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100) NOT NULL,
  status VARCHAR(50) DEFAULT 'available' CHECK (status IN ('available', 'assigned', 'maintenance', 'retired')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Asset Assignments (Log track)
CREATE TABLE asset_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE NOT NULL,
  assigned_to UUID REFERENCES profiles(id) NOT NULL,
  assigned_by UUID REFERENCES profiles(id) NOT NULL,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  returned_at TIMESTAMPTZ,
  condition_notes TEXT
);

-- 10. Academic Marks Table (For Analytics)
CREATE TABLE academic_marks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE NOT NULL,
  internal_marks DECIMAL(5,2),
  external_marks DECIMAL(5,2),
  total_marks DECIMAL(5,2),
  semester INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, subject_id)
);

-- Indexes for Performance targeting frequent queries
CREATE INDEX idx_profiles_college_id ON profiles(college_id);
CREATE INDEX idx_attendance_student_subject ON attendance(student_id, subject_id);
CREATE INDEX idx_book_issues_student ON book_issues(student_id);
CREATE INDEX idx_complaints_user ON complaints(user_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_assets_tag ON assets(asset_tag);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE complaints;
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;
```

---

## 3. RLS POLICY PLAN

| Table | SELECT (Read) | INSERT (Create) | UPDATE | DELETE |
| :--- | :--- | :--- | :--- | :--- |
| **profiles** | All Authenticated Users | Admin / Trigger only | User's own profile AND Admins | Admin only |
| **attendance** | Student (own), Faculty (their classes), Admin (all) | Faculty, Admin | Faculty, Admin | Admin only |
| **books** | All Authenticated Users | Admin only | Admin only | Admin only |
| **book_issues** | Student (own), Admin (all) | Admin only | Admin only | Admin only |
| **complaints** | User (own), Admin (all) | All Authenticated Users | User (if status is 'open') AND Admin | Admin only |
| **assets** | Faculty (assigned to them), Admin (all) | Admin only | Admin only | Admin only |
| **asset_assignments**| Faculty (own), Admin (all) | Admin only | Admin only | Admin only |
| **academic_marks** | Student (own), Faculty, Admin (all) | Faculty, Admin | Faculty, Admin | Admin only |

---

## 4. API / SERVER ACTIONS PLAN

| File Path | Action Name | Description | DB Tables Touched | Allowed Roles |
| :--- | :--- | :--- | :--- | :--- |
| `actions/auth.ts` | `getSessionUser` | Verifies JWT and fetches user role properties | `profiles` | All |
| `actions/attendance.ts` | `markAttendanceById` | Faculty types/scans college_id to mark present/absent | `attendance`, `profiles` | Faculty, Admin |
| `actions/attendance.ts` | `getStudentAttendance`| Returns aggregated % mapped by subject with alerts < 75% | `attendance`, `subjects` | Student, Faculty, Admin |
| `actions/library.ts` | `searchCatalog` | Fuzzy search for books by title/isbn | `books` | All |
| `actions/library.ts` | `processBookIssue` | Assigns a book copy to a student college ID | `books`, `book_issues` | Admin |
| `actions/complaints.ts`| `submitComplaint` | Create complaint record w/ optional file upload mapped to bucket | `complaints` | All |
| `actions/complaints.ts`| `updateComplaintStatus`| Advance complaint through pipeline (e.g., Open -> Resolved) | `complaints` | Admin |
| `actions/assets.ts` | `assignFacultyAsset` | Checkout hardware to faculty and logs the chain of custody | `assets`, `asset_assignments`| Admin |
| `actions/analytics.ts` | `getAcademicMetrics` | Aggregates history + calls GPA predictor | `academic_marks`, `attendance`| Student, Faculty, Admin |

---

## 5. COMPONENT PLAN

| Component Name | File Path | Renders | Received Props | Used By |
| :--- | :--- | :--- | :--- | :--- |
| **RoleGuard** | `components/layout/RoleGuard.tsx` | Next.js children wrapper that handles Auth boundary | `allowedRoles: string[]`, `children` | Layouts, Dashboard Roots |
| **Sidebar** | `components/layout/Sidebar.tsx` | Navigation sidebar dynamic based on active role | `role: "student" \| "faculty" \| "admin"` | Dashboard Layouts |
| **StatCard** | `components/dashboards/StatCard.tsx` | Reusable metric visualizer (e.g., "Total Students: 500") | `title`, `value`, `icon`, `trend`, `alertVariant?` | All Dashboards |
| **IDScannerInput** | `components/attendance/IDScannerInput.tsx` | Specialized input listening to keyboard/barcode scans | `onScan(college_id: string)` | Faculty Attendance Page |
| **AttendanceBarChart**| `components/analytics/AttendanceBarChart.tsx` | Recharts Bar Chart showing % per subject + 75% threshold line | `data: { subject, percentage }[]` | Student, Admin Analytics |
| **GPARadarChart** | `components/analytics/GPARadarChart.tsx` | Recharts Radar showing academic balance | `data: { subject, score, max }[]` | Student Analytics |
| **ComplaintModal** | `components/complaints/ComplaintModal.tsx` | shadcn Dialog with form & file input | `isOpen`, `onClose()` | Student, Faculty Complaints|
| **KanbanBoard** | `components/complaints/KanbanBoard.tsx` | Drag and drop board for handling complaint states | `complaints[]` | Admin Complaints |
| **AssetTrackingTable**| `components/assets/AssetTrackingTable.tsx` | React Table with status badges and checkout actions | `assets[]`, `onCheckout(id)` | Admin Assets |

---

## 6. SUPABASE SERVICES PLAN

- **Auth:** Normal Email/Password provider. Upon successful registration, a Postgres trigger automatically replicates the ID to the public `profiles` table to maintain RBAC role data without bloating JWT headers.
- **Storage:** 
  - `complaint-attachments` bucket: 5MB restriction, accepts standard document formats (`PDF`, `JPG`, `PNG`, `DOCX`).
- **Realtime:**
  - `complaints` table: The Admin's `KanbanBoard` listens to `INSERT` and `UPDATE` payload events, immediately sorting new tickets to "Open" and playing a toast notification without page reloads.
- **Edge Functions:**
  - `predict-gpa`: A Deno-based TypeScript edge function utilized for the **Predictive Academic Analytics**. It receives an array of previous semester GPAs, current attendance %, and internal marks, runs a predictive algorithm/formula, and returns a JSON payload containing the `predicted_gpa` and Boolean `at_risk_flag`.

---

## 7. PAGE ROUTE MAP

| URL Path | Allowed Role(s) | Data Fetched (Next.js Server Side) | Key Components utilized |
| :--- | :--- | :--- | :--- |
| `/login` | Public | None | LoginForm |
| `/student` | Student | Profile, Upcoming Due Books, Unresolved Complaints| StudentOverview, StatCard |
| `/student/attendance` | Student | Total Attendance %, Attendance Array by Subject | AttendanceBarChart |
| `/student/library` | Student | List of issued books, Searchable book catalog | BookSearch |
| `/student/complaints` | Student | User's own complaints array | ComplaintModal |
| `/student/analytics` | Student | Grades Array, Edge Function GPA Prediction | GPARadarChart |
| `/faculty` | Faculty | Assigned Classes count, Assets checked out | StatCard, AssetTrackingTable |
| `/faculty/attendance` | Faculty | Roster List matching Subject | IDScannerInput |
| `/admin` | Admin | System Aggregations (Total students, active issues) | AdminOverview, StatCard |
| `/admin/attendance` | Admin | College wide attendance aggregates (< 75% lists) | AttendanceBarChart |
| `/admin/complaints` | Admin | All complaint objects | KanbanBoard |
| `/admin/library` | Admin | Total Books, Overdue arrays | BookSearch |
| `/admin/assets` | Admin | Asset library array | AssetTrackingTable |

---

## 8. DEVELOPMENT SEQUENCE (HACKATHON OPTIMIZED)

*Time allocations based on a standard 24-hr hackathon environment.*

- **Phase 1: Foundation Setup (Hours 1-3)**
  - Initialize Next.js 14 App Router, install shadcn/ui boilerplate, initialize Supabase project.
  - Apply generated SQL Schema and seed realistic dummy data (Crucial for UI building).
- **Phase 2: Authentication & Guarding (Hours 4-6)**
  - Wire up Supabase Auth and `profiles` trigger.
  - Implement the `RoleGuard` wrapper and create layout boundaries for `/student`, `/faculty`, and `/admin`.
- **Phase 3: High-Impact Visuals (Hours 7-12)** 
  - **Predictive Analytics & Dashboards:** Implement Recharts components and wire up the `predict-gpa` edge function (or inline algorithm). Visually stunning charts look great for judges.
  - **Realtime Complaints:** Build the Kanban board and wire it to Supabase Realtime for a "live demo" wow factor.
- **Phase 4: Core Domain Logic (Hours 13-18)**
  - **Attendance System:** Implement the ID Scanner feature and aggregate views.
  - **Library Management:** Implement book cataloging and active issued lists.
- **Phase 5: Quick-Wins & Cleanup (Hours 19-21)**
  - **Asset Tracking:** Basic CRUD table for hardware (easy implementations).
- **Phase 6: Lock Down & Deploy (Hours 22-24)**
  - Apply Supabase RLS policies (so judges can't break demo data).
  - Vercel Deployment, Env Variable checks, general bug squashing and responsive design pass.
  - *Fallback strategy:* If running behind, drop Asset Tracking entirely to ensure Analytics and Realtime Complaints work flawlessly.

---

## 9. ENV VARIABLES LIST

```env
# Supabase Base Setup
NEXT_PUBLIC_SUPABASE_URL=your_project_url       # Required: Client/Server connections to Supabase cloud
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key     # Required: Safe public key used by browser client to auth/fetch
SUPABASE_SERVICE_ROLE_KEY=your_service_role     # Required: Highly privileged server-only key for Admin mutations bypassing RLS

# Environment Handling
NEXT_PUBLIC_APP_URL=http://localhost:3000       # Optional: Absolute URL for redirects + OAuth callback routing
```

---

## 10. POTENTIAL RISKS & SOLUTIONS

1. **Risk:** Hitting Supabase Free Tier Realtime Limits during judging/demo.
   - **Solution:** Restrict Realtime presence/subscription *only* to users logged in specifically as `admin` on the `/admin/complaints` page rather than pushing events globally to all clients. Use `useEffect` returns to gracefully detach channels.
2. **Risk:** Next.js App Router caching returning stale data after Server Actions.
   - **Solution:** Utilize standard `revalidatePath('/[route]', 'page')` inside every Server Action immediately succeeding a Supabase mutation logic block to bust the cache.
3. **Risk:** RLS Policies accidentally locking out critical Server Component fetches.
   - **Solution:** Rely heavily on `supabase.auth.getUser()` in Server Actions rather than anonymous client requests; optionally use the `SUPABASE_SERVICE_ROLE_KEY` inside protected admin-only `/actions/` for complex cross-relational fetches without fighting RLS.
4. **Risk:** UI custom styling causing responsive design breakage and slowing development.
   - **Solution:** Strict enforcement of using pre-built **shadcn/ui** components. Completely avoid custom CSS logic; stick entirely to Tailwind utility classes to ensure mobile-responsiveness implicitly.
5. **Risk:** Complexity of the Edge Function ML/Predictive logic eating up too much Hackathon time.
   - **Solution:** Start the MVP with a rigid standard weighted Math formula algorithm inside a Server Action (e.g., `(Attendance * 0.3) + (Internal * 0.7)`). Only migrate it to an Edge Function as an advanced showcase if hours permit.
