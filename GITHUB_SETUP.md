# GitHub Repository Setup Guide

This guide will help you set up your GitHub repository for Baz's Gold Trail.

## Step 1: Create the Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right → "New repository"
3. Repository name: `BazsGoldTrail`
4. Description: `A WoW addon that tracks gold across all your characters with session tracking and Warband Bank support`
5. Choose "Public" (required for CurseForge integration)
6. **Do NOT** initialize with README, .gitignore, or license (we already have these)
7. Click "Create repository"

## Step 2: Initialize Local Repository

In your `BazsGoldTrail` folder, open a terminal/command prompt:

```bash
# Initialize git
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial release v1.0.0 - Complete rebuild for TWW/Midnight"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR-USERNAME/BazsGoldTrail.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Replace `YOUR-USERNAME` with your actual GitHub username!**

## Step 3: Update README Links

Edit `README.md` and replace:
- `[your-username]` with your GitHub username in the Support section

## Step 4: Create a Release

1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `v1.0.0 - Initial Release`
5. Description: Copy the "Initial Release" section from CHANGELOG.md
6. Upload `BazsGoldTrail.zip` as a release asset
7. Click "Publish release"

## Step 5: Add Topics

In your repository settings, add these topics for discoverability:
- `world-of-warcraft`
- `wow-addon`
- `warcraft`
- `the-war-within`
- `midnight`
- `lua`
- `gold-tracking`

## Step 6: Enable Discussions (Optional)

1. Go to Settings → General
2. Scroll to "Features"
3. Check "Discussions"

This allows users to ask questions and share tips!

## Step 7: Add Screenshots (Recommended)

Create a `screenshots` folder in your repository and add:
1. Screenshot of the mouseover tooltip
2. Screenshot of the options panel
3. Screenshot of the chat command output

Update README.md to include:
```markdown
## Screenshots

![Mouseover Tooltip](screenshots/tooltip.png)
*Hover over your gold to see wealth across all characters*

![Options Panel](screenshots/options.png)
*Manage favourites and customize display settings*
```

## Preparing for CurseForge

### Before Submitting

1. Create high-quality screenshots (ideally 1920x1080 or 2560x1440)
2. Consider recording a short video demo
3. Write a compelling project description
4. Test thoroughly on both The War Within and Midnight

### CurseForge Project Setup

1. Go to [CurseForge for Authors](https://authors.curseforge.com/)
2. Create a new project
3. Category: "WoW Addons"
4. Link your GitHub repository
5. Set up automatic releases (CurseForge can auto-package from Git tags)
6. Add the project description from README.md
7. Upload screenshots
8. Set game versions (11.0.7, 12.0.1)
9. Add tags: gold, economy, tracking, warband

### Automatic Packaging

CurseForge can automatically create releases when you push a Git tag:

```bash
# Create a tag
git tag -a v1.0.1 -m "Version 1.0.1"

# Push tag to GitHub
git push origin v1.0.1
```

The `.pkgmeta` file will tell CurseForge how to package your addon.

## Ongoing Maintenance

### For Each Update

1. Update version number in `BazsGoldTrail.toc`
2. Add changes to `CHANGELOG.md` under a new version heading
3. Commit changes
4. Create and push a new tag:
   ```bash
   git tag -a v1.1.0 -m "Version 1.1.0"
   git push origin v1.1.0
   ```
5. Create a GitHub release
6. CurseForge will automatically package and release (if configured)

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.x.x): Breaking changes or major rewrites
- **MINOR** (x.1.x): New features, backwards compatible
- **PATCH** (x.x.1): Bug fixes, backwards compatible

Examples:
- `1.0.1` - Fixed tooltip positioning bug
- `1.1.0` - Added guild bank tracking feature
- `2.0.0` - Complete rewrite for new WoW expansion

## Need Help?

- [GitHub Docs: Getting Started](https://docs.github.com/en/get-started)
- [CurseForge Upload Guide](https://support.curseforge.com/en/support/solutions/articles/9000197321-curseforge-upload-guide)
- [WoW Interface Version Numbers](https://wowpedia.fandom.com/wiki/TOC_format)

---

Good luck with your repository! 🚀
