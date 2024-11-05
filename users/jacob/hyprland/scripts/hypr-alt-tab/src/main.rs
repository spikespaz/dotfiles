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

    let active_client = if let Some(active_client) = Client::get_active()? {
        active_client
    } else {
        return Ok(());
    };

    if active_client.floating {
        change_floating_active(Some(&active_client), settings.current_workspace_only)?;
    } else if !active_client.grouped.is_empty() {
        Dispatch::call(DispatchType::ChangeGroupActive(
            WindowSwitchDirection::Forward,
        ))?;
    }

    Ok(())
}

/// Like `changegroupactive` dispatcher but treats floating windows as "tabs" in a "group".
///
/// Returns the new active client (only if changed) upon success.
fn change_floating_active(
    active_client: Option<&Client>,
    current_workspace_only: bool,
) -> hyprland::Result<Option<Client>> {
    let active_client_owned;

    let active_client = if let Some(active_client) = active_client {
        active_client
    } else if let Some(active_client) = Client::get_active()? {
        active_client_owned = active_client;
        &active_client_owned
    } else {
        return Ok(None);
    };

    if !active_client.floating {
        return Ok(None);
    }

    let mut floating_clients = Clients::get()?.into_iter().filter(|c| {
        c.floating && (!current_workspace_only || (c.workspace.id == active_client.workspace.id))
    });

    // According to Vaxry in the issue linked below,
    // the topmost floating window is going to be the last in the JSON list.
    // I say this is an implementation detail, but it's what we have to work with.
    // <https://github.com/hyprwm/Hyprland/issues/8283>
    if let Some(focus_client) = floating_clients.nth_back(1) {
        Dispatch::call(DispatchType::Custom(
            "alterzorder",
            &format!("bottom, {}", active_client.address),
        ))?;

        Dispatch::call(DispatchType::FocusWindow(WindowIdentifier::Address(
            focus_client.address.clone(),
        )))?;

        Ok(Some(focus_client))
    } else {
        Ok(None)
    }
}
