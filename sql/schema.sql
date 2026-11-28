CREATE DATABASE IF NOT EXISTS messenger;
USE messenger;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_username UNIQUE (username),
    -- constraint: no empty or whitespace usernames so accounts,
    -- cannot be created with blank  names
    CONSTRAINT chk_users_username_not_blank CHECK (CHAR_LENGTH(TRIM(username)) > 0),
    -- constraint: no empty or whitespace passwords in database
    CONSTRAINT chk_users_password_not_blank CHECK (CHAR_LENGTH(TRIM(password)) > 0)
);

CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rooms_name UNIQUE (name),
    -- constraint: prevents blank or space room names 
    CONSTRAINT chk_rooms_name_not_blank CHECK (CHAR_LENGTH(TRIM(name)) > 0)
);
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    room_id INT NULL,
    receiver_id INT NULL,
    text VARCHAR(500) NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- ON DELETE RESTRICT: blocks deleting a user who has sent messages 
    CONSTRAINT fk_messages_sender
        FOREIGN KEY (sender_id) REFERENCES users (id)
        ON DELETE RESTRICT,
    -- ON DELETE CASCADE: when a room is deleted, messages in that room
    -- are deleted with it
    CONSTRAINT fk_messages_room
        FOREIGN KEY (room_id) REFERENCES rooms (id)
        ON DELETE CASCADE,

    -- ON DELETE RESTRICT: blocks deleting a user who is as a private-message receiever
    CONSTRAINT fk_messages_receiver
        FOREIGN KEY (receiver_id) REFERENCES users (id)
        ON DELETE RESTRICT,
    -- constraint: every message must have either a room or a private
    -- receiver, never both at once and never neither
    CONSTRAINT chk_messages_target
        CHECK ((room_id IS NULL) <> (receiver_id IS NULL)),

    -- constraint: prevents saving empty or whitespace message text
    CONSTRAINT chk_messages_text_not_blank
        CHECK (CHAR_LENGTH(TRIM(text)) > 0)
);

INSERT IGNORE INTO rooms (name) VALUES ('general');
--
-- Test database: messenger_test
--
CREATE DATABASE IF NOT EXISTS messenger_test;
USE messenger_test;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_test_users_username UNIQUE (username),
    --  constraint: matches main DB by rejecting blank test usernames
    CONSTRAINT chk_test_users_username_not_blank CHECK (CHAR_LENGTH(TRIM(username)) > 0),
    --  constraint: matches main DB by rejecting blank test passwords
    CONSTRAINT chk_test_users_password_not_blank CHECK (CHAR_LENGTH(TRIM(password)) > 0)
);

CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_test_rooms_name UNIQUE (name),
    -- constraint: matches main DB by rejecting blank test room names
    CONSTRAINT chk_test_rooms_name_not_blank CHECK (CHAR_LENGTH(TRIM(name)) > 0)
);

CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    room_id INT NULL,
    receiver_id INT NULL,
    text VARCHAR(500) NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- ON DELETE RESTRICT: matches main DB so tests verify users with sent
    -- messages cannot be deleted.
    CONSTRAINT fk_test_messages_sender
        FOREIGN KEY (sender_id) REFERENCES users (id)
        ON DELETE RESTRICT,

    -- ON DELETE CASCADE: matches main DB so deleting a test room removes its
    -- room messages automatically.
    CONSTRAINT fk_test_messages_room
        FOREIGN KEY (room_id) REFERENCES rooms (id)
        ON DELETE CASCADE,

    -- ON DELETE RESTRICT: matches main DB so private-message receivers cannot
    -- be deleted while referenced by messages.
    CONSTRAINT fk_test_messages_receiver
        FOREIGN KEY (receiver_id) REFERENCES users (id)
        ON DELETE RESTRICT,

    -- constraint: one of between room_id and receiver_id in
    -- the test database as well
    CONSTRAINT chk_test_messages_target
        CHECK ((room_id IS NULL) <> (receiver_id IS NULL)),

    -- constraint: prevents blank test message bodies
    CONSTRAINT chk_test_messages_text_not_blank
        CHECK (CHAR_LENGTH(TRIM(text)) > 0)
);

INSERT IGNORE INTO rooms (name) VALUES ('general');