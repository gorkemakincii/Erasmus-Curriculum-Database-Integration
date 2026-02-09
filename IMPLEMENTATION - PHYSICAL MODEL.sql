DROP TABLE IF EXISTS UNIVERSITY, FACULTY, DEPARTMENT, PERSON, INSTRUCTOR, STUDENT, COURSE, SEMESTER, SECTION, SESSION, ASSESSMENT, WORKLOAD, WEEKLY_PLAN, RESOURCES, LEARNING_OUTCOMES, HAS_PREQ_QOREQ, EQUIVALENCE, WANTS_TO_TAKE, TAKES, TEACHES, COORDİNATES, ASISTS, INS_RESEARCHFIELDS CASCADE;
-- ==========================================
-- 1. İDARİ YAPI (STRUCTURE)
-- ==========================================
CREATE TABLE UNIVERSITY (
    UniID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Website VARCHAR(255),
    ErasmusCode VARCHAR(50),
    City VARCHAR(100),
    Country VARCHAR(100)
);

INSERT INTO UNIVERSITY (UniID, Name, Website, ErasmusCode, City, Country) VALUES 
(1, 'TOBB University of Economics and Technology', 'www.etu.edu.tr', 'TR ANKARA11', 'Ankara', 'Türkiye'),
(2, 'Hacettepe University', 'www.hacettepe.edu.tr', 'TR ANKARA03', 'Ankara', 'Türkiye'),
(3, 'Izmir Institute of Technology', 'www.iyte.edu.tr', 'TR IZMIR03', 'Izmir', 'Türkiye');

-- SERIAL (Auto-increment) sayacını güncelliyoruz ki sonraki eklemelerde hata almayasın
SELECT setval(pg_get_serial_sequence('university', 'uniid'), (SELECT MAX(uniid) FROM university));

CREATE TABLE FACULTY (
    FacultyID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Website VARCHAR(255),
    UniID INT REFERENCES UNIVERSITY(UniID) ON DELETE CASCADE,
    DeanSSN VARCHAR(11) -- INSTRUCTOR oluştuktan sonra bağlanacak
);
INSERT INTO FACULTY (FacultyID, Name, Website, UniID, DeanSSN) VALUES 
(10, 'Faculty of Engineering', 'https://mf.etu.edu.tr', 1, NULL),
(20, 'Faculty of Engineering', 'https://muhfak.hacettepe.edu.tr', 2, NULL),
(30, 'Faculty of Engineering', 'https://eng.iyte.edu.tr', 3, NULL);

-- SERIAL sayacını güncelliyoruz ki 10, 20, 30'dan sonra çakışma olmasın
SELECT setval(pg_get_serial_sequence('faculty', 'facultyid'), (SELECT MAX(facultyid) FROM faculty));

CREATE TABLE DEPARTMENT (
    DCode VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Language VARCHAR(50),
    Website VARCHAR(255),
    FacultyID INT REFERENCES FACULTY(FacultyID) ON DELETE CASCADE,
    ChairSSN VARCHAR(11) -- INSTRUCTOR oluştuktan sonra bağlanacak
);
-- DEPARTMENT Verilerini Ekliyoruz
INSERT INTO DEPARTMENT (DCode, Name, Language, Website, FacultyID, ChairSSN) VALUES 
('TOBB_YZ', 'Artificial Intelligence Engineering', 'Turkish', 'https://etu.edu.tr', 10, NULL),
('HAC_CENG', 'Computer Engineering', 'English', 'https://cs.hacettepe.edu.tr', 20, NULL),
('IYTE_CENG', 'Computer Engineering', 'English', 'https://ceng.iyte.edu.tr', 30, NULL);

-- ==========================================
-- 2. KİŞİLER (PEOPLE)
-- ==========================================
CREATE TABLE PERSON (
    SSN VARCHAR(11) PRIMARY KEY,
    FName VARCHAR(50) NOT NULL,
    Minit CHAR(1),
    LName VARCHAR(50) NOT NULL,
    MailAddress VARCHAR(100),
    Phone VARCHAR(20)
);
INSERT INTO PERSON (SSN, FName, Minit, LName, MailAddress, Phone) VALUES 
('11111111111', 'Osman', NULL, 'Erogul', 'erogul@etu.edu.tr', '903123000000'),
('22222222222', 'Ahmet', NULL, 'Ozbayoglu', 'mozbayoglu@etu.edu.tr', '903120000000'),
('33333333333', 'Halil', 'S', 'Vural', 'muhfak@hacettepe.edu.tr', '903123000001'),
('44444444444', 'Ebru', NULL, 'Akcapinar', 'ebru@hacettepe.edu.tr', '900000000000'),
('55555555555', 'Mehmet', 'H', 'Polat', 'mehmetpo@iyte.edu.tr', '900000000001'),
('66666666666', 'Onur', NULL, 'Demirors', 'onurdemir@iyte.edu.tr', '900000000002'),
('77777777777', 'Arda', NULL, 'Yilmaz', 'arda.yilmaz@etu.edu.tr', '901000000000'),
('88888888888', 'Selin', 'J', 'Demir', 'selin.demir@hacettepe.edu.tr', '901000000001');

CREATE TABLE INSTRUCTOR (
    ISSN VARCHAR(11) PRIMARY KEY REFERENCES PERSON(SSN) ON DELETE CASCADE,
    Rank VARCHAR(50),
    Office VARCHAR(100),
    Website VARCHAR(255),
    DCode VARCHAR(20) REFERENCES DEPARTMENT(DCode)
);
INSERT INTO INSTRUCTOR (ISSN, Rank, Office, Website, DCode) VALUES 
('11111111111', 'Professor', 'Dean Office', 'https://etu.edu.tr', 'TOBB_YZ'),
('22222222222', 'Research Assi', 'Room Z-68', 'https://etu.edu.tr', 'TOBB_YZ'),
('33333333333', 'Research Assi', 'Faculty Dean', 'https://muhfa', 'HAC_CENG'),
('44444444444', 'Professor', 'Room 210', 'https://cs.hacettepe.edu.tr', 'HAC_CENG'),
('55555555555', 'Research Assistant', 'Engineering Building', 'https://eng.iyte.edu.tr', 'IYTE_CENG'),
('66666666666', 'Professor', 'Room CENG-101', 'https://ceng.iyte.edu.tr', 'IYTE_CENG');

