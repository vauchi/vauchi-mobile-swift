// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Models.swift
// Decodable types matching core UI JSON output (serde snake_case)
// Maps to: vauchi-core/src/ui/screen.rs, component.rs, action.rs

import Foundation
import SwiftUI

// MARK: - Design Token Environment

/// SwiftUI environment key for injecting design tokens into the view hierarchy.
private struct DesignTokensKey: EnvironmentKey {
    static let defaultValue: DesignTokens = .defaults
}

public extension EnvironmentValues {
    var designTokens: DesignTokens {
        get { self[DesignTokensKey.self] }
        set { self[DesignTokensKey.self] = newValue }
    }
}

// MARK: - JSON Decoding Strategy

/// Shared decoder configured for serde snake_case output.
public let coreJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

/// Shared encoder for sending UserAction to core.
/// Does NOT use `.convertToSnakeCase` because UserAction's custom `encode(to:)`
/// already emits the correct keys (PascalCase variant names like "TextChanged",
/// snake_case field names like "component_id"). Applying `.convertToSnakeCase`
/// would corrupt variant keys to "text_changed", breaking serde deserialization.
public let coreJSONEncoder: JSONEncoder = .init()

// MARK: - Design Tokens

/// Layout tokens for consistent cross-platform rendering.
/// Maps to: `vauchi-core::theme::DesignTokens`
public struct DesignTokens: Decodable {
    public let spacing: SpacingTokens
    public let spacingDirection: SpacingDirectionTokens
    public let typography: TypographyTokens
    public let borderRadius: BorderRadiusTokens
    public let touchTarget: TouchTargetTokens
    public let motion: MotionTokens

    public init(
        spacing: SpacingTokens,
        spacingDirection: SpacingDirectionTokens,
        typography: TypographyTokens,
        borderRadius: BorderRadiusTokens,
        touchTarget: TouchTargetTokens,
        motion: MotionTokens
    ) {
        self.spacing = spacing
        self.spacingDirection = spacingDirection
        self.typography = typography
        self.borderRadius = borderRadius
        self.touchTarget = touchTarget
        self.motion = motion
    }

    public static let defaults = DesignTokens(
        spacing: SpacingTokens(xs: 4, sm: 8, smMd: 12, md: 16, lg: 24, xl: 32),
        spacingDirection: SpacingDirectionTokens(
            contentStart: 16, contentEnd: 16,
            listItemStart: 8, listItemEnd: 8,
            listItemInlineStart: 12, listItemInlineEnd: 12
        ),
        typography: TypographyTokens(titleSize: 24, subtitleSize: 18, bodySize: 16, captionSize: 14),
        borderRadius: BorderRadiusTokens(sm: 4, md: 8, mdLg: 12, lg: 16),
        touchTarget: TouchTargetTokens(minimum: 44),
        motion: MotionTokens(enterDurationMs: 200, exitDurationMs: 150, emphasisDurationMs: 300)
    )
}

public struct SpacingTokens: Decodable {
    public let xs: UInt16
    public let sm: UInt16
    public let smMd: UInt16
    public let md: UInt16
    public let lg: UInt16
    public let xl: UInt16

    public init(xs: UInt16, sm: UInt16, smMd: UInt16 = 12, md: UInt16, lg: UInt16, xl: UInt16) {
        self.xs = xs
        self.sm = sm
        self.smMd = smMd
        self.md = md
        self.lg = lg
        self.xl = xl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        xs = try container.decode(UInt16.self, forKey: .xs)
        sm = try container.decode(UInt16.self, forKey: .sm)
        smMd = try container.decodeIfPresent(UInt16.self, forKey: .smMd) ?? 12
        md = try container.decode(UInt16.self, forKey: .md)
        lg = try container.decode(UInt16.self, forKey: .lg)
        xl = try container.decode(UInt16.self, forKey: .xl)
    }

    private enum CodingKeys: String, CodingKey {
        case xs, sm, smMd, md, lg, xl
    }
}

public struct SpacingDirectionTokens: Decodable {
    public let contentStart: UInt16
    public let contentEnd: UInt16
    public let listItemStart: UInt16
    public let listItemEnd: UInt16
    public let listItemInlineStart: UInt16
    public let listItemInlineEnd: UInt16

    public init(
        contentStart: UInt16,
        contentEnd: UInt16,
        listItemStart: UInt16,
        listItemEnd: UInt16,
        listItemInlineStart: UInt16,
        listItemInlineEnd: UInt16
    ) {
        self.contentStart = contentStart
        self.contentEnd = contentEnd
        self.listItemStart = listItemStart
        self.listItemEnd = listItemEnd
        self.listItemInlineStart = listItemInlineStart
        self.listItemInlineEnd = listItemInlineEnd
    }
}

public struct TypographyTokens: Decodable {
    public let titleSize: UInt16
    public let subtitleSize: UInt16
    public let bodySize: UInt16
    public let captionSize: UInt16

    public init(titleSize: UInt16, subtitleSize: UInt16, bodySize: UInt16, captionSize: UInt16) {
        self.titleSize = titleSize
        self.subtitleSize = subtitleSize
        self.bodySize = bodySize
        self.captionSize = captionSize
    }
}

public struct BorderRadiusTokens: Decodable {
    public let sm: UInt16
    public let md: UInt16
    public let mdLg: UInt16
    public let lg: UInt16

    public init(sm: UInt16, md: UInt16, mdLg: UInt16, lg: UInt16) {
        self.sm = sm
        self.md = md
        self.mdLg = mdLg
        self.lg = lg
    }
}

public struct TouchTargetTokens: Decodable {
    public let minimum: UInt16

    public init(minimum: UInt16) {
        self.minimum = minimum
    }
}

public struct MotionTokens: Decodable {
    public let enterDurationMs: UInt16
    public let exitDurationMs: UInt16
    public let emphasisDurationMs: UInt16

    public init(enterDurationMs: UInt16, exitDurationMs: UInt16, emphasisDurationMs: UInt16) {
        self.enterDurationMs = enterDurationMs
        self.exitDurationMs = exitDurationMs
        self.emphasisDurationMs = emphasisDurationMs
    }
}

// MARK: - ScreenModel

/// Describes a full screen to render.
/// Maps to: `vauchi-core::ui::screen::ScreenModel`
public struct ScreenModel: Decodable {
    public let screenId: String
    public let title: String
    public let subtitle: String?
    public let components: [Component]
    public let actions: [ScreenAction]
    public let progress: Progress?
    public let tokens: DesignTokens
    /// Whether the renderer scrolls the screen content or renders a
    /// fixed, non-scrolling layout sized to the viewport. Absent on the
    /// wire when `.scroll` (the default), so this defaults to `.scroll`.
    public let layout: ScreenLayout

    public init(
        screenId: String,
        title: String,
        subtitle: String? = nil,
        components: [Component],
        actions: [ScreenAction],
        progress: Progress? = nil,
        tokens: DesignTokens = .defaults,
        layout: ScreenLayout = .scroll
    ) {
        self.screenId = screenId
        self.title = title
        self.subtitle = subtitle
        self.components = components
        self.actions = actions
        self.progress = progress
        self.tokens = tokens
        self.layout = layout
    }

    private enum CodingKeys: String, CodingKey {
        case screenId, title, subtitle, components, actions, progress, tokens, layout
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenId = try container.decode(String.self, forKey: .screenId)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        components = try container.decode([Component].self, forKey: .components)
        actions = try container.decode([ScreenAction].self, forKey: .actions)
        progress = try container.decodeIfPresent(Progress.self, forKey: .progress)
        tokens = try container.decodeIfPresent(DesignTokens.self, forKey: .tokens) ?? .defaults
        layout = try container.decodeIfPresent(ScreenLayout.self, forKey: .layout) ?? .scroll
    }
}

/// Whether the renderer scrolls the screen content or renders a fixed,
/// non-scrolling layout sized to the viewport. Absent on the wire when
/// `Scroll` (the default), so the field defaults to `.scroll`.
/// `pinned`: chrome stays pinned and the screen's list component owns
/// scrolling (lazy); unlike `fixed`, overlays may still reflow
/// (design `2026-06-11-contacts-list-windowing`).
/// Maps to: `vauchi-core::ui::screen::ScreenLayout`
public enum ScreenLayout: String, Decodable {
    case scroll = "Scroll"
    case fixed = "Fixed"
    case pinned = "Pinned"
}

