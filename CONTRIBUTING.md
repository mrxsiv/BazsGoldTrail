# Contributing to Baz's Gold Trail

Thank you for your interest in contributing to Baz's Gold Trail! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Your WoW version and addon version
- Any error messages from `/console scriptErrors 1`

### Suggesting Features

Feature requests are welcome! Please:
- Check existing issues to avoid duplicates
- Clearly describe the feature and its benefits
- Explain how it would work from a user perspective
- Consider whether it fits the addon's core purpose (gold tracking)

### Pull Requests

We welcome pull requests for:
- Bug fixes
- New features (discuss in an issue first)
- Documentation improvements
- Code quality improvements

**Before submitting:**
1. Test your changes in-game (both The War Within and Midnight if possible)
2. Ensure your code follows the existing style
3. Update documentation if needed
4. Add a note to CHANGELOG.md under "Unreleased"

**Code Style:**
- Use 4-space indentation (not tabs)
- Comment complex logic
- Use descriptive variable names
- Follow existing naming conventions (e.g., `camelCase` for local variables)

## Development Setup

### Prerequisites
- World of Warcraft (Retail)
- A text editor (VS Code with Lua extension recommended)
- Git

### Local Development
1. Fork the repository
2. Clone your fork to your WoW AddOns directory:
   ```bash
   cd "World of Warcraft/_retail_/Interface/AddOns"
   git clone https://github.com/YOUR-USERNAME/BazsGoldTrail.git
   ```
3. Make your changes
4. Test in-game with `/reload`
5. Commit and push to your fork
6. Open a pull request

### Testing Checklist
- [ ] Tooltip displays correctly when hovering over gold
- [ ] Session tracking updates properly
- [ ] Favourites system works (star toggle, sorting)
- [ ] Options panel displays and functions correctly
- [ ] Slash commands work as expected
- [ ] Data persists between sessions (except session tracking)
- [ ] No Lua errors (enable with `/console scriptErrors 1`)
- [ ] Works with both combined bags and separate bag frames

## Code of Conduct

### Our Standards
- Be respectful and welcoming
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards other community members

### Unacceptable Behavior
- Harassment, trolling, or personal attacks
- Publishing others' private information
- Any conduct inappropriate in a professional setting

## Questions?

Feel free to open an issue with the "question" label if you need clarification on anything!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make Baz's Gold Trail better! 🎉