CREATE TABLE STUDENT (
    SSSN VARCHAR(11) PRIMARY KEY REFERENCES PERSON(SSN) ON DELETE CASCADE,
    StudentID VARCHAR(20) UNIQUE NOT NULL,
    SenderDCode VARCHAR(20) REFERENCES DEPARTMENT(DCode),
    ReceiverDCode VARCHAR(20) REFERENCES DEPARTMENT(DCode)
);
INSERT INTO STUDENT (SSSN, StudentID, SenderDCode, ReceiverDCode) VALUES 
('77777777777', '211101001', 'TOBB_YZ', 'HAC_CENG'),
('88888888888', '222102005', 'HAC_CENG', 'IYTE_CENG');
-- ==========================================
-- 3. AKADEMİK YAPI (ACADEMICS)
-- ==========================================
CREATE TABLE COURSE (
    CourseCode VARCHAR(20) PRIMARY KEY,
    CourseName VARCHAR(255) NOT NULL,
    CourseContent TEXT,
    CourseDeliveryMethod VARCHAR(100),
    ECTS INT,
    CourseCredit INT,
    Hours INT,
    Language VARCHAR(50),
    Objectives TEXT,
    CourseLevel VARCHAR(50), -- 'Undergraduate', 'Graduate'
    CourseType VARCHAR(50),  -- 'Mandatory', 'Elective'
    CourseMethodTechniques TEXT,
    ElectiveType VARCHAR(50),
    DCode VARCHAR(20) REFERENCES DEPARTMENT(DCode)
);
INSERT INTO COURSE (CourseCode, CourseName, CourseContent, CourseDeliveryMethod, ECTS, CourseCredit, Hours, Language, Objectives, CourseLevel, CourseType, CourseMethodTechniques, ElectiveType, DCode) VALUES 
-- IYTE_CENG Dersleri
('CENG113', 'Programming Basics', 'Fundamentals of computer programming: sequence, decision, repetition, syntax, compilation, debugging', 'Face to Face', 6, 4, 5, 'English', 'To give the students a basic understanding of programming', 'Undergraduate', 'Mandatory', 'Lecture and Lab', NULL, 'IYTE_CENG'),
('CENG213', 'Theory of Computation', 'Regular languages, finite automata, context-free languages, pushdown automata', 'Face to Face', 5, 3, 3, 'English', 'To teach formal languages and computation theory', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'IYTE_CENG'),
('CENG312', 'Computer Networks', 'Network layers, protocols, TCP/IP, wireless and mobile networks', 'Face to Face', 5, 3, 3, 'English', 'To provide knowledge about network communication', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'IYTE_CENG'),
('CENG463', 'Introduction to ML', 'Supervised and unsupervised learning, regression, classification', 'Face to Face', 5, 3, 3, 'English', 'Gaining foundational knowledge in machine learning', 'Undergraduate', 'Elective', 'Lecture', 'Technical', 'IYTE_CENG'),
('MATH141', 'Calculus I', 'Functions, limits, continuity, derivatives, applications of derivatives', 'Face to Face', 5, 4, 5, 'English', 'To introduce basic calculus concepts', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'IYTE_CENG'),

-- TOBB_YZ Dersleri
('BIL113', 'Advanced Programming', 'Advanced data structures and algorithm design in C++', 'Face to Face', 6, 4, 4, 'Turkish', 'Understanding complex programming structures', 'Undergraduate', 'Mandatory', 'Lecture and Lab', NULL, 'TOBB_YZ'),
('YZ101', 'Intro to AI', 'History of AI, search algorithms, logic programming', 'Face to Face', 5, 3, 3, 'Turkish', 'Basic understanding of artificial intelligence', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'TOBB_YZ'),
('MAT101', 'Calculus I', 'Limit, continuity, derivatives and integrals', 'Face to Face', 7, 4, 5, 'Turkish', 'Developing mathematical analytical skills', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'TOBB_YZ'),
('YZ421', 'Neural Networks', 'Multi-layer perceptrons, backpropagation, deep learning basics', 'Face to Face', 6, 3, 3, 'English', 'To teach neural network architectures', 'Undergraduate', 'Elective', 'Lecture', 'Technical', 'TOBB_YZ'),
('YZ432', 'Natural Lang. Proc.', 'Text processing, word embeddings, sequence models', 'Face to Face', 5, 3, 3, 'English', 'Understanding human language through computation', 'Undergraduate', 'Elective', 'Lecture', 'Technical', 'TOBB_YZ'),

-- HAC_CENG Dersleri
('CMP603', 'Adv. Data Structures', 'In-depth study of advanced algorithms and complexity', 'Face to Face', 8, 3, 3, 'English', 'Advanced data structure implementation', 'Graduate', 'Elective', 'Seminar', 'Technical', 'HAC_CENG'),
('BBM101', 'Intro to CS', 'Hardware, Software and programming logic basics', 'Face to Face', 6, 3, 4, 'English', 'Foundational computer science concepts', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'HAC_CENG'),
('BBM201', 'Data Structures', 'Lists, stacks, queues, trees and hashing', 'Face to Face', 7, 3, 4, 'English', 'To implement and analyze data structures', 'Undergraduate', 'Mandatory', 'Lecture and Lab', NULL, 'HAC_CENG'),
('BBM341', 'Systems Programming', 'Linux kernel, process management, memory allocation', 'Face to Face', 6, 3, 3, 'English', 'Understanding low-level systems and OS logic', 'Undergraduate', 'Mandatory', 'Lecture', NULL, 'HAC_CENG'),
('BBM465', 'Information Security', 'Cryptography, network security, authentication protocols', 'Face to Face', 5, 3, 3, 'English', 'Gaining expertise in cyber security principles', 'Undergraduate', 'Elective', 'Lecture', 'Technical', 'HAC_CENG');

CREATE TABLE SEMESTER (
    SemesterID SERIAL PRIMARY KEY,
    Year INT NOT NULL,
    Term VARCHAR(20) NOT NULL
);
INSERT INTO SEMESTER (SemesterID, Year, Term) VALUES 
(1, 2023, 'Fall'), (2, 2024, 'Spring'), (3, 2024, 'Summer'), 
(4, 2024, 'Fall'), (5, 2025, 'Spring'), (6, 2022, 'Fall'), 
(7, 2023, 'Spring'), (8, 2023, 'Summer'), (9, 2021, 'Fall'), 
(10, 2022, 'Spring');

-- Serial sayacını güncelleme
SELECT setval(pg_get_serial_sequence('semester', 'semesterid'), (SELECT MAX(semesterid) FROM semester));

CREATE TABLE SECTION (
    SectionID SERIAL PRIMARY KEY,
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    SemesterID INT REFERENCES SEMESTER(SemesterID)
);
INSERT INTO SECTION (SectionID, CourseCode, SemesterID) VALUES 
(1, 'YZ101', 1), (2, 'YZ101', 4), (3, 'BIL113', 1), (4, 'BIL113', 4),
(5, 'YZ421', 2), (6, 'YZ432', 5), (7, 'MAT101', 1), (8, 'CENG113', 1),
(9, 'CENG113', 4), (10, 'CENG213', 2), (11, 'CENG312', 1), (12, 'CENG463', 4),
(13, 'MATH141', 1), (14, 'BBM101', 1), (15, 'BBM101', 4), (16, 'BBM201', 2),
(17, 'BBM341', 4), (18, 'BBM465', 5), (19, 'CMP603', 1), (20, 'CMP603', 4);

-- Serial sayacını güncelleme
SELECT setval(pg_get_serial_sequence('section', 'sectionid'), (SELECT MAX(sectionid) FROM section));