/// Step progress indicator.
/// Maps to: `vauchi-core::ui::screen::Progress`
public struct Progress: Decodable {
    public let currentStep: UInt8
    public let totalSteps: UInt8
    public let label: String?

    public init(currentStep: UInt8, totalSteps: UInt8, label: String? = nil) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.label = label
    }
}

/// A button or action the user can take on the screen.
/// Maps to: `vauchi-core::ui::screen::ScreenAction`
public struct ScreenAction: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let style: ActionStyle
    public let enabled: Bool
    /// Optional accessibility override. `nil` → frontends derive the
    /// screen-reader announcement from `label`. Present → `a11y.label`
    /// replaces it and `a11y.hint` surfaces as the VoiceOver hint.
    /// Maps to `vauchi-core::ui::screen::ScreenAction::a11y` (serde
    /// `#[serde(default, skip_serializing_if = "Option::is_none")]`).
    public var a11y: A11y?

    public init(id: String, label: String, style: ActionStyle, enabled: Bool, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.style = style
        self.enabled = enabled
        self.a11y = a11y
    }
}

/// Visual style for a screen action.
/// Maps to: `vauchi-core::ui::screen::ActionStyle`
public enum ActionStyle: String, Decodable {
    case primary = "Primary"
    case secondary = "Secondary"
    case destructive = "Destructive"
}

// MARK: - Component

/// A UI component that core tells frontends to render.
/// Maps to: `vauchi-core::ui::component::Component`
///
/// Rust serde serializes enums as `{"VariantName": {"field": "value"}}` or
/// `"VariantName"` for unit variants. We use custom `Decodable` to handle this.
public enum Component: Decodable {
    case text(TextComponent)
    case textInput(TextInputComponent)
    case toggleList(ToggleListComponent)
    case fieldList(FieldListComponent)
    case preview(PreviewComponent)
    case infoPanel(InfoPanelComponent)
    case list(ListComponent)
    case settingsGroup(SettingsGroupComponent)
    case actionList(ActionListComponent)
    case statusIndicator(StatusIndicatorComponent)
    case pinInput(PinInputComponent)
    case qrCode(QrCodeComponent)
    case confirmationDialog(ConfirmationDialogComponent)
    case showToast(ShowToastComponent)
    case inlineConfirm(InlineConfirmComponent)
    case editableText(EditableTextComponent)
    case banner(BannerComponent)
    case dropdown(DropdownComponent)
    case avatarPreview(AvatarPreviewComponent)
    case slider(SliderComponent)
    case divider
    /// Generic ongoing-status indicator emitted for chrome (sync state,
    /// connectivity, backup-overdue, update-available). Distinct semantic
    /// role from `.statusIndicator` (used for screen-body in-progress
    /// status). See: shell-purity investigation 2026-05-28.
    case indicator(IndicatorComponent)
    /// Structured menu — multiple labeled sections of tappable items.
    /// Distinct from `.actionList` (flat menu); the section grouping is
    /// structural, not optional. See: shell-purity investigation 2026-05-28.
    case sectionedActionList(SectionedActionListComponent)
    /// Horizontal container — renders its child components left-to-right.
    /// The first child (e.g. a camera/QR preview) flexes; later children
    /// (e.g. an action list) take their share. Each child is width-bounded
    /// so a child that fills its width internally does not overflow.
    /// Distinct from the (vertical) screen component stack.
    case row(RowComponent)
    /// Unknown component from a newer core version — render as empty space.
    /// Prevents crash when core adds new component types that this shell
    /// version doesn't know about. See: design-as-code-plan Phase 2b.
    case unknown

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public init(from decoder: Decoder) throws {
        // Try unit variant first ("Divider" or any unknown string)
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self)
        {
            if stringValue == "Divider" {
                self = .divider
            } else {
                // Unknown unit variant — degrade gracefully
                self = .unknown
            }
            return
        }

        // Struct variants: {"VariantName": {...}}
        let container = try decoder.container(keyedBy: VariantKey.self)

        if container.contains(.text) {
            self = try .text(container.decode(TextComponent.self, forKey: .text))
        } else if container.contains(.textInput) {
            self = try .textInput(container.decode(TextInputComponent.self, forKey: .textInput))
        } else if container.contains(.toggleList) {
            self = try .toggleList(container.decode(ToggleListComponent.self, forKey: .toggleList))
        } else if container.contains(.fieldList) {
            self = try .fieldList(container.decode(FieldListComponent.self, forKey: .fieldList))
        } else if container.contains(.preview) {
            self = try .preview(container.decode(PreviewComponent.self, forKey: .preview))
        } else if container.contains(.infoPanel) {
            self = try .infoPanel(container.decode(InfoPanelComponent.self, forKey: .infoPanel))
        } else if container.contains(.list) {
            self = try .list(container.decode(ListComponent.self, forKey: .list))
        } else if container.contains(.settingsGroup) {
            self = try .settingsGroup(container.decode(SettingsGroupComponent.self, forKey: .settingsGroup))
        } else if container.contains(.actionList) {
            self = try .actionList(container.decode(ActionListComponent.self, forKey: .actionList))
        } else if container.contains(.statusIndicator) {
            self = try .statusIndicator(container.decode(StatusIndicatorComponent.self, forKey: .statusIndicator))
        } else if container.contains(.pinInput) {
            self = try .pinInput(container.decode(PinInputComponent.self, forKey: .pinInput))
        } else if container.contains(.qrCode) {
            self = try .qrCode(container.decode(QrCodeComponent.self, forKey: .qrCode))
        } else if container.contains(.confirmationDialog) {
            self = try .confirmationDialog(
                container.decode(ConfirmationDialogComponent.self, forKey: .confirmationDialog)
            )
        } else if container.contains(.showToast) {
            self = try .showToast(container.decode(ShowToastComponent.self, forKey: .showToast))
        } else if container.contains(.inlineConfirm) {
            self = try .inlineConfirm(container.decode(InlineConfirmComponent.self, forKey: .inlineConfirm))
        } else if container.contains(.editableText) {
            self = try .editableText(container.decode(EditableTextComponent.self, forKey: .editableText))
        } else if container.contains(.banner) {
            self = try .banner(container.decode(BannerComponent.self, forKey: .banner))
        } else if container.contains(.dropdown) {
            self = try .dropdown(container.decode(DropdownComponent.self, forKey: .dropdown))
        } else if container.contains(.avatarPreview) {
            self = try .avatarPreview(container.decode(AvatarPreviewComponent.self, forKey: .avatarPreview))
        } else if container.contains(.slider) {
            self = try .slider(container.decode(SliderComponent.self, forKey: .slider))
        } else if container.contains(.indicator) {
            self = try .indicator(container.decode(IndicatorComponent.self, forKey: .indicator))
        } else if container.contains(.sectionedActionList) {
            self = try .sectionedActionList(
                container.decode(SectionedActionListComponent.self, forKey: .sectionedActionList)
            )
        } else if container.contains(.row) {
            self = try .row(container.decode(RowComponent.self, forKey: .row))
        } else {
            // Unknown struct variant — core is newer than this shell.
            // Degrade gracefully instead of crashing.
            self = .unknown
        }
    }

    private enum VariantKey: String, CodingKey {
        case text = "Text"
        case textInput = "TextInput"
        case toggleList = "ToggleList"
        case fieldList = "FieldList"
        case preview = "Preview"
        case infoPanel = "InfoPanel"
        case list = "List"
        case settingsGroup = "SettingsGroup"
        case actionList = "ActionList"
        case statusIndicator = "StatusIndicator"
        case pinInput = "PinInput"
        case qrCode = "QrCode"
        case confirmationDialog = "ConfirmationDialog"
        case showToast = "ShowToast"
        case inlineConfirm = "InlineConfirm"
        case editableText = "EditableText"
        case banner = "Banner"
        case dropdown = "Dropdown"
        case avatarPreview = "AvatarPreview"
        case slider = "Slider"
        case indicator = "Indicator"
        case sectionedActionList = "SectionedActionList"
        case row = "Row"
    }
}

