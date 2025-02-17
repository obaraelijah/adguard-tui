use tui::{
    style::{Color, Modifier, Style},
    text::{Span, Line},
    widgets::{Block, Borders, Paragraph, Wrap},
};

use crate::fetch::fetch_status::StatusResponse;

pub fn render_status_paragraph(status: &StatusResponse) -> Paragraph {
    let block = Block::default()
        .borders(Borders::ALL)
        .style(Style::default().fg(Color::Gray))
        .title(Span::styled(
            "Status",
            Style::default().add_modifier(Modifier::BOLD),
        ));

    let text = vec![
        Line::from(vec![
            Span::styled("Version: ", Style::default()),
            Span::raw(format!("{}", status.version)),
        ]),
        Line::from(vec![
            Span::styled("DNS Port: ", Style::default()),
            Span::raw(format!("{}", status.dns_port)),
        ]),
        Line::from(vec![
            Span::styled("Protection Enabled: ", Style::default()),
            Span::raw(format!("{}", status.protection_enabled)),
        ]),
        // You can add other fields you want to display here
    ];
    Paragraph::new(text).wrap(Wrap { trim: true }).block(block)
}