CREATE TABLE SESSION (
    SectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    SessionNo INT,
    GroupType VARCHAR(50),
    Building VARCHAR(100),
    RoomNo VARCHAR(50),
    Day VARCHAR(20),
    StartTime TIME,
    EndTime TIME,
    PRIMARY KEY (SectionID, SessionNo)
);
INSERT INTO SESSION (SectionID, SessionNo, GroupType, Building, RoomNo, Day, StartTime, EndTime) VALUES 
(1, 1, 'Lecture', 'MF Building', 'Z-10', 'Monday', '09:00:00', '11:50:00'),
(3, 1, 'Lecture', 'MF Building', 'Z-11', 'Tuesday', '13:00:00', '15:50:00'),
(8, 1, 'Lecture', 'IYTE Eng.', 'CENG-1', 'Wednesday', '09:00:00', '11:50:00'),
(11, 1, 'Lecture', 'IYTE Eng.', 'CENG-2', 'Thursday', '14:00:00', '16:50:00'),
(14, 1, 'Lecture', 'Hacettepe CS', 'EB-101', 'Monday', '10:00:00', '12:50:00'),
(16, 1, 'Lecture', 'Hacettepe CS', 'EB-202', 'Wednesday', '13:00:00', '15:50:00'),
(19, 1, 'Seminar', 'Hacettepe CS', 'Lab-1', 'Friday', '09:00:00', '11:50:00');

-- ==========================================
-- 4. DERS DETAYLARI (COURSE DETAILS)
-- ==========================================
CREATE TABLE ASSESSMENT (
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    Assessment_Name VARCHAR(100),
    Quantity INT,
    Percentage INT,
    PRIMARY KEY (CourseCode, Assessment_Name)
);
INSERT INTO ASSESSMENT (CourseCode, Assessment_Name, Quantity, Percentage) VALUES 
-- CENG113
('CENG113', 'Midterm Exam', 1, 25),
('CENG113', 'Final Exam', 1, 35),
('CENG113', 'Laboratory Performance', 10, 30),
('CENG113', 'Weekly Assignments', 5, 10),
-- CENG213
('CENG213', 'Midterm Exam', 1, 30),
('CENG213', 'Final Exam', 1, 45),
('CENG213', 'Theoretical Quizzes', 4, 15),
('CENG213', 'Homework', 2, 10),
-- CENG312
('CENG312', 'Midterm Exam', 1, 40),
('CENG312', 'Final Exam', 1, 50),
('CENG312', 'Network Simulation Task', 1, 10),
-- CENG463
('CENG463', 'Machine Learning Project', 1, 40),
('CENG463', 'Final Exam', 1, 40),
('CENG463', 'Research Paper Review', 2, 20),
-- MATH141
('MATH141', 'Midterm 1', 1, 25),
('MATH141', 'Midterm 2', 1, 25),
('MATH141', 'Final Exam', 1, 40),
('MATH141', 'Online Exercises', 10, 10),
-- BIL113
('BIL113', 'Midterm Exam', 1, 30),
('BIL113', 'Final Exam', 1, 40),
('BIL113', 'Lab Exam', 1, 20),
('BIL113', 'Programming Project', 1, 10),
-- YZ101
('YZ101', 'Midterm Exam', 1, 40),
('YZ101', 'Final Exam', 1, 50),
('YZ101', 'Attendance & Participation', 1, 10),
-- MAT101
('MAT101', 'Midterm Exam', 1, 40),
('MAT101', 'Final Exam', 1, 50),
('MAT101', 'Quiz', 5, 10),
-- YZ421
('YZ421', 'Deep Learning Project', 1, 50),
('YZ421', 'Final Exam', 1, 30),
('YZ421', 'Seminar Presentation', 1, 20),
-- YZ432
('YZ432', 'NLP Project', 1, 40),
('YZ432', 'Final Exam', 1, 40),
('YZ432', 'Coding Assignments', 4, 20),
-- CMP603
('CMP603', 'Term Paper', 1, 50),
('CMP603', 'Seminar', 1, 20),
('CMP603', 'Final Exam', 1, 30),
-- BBM101
('BBM101', 'Midterm Exam', 1, 30),
('BBM101', 'Final Exam', 1, 45),
('BBM101', 'Programming Assignment', 4, 25),
-- BBM201
('BBM201', 'Midterm Exam', 1, 30),
('BBM201', 'Final Exam', 1, 40),
('BBM201', 'Lab Performance', 12, 30),
-- BBM341
('BBM341', 'Systems Projects', 2, 40),
('BBM341', 'Final Exam', 1, 40),
('BBM341', 'Quizzes', 4, 20),
-- BBM465
('BBM465', 'Cyber Security Project', 1, 40),
('BBM465', 'Final Exam', 1, 40),
('BBM465', 'Lab Scenarios', 5, 20);

CREATE TABLE WORKLOAD (
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    Activity_Name VARCHAR(100),
    Quantity INT,
    Duration INT,
    PRIMARY KEY (CourseCode, Activity_Name)
);
INSERT INTO WORKLOAD (CourseCode, Activity_Name, Quantity, Duration) VALUES 
-- IZTECH (CENG113, CENG213, CENG463)
('CENG113', 'Theoretical Course Hours', 14, 3),
('CENG113', 'Laboratory / Application', 14, 2),
('CENG113', 'Midterm Exam Preparation', 2, 10),
('CENG113', 'Final Exam Preparation', 1, 15),
('CENG113', 'Quizzes', 10, 1),
('CENG213', 'Study Hours Out of Class', 14, 3),
('CENG213', 'Homework / Assignments', 4, 8),
('CENG463', 'Term Project', 1, 40),
('CENG463', 'Literature Review', 1, 20),

-- TOBB ETÜ (BIL113, YZ101, YZ421)
('BIL113', 'Advanced OOP Exercises', 10, 4),
('BIL113', 'Laboratory Performance', 14, 2),
('BIL113', 'Midterm Preparation', 1, 20),
('BIL113', 'Final Preparation', 1, 30),
('YZ101', 'Theoretical Lectures', 14, 3),
('YZ101', 'AI Algorithm Simulations', 5, 6),
('YZ421', 'Presentation / Seminar Prep', 1, 15),
('YZ421', 'Deep Learning Project', 1, 50),

-- HACETTEPE (CMP603, BBM201, BBM465)
('CMP603', 'Research Paper Writing', 1, 80),
('CMP603', 'Advanced Seminar', 1, 20),
('CMP603', 'Query Optimization Study', 1, 40),
('BBM201', 'Data Structure Implementation', 4, 12),
('BBM201', 'Theoretical Lectures', 14, 3),
('BBM465', 'Security Audit Simulation', 2, 15),
('BBM465', 'Cryptographic Research', 1, 25),
('BBM465', 'Cyber Attack Scenarios', 5, 4);