// MARK: - A11y

/// Core-driven accessibility metadata attached to components.
/// Maps to: `vauchi-core::ui::component::A11y`
public struct A11y: Decodable {
    public let label: String?
    public let hint: String?
    public let role: String?

    public init(label: String? = nil, hint: String? = nil, role: String? = nil) {
        self.label = label
        self.hint = hint
        self.role = role
    }
}

// MARK: - Component Data Types

public struct TextComponent: Decodable {
    public let id: String
    public let content: String
    public let style: TextStyle

    public init(id: String, content: String, style: TextStyle) {
        self.id = id
        self.content = content
        self.style = style
    }
}

public enum TextStyle: String, Decodable {
    case title = "Title"
    case subtitle = "Subtitle"
    case body = "Body"
    case caption = "Caption"
}

public struct TextInputComponent: Decodable {
    public let id: String
    public let label: String
    public let value: String
    public let placeholder: String?
    public let maxLength: Int?
    public let validationError: String?
    public let inputType: InputType
    public var a11y: A11y?

    public init(
        id: String,
        label: String,
        value: String,
        placeholder: String? = nil,
        maxLength: Int? = nil,
        validationError: String? = nil,
        inputType: InputType,
        a11y: A11y? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.validationError = validationError
        self.inputType = inputType
        self.a11y = a11y
    }
}

public enum InputType: String, Decodable {
    case text = "Text"
    case phone = "Phone"
    case email = "Email"
    case password = "Password"
}

public struct ToggleListComponent: Decodable {
    public let id: String
    public let label: String
    public let items: [ToggleItem]
    public var a11y: A11y?

    public init(id: String, label: String, items: [ToggleItem], a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.items = items
        self.a11y = a11y
    }
}

public struct ToggleItem: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let selected: Bool
    public let subtitle: String?
    public var a11y: A11y?

    public init(id: String, label: String, selected: Bool, subtitle: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.selected = selected
        self.subtitle = subtitle
        self.a11y = a11y
    }
}

public struct FieldListComponent: Decodable {
    public let id: String
    public let fields: [Field]
    public let visibilityMode: VisibilityMode
    public let availableGroups: [String]
    public var a11y: A11y?

    public init(id: String, fields: [Field], visibilityMode: VisibilityMode, availableGroups: [String], a11y: A11y? = nil) {
        self.id = id
        self.fields = fields
        self.visibilityMode = visibilityMode
        self.availableGroups = availableGroups
        self.a11y = a11y
    }
}

public enum VisibilityMode: String, Decodable {
    // No visibility column — display fields read-only. Mirrors core's
    // `VisibilityMode::ReadOnly` (vauchi-app/src/ui/component/mod.rs).
    // Missing here would throw a Decodable error on any screen emitting
    // ReadOnly, dropping the render (same drift fixed on Android).
    case readOnly = "ReadOnly"
    case showHide = "ShowHide"
    case perGroup = "PerGroup"
}

public struct Field: Decodable, Identifiable {
    public let id: String
    public let fieldType: String
    public let label: String
    public let value: String
    public let visibility: UiFieldVisibility
    public var a11y: A11y?

    public init(id: String, fieldType: String, label: String, value: String, visibility: UiFieldVisibility, a11y: A11y? = nil) {
        self.id = id
        self.fieldType = fieldType
        self.label = label
        self.value = value
        self.visibility = visibility
        self.a11y = a11y
    }
}

/// UI-level field visibility state.
/// Serde outputs: `"Shown"`, `"Hidden"`, or `{"Groups": ["Family", ...]}`
public enum UiFieldVisibility: Decodable {
    case shown
    case hidden
    case groups([String])

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self)
        {
            switch stringValue {
            case "Shown": self = .shown
            case "Hidden": self = .hidden
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown UiFieldVisibility variant: \(stringValue)"
                    )
                )
            }
            return
        }

        let container = try decoder.container(keyedBy: GroupsKey.self)
        let groups = try container.decode([String].self, forKey: .groups)
        self = .groups(groups)
    }

    private enum GroupsKey: String, CodingKey {
        case groups = "Groups"
    }
}

public struct PreviewComponent: Decodable {
    public let name: String
    public let avatarData: [UInt8]?
    public let fields: [Field]
    public let variants: [PreviewVariant]
    public let selectedVariant: String?
    /// G1 (ADR-021/043, core!695): pre-filtered list emitted by core's
    /// `build_visible_fields` helper. Frontends should render this
    /// directly rather than reproducing the filter / fallback in Swift.
    /// Defaults to `[]` so pre-G1 ScreenModel JSON still decodes;
    /// frontends fall back to `fields` when the list is empty.
    public let visibleFields: [Field]
    public var a11y: A11y?

    public init(
        name: String,
        avatarData: [UInt8]? = nil,
        fields: [Field],
        variants: [PreviewVariant],
        selectedVariant: String? = nil,
        visibleFields: [Field] = [],
        a11y: A11y? = nil
    ) {
        self.name = name
        self.avatarData = avatarData
        self.fields = fields
        self.variants = variants
        self.selectedVariant = selectedVariant
        self.visibleFields = visibleFields
        self.a11y = a11y
    }

    private enum CodingKeys: String, CodingKey {
        /// Raw values match property names (camelCase) so the consumer's
        /// `convertFromSnakeCase` strategy can resolve `avatar_data` → `avatarData`
        /// before key lookup. Snake_case raw values would mask convertFromSnakeCase
        /// and break decode (variants fixture lookup miss, observed v0.28.1+ tag).
        case name, avatarData, fields, variants, selectedVariant, visibleFields, a11y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        avatarData = try container.decodeIfPresent([UInt8].self, forKey: .avatarData)
        fields = try container.decode([Field].self, forKey: .fields)
        variants = try container.decode([PreviewVariant].self, forKey: .variants)
        selectedVariant = try container.decodeIfPresent(String.self, forKey: .selectedVariant)
        visibleFields = try container.decodeIfPresent([Field].self, forKey: .visibleFields) ?? []
        a11y = try container.decodeIfPresent(A11y.self, forKey: .a11y)
    }
}

public struct PreviewVariant: Decodable, Identifiable {
    public let variantId: String
    public let displayName: String
    public let visibleFields: [Field]

    public init(variantId: String, displayName: String, visibleFields: [Field]) {
        self.variantId = variantId
        self.displayName = displayName
        self.visibleFields = visibleFields
    }

    public var id: String {
        variantId
    }
}

public struct InfoPanelComponent: Decodable {
    public let id: String
    public let icon: String?
    public let title: String
    public let items: [InfoItem]
    public var a11y: A11y?

    public init(id: String, icon: String? = nil, title: String, items: [InfoItem], a11y: A11y? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.items = items
        self.a11y = a11y
    }
}

public struct InfoItem: Decodable, Identifiable {
    public let icon: String?
    public let title: String
    public let detail: String

    public init(icon: String? = nil, title: String, detail: String) {
        self.icon = icon
        self.title = title
        self.detail = detail
    }

    public var id: String {
        title
    }
}

// MARK: - List Component

public struct ListComponent: Decodable {
    public let id: String
    public let items: [Item]
    public let searchable: Bool
    /// Windowed emission (Track B of
    /// `2026-06-11-contacts-list-eager-render-anr`): when nonzero,
    /// `items` is the `[offset, offset + window)` slice of a
    /// `totalCount`-sized filtered set and the renderer should dispatch
    /// `UserAction.listWindowRequested` as scrolling approaches the
    /// window edge. Zero = unwindowed (`items` is the complete set).
    public let totalCount: Int
    public let offset: Int
    public let window: Int

    public init(
        id: String,
        items: [Item],
        searchable: Bool,
        totalCount: Int = 0,
        offset: Int = 0,
        window: Int = 0
    ) {
        self.id = id
        self.items = items
        self.searchable = searchable
        self.totalCount = totalCount
        self.offset = offset
        self.window = window
    }

