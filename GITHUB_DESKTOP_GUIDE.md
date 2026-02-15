# GitHub Desktop Setup Guide (Easy Mode)

**Good news:** You already installed the right tool! GitHub Desktop is much easier than using command line.

## Step 1: Create the GitHub Repository (Online)

1. Go to https://github.com and sign in
2. Click the **"+"** icon in the top right corner
3. Click **"New repository"**
4. Fill in:
   - **Repository name:** `BazsGoldTrail`
   - **Description:** `A WoW addon that tracks gold across all your characters`
   - **Public** (not Private)
   - **Do NOT check** "Add a README file" (we already have one)
   - **Do NOT check** "Add .gitignore" (we already have one)
   - **Do NOT check** "Choose a license" (we already have one)
5. Click **"Create repository"**

**Stop here!** Don't do anything else on the website yet.

---

## Step 2: Prepare Your Files

1. Extract the `BazsGoldTrail-Repository.zip` file you downloaded from me
2. You should now have a folder called `BazsGoldTrail` with these files inside:
   - BazsGoldTrail.toc
   - BazsGoldTrail.lua
   - README.md
   - CHANGELOG.md
   - LICENSE
   - CONTRIBUTING.md
   - GITHUB_SETUP.md
   - TESTING.md
   - .gitignore
   - .pkgmeta

3. **Move this entire folder** to somewhere easy to find, like:
   - `C:\Users\YourName\Documents\GitHub\BazsGoldTrail`
   
   (Create the `GitHub` folder if it doesn't exist)

---

## Step 3: Open GitHub Desktop

1. Launch **GitHub Desktop**
2. If this is your first time:
   - Click **"Sign in to GitHub.com"**
   - Enter your GitHub username and password
   - Click **"Authorize desktop"**

---

## Step 4: Add Your Project to GitHub Desktop

1. In GitHub Desktop, click **"File"** → **"Add local repository"**
2. Click **"Choose..."** button
3. Navigate to your `BazsGoldTrail` folder (the one you extracted)
4. Click **"Select Folder"**

You'll see an error saying "This directory does not appear to be a Git repository."

**That's okay!** Click the **"create a repository"** link in the error message.

---

## Step 5: Initialize the Repository

You should now see a window titled "Create a repository"

1. **Name:** Should already say `BazsGoldTrail`
2. **Local path:** Should point to your folder
3. **Git ignore:** Leave as "None" (we already have .gitignore)
4. **License:** Leave as "None" (we already have LICENSE)
5. **Initialize this repository with a README:** **UNCHECK THIS** (we already have README.md)
6. Click **"Create repository"**

---

## Step 6: Review Your Changes

GitHub Desktop will now show you all the files:

1. On the left side, you should see a list of files with green "+" icons:
   - BazsGoldTrail.toc
   - BazsGoldTrail.lua
   - README.md
   - CHANGELOG.md
   - etc.

2. At the bottom left, there's a box that says "Summary (required)"
3. Type: `Initial release v1.0.0`
4. Click the blue **"Commit to main"** button

---

## Step 7: Link to GitHub

Now we need to upload this to GitHub.com:

1. Click the blue **"Publish repository"** button at the top
2. A window appears:
   - **Name:** BazsGoldTrail
   - **Description:** (optional, leave blank or add description)
   - **Keep this code private:** **UNCHECK THIS** (must be public for CurseForge)
3. Click **"Publish repository"**

**Done!** Your code is now on GitHub!

---

## Step 8: Verify It Worked

1. Go to GitHub.com in your web browser
2. Click your profile icon → "Your repositories"
3. You should see **BazsGoldTrail** in the list
4. Click on it
5. You should see all your files: README.md, CHANGELOG.md, etc.

**Success!** 🎉

---

## Step 9: Create Your First Release

1. On GitHub.com, in your BazsGoldTrail repository:
2. Click **"Releases"** on the right side (or go to the "Releases" tab)
3. Click **"Create a new release"**
4. Fill in:
   - **Choose a tag:** Type `v1.0.0` and click "Create new tag: v1.0.0 on publish"
   - **Release title:** `v1.0.0 - Initial Release`
   - **Description:** Copy and paste this:
   
   ```
   Initial release of Baz's Gold Trail - a complete rebuild of the MoneyTrail concept for The War Within and Midnight.

   ## Features
   - Session tracking (Gained/Spent/Profit)
   - Multi-character gold overview with class colors
   - Warband Bank integration
   - Favourites system
   - Mouseover tooltip display
   - In-game options panel
   
   Compatible with The War Within (11.0.7) and Midnight (12.0.1).
   ```

5. Under "Attach binaries", click **"choose your files"**
6. Select the **BazsGoldTrail-v1.0.0.zip** file (the addon-only package, not the repository one)
7. Click **"Publish release"**

**Your first release is live!**

---

## Making Future Updates

When you want to release a new version:

### In GitHub Desktop:

1. Make your changes to the .lua or .toc files
2. GitHub Desktop will show the changed files
3. Type a commit message like "Fixed tooltip positioning bug"
4. Click **"Commit to main"**
5. Click **"Push origin"** at the top

### On GitHub.com:

1. Update the version number in BazsGoldTrail.toc
2. Add your changes to CHANGELOG.md
3. Create a new release with the new version number (v1.0.1, v1.1.0, etc.)
4. Upload the new .zip file

---

## Common Questions

**Q: Where is my repository stored on my computer?**
A: In the folder you chose (probably `C:\Users\YourName\Documents\GitHub\BazsGoldTrail`)

**Q: How do I make changes?**
A: Edit the files normally (in Notepad, VS Code, etc.). GitHub Desktop will detect the changes automatically.

**Q: What does "Push origin" mean?**
A: It uploads your changes from your computer to GitHub.com

**Q: What if I made a mistake?**
A: GitHub Desktop has an "Undo" feature. You can also ask for help on the GitHub Desktop forums.

**Q: Do I need to know command line stuff?**
A: **Nope!** GitHub Desktop does it all for you with buttons and menus.

---

## Need More Help?

- [GitHub Desktop Documentation](https://docs.github.com/en/desktop)
- [GitHub Desktop Video Tutorial](https://www.youtube.com/results?search_query=github+desktop+tutorial)

---

You're doing great! Once you've published your repository, you're ready to submit to CurseForge whenever you want.
