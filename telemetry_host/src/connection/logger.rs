use std::{
    fs::{self, File, OpenOptions},
    io::{self, BufWriter, prelude::*},
    path::Path,
    time::{SystemTime, UNIX_EPOCH},
};

use chrono::NaiveDateTime;
use serde::Serialize;
use serde_json;

/// A simpler logging utility using the JSON lines format that ignores any write errors.
pub struct Logger {
    file: Option<BufWriter<File>>
}

impl Logger {
    pub fn new(filename: Option<String>) -> Logger {
        Logger {
            file: maybe_create_file(filename)
        }
    }

    pub fn log<T>(&mut self, value: &T) where T: Serialize {
        if let Some(ref mut writer) = self.file {
            if let Err(e) = serde_json::to_writer(&mut *writer, value)
                .map_err(|e| io::Error::from(e))
                .and_then(|_| writeln!(writer, ""))
                .and_then(|_| writer.flush())
            {
                println!("Failed to write to log: {}", e);
            }
        }
    }
}

fn maybe_create_file(filename: Option<String>) -> Option<BufWriter<File>> {
    if let Some(filename) = filename {
        let time =  NaiveDateTime::from_timestamp(timestamp(), 0);
        let dir_name = format!("logs/{}", time.format("%Y%m%d_%H%M%S"));
        let path = Path::new(&dir_name);

        let _ = fs::create_dir_all(path);

        match OpenOptions::new().append(true).create(true).open(path.join(filename)) {
            Ok(file) => {
                let mut out = BufWriter::new(file);
                match writeln!(out, "") {
                    Ok(..) => Some(out),
                    Err(e) => {
                        println!("Failed to write to log: {:?}", e);
                        None
                    }
                }
            },
            Err(e) => {
                println!("Failed to create file: {:?}", e);
                None
            }
        }
    }
    else {
        None
    }
}

fn timestamp() -> i64 {
    SystemTime::now().duration_since(UNIX_EPOCH).expect("Error computing timestamp").as_secs() as i64
}
