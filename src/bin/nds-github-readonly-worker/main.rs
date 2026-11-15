#[cfg(target_os = "linux")]
mod entrypoint;
#[cfg(target_os = "linux")]
mod reader;
fn main() {
    #[cfg(target_os = "linux")]
    entrypoint::run();
    #[cfg(not(target_os = "linux"))]
    std::process::exit(13);
}
