-- Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    role VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice Johnson', 'Engineering', 'Software Engineer'),
(2, 'Bob Smith', 'HR', 'HR Manager'),
(3, 'Clara Lee', 'Finance', 'Accountant'),
(4, 'David Kumar', 'Engineering', 'DevOps Engineer'),
(5, 'Eva Brown', 'Marketing', 'Marketing Lead'),
(6, 'Frank Li', 'Engineering', 'QA Engineer'),
(7, 'Grace Tan', 'Finance', 'CFO'),
(8, 'Henry Wu', 'Engineering', 'CTO'),
(9, 'Isla Patel', 'Support', 'Customer Support'),
(10, 'Jack Chen', 'HR', 'Recruiter');

-- Keycard Logs Table
CREATE TABLE keycard_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    room VARCHAR(50),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP
);

INSERT INTO keycard_logs VALUES
(1, 1, 'Office', '2025-10-15 08:00', '2025-10-15 12:00'),
(2, 2, 'HR Office', '2025-10-15 08:30', '2025-10-15 17:00'),
(3, 3, 'Finance Office', '2025-10-15 08:45', '2025-10-15 12:30'),
(4, 4, 'Server Room', '2025-10-15 08:50', '2025-10-15 09:10'),
(5, 5, 'Marketing Office', '2025-10-15 09:00', '2025-10-15 17:30'),
(6, 6, 'Office', '2025-10-15 08:30', '2025-10-15 12:30'),
(7, 7, 'Finance Office', '2025-10-15 08:00', '2025-10-15 18:00'),
(8, 8, 'Server Room', '2025-10-15 08:40', '2025-10-15 09:05'),
(9, 9, 'Support Office', '2025-10-15 08:30', '2025-10-15 16:30'),
(10, 10, 'HR Office', '2025-10-15 09:00', '2025-10-15 17:00'),
(11, 4, 'CEO Office', '2025-10-15 20:50', '2025-10-15 21:00'); -- killer

-- Calls Table
CREATE TABLE calls (
    call_id INT PRIMARY KEY,
    caller_id INT,
    receiver_id INT,
    call_time TIMESTAMP,
    duration_sec INT
);

INSERT INTO calls VALUES
(1, 4, 1, '2025-10-15 20:55', 45),
(2, 5, 1, '2025-10-15 19:30', 120),
(3, 3, 7, '2025-10-15 14:00', 60),
(4, 2, 10, '2025-10-15 16:30', 30),
(5, 4, 7, '2025-10-15 20:40', 90);

-- Alibis Table
CREATE TABLE alibis (
    alibi_id INT PRIMARY KEY,
    employee_id INT,
    claimed_location VARCHAR(50),
    claim_time TIMESTAMP
);

INSERT INTO alibis VALUES
(1, 1, 'Office', '2025-10-15 20:50'),
(2, 4, 'Server Room', '2025-10-15 20:50'), -- false alibi
(3, 5, 'Marketing Office', '2025-10-15 20:50'),
(4, 6, 'Office', '2025-10-15 20:50');

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT PRIMARY KEY,
    room VARCHAR(50),
    description VARCHAR(255),
    found_time TIMESTAMP
);

INSERT INTO evidence VALUES
(1, 'CEO Office', 'Fingerprint on desk', '2025-10-15 21:05'),
(2, 'CEO Office', 'Keycard swipe logs mismatch', '2025-10-15 21:10'),
(3, 'Server Room', 'Unusual access pattern', '2025-10-15 21:15');


select * from alibis;
select * from calls;
select * from employees;
select * from evidence;
select * from keycard_logs;

-- Step 1: Get all evidence found in the CEO Office.
-- This gives the crime scene and approximate crime time.
SELECT evidence_id, room, description, found_time
FROM evidence
WHERE room = 'CEO Office'
ORDER BY found_time;

-- Step 2: Find employees who accessed the CEO Office near the crime.
-- We consider a 30-minute window before and after the first evidence timestamp.

SELECT kl.log_id, kl.employee_id, emp.name, kl.room,
       kl.entry_time, kl.exit_time
