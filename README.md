# CampusFlow

CampusFlow is a responsive student collaboration app built with PHP 8+, MySQL 8+, PDO, Bootstrap 5, and vanilla JavaScript. It brings course-based study sessions, a 48-hour deadline reminder, a course Q&A/resources board, and a per-course checklist into one student dashboard.

## Features

- **Accounts and profiles:** registration, login/logout, password hashing, editable student information, and course selection.
- **Study/project groups:** create sessions, search by course code or keyword, request to join, and accept/decline requests as the session creator. The creator counts as one member; accepted requests cannot exceed the session's capacity.
- **Deadline calendar:** add exams, assignments, quizzes, and projects; view a monthly calendar and upcoming schedule; mark deadlines complete or delete them.
- **48-hour reminder:** the dashboard uses a server-side query for incomplete deadlines between `NOW()` and `NOW() + INTERVAL 48 HOUR`.
- **Course board:** publish questions or resource links and reply to posts.
- **Course checklist:** create, complete/uncomplete, filter, and delete personal course tasks.
- **Security basics:** PDO prepared statements, password hashing, CSRF tokens on every form submission, output escaping, URL scheme validation, and per-user ownership checks.

## Requirements

- PHP 8.1 or newer (8.2+ recommended)
- MySQL 8.0.16 or newer / MariaDB with compatible InnoDB and CHECK-constraint support
- PHP extensions: `pdo_mysql`, `mbstring`
- Apache (XAMPP is suitable)
- Internet access for the Bootstrap CDN and Google Fonts, or replace those CDN references with local assets

## Run locally with XAMPP

1. **Start Apache and MySQL** from the XAMPP Control Panel.
2. Copy the `campusflow` folder into `C:\xampp\htdocs\`.
3. Open phpMyAdmin at `http://localhost/phpmyadmin`.
4. Import `database.sql`. It creates the `campusflow` database, tables, indexes, constraints, and sample records. **The script drops and recreates the CampusFlow tables**, so do not import it into a database containing data you need to keep.
5. Copy `.env.example` to `.env` in the project root. The defaults work with a standard XAMPP MySQL installation:

   ```ini
   APP_NAME=CampusFlow
   APP_ENV=local
   APP_DEBUG=true
   APP_TIMEZONE=Asia/Dhaka
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_NAME=campusflow
   DB_USER=root
   DB_PASS=
   ```

   Change `DB_USER` / `DB_PASS` if your MySQL credentials differ. The project reads `.env` itself and does not require Composer or a dotenv package.

6. Make sure PHP has `pdo_mysql` and `mbstring` enabled in `php.ini`. Restart Apache after changing extensions.
7. Visit **`http://localhost/campusflow/public/`**.

### Demo accounts

| Email | Password | Notes |
|---|---|---|
| `siam@campusflow.test` | `Campus123!` | Main seeded student; has four active courses and sample deadlines/tasks |
| `nadia@campusflow.test` | `Study123!` | Second seeded student; useful for testing requests and replies |

The demo accounts are for local testing only. Do not use these credentials on a public deployment.

## Project structure

```text
campusflow/
├── app/
│   ├── config/config.php       # Reads .env and application settings
│   ├── controllers/            # Auth, dashboard, groups, deadlines, board, tasks, profile
│   ├── views/                  # Server-rendered page templates
│   │   ├── layouts/            # Shared header and footer
│   │   ├── auth/
│   │   ├── sessions/
│   │   ├── deadlines/
│   │   ├── posts/
│   │   ├── tasks/
│   │   └── profile/
│   ├── bootstrap.php           # Session, config, controller loading
│   ├── database.php            # PDO connection
│   └── helpers.php             # Escaping, CSRF, flash, auth and common helpers
├── public/
│   ├── assets/css/app.css
│   ├── assets/js/app.js
│   ├── .htaccess
│   └── index.php               # Front controller / route dispatcher
├── database.sql
├── .env.example
├── .gitignore
└── README.md
```

## Main routes

The app uses a simple front controller with query-string routes:

| Route | Purpose |
|---|---|
| `?page=login` / `?page=register` | Authentication |
| `?page=dashboard` | Overview and 48-hour reminders |
| `?page=sessions` | Browse, search, and create study sessions |
| `?page=session-requests&id=1` | Creator-only join request management |
| `?page=calendar` | Monthly deadline calendar and deadline management |
| `?page=board` | Course questions, resource links, and replies |
| `?page=tasks` | Personal course checklist |
| `?page=profile` | Profile and course enrollment |

All write operations are POST requests and require a valid CSRF token. The controller verifies ownership before modifying a student's deadlines, tasks, hosted sessions, or profile.

## Database notes

- `user_courses` resolves the many-to-many relationship between students and courses.
- `session_requests` has a unique key on `(session_id, requester_id)`, preventing duplicate requests for a session.
- `session_creator` and `author` are resource-level permissions: the session creator is the user matching `study_sessions.creator_id`; a post author is the user matching `course_posts.user_id`. This avoids treating those contextual roles as global account types.
- `study_sessions.max_members` includes the creator. Session acceptance uses a transaction and `SELECT ... FOR UPDATE` on the session row to serialize concurrent acceptance attempts.
- The dashboard reminder query only selects incomplete deadlines due in the next 48 hours.
- Sample deadline and session timestamps are generated relative to `NOW()` when `database.sql` is imported, so the demo dashboard is useful immediately.

## Before deploying publicly

This is a local-development starter project, not a production-hardened deployment. Before going public:

1. Set `APP_DEBUG=false`, use a dedicated least-privilege MySQL account, and use HTTPS.
2. Configure the web server document root to point to the `public/` directory. Keep `.env`, `database.sql`, and application source outside the public document root.
3. Add rate limiting and email verification for authentication, password reset, and abuse prevention.
4. Add pagination and moderation/reporting for public course-board content.
5. Add automated tests, backups, security logging, and a deployment-specific session/cookie configuration.
6. Review timezone policy. The starter sets MySQL's session timezone to `+06:00` to match the default `Asia/Dhaka` app timezone; adjust both consistently if deploying elsewhere.

## Troubleshooting

- **Database connection error:** confirm MySQL is running and the `.env` database name, user, password, host, and port are correct.
- **`could not find driver`:** enable `pdo_mysql` in `php.ini`, then restart Apache.
- **`Call to undefined function mb_*`:** enable `mbstring` in `php.ini`, then restart Apache.
- **Blank page / generic error:** temporarily set `APP_DEBUG=true` in `.env` while developing. Turn it off on public deployments.
- **Wrong reminder times:** ensure the PHP timezone and MySQL session timezone are configured consistently.