    /// Keys stay camelCase so `convertFromSnakeCase` can resolve
    /// `total_count` → `totalCount` before lookup (see the avatar_data
    /// note on PreviewComponent — snake_case raw values silently fail).
    private enum CodingKeys: String, CodingKey {
        case id, items, searchable, totalCount, offset, window
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        items = try container.decode([Item].self, forKey: .items)
        searchable = try container.decode(Bool.self, forKey: .searchable)
        // Core skip-serializes zeros — absent keys are the unwindowed wire shape.
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        offset = try container.decodeIfPresent(Int.self, forKey: .offset) ?? 0
        window = try container.decodeIfPresent(Int.self, forKey: .window) ?? 0
    }
}

/// A lightweight item rendered by `Component::List`. Wire Humble: the
/// renderer doesn't know what kind of thing it represents — engine
/// produces UI-shaped items from any domain (contacts, decoy contacts,
/// quorum members, etc.).
public struct Item: Decodable, Identifiable {
    public let id: String
    public let name: String
    public let subtitle: String?
    public let avatarInitials: String
    public let status: String?
    public var actions: [ListItemAction] = []
    public var a11y: A11y?

    public init(
        id: String,
        name: String,
        subtitle: String? = nil,
        avatarInitials: String,
        status: String? = nil,
        actions: [ListItemAction] = [],
        a11y: A11y? = nil
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.avatarInitials = avatarInitials
        self.status = status
        self.actions = actions
        self.a11y = a11y
    }

    /// Default Decodable synthesis matches: `coreJSONDecoder` above sets
    /// `.convertFromSnakeCase`, so wire keys like `avatar_initials` are
    /// mapped automatically to their camelCase property names here. The
    /// custom init only exists so `actions` defaults to empty when absent
    /// from legacy fixtures or older engine versions.
    private enum CodingKeys: String, CodingKey {
        case id, name, subtitle, avatarInitials, status, actions, a11y
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        subtitle = try c.decodeIfPresent(String.self, forKey: .subtitle)
        avatarInitials = try c.decode(String.self, forKey: .avatarInitials)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        actions = (try? c.decode([ListItemAction].self, forKey: .actions)) ?? []
        a11y = try? c.decode(A11y.self, forKey: .a11y)
    }
}

/// Semantic classification for a per-row action. Mirrors
/// `vauchi-core::ui::component::ListItemActionKind`. Serialized snake_case.
public enum ListItemActionKind: String, Decodable {
    case archive
    case unarchive
    case hide
    case unhide
    case delete
    case undelete
    case custom
    /// Forward-compat fallback for kinds added in a newer core.
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ListItemActionKind(rawValue: raw) ?? .unknown
    }
}

/// A per-row swipe/context-menu action produced by core. Mirrors
/// `vauchi-core::ui::component::ListItemAction`.
public struct ListItemAction: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let kind: ListItemActionKind
    public let destructive: Bool

    public init(
        id: String,
        label: String,
        kind: ListItemActionKind,
        destructive: Bool = false
    ) {
        self.id = id
        self.label = label
        self.kind = kind
        self.destructive = destructive
    }

    private enum CodingKeys: String, CodingKey {
        case id, label, kind, destructive
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        label = try c.decode(String.self, forKey: .label)
        kind = try c.decode(ListItemActionKind.self, forKey: .kind)
        destructive = (try? c.decode(Bool.self, forKey: .destructive)) ?? false
    }
}

// MARK: - SettingsGroup Component

public struct SettingsGroupComponent: Decodable {
    public let id: String
    public let label: String
    public let items: [SettingsItem]

    public init(id: String, label: String, items: [SettingsItem]) {
        self.id = id
        self.label = label
        self.items = items
    }
}

public struct SettingsItem: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let kind: SettingsItemKind
    public var a11y: A11y?

    public init(id: String, label: String, kind: SettingsItemKind, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.kind = kind
        self.a11y = a11y
    }
}

public enum SettingsItemKind: Decodable {
    case toggle(enabled: Bool)
    case value(value: String)
    case link(detail: String?)
    case destructive(label: String)
    case unknown

    public init(from decoder: Decoder) throws {
        // Serde produces: {"Toggle": {"enabled": true}}, etc.
        let container = try decoder.container(keyedBy: VariantKey.self)
        if container.contains(.toggle) {
            let data = try container.decode(ToggleData.self, forKey: .toggle)
            self = .toggle(enabled: data.enabled)
        } else if container.contains(.value) {
            let data = try container.decode(ValueData.self, forKey: .value)
            self = .value(value: data.value)
        } else if container.contains(.link) {
            let data = try container.decode(LinkData.self, forKey: .link)
            self = .link(detail: data.detail)
        } else if container.contains(.destructive) {
            let data = try container.decode(DestructiveData.self, forKey: .destructive)
            self = .destructive(label: data.label)
        } else {
            // Unknown settings item kind from newer core — show as link
            self = .unknown
        }
    }

    private enum VariantKey: String, CodingKey {
        case toggle = "Toggle"
        case value = "Value"
        case link = "Link"
        case destructive = "Destructive"
    }

    private struct ToggleData: Decodable { let enabled: Bool }
    private struct ValueData: Decodable { let value: String }
    private struct LinkData: Decodable { let detail: String? }
    private struct DestructiveData: Decodable { let label: String }
}

// MARK: - ActionList Component

public struct ActionListComponent: Decodable {
    public let id: String
    public let items: [ActionListItem]

    public init(id: String, items: [ActionListItem]) {
        self.id = id
        self.items = items
    }
}

// MARK: - Row Component

/// Horizontal container whose `items` are nested `Component`s rendered
/// left-to-right. Each child is width-bounded by the renderer so a child
/// that fills its width internally (e.g. an `ActionListComponent`) does
/// not overflow or overlap a flexing sibling (e.g. a camera preview).
/// Maps to: `vauchi-core::ui::component::Component::Row`
public struct RowComponent: Decodable {
    public let id: String
    public let items: [Component]

    public init(id: String, items: [Component]) {
        self.id = id
        self.items = items
    }
}

public struct ActionListItem: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let icon: String?
    public let detail: String?
    public var a11y: A11y?

    public init(id: String, label: String, icon: String? = nil, detail: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
        self.detail = detail
        self.a11y = a11y
    }
}

// MARK: - StatusIndicator Component

public struct StatusIndicatorComponent: Decodable {
    public let id: String
    public let icon: String?
    public let title: String
    public let detail: String?
    public let status: Status
    public var a11y: A11y?

    public init(id: String, icon: String? = nil, title: String, detail: String? = nil, status: Status, a11y: A11y? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.detail = detail
        self.status = status
        self.a11y = a11y
    }
}

public enum Status: String, Decodable {
    case pending = "Pending"
    case inProgress = "InProgress"
    case success = "Success"
    case failed = "Failed"
    case warning = "Warning"
}

// MARK: - Indicator Component

/// Chrome-positioned status indicator — sync state, connectivity, backup
/// overdue, update available. Renders as a native chip / pill the
/// frontend places in toolbar / header / status area per its idiom.
/// Distinct from `StatusIndicatorComponent` (body-positioned, in-progress
/// operations).
public struct IndicatorComponent: Decodable {
    public let id: String
    public let label: String
    public let kind: IndicatorKind
    /// Optional tap action. `nil` = display-only (informational); non-nil =
    /// tap fires `UserAction.actionPressed(actionId: ...)`.
    public let actionId: String?
    public var a11y: A11y?

    public init(id: String, label: String, kind: IndicatorKind, actionId: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.kind = kind
        self.actionId = actionId
        self.a11y = a11y
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case label
        case kind
        case actionId = "action_id"
        case a11y
    }
}

/// Semantic color category for `IndicatorComponent`.
public enum IndicatorKind: String, Decodable {
    /// In-progress or freshly-confirmed — emphasis color.
    case active = "Active"
    /// Failed / attention-required — error color.
    case error = "Error"
    /// Idle / informational — muted color.
    case neutral = "Neutral"
    /// Transient busy state — animated indicator.
    case busy = "Busy"
}

// MARK: - SectionedActionList Component

