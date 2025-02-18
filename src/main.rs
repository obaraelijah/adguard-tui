mod fetch;
mod ui;
mod welcome;
mod widgets;

use reqwest::Client;
use std::{env, sync::Arc, time::Duration};
use tokio::time::interval;

use ui::draw_ui;

use fetch::{
    fetch_filters::fetch_adguard_filter_list, fetch_query_log::fetch_adguard_query_log,
    fetch_stats::fetch_adguard_stats, fetch_status::fetch_adguard_status,
};

async fn run() -> anyhow::Result<()> {
    // Create a reqwest client
    let client = Client::new();

    // AdGuard instance details, from env vars (verified in welcome.rs)
    let ip = env::var("ADGUARD_IP")?;
    let port = env::var("ADGUARD_PORT")?;
    let hostname = format!("http://{}:{}", ip, port);
    let username = env::var("ADGUARD_USERNAME")?;
    let password = env::var("ADGUARD_PASSWORD")?;

    // Fetch data that doesn't require updates
    let filters = fetch_adguard_filter_list(&client, &hostname, &username, &password).await?;

    // Open channels for data fetching where updates are required
    let (queries_tx, queries_rx) = tokio::sync::mpsc::channel(1);
    let (stats_tx, stats_rx) = tokio::sync::mpsc::channel(1);
    let (status_tx, status_rx) = tokio::sync::mpsc::channel(1);

    // Create a channel for the UI to notify the fetcher to shutdown
    let shutdown = Arc::new(tokio::sync::Notify::new());

    // Spawn the UI task, pass data and update channels
    let draw_ui_task = tokio::spawn(draw_ui(
        queries_rx,
        stats_rx,
        status_rx,
        filters,
        Arc::clone(&shutdown),
    ));

    // Get update interval (in seconds)
    let interval_secs: u64 = env::var("ADGUARD_UPDATE_INTERVAL")
        .unwrap_or_else(|_| "2".into())
        .parse()?;
    let mut interval = interval(Duration::from_secs(interval_secs));

    // Open loop for fetching data at the specified interval
    loop {
        tokio::select! {
            _ = interval.tick() => {
                let queries = fetch_adguard_query_log(&client, &hostname, &username, &password).await?;
                if queries_tx.send(queries.data).await.is_err() {
                    return Err(anyhow::anyhow!("Failed to send query data"));
                }

                let stats = fetch_adguard_stats(&client, &hostname, &username, &password).await?;
                if stats_tx.send(stats).await.is_err() {
                    return Err(anyhow::anyhow!("Failed to send stats data"));
                }

                let status = fetch_adguard_status(&client, &hostname, &username, &password).await?;
                if status_tx.send(status).await.is_err() {
                    return Err(anyhow::anyhow!("Failed to send status data"));
                }
            }
            _ = shutdown.notified() => {
                break;
            }
        }
    }

    draw_ui_task.await??;

    Ok(())
}

fn main() {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        welcome::welcome()
            .await
            .or_else(|e| {
                eprintln!("Failed to initialize: {}", e);
                Err(std::io::Error::new(
                    std::io::ErrorKind::Other,
                    "Failed to initialize",
                ))
            })
            .unwrap();

        run()
            .await
            .or_else(|e| {
                eprintln!("Failed to run: {}", e);
                Err(std::io::Error::new(
                    std::io::ErrorKind::Other,
                    "Failed to run",
                ))
            })
            .unwrap();
    });
}
