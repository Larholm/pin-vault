/// The four cell colours (GRID-003, DATA-005).
///
/// Raw values match the Android identifiers so that a future shared backup
/// format can use them unchanged. Whether iOS renders the exact Android hues
/// is an open visual-parity decision (OPEN-012); see `androidReferenceRGB`.
public enum GridColor: String, CaseIterable, Codable, Sendable {
    case red = "RED"
    case blue = "BLUE"
    case green = "GREEN"
    case yellow = "YELLOW"

    /// Android's current cell colours (spec §5.1). Reference values only.
    public var androidReferenceRGB: (red: UInt8, green: UInt8, blue: UInt8) {
        switch self {
        case .red: return (255, 100, 100)    // #FF6464
        case .blue: return (110, 182, 255)   // #6EB6FF
        case .green: return (78, 205, 196)   // #4ECDC4
        case .yellow: return (253, 203, 110) // #FDCB6E
        }
    }

    /// Human-readable name for accessibility labels (UX-006).
    public var accessibilityName: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .green: return "Green"
        case .yellow: return "Yellow"
        }
    }
}
