use hyprland::data::{Client, Clients};
use hyprland::dispatch::{Dispatch, DispatchType, WindowIdentifier, WindowSwitchDirection};
use hyprland::shared::{HyprData, HyprDataActiveOptional};

struct Settings {
    /// If `true`, disables focusing/switching to windows on other workspaces.
    current_workspace_only: bool,
}

fn main() -> anyhow::Result<()> {
    let settings = Settings {
        current_workspace_only: true,
    };

    if let Some(active_client) = Client::get_active()? {
        if active_client.floating {
            // Move the current (topmost) floating window below another (if there is another).
            Dispatch::call(DispatchType::Custom(
                "alterzorder",
                &format!("bottom, {}", active_client.address),
            ))?;

            // Find the new topmost floating window.
            // Also, if `current_workspace_only`, filter out windows from other workspaces.
            let floating_clients = Clients::get()?.into_iter().filter(|c| {
                c.floating
                    && (!settings.current_workspace_only
                        || (c.workspace.id == active_client.workspace.id))
            });

            // According to Vaxry in the issue linked below,
            // the topmost floating window is going to be the last in the JSON list.
            // I say this is an implementation detail, but it's what we have to work with.
            // <https://github.com/hyprwm/Hyprland/issues/8283>
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