CREATE TABLE WEEKLY_PLAN (
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    Week INT,
    Topic TEXT,
    PRIMARY KEY (CourseCode, Week)
);
INSERT INTO WEEKLY_PLAN (CourseCode, Week, Topic) VALUES 
-- CENG113 (IZTECH)
('CENG113', 1, 'Intro to Computing & Problem Solving'), ('CENG113', 2, 'Algorithms & Pseudo-code'), ('CENG113', 3, 'Variables, Data Types & Basic I/O'), ('CENG113', 4, 'Operators & Expressions'), ('CENG113', 5, 'Control Structures: Selection (If-Else)'), ('CENG113', 6, 'Control Structures: Repetition (Loops)'), ('CENG113', 7, 'Functions & Modular Programming'), ('CENG113', 8, 'Recursion Principles'), ('CENG113', 9, 'Arrays & Vector Basics'), ('CENG113', 10, 'Multidimensional Arrays & Matrices'), ('CENG113', 11, 'Pointers & Memory Management'), ('CENG113', 12, 'Characters & String Processing'), ('CENG113', 13, 'Structures & Custom Data Types'), ('CENG113', 14, 'File Processing & Stream I/O'),

-- CENG213 (IZTECH)
('CENG213', 1, 'Deterministic Finite Automata (DFA)'), ('CENG213', 2, 'Non-deterministic Finite Automata (NFA)'), ('CENG213', 3, 'Regular Expressions & Languages'), ('CENG213', 4, 'Pumping Lemma for Regular Languages'), ('CENG213', 5, 'Context-Free Grammars (CFG)'), ('CENG213', 6, 'Pushdown Automata (PDA)'), ('CENG213', 7, 'Pumping Lemma for CFLs'), ('CENG213', 8, 'Turing Machine Basics'), ('CENG213', 9, 'Variants of Turing Machines'), ('CENG213', 10, 'Decidability & Undecidability'), ('CENG213', 11, 'The Halting Problem'), ('CENG213', 12, 'Reducibility Concepts'), ('CENG213', 13, 'P and NP Classes'), ('CENG213', 14, 'NP-Completeness & Proofs'),

-- CENG312 (IZTECH)
('CENG312', 1, 'Network Architectures & OSI Model'), ('CENG312', 2, 'Physical Layer & Signaling'), ('CENG312', 3, 'Data Link Layer & Framing'), ('CENG312', 4, 'Error Detection & Correction'), ('CENG312', 5, 'Medium Access Control (MAC)'), ('CENG312', 6, 'Ethernet & Local Area Networks'), ('CENG312', 7, 'Network Layer: IP Addressing'), ('CENG312', 8, 'Routing Algorithms (Link State/Distance Vector)'), ('CENG312', 9, 'Transport Layer: UDP & Reliability'), ('CENG312', 10, 'TCP Connection & Flow Control'), ('CENG312', 11, 'Congestion Control Mechanisms'), ('CENG312', 12, 'Application Layer: HTTP, DNS, SMTP'), ('CENG312', 13, 'Network Security Basics'), ('CENG312', 14, 'Wireless & Mobile Networks'),

-- CENG463 (IZTECH)
('CENG463', 1, 'Intro to Machine Learning Paradigms'), ('CENG463', 2, 'Linear Regression & Least Squares'), ('CENG463', 3, 'Logistic Regression & Classification'), ('CENG463', 4, 'Overfitting & Regularization (L1/L2)'), ('CENG463', 5, 'Decision Trees & Entropy'), ('CENG463', 6, 'Ensemble Methods: Random Forest'), ('CENG463', 7, 'Support Vector Machines (SVM)'), ('CENG463', 8, 'Clustering: K-Means & Hierarchical'), ('CENG463', 9, 'Principal Component Analysis (PCA)'), ('CENG463', 10, 'Neural Network Basics & Backpropagation'), ('CENG463', 11, 'Deep Learning & CNN Foundations'), ('CENG463', 12, 'Evaluation Metrics & Cross-Validation'), ('CENG463', 13, 'Bayesian Learning & Naive Bayes'), ('CENG463', 14, 'ML System Design & Ethics'),

-- MATH141 (IZTECH)
('MATH141', 1, 'Functions & Inverse Functions'), ('MATH141', 2, 'Limits & Continuity'), ('MATH141', 3, 'Formal Definition of Limit'), ('MATH141', 4, 'Differentiation Rules'), ('MATH141', 5, 'Chain Rule & Implicit Differentiation'), ('MATH141', 6, 'Mean Value Theorem'), ('MATH141', 7, 'Curve Sketching & L''Hopital''s Rule'), ('MATH141', 8, 'Optimization Problems'), ('MATH141', 9, 'Definite & Indefinite Integrals'), ('MATH141', 10, 'Fundamental Theorem of Calculus'), ('MATH141', 11, 'Integration by Substitution'), ('MATH141', 12, 'Integration by Parts'), ('MATH141', 13, 'Area Between Curves'), ('MATH141', 14, 'Volumes of Revolution'),

-- BIL113 (TOBB)
('BIL113', 1, 'Java Syntax & Basic OOP Concepts'), ('BIL113', 2, 'Classes, Objects & Methods'), ('BIL113', 3, 'Constructors & Encapsulation'), ('BIL113', 4, 'Inheritance & Polymorphism'), ('BIL113', 5, 'Abstract Classes & Interfaces'), ('BIL113', 6, 'Exception Handling Mechanisms'), ('BIL113', 7, 'Generics & Collections Framework'), ('BIL113', 8, 'Java I/O & Serialization'), ('BIL113', 9, 'Multithreading & Concurrency'), ('BIL113', 10, 'GUI Development with Swing/JavaFX'), ('BIL113', 11, 'Lambda Expressions & Streams'), ('BIL113', 12, 'Database Connectivity (JDBC)'), ('BIL113', 13, 'Design Patterns in Java'), ('BIL113', 14, 'Unit Testing & Debugging'),

-- YZ101 (TOBB)
('YZ101', 1, 'AI History & Foundations'), ('YZ101', 2, 'Search: BFS, DFS, Uniform Cost'), ('YZ101', 3, 'Heuristic Search: A* & Greedy'), ('YZ101', 4, 'Local Search: Hill Climbing, SA'), ('YZ101', 5, 'Constraint Satisfaction Problems'), ('YZ101', 6, 'Game Playing: Minimax & Alpha-Beta'), ('YZ101', 7, 'Propositional Logic & Inference'), ('YZ101', 8, 'First-Order Logic Syntax & Semantics'), ('YZ101', 9, 'Uncertainty & Probability Basics'), ('YZ101', 10, 'Bayesian Networks'), ('YZ101', 11, 'Hidden Markov Models'), ('YZ101', 12, 'Intro to Machine Learning'), ('YZ101', 13, 'Reinforcement Learning Basics'), ('YZ101', 14, 'AI Safety & Social Impact'),

-- MAT101 (TOBB)
('MAT101', 1, 'Functions, Limits & Continuity'), ('MAT101', 2, 'Derivative Concept & Rules'), ('MAT101', 3, 'Trig & Logarithmic Derivatives'), ('MAT101', 4, 'Related Rates'), ('MAT101', 5, 'Extrema & Concavity'), ('MAT101', 6, 'Curve Sketching'), ('MAT101', 7, 'Integration Basics'), ('MAT101', 8, 'Area Calculation'), ('MAT101', 9, 'Volume by Disk/Washer Method'), ('MAT101', 10, 'Transcendental Functions'), ('MAT101', 11, 'Integration Techniques'), ('MAT101', 12, 'Improper Integrals'), ('MAT101', 13, 'Infinite Sequences'), ('MAT101', 14, 'Power Series & Taylor Series'),

