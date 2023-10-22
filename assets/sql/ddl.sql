CREATE TABLE IF NOT EXISTS settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  participationConsent INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  categoryId INTEGER,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  unit TEXT,
  FOREIGN KEY(categoryId) REFERENCES settings_categories(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS journal (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE UNIQUE,
  symptoms TEXT,
  pain INTEGER
);

CREATE TABLE IF NOT EXISTS pain_descriptors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalId INTEGER,
  descriptor TEXT,
  FOREIGN KEY(journalId) REFERENCES journal(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS location_markers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalId INTEGER,
  x REAL,
  y REAL,
  description TEXT,
  FOREIGN KEY(journalId) REFERENCES journal(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS medications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalId INTEGER,
  name TEXT,
  FOREIGN KEY(journalId) REFERENCES journal(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalId INTEGER,
  bytes BLOB,
  description TEXT,
  name TEXT,
  mimeType TEXT,
  FOREIGN KEY(journalId) REFERENCES journal(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS journal_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalId INTEGER,
  settingsCategoryId INTEGER,
  active INTEGER,
  FOREIGN KEY(journalId) REFERENCES journal(id) ON DELETE CASCADE,
  FOREIGN KEY(settingsCategoryId) REFERENCES settings_categories(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS journal_parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journalCategoryId INTEGER,
  settingsParameterId INTEGER,
  value INTEGER,
  FOREIGN KEY(journalCategoryId) REFERENCES journal_categories(id) ON DELETE CASCADE,
  FOREIGN KEY(settingsParameterId) REFERENCES settings_parameters(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  isEnabled INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  hour INT NOT NULL,
  minute INT NOT NULL,
  type TEXT NOT NULL
);