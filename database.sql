-- CampusFlow database schema and demo data
-- MySQL 8.0.16+ recommended (for enforced CHECK constraints).
CREATE DATABASE IF NOT EXISTS campusflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campusflow;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS course_tasks;
DROP TABLE IF EXISTS course_replies;
DROP TABLE IF EXISTS course_posts;
DROP TABLE IF EXISTS deadlines;
DROP TABLE IF EXISTS session_requests;
DROP TABLE IF EXISTS study_sessions;
DROP TABLE IF EXISTS user_courses;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    department VARCHAR(120) NOT NULL DEFAULT '',
    semester VARCHAR(60) NOT NULL DEFAULT '',
    role ENUM('student', 'admin') NOT NULL DEFAULT 'student',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(30) NOT NULL,
    course_title VARCHAR(180) NOT NULL,
    semester_label VARCHAR(60) NOT NULL DEFAULT '',
    UNIQUE KEY uq_courses_code_semester (course_code, semester_label),
    KEY idx_courses_code (course_code)
) ENGINE=InnoDB;

CREATE TABLE user_courses (
    user_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, course_id),
    KEY idx_user_courses_course (course_id),
    CONSTRAINT fk_user_courses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_courses_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE study_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    creator_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    location VARCHAR(180) NOT NULL,
    session_datetime DATETIME NOT NULL,
    max_members TINYINT UNSIGNED NOT NULL DEFAULT 4,
    status ENUM('open', 'cancelled', 'completed') NOT NULL DEFAULT 'open',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_session_max_members CHECK (max_members BETWEEN 2 AND 30),
    CONSTRAINT fk_sessions_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_sessions_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE RESTRICT,
    KEY idx_sessions_course_status_date (course_id, status, session_datetime),
    KEY idx_sessions_creator (creator_id),
    KEY idx_sessions_datetime (session_datetime)
) ENGINE=InnoDB;

CREATE TABLE session_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT UNSIGNED NOT NULL,
    requester_id BIGINT UNSIGNED NOT NULL,
    status ENUM('pending', 'accepted', 'declined') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_session_requester (session_id, requester_id),
    KEY idx_requests_session_status (session_id, status),
    KEY idx_requests_requester (requester_id),
    CONSTRAINT fk_requests_session FOREIGN KEY (session_id) REFERENCES study_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_requests_requester FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE deadlines (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    type ENUM('exam', 'assignment', 'quiz', 'project') NOT NULL,
    due_datetime DATETIME NOT NULL,
    is_completed TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_deadlines_user_due (user_id, due_datetime, is_completed),
    KEY idx_deadlines_course (course_id),
    CONSTRAINT fk_deadlines_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_deadlines_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE course_posts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    post_type ENUM('question', 'note_link') NOT NULL,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    resource_url VARCHAR(2048) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_posts_course_created (course_id, created_at),
    KEY idx_posts_user (user_id),
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_posts_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE course_replies (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_replies_post_created (post_id, created_at),
    KEY idx_replies_user (user_id),
    CONSTRAINT fk_replies_post FOREIGN KEY (post_id) REFERENCES course_posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_replies_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE course_tasks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    is_done TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_tasks_user_course (user_id, course_id, is_done),
    CONSTRAINT fk_tasks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT INTO users (id, name, email, password_hash, department, semester, role) VALUES
(1, 'Siam Rahman', 'siam@campusflow.test', '$2y$12$rTOkRZONQrwnc5.jmAPjt.JMR0lAXSeKT9nA0moB/K9z0./TY1HoK', 'Computer Science & Engineering', '3rd Year · 1st Semester', 'student'),
(2, 'Nadia Ahmed', 'nadia@campusflow.test', '$2y$12$MtCGapukTFv0YndD2XDraeC5nRh590kIYjwPZM03QL1WHuwOjCigC', 'Computer Science & Engineering', '3rd Year · 1st Semester', 'student');

INSERT INTO courses (id, course_code, course_title, semester_label) VALUES
(1, 'CSE3292', 'Object-Oriented Programming Lab', 'Fall 2026'),
(2, 'CSE2101', 'Data Structures and Algorithms', 'Fall 2026'),
(3, 'MAT1205', 'Linear Algebra', 'Fall 2026'),
(4, 'CSE3301', 'Database Management Systems', 'Fall 2026'),
(5, 'ENG2103', 'Technical Communication', 'Fall 2026');

INSERT INTO user_courses (user_id, course_id) VALUES
(1,1),(1,2),(1,3),(1,4),(2,1),(2,2),(2,5);

INSERT INTO study_sessions (id, creator_id, course_id, title, topic, location, session_datetime, max_members, status) VALUES
(1, 2, 1, 'Java OOP practice circle', 'Inheritance, interfaces and polymorphism', 'Campus library · Floor 3', DATE_ADD(NOW(), INTERVAL 2 DAY), 5, 'open'),
(2, 1, 2, 'DSA problem-solving sprint', 'Linked lists and binary search trees', 'CSE Lab 204', DATE_ADD(NOW(), INTERVAL 1 DAY), 4, 'open'),
(3, 2, 3, 'Linear algebra revision', 'Matrix operations and vector spaces', 'Online · Google Meet', DATE_ADD(NOW(), INTERVAL 5 DAY), 6, 'open');

INSERT INTO session_requests (session_id, requester_id, status) VALUES
(1, 1, 'pending'),
(2, 2, 'pending');

INSERT INTO deadlines (user_id, course_id, title, type, due_datetime, is_completed) VALUES
(1, 1, 'OOP Lab assignment 3', 'assignment', DATE_ADD(NOW(), INTERVAL 20 HOUR), 0),
(1, 2, 'DSA quiz 2', 'quiz', DATE_ADD(NOW(), INTERVAL 42 HOUR), 0),
(1, 3, 'Linear algebra midterm', 'exam', DATE_ADD(NOW(), INTERVAL 8 DAY), 0),
(1, 4, 'Database ER diagram project', 'project', DATE_ADD(NOW(), INTERVAL 12 DAY), 0),
(2, 1, 'Java practical preparation', 'assignment', DATE_ADD(NOW(), INTERVAL 30 HOUR), 0);

INSERT INTO course_posts (id, user_id, course_id, post_type, title, body, resource_url) VALUES
(1, 2, 1, 'When should we use an interface?', 'I understand the syntax, but I am confused about when an interface is a better choice than an abstract class. Can someone explain with a simple example?', NULL),
(2, 1, 2, 'DSA visualisation resource', 'This visualisation helped me understand how linked lists work. Sharing it for anyone revising the topic.', 'https://visualgo.net/en/list'),
(3, 2, 3, 'Tips for matrix multiplication', 'Remember to check that the number of columns in the first matrix equals the number of rows in the second matrix.', NULL);

INSERT INTO course_replies (post_id, user_id, body) VALUES
(1, 1, 'Use an interface when you want unrelated classes to follow the same contract. For example, Printable can be implemented by Book and Report.'),
(3, 1, 'Also, the result matrix has the row count of the first matrix and the column count of the second matrix.');

INSERT INTO course_tasks (user_id, course_id, title, is_done) VALUES
(1, 1, 'Revise method overriding', 1),
(1, 1, 'Complete polymorphism lab sheet', 0),
(1, 2, 'Solve 5 linked-list problems', 0),
(1, 3, 'Review row reduction examples', 0),
(2, 1, 'Practice Java constructors', 0);