-- YZ421 (TOBB)
('YZ421', 1, 'Biological vs Artificial Neurons'), ('YZ421', 2, 'Perceptron Learning Rule'), ('YZ421', 3, 'Multi-layer Perceptrons (MLP)'), ('YZ421', 4, 'Backpropagation Algorithm'), ('YZ421', 5, 'Activation Functions & Loss'), ('YZ421', 6, 'Optimization: SGD, Adam, RMSprop'), ('YZ421', 7, 'Convolutional Neural Networks (CNN)'), ('YZ421', 8, 'Recurrent Neural Networks (RNN)'), ('YZ421', 9, 'LSTM & GRU Architectures'), ('YZ421', 10, 'Autoencoders & Dimensionality'), ('YZ421', 11, 'Generative Adversarial Networks (GAN)'), ('YZ421', 12, 'Attention Mechanisms'), ('YZ421', 13, 'Transformer Models'), ('YZ421', 14, 'Transfer Learning & Fine-tuning'),

-- YZ432 (TOBB)
('YZ432', 1, 'Language Models & Tokenization'), ('YZ432', 2, 'N-gram Models'), ('YZ432', 3, 'Part-of-Speech (POS) Tagging'), ('YZ432', 4, 'Hidden Markov Models in NLP'), ('YZ432', 5, 'Word Embeddings: Word2Vec, GloVe'), ('YZ432', 6, 'Sequence Labeling & NER'), ('YZ432', 7, 'Syntax Parsing: CFG & Dependency'), ('YZ432', 8, 'Semantic Analysis & Word Sense'), ('YZ432', 9, 'Machine Translation: Seq2Seq'), ('YZ432', 10, 'Attention in NLP'), ('YZ432', 11, 'BERT & Transformer Applications'), ('YZ432', 12, 'Sentiment Analysis & Opinion Mining'), ('YZ432', 13, 'Question Answering Systems'), ('YZ432', 14, 'Dialogue Systems & Chatbots'),

-- CMP603 (HACETTEPE)
('CMP603', 1, 'Advanced Relational Model'), ('CMP603', 2, 'Query Execution & Optimization'), ('CMP603', 3, 'Transaction Management & ACID'), ('CMP603', 4, 'Concurrency Control Protocols'), ('CMP603', 5, 'Recovery Systems & Logging'), ('CMP603', 6, 'Distributed Database Systems'), ('CMP603', 7, 'NoSQL: Key-Value & Document'), ('CMP603', 8, 'Graph Databases & Neo4j'), ('CMP603', 9, 'Data Warehousing & OLAP'), ('CMP603', 10, 'Parallel Databases'), ('CMP603', 11, 'XML & Semi-structured Data'), ('CMP603', 12, 'Spatial & Temporal Databases'), ('CMP603', 13, 'Stream Data Management'), ('CMP603', 14, 'Big Data Frameworks (Hadoop/Spark)'),

-- BBM101 (HACETTEPE)
('BBM101', 1, 'History of Computing & Logic'), ('BBM101', 2, 'Binary Systems & Number Rep.'), ('BBM101', 3, 'Boolean Algebra & Gate Logic'), ('BBM101', 4, 'Computer Architecture Intro'), ('BBM101', 5, 'Algorithm Design Concepts'), ('BBM101', 6, 'Flowcharts & Basic Programming'), ('BBM101', 7, 'Operating Systems Overview'), ('BBM101', 8, 'Networking & Internet Basics'), ('BBM101', 9, 'Database Management Intro'), ('BBM101', 10, 'Software Engineering Principles'), ('BBM101', 11, 'Ethics in Computing'), ('BBM101', 12, 'Cyber Security Fundamentals'), ('BBM101', 13, 'Future of Computing: Quantum/Bio'), ('BBM101', 14, 'Career Paths in Comp. Eng.'),

-- BBM201 (HACETTEPE)
('BBM201', 1, 'Complexity Analysis (Big-O)'), ('BBM201', 2, 'Abstract Data Types (ADT)'), ('BBM201', 3, 'Stacks & Queues'), ('BBM201', 4, 'Linked Lists: Singly & Doubly'), ('BBM201', 5, 'Skip Lists & Self-Organizing Lists'), ('BBM201', 6, 'Binary Search Trees (BST)'), ('BBM201', 7, 'Balanced Trees: AVL & Red-Black'), ('BBM201', 8, 'Multi-way Trees: B-Trees'), ('BBM201', 9, 'Hashing & Collision Resolution'), ('BBM201', 10, 'Heaps & Priority Queues'), ('BBM201', 11, 'Graph Representation'), ('BBM201', 12, 'Graph Traversals: BFS, DFS'), ('BBM201', 13, 'Minimum Spanning Trees'), ('BBM201', 14, 'Shortest Paths & Network Flow'),

-- BBM341 (HACETTEPE)
('BBM341', 1, 'System Programming in C'), ('BBM341', 2, 'File Systems & I/O Calls'), ('BBM341', 3, 'Process Creation & Management'), ('BBM341', 4, 'Signals & Error Handling'), ('BBM341', 5, 'Threads & POSIX Pthreads'), ('BBM341', 6, 'Critical Sections & Mutexes'), ('BBM341', 7, 'Deadlock Detection & Avoidance'), ('BBM341', 8, 'Virtual Memory Management'), ('BBM341', 9, 'Inter-process Comm: Pipes/FIFO'), ('BBM341', 10, 'IPC: Message Queues & Semaphores'), ('BBM341', 11, 'Socket Programming: TCP/UDP'), ('BBM341', 12, 'Advanced Socket Options'), ('BBM341', 13, 'Security in System Programming'), ('BBM341', 14, 'System Performance & Profiling'),

-- BBM465 (HACETTEPE)
('BBM465', 1, 'Security Goals: CIA Triad'), ('BBM465', 2, 'Classical Encryption Techniques'), ('BBM465', 3, 'Block Ciphers & DES/AES'), ('BBM465', 4, 'Public Key Crypto: RSA, ElGamal'), ('BBM465', 5, 'Diffie-Hellman & Key Exchange'), ('BBM465', 6, 'Hash Functions & Digital Signatures'), ('BBM465', 7, 'Authentication Protocols'), ('BBM465', 8, 'Network Access Control & Kerberos'), ('BBM465', 9, 'IP Security (IPsec)'), ('BBM465', 10, 'Web Security: TLS/SSL'), ('BBM465', 11, 'Wireless Network Security'), ('BBM465', 12, 'Intrusion Detection Systems (IDS)'), ('BBM465', 13, 'Malicious Software & Viruses'), ('BBM465', 14, 'Ethical Hacking & Legal Issues');