/// Structured menu — multiple labeled sections of tappable items. Used
/// by `MoreEngine` for grouped settings entries (primary / secondary /
/// data / legal). Distinct from `ActionListComponent` (flat menu).
public struct SectionedActionListComponent: Decodable {
    public let id: String
    public let sections: [Section]

    public init(id: String, sections: [Section]) {
        self.id = id
        self.sections = sections
    }
}

/// A named section within a `SectionedActionListComponent`. Reuses
/// `ActionListItem` for its rows so frontends get a single typed-item
/// renderer regardless of grouping.
public struct Section: Decodable, Identifiable {
    public let id: String
    public let label: String
    public let items: [ActionListItem]

    public init(id: String, label: String, items: [ActionListItem]) {
        self.id = id
        self.label = label
        self.items = items
    }
}

// MARK: - PinInput Component

public struct PinInputComponent: Decodable {
    public let id: String
    public let label: String
    public let length: Int
    public let masked: Bool
    public let validationError: String?
    public var a11y: A11y?

    public init(id: String, label: String, length: Int, masked: Bool, validationError: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.length = length
        self.masked = masked
        self.validationError = validationError
        self.a11y = a11y
    }
}

// MARK: - QrCode Component

public struct QrCodeComponent: Decodable {
    public let id: String
    public let data: String
    public let mode: QrMode
    public let label: String?
    public var a11y: A11y?

    public init(id: String, data: String, mode: QrMode, label: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.data = data
        self.mode = mode
        self.label = label
        self.a11y = a11y
    }
}

public enum QrMode: String, Decodable {
    case display = "Display"
    case scan = "Scan"
}

// MARK: - ConfirmationDialog Component

public struct ConfirmationDialogComponent: Decodable {
    public let id: String
    public let title: String
    public let message: String
    public let confirmText: String
    public let destructive: Bool

    public init(id: String, title: String, message: String, confirmText: String, destructive: Bool) {
        self.id = id
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.destructive = destructive
    }
}

// MARK: - ShowToast Component

public struct ShowToastComponent: Decodable {
    public let id: String
    public let message: String
    public let undoActionId: String?
    public let durationMs: UInt32

    public init(id: String, message: String, undoActionId: String? = nil, durationMs: UInt32) {
        self.id = id
        self.message = message
        self.undoActionId = undoActionId
        self.durationMs = durationMs
    }
}

// MARK: - InlineConfirm Component

public struct InlineConfirmComponent: Decodable {
    public let id: String
    public let warning: String
    public let confirmText: String
    public let cancelText: String
    public let destructive: Bool
    public var a11y: A11y?

    public init(id: String, warning: String, confirmText: String, cancelText: String, destructive: Bool, a11y: A11y? = nil) {
        self.id = id
        self.warning = warning
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.destructive = destructive
        self.a11y = a11y
    }
}

// MARK: - EditableText Component

public struct EditableTextComponent: Decodable {
    public let id: String
    public let label: String
    public let value: String
    public let editing: Bool
    public let validationError: String?
    public var a11y: A11y?

    public init(id: String, label: String, value: String, editing: Bool, validationError: String? = nil, a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.value = value
        self.editing = editing
        self.validationError = validationError
        self.a11y = a11y
    }
}

// MARK: - Banner Component

public struct BannerComponent: Decodable {
    public let text: String
    public let actionLabel: String
    public let actionId: String
    public var a11y: A11y?

    public init(text: String, actionLabel: String, actionId: String, a11y: A11y? = nil) {
        self.text = text
        self.actionLabel = actionLabel
        self.actionId = actionId
        self.a11y = a11y
    }
}

// MARK: - Dropdown Component

public struct DropdownComponent: Decodable {
    public let id: String
    public let label: String
    public let selected: String?
    public let options: [DropdownOption]
    public var a11y: A11y?

    public init(id: String, label: String, selected: String? = nil, options: [DropdownOption], a11y: A11y? = nil) {
        self.id = id
        self.label = label
        self.selected = selected
        self.options = options
        self.a11y = a11y
    }
}

public struct DropdownOption: Decodable, Identifiable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

// MARK: - AvatarPreview Component

public struct AvatarPreviewComponent: Decodable {
    public let id: String
    public let imageData: [UInt8]?
    public let initials: String
    public let bgColor: [UInt8]?
    public let brightness: Float
    public let editable: Bool
    public let a11y: A11y?

    public init(
        id: String,
        imageData: [UInt8]? = nil,
        initials: String,
        bgColor: [UInt8]? = nil,
        brightness: Float,
        editable: Bool,
        a11y: A11y? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.initials = initials
        self.bgColor = bgColor
        self.brightness = brightness
        self.editable = editable
        self.a11y = a11y
    }
}

// MARK: - Slider Component

public struct SliderComponent: Decodable {
    public let id: String
    public let label: String
    public let value: Float
    public let min: Float
    public let max: Float
    public let step: Float
    public let minIcon: String?
    public let maxIcon: String?
    public let a11y: A11y?

    public init(
        id: String,
        label: String,
        value: Float,
        min: Float,
        max: Float,
        step: Float,
        minIcon: String? = nil,
        maxIcon: String? = nil,
        a11y: A11y? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.min = min
        self.max = max
        self.step = step
        self.minIcon = minIcon
        self.maxIcon = maxIcon
        self.a11y = a11y
    }
}

// MARK: - UserAction (Encodable for sending to core)

/// An action the user performed in the UI.
/// Maps to: `vauchi-core::ui::action::UserAction`
///
/// Uses custom encoding to match serde's `{"VariantName": {...}}` format.
public enum UserAction: Encodable {
    case textChanged(componentId: String, value: String)
    case itemToggled(componentId: String, itemId: String)
    case actionPressed(actionId: String)
    case fieldVisibilityChanged(fieldId: String, groupId: String?, visible: Bool)
    case groupViewSelected(groupName: String?)
    case searchChanged(componentId: String, query: String)
    case listItemSelected(componentId: String, itemId: String)
    case listItemAction(componentId: String, itemId: String, actionId: String)
    /// The lazy list is approaching the edge of a windowed
    /// `Component::List` emission — ask core to re-slice from `offset`
    /// (Track B of `2026-06-11-contacts-list-eager-render-anr`).
    case listWindowRequested(componentId: String, offset: Int)
    case settingsToggled(componentId: String, itemId: String)
    case undoPressed(actionId: String)
    case sliderChanged(componentId: String, valueMilli: Int32)
    /// Top-level tab tap (ADR-043 Am4). `actionId` is the opaque
    /// canonical id from `tabInfo()`; core resolves it to the canonical
    /// screen. Maps to `UserAction::NavigateToTab { action_id }`.
    case navigateToTab(actionId: String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: VariantKey.self)

