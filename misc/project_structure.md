# Krishibhaav Project Structure

Here is a visual map of the current directory structure, focusing heavily on the `lib` codebase since it is the core of the Flutter application.

## Directory Mindmap

```mermaid
mindmap
  root((Krishibhaav))
    lib
      core
        barrel_logic.dart
        colors.dart
        market_message_parser.dart
        market_status.dart
        text_styles.dart
      models
        agent_settings_model.dart
        barrel_booking_model.dart
        barrel_stock_model.dart
        board_rate_model.dart
        farmer_price_model.dart
        open_market_price_point.dart
        price_point.dart
        user_model.dart
      providers
        agent_provider.dart
        auth_provider.dart
        farmer_provider.dart
        theme_provider.dart
      screens
        agent
          add_farmer_sheet.dart
          agent_home_screen.dart
          barrel_booking_detail_sheet.dart
          farmer_detail_sheet.dart
        auth
          login_register_screen.dart
          otp_screen.dart
        farmer
          farmer_barrel_action_sheet.dart
          farmer_barrel_request_sheet.dart
          farmer_home_screen.dart
        splash_screen.dart
      services
        agent_service.dart
        auth_service.dart
        barrel_service.dart
        board_rate_service.dart
        cache_service.dart
        farmer_history_service.dart
        farmer_service.dart
        fcm_dispatch_service.dart
        notification_service.dart
        price_history_service.dart
      utils
        theme.dart
      widgets
        barrel_booking_card.dart
        barrel_stock_edit_dialog.dart
        farmer_barrel_booking_card.dart
        farmer_list_card.dart
        paste_market_message_sheet.dart
        price_chart_widget.dart
        price_edit_dialog.dart
        profile_sheet.dart
        stats_grid_widget.dart
      app_router.dart
      firebase_options.dart
      main.dart
    test
      barrel_logic_test.dart
      market_message_parser_test.dart
      router_redirect_test.dart
    misc
      BUG_REPORT.md
      LOGBOOK.md
      LOREBOOK.md
      PROGRESS_TRACKER.md
      V2_SPEC.md
      project_structure.md
    assets
      branding
        icon_tile.png
        lockup.png
        symbol.png
        symbol_white.png
      service_account.json
    pubspec.yaml
```

## Architectural Flow Graph

```mermaid
graph TD
    subgraph UI Layer
        Screens["Screens\n(Auth, Agent, Farmer)"]
        Widgets["Reusable Widgets"]
    end

    subgraph State Management
        Providers["Providers\n(Farmer, Agent, Auth)"]
    end

    subgraph Core Services
        Services["Services\n(Firebase, Barrel, History)"]
        Router["App Router\n(go_router)"]
    end

    subgraph Data Models
        Models["Models\n(User, Prices, Barrels)"]
    end

    Screens -->|Listens & Triggers| Providers
    Widgets -->|Used in| Screens
    Providers -->|Calls| Services
    Providers -->|Holds State| Models
    Services -->|Returns| Models
    Router -->|Navigates| Screens
```