CREATE TABLE RESOURCES (
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    CResource VARCHAR(255),
    PRIMARY KEY (CourseCode, CResource)
);
INSERT INTO RESOURCES (CourseCode, CResource) VALUES 
-- CENG (IZTECH)
('CENG113', 'C Programming Language – Kernighan & Ritchie'),
('CENG113', 'Online C Compiler & Practice Problems'),
('CENG113', 'Lecture Slides and Lab Sheets'),
('CENG213', 'Introduction to Automata Theory – Hopcroft & Ullman'),
('CENG213', 'Lecture Notes on Formal Languages'),
('CENG213', 'Problem Sets and Solution Manuals'),
('CENG312', 'Computer Networking – Kurose & Ross'),
('CENG312', 'Wireshark Network Analysis Labs'),
('CENG312', 'Networking Protocol RFC Documents'),
('CENG463', 'Pattern Recognition and Machine Learning – Bishop'),
('CENG463', 'Scikit-learn & Python ML Tutorials'),
('CENG463', 'Research Papers on Machine Learning'),
('MATH141', 'Calculus – Stewart'),
('MATH141', 'Solved Calculus Problem Sets'),
('MATH141', 'Online Calculus Video Lectures'),

-- BIL & YZ & MAT (TOBB)
('BIL113', 'Effective Java – Joshua Bloch'),
('BIL113', 'Java Official Documentation'),
('BIL113', 'Object-Oriented Design Examples'),
('YZ101', 'Artificial Intelligence – Russell & Norvig'),
('YZ101', 'AI Search Algorithm Simulators'),
('YZ101', 'Lecture Slides and Case Studies'),
('MAT101', 'Calculus – Thomas'),
('MAT101', 'Worked Examples and Exercises'),
('MAT101', 'Mathematical Visualization Tools'),
('YZ421', 'Deep Learning – Goodfellow et al.'),
('YZ421', 'TensorFlow & PyTorch Tutorials'),
('YZ421', 'Research Articles on Neural Networks'),
('YZ432', 'Speech and Language Processing – Jurafsky & Martin'),
('YZ432', 'NLP Python Libraries Documentation'),
('YZ432', 'Datasets for Text Processing'),

-- CMP & BBM (HACETTEPE)
('CMP603', 'Database System Concepts – Silberschatz'),
('CMP603', 'Recent Research Papers on Databases'),
('CMP603', 'Advanced SQL and NoSQL Tutorials'),
('BBM101', 'Introduction to Computing Systems'),
('BBM101', 'Computer Engineering Lecture Notes'),
('BBM101', 'Basic Programming Exercises'),
('BBM201', 'Data Structures and Algorithms – Cormen'),
('BBM201', 'Algorithm Visualization Tools'),
('BBM201', 'Programming Assignments Repository'),
('BBM341', 'Advanced Programming in UNIX Environment'),
('BBM341', 'Linux System Programming Manuals'),
('BBM341', 'C System Programming Examples'),
('BBM465', 'Cryptography and Network Security – Stallings'),
('BBM465', 'Security Tools and Lab Exercises'),
('BBM465', 'Case Studies on Cyber Attacks');

CREATE TABLE LEARNING_OUTCOMES (
    CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    COutcomes TEXT,
    PRIMARY KEY (CourseCode, COutcomes)
);
INSERT INTO LEARNING_OUTCOMES (CourseCode, COutcomes) VALUES 
-- CENG (IZTECH)
('CENG113', 'Design and implement algorithms using C programming language'),
('CENG113', 'Apply memory management techniques using pointers and structures'),
('CENG113', 'Develop modular software components with proper file I/O operations'),
('CENG213', 'Construct and minimize Finite Automata for regular languages'),
('CENG213', 'Differentiate between decidable and undecidable computational problems'),
('CENG213', 'Analyze the complexity classes P and NP for specific algorithms'),
('CENG312', 'Analyze data link, network, and transport layer protocols'),
('CENG312', 'Configure and troubleshoot local area network (LAN) architectures'),
('CENG312', 'Evaluate TCP/IP congestion control and flow control mechanisms'),
('CENG463', 'Build and train supervised and unsupervised machine learning models'),
('CENG463', 'Perform exploratory data analysis and feature engineering'),
('CENG463', 'Evaluate model performance using cross-validation and confusion matrices'),
('MATH141', 'Compute limits, derivatives, and integrals of transcendental functions'),
('MATH141', 'Solve optimization and related rates problems using calculus'),
('MATH141', 'Apply the Fundamental Theorem of Calculus to engineering problems'),

-- BIL & YZ & MAT (TOBB)
('BIL113', 'Implement advanced object-oriented design patterns in Java'),
('BIL113', 'Manage multi-threaded execution and concurrent data access'),
('BIL113', 'Develop interactive Graphical User Interfaces (GUI) with event handling'),
('YZ101', 'Formulate real-world problems as search or logic-based AI tasks'),
('YZ101', 'Implement adversarial search for strategic game-playing agents'),
('YZ101', 'Apply probabilistic reasoning using Bayesian networks'),
('MAT101', 'Understand the concepts of convergence for sequences and series'),
('MAT101', 'Use Taylor and Power series to approximate complex functions'),
('MAT101', 'Calculate volumes and surface areas of solids of revolution'),
('YZ421', 'Design and optimize deep neural network architectures'),
('YZ421', 'Apply backpropagation and gradient descent for model training'),
('YZ421', 'Implement CNNs for image recognition and RNNs for sequence modeling'),
('YZ432', 'Apply tokenization and word embedding techniques for text analysis'),
('YZ432', 'Build sequence-to-sequence models for machine translation'),
('YZ432', 'Fine-tune transformer models like BERT for specific NLP tasks'),

-- CMP & BBM (HACETTEPE)
('CMP603', 'Design distributed and parallel database system architectures'),
('CMP603', 'Optimize complex SQL queries using execution plans and indexing'),
('CMP603', 'Implement ACID compliant transaction management systems'),
('BBM101', 'Explain the principles of computer architecture and gate logic'),
('BBM101', 'Represent data types and instructions in binary and hexadecimal formats'),
('BBM101', 'Understand the social and ethical impacts of computer engineering'),
('BBM201', 'Select appropriate data structures to optimize algorithm performance'),
('BBM201', 'Implement and balance advanced trees like AVL and Red-Black trees'),
('BBM201', 'Apply graph algorithms for shortest path and minimum spanning tree problems'),
('BBM341', 'Utilize system calls for process and file management in Unix/Linux'),
('BBM341', 'Implement inter-process communication (IPC) using pipes and sockets'),
('BBM341', 'Synchronize concurrent threads using mutexes and semaphores'),
('BBM465', 'Apply symmetric and asymmetric cryptographic algorithms'),
('BBM465', 'Identify and mitigate common network security vulnerabilities'),
('BBM465', 'Implement digital signatures and public key infrastructure (PKI)');