        switch self {
        case let .textChanged(componentId, value):
            var nested = container.nestedContainer(keyedBy: TextChangedKeys.self, forKey: .textChanged)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(value, forKey: .value)

        case let .itemToggled(componentId, itemId):
            var nested = container.nestedContainer(keyedBy: ItemToggledKeys.self, forKey: .itemToggled)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(itemId, forKey: .itemId)

        case let .actionPressed(actionId):
            var nested = container.nestedContainer(keyedBy: ActionPressedKeys.self, forKey: .actionPressed)
            try nested.encode(actionId, forKey: .actionId)

        case let .fieldVisibilityChanged(fieldId, groupId, visible):
            var nested = container.nestedContainer(keyedBy: FieldVisibilityKeys.self, forKey: .fieldVisibilityChanged)
            try nested.encode(fieldId, forKey: .fieldId)
            try nested.encodeIfPresent(groupId, forKey: .groupId)
            try nested.encode(visible, forKey: .visible)

        case let .groupViewSelected(groupName):
            var nested = container.nestedContainer(keyedBy: GroupViewSelectedKeys.self, forKey: .groupViewSelected)
            try nested.encodeIfPresent(groupName, forKey: .groupName)

        case let .searchChanged(componentId, query):
            var nested = container.nestedContainer(keyedBy: SearchChangedKeys.self, forKey: .searchChanged)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(query, forKey: .query)

        case let .listItemSelected(componentId, itemId):
            var nested = container.nestedContainer(keyedBy: ListItemSelectedKeys.self, forKey: .listItemSelected)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(itemId, forKey: .itemId)

        case let .listItemAction(componentId, itemId, actionId):
            var nested = container.nestedContainer(keyedBy: ListItemActionKeys.self, forKey: .listItemAction)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(itemId, forKey: .itemId)
            try nested.encode(actionId, forKey: .actionId)

        case let .listWindowRequested(componentId, offset):
            var nested = container.nestedContainer(keyedBy: ListWindowRequestedKeys.self, forKey: .listWindowRequested)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(offset, forKey: .offset)

        case let .settingsToggled(componentId, itemId):
            var nested = container.nestedContainer(keyedBy: SettingsToggledKeys.self, forKey: .settingsToggled)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(itemId, forKey: .itemId)

        case let .undoPressed(actionId):
            var nested = container.nestedContainer(keyedBy: UndoPressedKeys.self, forKey: .undoPressed)
            try nested.encode(actionId, forKey: .actionId)

        case let .sliderChanged(componentId, valueMilli):
            var nested = container.nestedContainer(keyedBy: SliderChangedKeys.self, forKey: .sliderChanged)
            try nested.encode(componentId, forKey: .componentId)
            try nested.encode(valueMilli, forKey: .valueMilli)

        case let .navigateToTab(actionId):
            var nested = container.nestedContainer(keyedBy: NavigateToTabKeys.self, forKey: .navigateToTab)
            try nested.encode(actionId, forKey: .actionId)
        }
    }

    private enum VariantKey: String, CodingKey {
        case textChanged = "TextChanged"
        case itemToggled = "ItemToggled"
        case actionPressed = "ActionPressed"
        case fieldVisibilityChanged = "FieldVisibilityChanged"
        case groupViewSelected = "GroupViewSelected"
        case searchChanged = "SearchChanged"
        case listItemSelected = "ListItemSelected"
        case listItemAction = "ListItemAction"
        case listWindowRequested = "ListWindowRequested"
        case settingsToggled = "SettingsToggled"
        case undoPressed = "UndoPressed"
        case sliderChanged = "SliderChanged"
        case navigateToTab = "NavigateToTab"
    }

    private enum TextChangedKeys: String, CodingKey {
        case componentId = "component_id"
        case value
    }

    private enum ItemToggledKeys: String, CodingKey {
        case componentId = "component_id"
        case itemId = "item_id"
    }

    private enum ListWindowRequestedKeys: String, CodingKey {
        case componentId = "component_id"
        case offset
    }

    private enum ActionPressedKeys: String, CodingKey {
        case actionId = "action_id"
    }

    private enum NavigateToTabKeys: String, CodingKey {
        case actionId = "action_id"
    }

    private enum FieldVisibilityKeys: String, CodingKey {
        case fieldId = "field_id"
        case groupId = "group_id"
        case visible
    }

    private enum GroupViewSelectedKeys: String, CodingKey {
        case groupName = "group_name"
    }

    private enum SearchChangedKeys: String, CodingKey {
        case componentId = "component_id"
        case query
    }

    private enum ListItemSelectedKeys: String, CodingKey {
        case componentId = "component_id"
        case itemId = "item_id"
    }

    private enum ListItemActionKeys: String, CodingKey {
        case componentId = "component_id"
        case itemId = "item_id"
        case actionId = "action_id"
    }

    private enum SettingsToggledKeys: String, CodingKey {
        case componentId = "component_id"
        case itemId = "item_id"
    }

    private enum UndoPressedKeys: String, CodingKey {
        case actionId = "action_id"
    }

    private enum SliderChangedKeys: String, CodingKey {
        case componentId = "component_id"
        case valueMilli = "value_milli"
    }
}

// MARK: - PostOnboardingDestination

/// Where to navigate after onboarding completes.
/// Maps to: `vauchi-core::ui::action::PostOnboardingDestination`
public enum PostOnboardingDestination: String, Decodable {
    case mainScreen = "MainScreen"
    case exchange = "Exchange"
    case importContacts = "ImportContacts"
    case securityInfo = "SecurityInfo"
    case backupSetup = "BackupSetup"
}

// MARK: - ActionResult

/// The result of handling a user action.
/// Maps to: `vauchi-core::ui::action::ActionResult`
public enum ActionResult: Decodable {
    case updateScreen(ScreenModel)
    case navigateTo(ScreenModel)
    case validationError(componentId: String, message: String)
    case complete
    case completeWith(destination: PostOnboardingDestination)
    case startDeviceLink
    case openContact(contactId: String)
    case editContact(contactId: String)
    case openUrl(url: String)
    case showAlert(title: String, message: String)
    case requestCamera
    case openEntryDetail(fieldId: String)
    case showToast(message: String, undoActionId: String?)
    case wipeComplete
    case commands(commands: [CommandDTO])
    case showFormDialog(dialogType: String, contextId: String?)
    case previewAs(contactId: String)
    case biometricUnlockOutcome(outcome: String)
    case unknown

    public init(from decoder: Decoder) throws {
        // Unit variants: "Complete", "StartDeviceLink", etc.
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self)
        {
            switch stringValue {
            case "Complete": self = .complete
            case "StartDeviceLink": self = .startDeviceLink
            case "RequestCamera": self = .requestCamera
            case "WipeComplete": self = .wipeComplete
            default: self = .unknown
            }
            return
        }

        // Struct variants: {"VariantName": {...}}
        let container = try decoder.container(keyedBy: VariantKey.self)

        if container.contains(.updateScreen) {
            self = try .updateScreen(container.decode(ScreenModel.self, forKey: .updateScreen))
        } else if container.contains(.navigateTo) {
            self = try .navigateTo(container.decode(ScreenModel.self, forKey: .navigateTo))
        } else if container.contains(.validationError) {
            let error = try container.decode(ValidationErrorData.self, forKey: .validationError)
            self = .validationError(componentId: error.componentId, message: error.message)
        } else if container.contains(.completeWith) {
            let data = try container.decode(CompleteWithData.self, forKey: .completeWith)
            self = .completeWith(destination: data.destination)
        } else if container.contains(.openContact) {
            let data = try container.decode(OpenContactData.self, forKey: .openContact)
            self = .openContact(contactId: data.contactId)
        } else if container.contains(.editContact) {
            let data = try container.decode(EditContactData.self, forKey: .editContact)
            self = .editContact(contactId: data.contactId)
        } else if container.contains(.openUrl) {
            let data = try container.decode(OpenUrlData.self, forKey: .openUrl)
            self = .openUrl(url: data.url)
        } else if container.contains(.showAlert) {
            let data = try container.decode(ShowAlertData.self, forKey: .showAlert)
            self = .showAlert(title: data.title, message: data.message)
        } else if container.contains(.openEntryDetail) {
            let data = try container.decode(OpenEntryDetailData.self, forKey: .openEntryDetail)
            self = .openEntryDetail(fieldId: data.fieldId)
        } else if container.contains(.showToast) {
            let data = try container.decode(ShowToastData.self, forKey: .showToast)
            self = .showToast(message: data.message, undoActionId: data.undoActionId)
        } else if container.contains(.commands) {
            let data = try container.decode(CommandsData.self, forKey: .commands)
            self = .commands(commands: data.commands)
        } else if container.contains(.showFormDialog) {
            let data = try container.decode(ShowFormDialogData.self, forKey: .showFormDialog)
            self = .showFormDialog(dialogType: data.dialogType, contextId: data.contextId)
        } else if container.contains(.previewAs) {
            let data = try container.decode(PreviewAsData.self, forKey: .previewAs)
            self = .previewAs(contactId: data.contactId)
        } else if container.contains(.biometricUnlockOutcome) {
            let data = try container.decode(BiometricUnlockOutcomeData.self, forKey: .biometricUnlockOutcome)
            self = .biometricUnlockOutcome(outcome: data.outcome)
        } else {
            self = .unknown
        }
    }

    private enum VariantKey: String, CodingKey {
        case updateScreen = "UpdateScreen"
        case navigateTo = "NavigateTo"
        case validationError = "ValidationError"
        case completeWith = "CompleteWith"
        case openContact = "OpenContact"
        case editContact = "EditContact"
        case openUrl = "OpenUrl"
        case showAlert = "ShowAlert"
        case openEntryDetail = "OpenEntryDetail"
        case showToast = "ShowToast"
        case commands = "Commands"
        case showFormDialog = "ShowFormDialog"
        case previewAs = "PreviewAs"
        case biometricUnlockOutcome = "BiometricUnlockOutcome"
    }

    private struct CompleteWithData: Decodable {
        let destination: PostOnboardingDestination
    }

    private struct ValidationErrorData: Decodable {
        let componentId: String
        let message: String
    }

    private struct OpenContactData: Decodable {
        let contactId: String
    }

    private struct EditContactData: Decodable {
        let contactId: String
    }

    private struct OpenUrlData: Decodable {
        let url: String
    }

    private struct ShowAlertData: Decodable {
        let title: String
        let message: String
    }

    private struct OpenEntryDetailData: Decodable {
        let fieldId: String
    }

    private struct ShowToastData: Decodable {
        let message: String
        let undoActionId: String?
    }

    private struct CommandsData: Decodable {
        let commands: [CommandDTO]
    }

    private struct ShowFormDialogData: Decodable {
        let dialogType: String
        let contextId: String?
    }

    private struct PreviewAsData: Decodable {
        let contactId: String
    }

    private struct BiometricUnlockOutcomeData: Decodable {
        let outcome: String
    }
}

