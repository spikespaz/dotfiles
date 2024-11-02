use hyprland::data::{Client, Clients};
use hyprland::dispatch::{Dispatch, DispatchType, WindowIdentifier, WindowSwitchDirection};
use hyprland::shared::{HyprData, HyprDataActiveOptional};

fn main() -> anyhow::Result<()> {
    if let Some(active_client) = Client::get_active()? {
        if active_client.floating {
            // Move the current (topmost) floating window below another (if there is another).
            Dispatch::call(DispatchType::Custom("alterzorder", "bottom, activewindow"))?;

            // Find the new topmost floating window and focus it.
            let floating_clients = Clients::get()?.into_iter().filter(|c| c.floating);
            // https://github.com/hyprwm/Hyprland/issues/8283
            if let Some(topmost) = floating_clients.last() {
                Dispatch::call(DispatchType::FocusWindow(WindowIdentifier::Address(
                    topmost.address,
                )))?;
                Ok(())
            } else {
                unreachable!("if the active_client is floating, there is always at least one floating window")
            }
        } else if !active_client.grouped.is_empty() {
            Dispatch::call(DispatchType::ChangeGroupActive(
                WindowSwitchDirection::Forward,
            ))?;
            Ok(())
        } else {
            Ok(())
        }
    } else {
        Ok(())
    }
}
