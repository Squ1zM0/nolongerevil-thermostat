# Local-Only Mode Documentation

This directory contains comprehensive documentation for the NoLongerEvil Thermostat project, with a focus on the Local-Only Mode feature.

## Files

### [FAQ.md](FAQ.md)
Frequently Asked Questions and troubleshooting guide for Local-Only Mode.

**Contents:**
- General questions about local-only mode
- Installation questions and issues
- Display and UI configuration
- Sensor calibration and accuracy
- Power and battery management
- Error messages and their solutions
- Advanced troubleshooting steps
- Best practices for optimal performance

**Use when:** You encounter an issue or have questions about local-only mode functionality.

### [UI_MOCKUP.md](UI_MOCKUP.md)
User interface design specifications and mockups for Local-Only Mode display.

**Contents:**
- Main display layouts (minimal, compact, detailed)
- Font specifications and sizing
- Color schemes and theming
- Settings menu structure
- Alert states and visual indicators
- Startup sequence
- Power saving modes
- Display specifications

**Use when:** You're implementing UI changes, contributing to the project, or want to understand the display design.

### [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md) ⭐
**Final, production-ready UI design specification with clean, minimalist aesthetic.**

**Contents:**
- Complete design philosophy and principles
- Exact pixel specifications and measurements
- Typography guidelines (fonts, sizes, weights)
- Color palette with hex codes
- CSS-style reference implementation
- Design tokens for developers
- Accessibility standards (WCAG AAA compliant)
- Animation and transition specifications
- Power optimization details

**Use when:** Implementing the actual UI, need exact specifications, or reviewing design decisions.

### [ui-mockup.html](ui-mockup.html) 🎨
**Interactive HTML mockup demonstrating the final UI design.**

**Features:**
- Live, interactive display
- Adjustable temperature and humidity values
- Power mode switching (Standard, Low Power, Night Mode)
- Alert state demonstration
- Clean, minimalist design implementation

**Use when:** You want to see and interact with the UI design, demonstrate to stakeholders, or test design concepts.

**To view:** Open in a web browser or run a local server:
```bash
python3 -m http.server 8000 --directory docs
# Then open http://localhost:8000/ui-mockup.html
```

## UI Design Screenshots