/// DTO for exchange commands from core (ADR-031).
/// Maps to: `vauchi-core::exchange::command::ExchangeCommand`
public enum CommandDTO: Decodable {
    case qrDisplay(data: String)
    case qrRequestScan
    case bleStartAdvertising(serviceUuid: String, payload: [UInt8])
    case bleStartScanning(serviceUuid: String)
    case bleStopScanning
    case bleConnect(deviceId: String)
    case bleWriteCharacteristic(uuid: String, data: [UInt8])
    case bleReadCharacteristic(uuid: String)
    case bleDisconnect
    case nfcActivate(payload: [UInt8])
    case nfcDeactivate
    case nfcSendApdu(data: [UInt8])
    case audioEmitChallenge(samples: [Float], sampleRate: UInt32)
    case audioListenForResponse(timeoutMs: UInt64, sampleRate: UInt32)
    case audioStop
    case accelerometerStart
    case accelerometerStop
    case directSend(payload: [UInt8], isInitiator: Bool)
    case directSendCard(ciphertext: [UInt8], isInitiator: Bool)
    case imagePickFromLibrary
    case imageCaptureFromCamera
    case imagePickFromFile
    case filePickFromUser(acceptedMimeTypes: [String], purpose: FilePickPurpose)
    case showShareSheet(url: String)
    case switchCamera(useFront: Bool)
    /// `level == nil` means "restore platform default"; the frontend's
    /// `CommandHandler` is responsible for snapshotting the prior
    /// brightness on the first non-nil value.
    case setScreenBrightness(level: Float?)
    case setIdleTimerDisabled(disabled: Bool)
    /// `orientation == nil` means "unlock to platform default"; the
    /// frontend's `CommandHandler` is responsible for applying the
    /// requested lock and clearing it on `nil`.
    case setOrientationLock(orientation: OrientationDTO?)
    /// Request a one-shot device location fix (ADR-051 capture-at-exchange).
    case locationRequest(timeoutMs: UInt32)
    /// Exchange-success ceremony (M2 S5). Frontends execute the requested
    /// haptic/sound/animation axis; skipped axes are silently ignored.
    case celebrate(haptic: String, sound: String, animation: String)
    case unknown

    public init(from decoder: Decoder) throws {
        if let bare = try? Self.decodeBareString(decoder) {
            self = bare
            return
        }
        let container = try decoder.container(keyedBy: CommandKey.self)
        self = try Self.decodeKeyed(container)
    }

    private static func decodeBareString(_ decoder: Decoder) throws -> CommandDTO {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        switch stringValue {
        case "QrRequestScan": return .qrRequestScan
        case "BleStopScanning": return .bleStopScanning
        case "BleDisconnect": return .bleDisconnect
        case "NfcDeactivate": return .nfcDeactivate
        case "AudioStop": return .audioStop
        case "AccelerometerStart": return .accelerometerStart
        case "AccelerometerStop": return .accelerometerStop
        case "ImagePickFromLibrary": return .imagePickFromLibrary
        case "ImageCaptureFromCamera": return .imageCaptureFromCamera
        case "ImagePickFromFile": return .imagePickFromFile
        default: return .unknown
        }
    }

    // swiftlint:disable function_body_length
    // Flat dispatch table for the closed `CommandKey` set. Each
    // `else if` decodes the matching `*Data` struct and re-wraps it
    // into the corresponding `CommandDTO` case. The body grows
    // linearly with new variants by design — splitting it would
    // scatter the table without improving readability.
    private static func decodeKeyed(
        _ container: KeyedDecodingContainer<CommandKey>
    ) throws -> CommandDTO {
        if container.contains(.qrDisplay) {
            let data = try container.decode(QrDisplayData.self, forKey: .qrDisplay)
            return .qrDisplay(data: data.data)
        } else if container.contains(.bleStartScanning) {
            let data = try container.decode(BleServiceData.self, forKey: .bleStartScanning)
            return .bleStartScanning(serviceUuid: data.serviceUuid)
        } else if container.contains(.bleConnect) {
            let data = try container.decode(BleConnectData.self, forKey: .bleConnect)
            return .bleConnect(deviceId: data.deviceId)
        } else if container.contains(.bleStartAdvertising) {
            let data = try container.decode(BleAdvertisingData.self, forKey: .bleStartAdvertising)
            return .bleStartAdvertising(serviceUuid: data.serviceUuid, payload: data.payload)
        } else if container.contains(.bleWriteCharacteristic) {
            let data = try container.decode(BleCharacteristicData.self, forKey: .bleWriteCharacteristic)
            return .bleWriteCharacteristic(uuid: data.uuid, data: data.data)
        } else if container.contains(.bleReadCharacteristic) {
            let data = try container.decode(BleReadData.self, forKey: .bleReadCharacteristic)
            return .bleReadCharacteristic(uuid: data.uuid)
        } else if container.contains(.nfcActivate) {
            let data = try container.decode(NfcActivateData.self, forKey: .nfcActivate)
            return .nfcActivate(payload: data.payload)
        } else if container.contains(.nfcSendApdu) {
            let data = try container.decode(NfcSendApduData.self, forKey: .nfcSendApdu)
            return .nfcSendApdu(data: data.data)
        } else if container.contains(.audioEmitChallenge) {
            let data = try container.decode(AudioChallengeData.self, forKey: .audioEmitChallenge)
            return .audioEmitChallenge(samples: data.samples, sampleRate: data.sampleRate)
        } else if container.contains(.audioListenForResponse) {
            let data = try container.decode(AudioListenData.self, forKey: .audioListenForResponse)
            return .audioListenForResponse(timeoutMs: data.timeoutMs, sampleRate: data.sampleRate)
        } else if container.contains(.directSend) {
            let data = try container.decode(DirectSendData.self, forKey: .directSend)
            return .directSend(payload: data.payload, isInitiator: data.isInitiator)
        } else if container.contains(.directSendCard) {
            let data = try container.decode(DirectSendCardData.self, forKey: .directSendCard)
            return .directSendCard(ciphertext: data.ciphertext, isInitiator: data.isInitiator)
        } else if container.contains(.filePickFromUser) {
            let data = try container.decode(FilePickFromUserData.self, forKey: .filePickFromUser)
            return .filePickFromUser(
                acceptedMimeTypes: data.acceptedMimeTypes,
                purpose: data.purpose
            )
        } else if container.contains(.showShareSheet) {
            let data = try container.decode(ShowShareSheetData.self, forKey: .showShareSheet)
            return .showShareSheet(url: data.url)
        } else if container.contains(.switchCamera) {
            let data = try container.decode(SwitchCameraData.self, forKey: .switchCamera)
            return .switchCamera(useFront: data.useFront)
        } else if container.contains(.setScreenBrightness) {
            let data = try container.decode(
                SetScreenBrightnessData.self,
                forKey: .setScreenBrightness
            )
            return .setScreenBrightness(level: data.level)
        } else if container.contains(.setIdleTimerDisabled) {
            let data = try container.decode(
                SetIdleTimerDisabledData.self,
                forKey: .setIdleTimerDisabled
            )
            return .setIdleTimerDisabled(disabled: data.disabled)
        } else if container.contains(.setOrientationLock) {
            let data = try container.decode(
                SetOrientationLockData.self,
                forKey: .setOrientationLock
            )
            return .setOrientationLock(orientation: data.orientation)
        } else if container.contains(.locationRequest) {
            let data = try container.decode(LocationRequestData.self, forKey: .locationRequest)
            return .locationRequest(timeoutMs: data.timeoutMs)
        } else if container.contains(.celebrate) {
            let data = try container.decode(CelebrateData.self, forKey: .celebrate)
            return .celebrate(haptic: data.haptic, sound: data.sound, animation: data.animation)
        } else {
            return .unknown
        }
    }

