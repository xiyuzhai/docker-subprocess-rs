use std::io::{self, BufRead, Write};
use std::process::{Command, Stdio};

fn main() {
    // Start the Docker container
    let mut child = Command::new("docker")
        .args(["run", "--gpus", "all", "-i", "rust-calculator"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to start Docker container");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    let stdout = child.stdout.take().expect("Failed to open stdout");
    let stdout_reader = io::BufReader::new(stdout);

    // Example: Send numbers to container program for addition
    let numbers = vec!["5", "3"];

    // Write numbers to container's stdin
    writeln!(stdin, "{}", numbers.join(" ")).expect("Failed to write to stdin");

    // Drop stdin after writing to signal EOF to the container
    drop(stdin);

    // Read result from container's stdout
    for line in stdout_reader.lines() {
        match line {
            Ok(result) => {
                // Only print lines that contain numeric results
                if let Ok(_) = result.trim().parse::<i32>() {
                    println!("Result from container: {}", result);
                    break; // Exit the loop after getting the numeric result
                }
            }
            Err(e) => eprintln!("Error reading from container: {}", e),
        }
    }

    // Wait for the child process to complete
    child.wait().expect("Failed to wait for Docker container");
}
