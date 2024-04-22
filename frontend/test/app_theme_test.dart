import 'dart:convert';

import 'package:financrr_frontend/modules/settings/models/theme.model.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const String validTheme = '''
{
  "id": "VALID",
  "logo_path": "assets/logo/logo_light.svg",
  "fallback_name": "Valid Theme",
  "preview_color": "0x111111",
  "theme_mode": "dark",
  "theme_data": {
    "brightness": "dark",
    "primary_color": "0x4B87FF",
    "background_color": "0x111111",
    "secondary_background_color": "0x1A1A1A",
    "hint_color": "0xB4B4B4",
    "card_color": "0x656565",
    "app_bar_theme_data": {
      "foreground_color": "0xFFFFFF",
      "title_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      }
    },
    "navigation_bar_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.4
      },
      "icon_color": "0x9E9E9E",
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "label_color": "0xE0E0E0"
    },
    "navigation_rail_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/indicator_color"
      },
      "selected_icon_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/icon_color"
      },
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "selected_label_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/label_color"
      },
      "unselected_label_color": "0xEEEEEE"
    },
    "elevated_button_theme_data": {
      "foreground_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_button_theme_data": {
      "foreground_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_selection_theme_data": {
      "selection_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "switch_theme_data": {
      "thumb_color": {
        "copy_from_path": "theme_data/primary_color"
      },
      "track_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.5
      }
    },
    "snack_bar_theme_data": {
      "content_text_color": "0xFFFFFF",
      "background_color": "0x656565"
    },
    "drawer_theme_data": {
      "background_color": {
        "copy_from_path": "theme_data/background_color"
      },
      "scrim_color": {
        "hex": "0xFFFFFF",
        "opacity": 0.1
      }
    }
  }
}
''';

const String invalidOverflowTheme = '''
{
  "id": "INVALID",
  "logo_path": "assets/logo/logo_light.svg",
  "fallback_name": "Invalid Theme (Stackoverflow, Cycling Colors)",
  "preview_color": {
    "copy_from_path": "theme_data/background_color"
  },
  "theme_mode": "dark",
  "theme_data": {
    "brightness": "dark",
    "primary_color": "0x4B87FF",
    "background_color": {
      "copy_from_path": "preview_color"
    },
    "secondary_background_color": "0x1A1A1A",
    "hint_color": "0xB4B4B4",
    "card_color": "0x656565",
    "app_bar_theme_data": {
      "foreground_color": "0xFFFFFF",
      "title_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      }
    },
    "navigation_bar_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.4
      },
      "icon_color": "0x9E9E9E",
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "label_color": "0xE0E0E0"
    },
    "navigation_rail_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/indicator_color"
      },
      "selected_icon_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/icon_color"
      },
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "selected_label_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/label_color"
      },
      "unselected_label_color": "0xEEEEEE"
    },
    "elevated_button_theme_data": {
      "foreground_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_button_theme_data": {
      "foreground_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_selection_theme_data": {
      "selection_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "switch_theme_data": {
      "thumb_color": {
        "copy_from_path": "theme_data/primary_color"
      },
      "track_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.5
      }
    },
    "snack_bar_theme_data": {
      "content_text_color": "0xFFFFFF",
      "background_color": "0x656565"
    },
    "drawer_theme_data": {
      "background_color": {
        "copy_from_path": "theme_data/background_color"
      },
      "scrim_color": {
        "hex": "0xFFFFFF",
        "opacity": 0.1
      }
    }
  }
}
''';

const String invalidPathTheme = '''
{
  "id": "INVALID",
  "logo_path": "assets/logo/logo_light.svg",
  "fallback_name": "Invalid Theme (Invalid Path)",
  "preview_color": "0x111111",
  "theme_mode": "dark",
  "theme_data": {
    "brightness": "dark",
    "primary_color": "0x4B87FF",
    "background_color": "0x111111",
    "secondary_background_color": "0x1A1A1A",
    "hint_color": "0xB4B4B4",
    "card_color": "0x656565",
    "app_bar_theme_data": {
      "foreground_color": "0xFFFFFF",
      "title_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "secondary_background_color"
      }
    },
    "navigation_bar_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.4
      },
      "icon_color": "0x9E9E9E",
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "label_color": "0xE0E0E0"
    },
    "navigation_rail_theme_data": {
      "indicator_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/indicator_color"
      },
      "selected_icon_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/icon_color"
      },
      "background_color": {
        "copy_from_path": "theme_data/secondary_background_color"
      },
      "selected_label_color": {
        "copy_from_path": "theme_data/navigation_bar_theme_data/label_color"
      },
      "unselected_label_color": "0xEEEEEE"
    },
    "elevated_button_theme_data": {
      "foreground_color": "0xFFFFFF",
      "background_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_button_theme_data": {
      "foreground_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "text_selection_theme_data": {
      "selection_color": {
        "copy_from_path": "theme_data/primary_color"
      }
    },
    "switch_theme_data": {
      "thumb_color": {
        "copy_from_path": "theme_data/primary_color"
      },
      "track_color": {
        "copy_from_path": "theme_data/primary_color",
        "opacity": 0.5
      }
    },
    "snack_bar_theme_data": {
      "content_text_color": "0xFFFFFF",
      "background_color": "0x656565"
    },
    "drawer_theme_data": {
      "background_color": {
        "copy_from_path": "theme_data/background_color"
      },
      "scrim_color": {
        "hex": "0xFFFFFF",
        "opacity": 0.1
      }
    }
  }
}
''';

void main() {
  group('AppTheme', () {
    group('.tryFromJson', () {
      test(' (valid)', () {
        final AppTheme? theme = AppTheme.tryFromJson(jsonDecode(validTheme));
        expect(theme, isNotNull);
        expect(theme!.id, 'VALID');
      });

      test(' (invalid: StackOverflowError (cycling colors))', () {
        expect(() => AppTheme.tryFromJson(jsonDecode(invalidOverflowTheme)), throwsA(isA<StackOverflowError>()));
      });

      test(' (invalid: StateError (invalid path))', () {
        expect(() => AppTheme.tryFromJson(jsonDecode(invalidPathTheme)), throwsA(isA<StateError>()));
      });
    });
  });
}