    // swiftlint:enable function_body_length

    private enum CommandKey: String, CodingKey {
        case qrDisplay = "QrDisplay"
        case bleStartAdvertising = "BleStartAdvertising"
        case bleStartScanning = "BleStartScanning"
        case bleConnect = "BleConnect"
        case bleWriteCharacteristic = "BleWriteCharacteristic"
        case bleReadCharacteristic = "BleReadCharacteristic"
        case nfcActivate = "NfcActivate"
        case nfcSendApdu = "NfcSendApdu"
        case audioEmitChallenge = "AudioEmitChallenge"
        case audioListenForResponse = "AudioListenForResponse"
        case directSend = "DirectSend"
        case directSendCard = "DirectSendCard"
        case filePickFromUser = "FilePickFromUser"
        case showShareSheet = "ShowShareSheet"
        case switchCamera = "SwitchCamera"
        case setScreenBrightness = "SetScreenBrightness"
        case setIdleTimerDisabled = "SetIdleTimerDisabled"
        case setOrientationLock = "SetOrientationLock"
        case locationRequest = "LocationRequest"
        case celebrate = "Celebrate"
    }

    private struct QrDisplayData: Decodable { let data: String }
    private struct BleServiceData: Decodable { let serviceUuid: String }
    private struct BleConnectData: Decodable { let deviceId: String }
    private struct BleAdvertisingData: Decodable { let serviceUuid: String; let payload: [UInt8] }
    private struct BleCharacteristicData: Decodable { let uuid: String; let data: [UInt8] }
    private struct BleReadData: Decodable { let uuid: String }
    private struct NfcActivateData: Decodable { let payload: [UInt8] }
    private struct NfcSendApduData: Decodable { let data: [UInt8] }
    // Core emits `AudioEmitChallenge { samples: Vec<f32>, sample_rate: u32 }`
    // and `AudioListenForResponse { timeout_ms: u64, sample_rate: u32 }`
    // (`core/vauchi-core/src/platform.rs`). `coreJSONDecoder`'s
    // `.convertFromSnakeCase` maps `sample_rate`/`timeout_ms` to the camelCase
    // fields. An earlier `data: [UInt8]` shape never matched the wire and
    // silently decoded to `.unknown` (same bug Android hit — NPE there).
    private struct AudioChallengeData: Decodable { let samples: [Float]; let sampleRate: UInt32 }
    private struct AudioListenData: Decodable { let timeoutMs: UInt64; let sampleRate: UInt32 }
    private struct DirectSendData: Decodable { let payload: [UInt8]; let isInitiator: Bool }
    private struct DirectSendCardData: Decodable { let ciphertext: [UInt8]; let isInitiator: Bool }
    private struct ShowShareSheetData: Decodable { let url: String }
    private struct SwitchCameraData: Decodable { let useFront: Bool }
    private struct SetScreenBrightnessData: Decodable { let level: Float? }
    private struct SetIdleTimerDisabledData: Decodable { let disabled: Bool }
    private struct LocationRequestData: Decodable { let timeoutMs: UInt32 }
    private struct SetOrientationLockData: Decodable { let orientation: OrientationDTO? }
    private struct CelebrateData: Decodable { let haptic: String; let sound: String; let animation: String }
}

/// DTO for orientation lock requests. Mirrors `vauchi-core::Orientation`.
public enum OrientationDTO: String, Decodable {
    case portrait = "Portrait"
    case landscape = "Landscape"
}

/// Envelope returned by `PlatformAppEngine.navigateToJson` /
/// `navigateBackJson` (Phase 2b of
/// `2026-05-04-exchange-command-screen-presentation`). Carries the
/// rendered `ScreenModel` plus any `CommandDTO`s emitted by the
/// `WorkflowEngine`'s `screen_entered` / `screen_exited` lifecycle
/// hooks during the navigation.
public struct ScreenEnvelope: Decodable {
    public let screen: ScreenModel
    public let commands: [CommandDTO]
}

/// Envelope returned by `PlatformAppEngine.handleActionJson`. Carries
/// the engine's `ActionResult` plus any `CommandDTO`s emitted as a
/// side-effect of navigation during the action.
///
/// JSON shape: `{"action_result": <ActionResult>, "commands": [...]}`.
/// `coreJSONDecoder` uses `.convertFromSnakeCase` which rewrites
/// `action_result` → `actionResult` before the synthesized `Decodable`
/// lookup, so no explicit `CodingKeys` is needed (matches the
/// `FilePickFromUserData` pattern above).
public struct ActionResultEnvelope: Decodable {
    public let actionResult: ActionResult
    public let commands: [CommandDTO]
}

/// Decoded payload for `CommandDTO.filePickFromUser`. Hoisted
/// out of `CommandDTO` to keep the variant decoder readable.
///
/// No explicit `CodingKeys`: `coreJSONDecoder` uses
/// `.convertFromSnakeCase`, which rewrites the JSON key
/// `accepted_mime_types` to `acceptedMimeTypes` *before* the synthesized
/// `Decodable` lookup runs. Adding a `CodingKey` whose `rawValue` is the
/// pre-conversion snake_case spelling silently breaks decoding (the
/// lookup is against the post-conversion key). Mirrors the other
/// inline DTOs in this file (`BleAdvertisingData`, `BleCharacteristicData`,
/// etc.), which all rely on the implicit conversion.
private struct FilePickFromUserData: Decodable {
    let acceptedMimeTypes: [String]
    let purpose: FilePickPurpose
}

/// DTO for the file-picker `purpose` field on
/// `CommandDTO.filePickFromUser` (ADR-031, Phase 1 of
/// `2026-05-03-core-file-picker-command`).
///
/// Decodes the JSON shape emitted by `vauchi-core::exchange::command::
/// FilePickPurpose` — bare-string variants for the well-known purposes
/// and a struct variant for `Other { label_key: String }`.
public enum FilePickPurpose: Decodable, Equatable {
    case importContacts
    case importBackup
    case other(labelKey: String)
    case unknown

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self)
        {
            switch stringValue {
            case "ImportContacts": self = .importContacts
            case "ImportBackup": self = .importBackup
            default: self = .unknown
            }
            return
        }

        let container = try decoder.container(keyedBy: PurposeKey.self)
        if container.contains(.other) {
            let data = try container.decode(FilePickPurposeOtherData.self, forKey: .other)
            self = .other(labelKey: data.labelKey)
        } else {
            self = .unknown
        }
    }

    private enum PurposeKey: String, CodingKey {
        case other = "Other"
    }
}

/// Decoded payload for `FilePickPurpose.other`. Hoisted out of
/// `FilePickPurpose` to keep the variant decoder readable.
///
/// No explicit `CodingKeys` — same trap as `FilePickFromUserData` (see
/// the comment there): a rawValue of `"label_key"` would be looked up
/// *after* `coreJSONDecoder`'s `.convertFromSnakeCase` has already
/// rewritten the JSON key to `labelKey`, and the lookup would miss.
/// Latent until a `FilePickPurpose::Other` ever ships from core; fixing
/// it now keeps the file consistent.
private struct FilePickPurposeOtherData: Decodable {
    let labelKey: String
}
