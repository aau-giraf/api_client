CREATE TABLE IF NOT EXISTS giraf_offline(
  offline_id INTEGER PRIMARY KEY,
  json BLOB NOT NULL,
  is_online INTEGER,
  is_deleted INTEGER DEFAULT 0,
  object TEXT NOT NULL,
  created_date TEXT NOT NULL,
  modified_date TEXT NOT NULL
);