### Standard Display
![Standard Mode](https://github.com/user-attachments/assets/04e8f518-894b-4c2d-9297-f715184f4ab5)

Clean, minimalist display showing:
- Large temperature (72°) - Primary focus
- Humidity percentage (41%) - Secondary info
- "Local Mode" status indicator

### Alert State
![Alert State](https://github.com/user-attachments/assets/a5b21a1a-40cf-4d0d-8a5f-69bf0097dcc7)

Temperature alert showing:
- Warning icon and message
- Large alert temperature (92°)
- Threshold information
- Dismiss button

## Design Highlights

### Clean & Minimalist
- **Large, readable typography** - 96px temperature visible from across the room
- **High contrast** - Pure white (#FFFFFF) on true black (#000000)
- **Generous spacing** - No visual clutter
- **Simple hierarchy** - Clear information priority

### Accessibility
- **WCAG AAA compliant** contrast ratios
- **Large touch targets** - Minimum 44×44px
- **Simple navigation** - Intuitive menu structure
- **Readable fonts** - System fonts for best rendering

### Power Efficient
- **True black background** - Optimized for OLED displays
- **Minimal animations** - Reduced power consumption
- **Configurable refresh rates** - 1-30 seconds
- **Multiple power modes** - Standard, Low Power, Night Mode

## Design Philosophy

The UI design follows these core principles:

1. **Information First** - Temperature and humidity are immediately visible
2. **Simplicity** - Only essential information shown
3. **Readability** - Large, clear typography
4. **Accessibility** - High contrast, large targets
5. **Efficiency** - Optimized for battery life
6. **Professionalism** - Clean, modern aesthetic

## Related Documentation

### Main Documentation Files

- **[../README.md](../README.md)** - Main project README with installation instructions
- **[../LOCAL_MODE.md](../LOCAL_MODE.md)** - Complete guide to Local-Only Mode feature
- **[../configs/README.md](../configs/README.md)** - Configuration files documentation

### Quick Links

**For Users:**
1. Start here: [Main README](../README.md)
2. Install local-only mode: [LOCAL_MODE.md](../LOCAL_MODE.md)
3. Troubleshooting: [FAQ.md](FAQ.md)

**For Developers:**
1. **UI specifications: [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md)** ⭐
2. Interactive mockup: [ui-mockup.html](ui-mockup.html)
3. Configuration format: [../configs/README.md](../configs/README.md)
4. Contributing: See main [README.md](../README.md)

**For Designers:**
1. **Final design spec: [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md)** ⭐
2. Interactive prototype: [ui-mockup.html](ui-mockup.html)
3. Visual mockups: [UI_MOCKUP.md](UI_MOCKUP.md)

## External Documentation

- **Official Docs:** [docs.nolongerevil.com](https://docs.nolongerevil.com)
- **Community Support:** [Discord](https://discord.gg/hackhouse)
- **GitHub Repository:** [github.com/codykociemba/NoLongerEvil-Thermostat](https://github.com/codykociemba/NoLongerEvil-Thermostat)

## Implementation Notes

### For Firmware Developers

When implementing the UI:

1. **Start with** [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md) for exact specifications
2. **Reference** the design tokens (colors, typography, spacing)
3. **Test with** [ui-mockup.html](ui-mockup.html) for visual comparison
4. **Follow** the CSS-style guidelines for consistent implementation

### Key Specifications

- **Display:** 480×480px circular, 400×400px safe zone
- **Temperature:** 96px Bold, #FFFFFF
- **Humidity:** 28px Light, #B0B0B0
- **Background:** #000000 (true black for OLED)
- **Spacing:** 40px top, 20px between elements
- **Refresh:** 5 seconds default (configurable 1-30s)

### Design Tokens Available

All design values are documented as design tokens in [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md):
- Colors (background, text, accents)
- Typography (sizes, weights, spacing)
- Layout (padding, margins, gaps)
- Animation (durations, easing)

## Contributing to Documentation

Contributions to improve documentation are welcome! When contributing:

### Documentation Standards

- Use clear, concise language
- Include examples where helpful
- Keep formatting consistent
- Update table of contents when adding sections
- Test all code examples
- Add screenshots for UI changes (when applicable)

### Markdown Style Guide

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers
- Use tables for structured data
- Include links to related documentation
- Keep line length reasonable (80-100 characters when possible)

### What to Document

**User-Facing:**
- Installation steps
- Configuration options
- Troubleshooting procedures
- Common use cases
- Best practices

**Developer-Facing:**
- Technical specifications
- API or configuration formats
- Design decisions and rationale
- Implementation notes
- Testing procedures

## Future Documentation

Planned documentation additions:

- **Development Guide** - How to build and modify firmware
- **API Reference** - Local API documentation (if/when implemented)
- **Configuration Reference** - Complete configuration file reference
- **Architecture Overview** - System architecture and components
- **Testing Guide** - How to test changes and contributions
- **Release Notes** - Version history and changes

## Getting Help

If you can't find what you're looking for:

1. Check the [FAQ](FAQ.md) first
2. Review [UI_DESIGN_FINAL.md](UI_DESIGN_FINAL.md) for design questions
3. Search the [GitHub issues](https://github.com/codykociemba/NoLongerEvil-Thermostat/issues)
4. Ask on [Discord](https://discord.gg/hackhouse)
5. Review [official documentation](https://docs.nolongerevil.com)

## License

Documentation is part of the NoLongerEvil Thermostat project and follows the same license. See [../LICENSE](../LICENSE) for details.

