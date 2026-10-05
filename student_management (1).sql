-- Student Management System
-- MySQL database setup

CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- -----------------------------------------------------
-- Students table
-- Used by login.php for student authentication
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    year VARCHAR(20) NOT NULL,
    college VARCHAR(150) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample student login
-- Student ID: 112434026
-- Password: 27.07.2006
INSERT INTO students
    (student_id, password, name, department, year, college)
VALUES
    ('112434026', '27.07.2006', 'Muthukumaran.s',
     'Computer Science', 'II Year', 'SCSVMV')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    department = VALUES(department),
    year = VALUES(year),
    college = VALUES(college);

-- -----------------------------------------------------
-- ID card registrations
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS id_card_registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL UNIQUE,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    year VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    college_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_idcard_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Subjects table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO subjects (subject_name) VALUES
    ('Web Technology'),
    ('Java'),
    ('Database')
ON DUPLICATE KEY UPDATE subject_name = VALUES(subject_name);

-- -----------------------------------------------------
-- Attendance table
-- Stores attendance for each student and subject
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    subject_id INT NOT NULL,
    total_classes INT NOT NULL DEFAULT 0,
    present_classes INT NOT NULL DEFAULT 0,
    absent_classes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_student_subject (student_id, subject_id),
    CONSTRAINT fk_attendance_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_attendance_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Sample attendance for student 112434026
INSERT INTO attendance
    (student_id, subject_id, total_classes, present_classes, absent_classes)
SELECT '112434026', id, 40, 36, 4
FROM subjects WHERE subject_name = 'Web Technology'
ON DUPLICATE KEY UPDATE
    total_classes = VALUES(total_classes),
    present_classes = VALUES(present_classes),
    absent_classes = VALUES(absent_classes);

INSERT INTO attendance
    (student_id, subject_id, total_classes, present_classes, absent_classes)
SELECT '112434026', id, 40, 34, 6
FROM subjects WHERE subject_name = 'Java'
ON DUPLICATE KEY UPDATE
    total_classes = VALUES(total_classes),
    present_classes = VALUES(present_classes),
    absent_classes = VALUES(absent_classes);

INSERT INTO attendance
    (student_id, subject_id, total_classes, present_classes, absent_classes)
SELECT '112434026', id, 40, 38, 2
FROM subjects WHERE subject_name = 'Database'
ON DUPLICATE KEY UPDATE
    total_classes = VALUES(total_classes),
    present_classes = VALUES(present_classes),
    absent_classes = VALUES(absent_classes);

-- -----------------------------------------------------
-- Useful attendance view
-- -----------------------------------------------------
CREATE OR REPLACE VIEW student_attendance AS
SELECT
    a.student_id,
    s.name AS student_name,
    sub.subject_name,
    a.total_classes,
    a.present_classes,
    a.absent_classes,
    CASE
        WHEN a.total_classes > 0
        THEN ROUND((a.present_classes / a.total_classes) * 100, 2)
        ELSE 0
    END AS percentage
FROM attendance a
JOIN students s
    ON a.student_id = s.student_id
JOIN subjects sub
    ON a.subject_id = sub.id;