CREATE TABLE HAS_PREQ_QOREQ (
    MainCourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    PRE_CORE_CourseCode VARCHAR(20) REFERENCES COURSE(CourseCode) ON DELETE CASCADE,
    Type VARCHAR(50),
    PRIMARY KEY (MainCourseCode, PRE_CORE_CourseCode)
);
-- Önce eksik olan Lab derslerini COURSE tablosuna tanımlayalım (Hata almamak için)
INSERT INTO COURSE (CourseCode, CourseName, CourseContent, ECTS, CourseCredit, DCode) VALUES 
('BBM103', 'Introduction to Programming Lab I', 'Practical applications of BBM101', 2, 2, 'HAC_CENG'),
('BBM203', 'Data Structures Lab', 'Practical applications of BBM201', 2, 2, 'HAC_CENG')
ON CONFLICT (CourseCode) DO NOTHING;

-- Şimdi ilişkileri ekleyebiliriz
INSERT INTO HAS_PREQ_QOREQ (MainCourseCode, PRE_CORE_CourseCode, Type) VALUES 
-- IZTECH Önkoşulları
('CENG213', 'CENG113', 'Prerequisite'),
('CENG312', 'CENG113', 'Prerequisite'),
('CENG463', 'MATH141', 'Prerequisite'),

-- TOBB Önkoşulları
('YZ421', 'YZ101', 'Prerequisite'),
('YZ432', 'YZ101', 'Prerequisite'),
('BIL113', 'MAT101', 'Prerequisite'),

-- HACETTEPE Önkoşul ve Yan Koşulları
('BBM201', 'BBM101', 'Prerequisite'),
('BBM341', 'BBM201', 'Prerequisite'),
('BBM103', 'BBM101', 'Corequisite'),
('BBM203', 'BBM201', 'Corequisite'),
('BBM465', 'BBM341', 'Prerequisite');
-- ==========================================
-- 5. ERASMUS SÜRECİ
-- ==========================================
CREATE TABLE EQUIVALENCE (
    EquivalenceID SERIAL PRIMARY KEY,
    Student_SSN VARCHAR(11) REFERENCES STUDENT(SSSN),
    Instructor_SSN VARCHAR(11) REFERENCES INSTRUCTOR(ISSN),
    TargetCourseCode VARCHAR(20) REFERENCES COURSE(CourseCode),
    SourceCourseCode VARCHAR(20) REFERENCES COURSE(CourseCode),
    ECTSDifference INT,
    Status VARCHAR(50)
);
INSERT INTO EQUIVALENCE (EquivalenceID, Student_SSN, Instructor_SSN, TargetCourseCode, SourceCourseCode, ECTSDifference, Status) VALUES 
-- Arda (777...) - Koordinatör: Osman Eroğul (11111111111)
(1, '77777777777', '11111111111', 'YZ101', 'BBM101', 0, 'Approved'),
(2, '77777777777', '11111111111', 'BIL113', 'BBM201', -1, 'Approved'),
(3, '77777777777', '11111111111', 'MAT101', 'BBM101', 1, 'Rejected'),

-- Selin (888...) - Koordinatör: Ebru Akçapınar (44444444444)
(4, '88888888888', '44444444444', 'BBM101', 'CENG113', 0, 'Approved'),
(5, '88888888888', '44444444444', 'BBM201', 'CENG213', 2, 'Pending'),
(6, '88888888888', '44444444444', 'BBM465', 'CENG312', 0, 'Rejected');

-- ID sayacını senkronize ediyoruz
SELECT setval(pg_get_serial_sequence('equivalence', 'equivalenceid'), (SELECT MAX(equivalenceid) FROM equivalence));

-- ==========================================
-- 6. ÖĞRENCİ VE HOCA EYLEMLERİ (ACTIONS)
-- ==========================================
CREATE TABLE WANTS_TO_TAKE (
    Student_SSN VARCHAR(11) REFERENCES STUDENT(SSSN) ON DELETE CASCADE,
    HomeSectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    PRIMARY KEY (Student_SSN, HomeSectionID)
);
INSERT INTO WANTS_TO_TAKE (Student_SSN, HomeSectionID) VALUES 
-- Arda (77777777777) - TOBB'daki ders şubeleri
('77777777777', 1), -- YZ101
('77777777777', 3), -- BIL113
('77777777777', 7), -- MAT101

-- Selin (88888888888) - Hacettepe'deki ders şubeleri
('88888888888', 14), -- BBM101
('88888888888', 16), -- BBM201
('88888888888', 17); -- BBM341

CREATE TABLE TAKES (
    Student_SSN VARCHAR(11) REFERENCES STUDENT(SSSN) ON DELETE CASCADE,
    HostSectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    PRIMARY KEY (Student_SSN, HostSectionID)
);
INSERT INTO TAKES (Student_SSN, HostSectionID) VALUES 
-- Arda (77777777777) - Hacettepe'de (Host) aldığı dersler
('77777777777', 14), -- BBM101
('77777777777', 15), -- BBM101 (Farklı şube veya dönem)
('77777777777', 16), -- BBM201
('77777777777', 17), -- BBM341
('77777777777', 18), -- BBM465
('77777777777', 19), -- CMP603
('77777777777', 20), -- CMP603

-- Selin (88888888888) - IZTECH'te (Host) aldığı dersler
('88888888888', 8),  -- CENG113
('88888888888', 9),  -- CENG113
('88888888888', 10), -- CENG213
('88888888888', 11), -- CENG312
('88888888888', 12), -- CENG463
('88888888888', 13); -- MATH141

CREATE TABLE TEACHES (
    TeacherISSN VARCHAR(11) REFERENCES INSTRUCTOR(ISSN) ON DELETE CASCADE,
    SectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    PRIMARY KEY (TeacherISSN, SectionID)
);
INSERT INTO TEACHES (TeacherISSN, SectionID) VALUES 
-- 11111111111 (Osman Hoca) için atanan şubeler
('11111111111', 1),
('11111111111', 2),
('11111111111', 5),
('11111111111', 8),
('11111111111', 9),
('11111111111', 10),
('11111111111', 11),
('11111111111', 12),

-- 44444444444 (Ebru Hoca) için atanan şubeler
('44444444444', 3),
('44444444444', 4),
('44444444444', 14),
('44444444444', 16),
('44444444444', 19),

-- 66666666666 (Onur Hoca) için atanan şubeler
('66666666666', 17),
('66666666666', 18);

CREATE TABLE COORDİNATES (
    CoordinatorISSN VARCHAR(11) REFERENCES INSTRUCTOR(ISSN) ON DELETE CASCADE,
    SectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    PRIMARY KEY (CoordinatorISSN, SectionID)
);
INSERT INTO COORDİNATES (CoordinatorISSN, SectionID) VALUES 
-- 22222222222 (Ahmet Hoca) Koordinatörlüğündeki Şubeler
('22222222222', 1),
('22222222222', 2),
('22222222222', 3),
('22222222222', 4),
('22222222222', 5),

-- 11111111111 (Osman Hoca) Koordinatörlüğündeki Şubeler
('11111111111', 8),
('11111111111', 9),
('11111111111', 10),
('11111111111', 11),
('11111111111', 12),

-- 44444444444 (Ebru Hoca) Koordinatörlüğündeki Şubeler
('44444444444', 14),
('44444444444', 15),
('44444444444', 16),
('44444444444', 19),
('44444444444', 20);