FROM keycard_logs kl
JOIN employees emp ON emp.employee_id = kl.employee_id
WHERE kl.room = 'CEO Office'
  AND kl.entry_time BETWEEN
        (
            -- Crime timestamp (from first evidence found in CEO Office)
            SELECT found_time
            FROM evidence
            WHERE room = 'CEO Office'
            ORDER BY found_time
            LIMIT 1
        ) - INTERVAL '30 minutes'
      AND
        (
            -- Same timestamp + 30 minutes
            SELECT found_time
            FROM evidence
            WHERE room = 'CEO Office'
            ORDER BY found_time
            LIMIT 1
        ) + INTERVAL '30 minutes'
ORDER BY kl.entry_time;

-- Step 3: Find employees whose alibi claim is contradicted by keycard logs.
-- If claim_time falls between entry/exit_time but locations differ → lying.

SELECT a.alibi_id, a.employee_id, emp.name,
       a.claimed_location, a.claim_time,
       kl.room AS actual_room, kl.entry_time, kl.exit_time
FROM alibis a
JOIN employees emp ON emp.employee_id = a.employee_id
JOIN keycard_logs kl ON kl.employee_id = a.employee_id
WHERE a.claim_time BETWEEN kl.entry_time AND kl.exit_time
  AND kl.room <> a.claimed_location   -- mismatch = false alibi
ORDER BY a.claim_time;

-- Step 5: Identify employees who were in the CEO Office
-- at the exact moment evidence was found.

SELECT ev.evidence_id, ev.room, ev.description, ev.found_time,
       kl.log_id, kl.employee_id, emp.name, kl.entry_time, kl.exit_time
FROM evidence ev
JOIN keycard_logs kl
  ON ev.room = kl.room
 AND ev.found_time BETWEEN kl.entry_time AND kl.exit_time
JOIN employees emp ON emp.employee_id = kl.employee_id
WHERE ev.room = 'CEO Office'
ORDER BY ev.found_time, kl.entry_time;

-- Step 6: Identify suspects who meet ALL criteria:
-- 1. Accessed CEO Office near the crime
-- 2. Lied in their alibi
-- 3. Participated in suspicious calls between 20:50–21:00

SELECT employee_id
FROM (
    ------------------------------------------------------------------
    -- Subquery A: Employees who accessed CEO Office near the crime
    ------------------------------------------------------------------
    SELECT DISTINCT kl.employee_id
    FROM keycard_logs kl
    WHERE kl.room = 'CEO Office'
      AND kl.entry_time BETWEEN
            (
                SELECT found_time
                FROM evidence
                WHERE room = 'CEO Office'
                ORDER BY found_time
                LIMIT 1
            ) - INTERVAL '30 minutes'
        AND
            (
                SELECT found_time
                FROM evidence
                WHERE room = 'CEO Office'
                ORDER BY found_time
                LIMIT 1
            ) + INTERVAL '30 minutes'
)
INTERSECT
SELECT employee_id
FROM (
    ------------------------------------------------------------------
    -- Subquery B: Employees with conflicting alibi (lying)
    ------------------------------------------------------------------
    SELECT DISTINCT a.employee_id
    FROM alibis a
    JOIN keycard_logs kl ON a.employee_id = kl.employee_id
    WHERE a.claim_time BETWEEN kl.entry_time AND kl.exit_time
      AND kl.room <> a.claimed_location
)
INTERSECT
SELECT employee_id
FROM (
    ------------------------------------------------------------------
    -- Subquery C: Employees involved in suspicious calls
    ------------------------------------------------------------------
    SELECT DISTINCT COALESCE(c.caller_id, c.receiver_id) AS employee_id
    FROM calls c
    WHERE c.call_time BETWEEN
            (
                (SELECT found_time::date
                 FROM evidence
                 WHERE room = 'CEO Office'
                 ORDER BY found_time
                 LIMIT 1)
                + time '20:50:00'
            )
        AND
            (
                (SELECT found_time::date
                 FROM evidence
                 WHERE room = 'CEO Office'
                 ORDER BY found_time
                 LIMIT 1)
                + time '21:00:00'
            )
);

select * from employees
where employee_id = 4 ;