CREATE TABLE ASISTS (
    AsistantISSN VARCHAR(11) REFERENCES INSTRUCTOR(ISSN) ON DELETE CASCADE,
    SectionID INT REFERENCES SECTION(SectionID) ON DELETE CASCADE,
    PRIMARY KEY (AsistantISSN, SectionID)
);
INSERT INTO ASISTS (AsistantISSN, SectionID) VALUES 
-- Ahmet Hoca/Asistan (22222222222) - TOBB Şubeleri
('22222222222', 1),
('22222222222', 2),
('22222222222', 3),
('22222222222', 4),

-- Halil Hoca/Asistan (33333333333) - Hacettepe Şubeleri
('33333333333', 14),
('33333333333', 16),
('33333333333', 17),
('33333333333', 19),

-- Mehmet Hoca/Asistan (55555555555) - IYTE Şubeleri
('55555555555', 8),
('55555555555', 10),
('55555555555', 11),
('55555555555', 12);

CREATE TABLE INS_RESEARCHFIELDS (
    Instructor_SSN VARCHAR(11) REFERENCES INSTRUCTOR(ISSN) ON DELETE CASCADE,
    IField VARCHAR(100),
    PRIMARY KEY (Instructor_SSN, IField)
);
INSERT INTO INS_RESEARCHFIELDS (Instructor_SSN, IField) VALUES 
-- Osman Hoca (11111111111)
('11111111111', 'Artificial Intelligence Optimization'),
('11111111111', 'Mathematical Modeling'),

-- Ahmet Hoca (22222222222)
('22222222222', 'Deep Learning'),
('22222222222', 'Natural Language Processing'),

-- Halil Hoca (33333333333)
('33333333333', 'Advanced Data Structures'),
('33333333333', 'Algorithm Analysis'),

-- Ebru Hoca (44444444444)
('44444444444', 'Information Security'),
('44444444444', 'Database Management Systems'),
('44444444444', 'Cryptography'),

-- Mehmet Hoca (55555555555)
('55555555555', 'Computer Networks'),
('55555555555', 'Machine Learning'),

-- Onur Hoca (66666666666)
('66666666666', 'Theory of Computation'),
('66666666666', 'Software Engineering');

-- ==========================================
-- 7. DÖNGÜSEL REFERANSLAR (ALTER)
-- ==========================================
ALTER TABLE FACULTY ADD CONSTRAINT fk_dean_ssn FOREIGN KEY (DeanSSN) REFERENCES INSTRUCTOR(ISSN);
ALTER TABLE DEPARTMENT ADD CONSTRAINT fk_chair_ssn FOREIGN KEY (ChairSSN) REFERENCES INSTRUCTOR(ISSN);
-- Fakülte Dekanlarını Atıyoruz
UPDATE FACULTY SET DeanSSN = '11111111111' WHERE FacultyID = 10; -- Osman Hoca (TOBB)
UPDATE FACULTY SET DeanSSN = '44444444444' WHERE FacultyID = 20; -- Ebru Hoca (Hacettepe)
UPDATE FACULTY SET DeanSSN = '66666666666' WHERE FacultyID = 30; -- Onur Hoca (IYTE)

-- Bölüm Başkanlarını Atıyoruz
UPDATE DEPARTMENT SET ChairSSN = '11111111111' WHERE DCode = 'TOBB_YZ';
UPDATE DEPARTMENT SET ChairSSN = '44444444444' WHERE DCode = 'HAC_CENG';
UPDATE DEPARTMENT SET ChairSSN = '66666666666' WHERE DCode = 'IYTE_CENG';


--IMPLEMENTATION(3-->TRIGGERS)
-- Trigger 1: Toplam Yüzde Kontrolü (Bir dersin sınav/ödev toplamı %100'ü geçemez)
-- 1. Önce fonksiyonu oluşturalım
CREATE OR REPLACE FUNCTION check_total_percent() 
RETURNS TRIGGER AS $$
DECLARE
    mevcut_toplam INTEGER;
BEGIN
    SELECT COALESCE(SUM(Percentage), 0)
    INTO mevcut_toplam
    FROM ASSESSMENT
    WHERE CourseCode = NEW.CourseCode;

    IF (mevcut_toplam + NEW.Percentage) > 100 THEN
        RAISE EXCEPTION 
        'Hata: % dersi için toplam yüzde 100ü aşıyor! (Mevcut: %, Eklenen: %)',
        NEW.CourseCode, mevcut_toplam, NEW.Percentage;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_limit_percent ON ASSESSMENT;

CREATE TRIGGER trg_limit_percent 
BEFORE INSERT ON ASSESSMENT 
FOR EACH ROW 
EXECUTE FUNCTION check_total_percent();-->LOOK

-- Trigger 2: Denklik Durumu Güncelleme Mesajı (Status değişince uyarı verir)
CREATE OR REPLACE FUNCTION notify_status_change() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Status <> NEW.Status THEN
        RAISE NOTICE 'Denklik durumu güncellendi: % -> %', OLD.Status, NEW.Status;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_status_change AFTER UPDATE ON EQUIVALENCE
FOR EACH ROW EXECUTE FUNCTION notify_status_change();-->LOOK

-- Trigger 3: ECTS Farkı Kontrolü (Fark 5'ten büyükse işlemden önce uyarır)
CREATE OR REPLACE FUNCTION check_ects_warning() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ECTSDifference > 5 THEN
        RAISE NOTICE 'Uyarı: ECTS farkı çok yüksek, akademik onay gerekebilir.';
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ects_warning BEFORE INSERT ON EQUIVALENCE
FOR EACH ROW EXECUTE FUNCTION check_ects_warning();-->LOOK


--IMPLEMENTATION(4-->meaningful check constraints)
-- 1. ECTS ve Kredi negatif olamaz
ALTER TABLE COURSE ADD CONSTRAINT check_ects_positive CHECK (ECTS > 0 AND CourseCredit >= 0);
-- 2. Değerlendirme yüzdesi 0-100 arasında olmalı
ALTER TABLE ASSESSMENT ADD CONSTRAINT check_percentage_range CHECK (Percentage > 0 AND Percentage <= 100);
-- 3. Dönem yılı mantıklı bir aralıkta olmalı
ALTER TABLE SEMESTER ADD CONSTRAINT check_semester_year CHECK (Year >= 2000 AND Year <= 2026);

-- Örnek UPDATE: Bir dersin ECTS değerini güncelleme
UPDATE COURSE SET ECTS = 8 WHERE CourseCode = 'CENG113';--select ects from course where CourseCode = 'CENG113';
-- Örnek DELETE: Geçersiz bir denklik başvurusunu silme
DELETE FROM EQUIVALENCE WHERE Status = 'Rejected' AND ECTSDifference > 5;
--INSERT
INSERT INTO INS_RESEARCHFIELDS (Instructor_SSN, IField) VALUES ('66666666666', 'Cloud Computing');
--SELECT * FROM INS_RESEARCHFIELDS WHERE Instructor_SSN = '66666666666';